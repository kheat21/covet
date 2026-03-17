//
//  GiftFlowView.swift
//  Covet
//

import SwiftUI

// MARK: - Models

enum GiftRecipientType: Equatable {
    case myself
    case anotherUser
    case external
}

struct GiftContext {
    var recipientType: GiftRecipientType
    var selectedUser: CovetUser? = nil
    var recipientName: String = ""
    var relationship: String = ""
    var occasion: String = ""
    var interests: [String] = []
    var additionalInfo: String = ""
    var budget: String = ""

    var displayName: String {
        if let u = selectedUser { return "@\(u.username)" }
        if !recipientName.isEmpty { return recipientName }
        return "yourself"
    }
}

struct GiftIdea: Identifiable, Decodable {
    let id: String
    var name: String
    var reason: String
    var priceRange: String
    var searchQuery: String
    var shopUrl: String

    enum CodingKeys: String, CodingKey {
        case name, reason
        case priceRange = "price_range"
        case searchQuery = "search_query"
        case shopUrl = "shop_url"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        name = try c.decode(String.self, forKey: .name)
        reason = try c.decode(String.self, forKey: .reason)
        priceRange = try c.decode(String.self, forKey: .priceRange)
        searchQuery = try c.decode(String.self, forKey: .searchQuery)
        shopUrl = (try? c.decode(String.self, forKey: .shopUrl)) ?? ""
    }
}

struct GiftAIResult {
    var ideas: [GiftIdea]
    var styleSummary: String?
}

// MARK: - AI Service

enum GiftAIService {
    // Add your Anthropic API key here
    // TODO: move to a Lambda proxy — never hardcode API keys in the app binary
    static let anthropicApiKey = ""

    static func generateIdeas(context: GiftContext, userProducts: [Product]) async throws -> GiftAIResult {
        guard !anthropicApiKey.isEmpty else {
            throw NSError(domain: "GiftAI", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Anthropic API key not configured"])
        }
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(anthropicApiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1500,
            "messages": [["role": "user", "content": buildPrompt(context: context, userProducts: userProducts)]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]],
           let text = content.first?["text"] as? String {
            return parseResult(from: text, context: context)
        }
        throw NSError(domain: "GiftAI", code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Could not parse AI response"])
    }

    private static func buildPrompt(context: GiftContext, userProducts: [Product]) -> String {
        var lines: [String] = ["You are a thoughtful gift advisor. Suggest 6–8 specific, creative gift ideas.\n"]

        switch context.recipientType {
        case .myself:
            lines.append("Recipient: the user themselves")
        case .anotherUser:
            if let u = context.selectedUser {
                lines.append("Recipient: @\(u.username)\(u.name.map { " (\($0))" } ?? "")")
            }
        case .external:
            if !context.recipientName.isEmpty { lines.append("Recipient: \(context.recipientName)") }
        }
        if !context.relationship.isEmpty { lines.append("Relationship: \(context.relationship)") }
        if !context.occasion.isEmpty     { lines.append("Occasion: \(context.occasion)") }
        if !context.interests.isEmpty    { lines.append("Interests: \(context.interests.joined(separator: ", "))") }
        if !context.additionalInfo.isEmpty { lines.append("Additional context: \(context.additionalInfo)") }
        if !context.budget.isEmpty       { lines.append("Budget: \(context.budget)") }
        if !userProducts.isEmpty {
            let names = userProducts.prefix(10).map { $0.name }.joined(separator: ", ")
            lines.append("Items they've saved on their shopping wishlist: \(names)")
        }
        let budgetInstruction = context.budget.isEmpty
            ? ""
            : "\nCRITICAL: Every single suggestion MUST be priced within \(context.budget). Do not suggest anything outside this budget range. The price_range field must fall within \(context.budget)."
        lines.append(budgetInstruction)
        let includeSummary = context.recipientType == .anotherUser
        lines.append("""

Return ONLY a valid JSON object, no markdown, no explanation:
{
  \(includeSummary ? "\"style_summary\": \"2-3 sentence paragraph about their personal style based on their saved items — mention specific brands, aesthetics, price point. e.g. They love clothes ranging from everyday fashion to cozy Eberjey pajamas. Brands they gravitate toward vary from Missoni to Jimmy Choo — veering on the side of luxury. Here are suggestions that keep the same chic style.\"," : "")
  "ideas": [
    {"name":"Specific Product Name","reason":"One-line why this fits them","price_range":"$X–$Y","search_query":"specific search term","shop_url":"https://www.amazon.com/s?k=specific+search+term"}
  ]
}

Make names specific (e.g. "Lululemon Align Leggings" not "leggings"). Focus on emotional resonance. Use real Amazon search URLs.
""")
        return lines.joined(separator: "\n")
    }

    private static func parseResult(from text: String, context: GiftContext) -> GiftAIResult {
        // Try to parse as object with ideas array
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}"), start <= end {
            let jsonStr = String(text[start...end])
            if let data = jsonStr.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let summary = obj["style_summary"] as? String
                var ideas: [GiftIdea] = []
                if let ideasArr = obj["ideas"] {
                    if let ideasData = try? JSONSerialization.data(withJSONObject: ideasArr) {
                        ideas = (try? JSONDecoder().decode([GiftIdea].self, from: ideasData)) ?? []
                    }
                }
                if !ideas.isEmpty { return GiftAIResult(ideas: ideas, styleSummary: summary) }
            }
        }
        // Fallback: try plain array
        if let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]"), start <= end {
            let jsonStr = String(text[start...end])
            let ideas = (try? JSONDecoder().decode([GiftIdea].self, from: Data(jsonStr.utf8))) ?? []
            return GiftAIResult(ideas: ideas, styleSummary: nil)
        }
        return GiftAIResult(ideas: [], styleSummary: nil)
    }
}

// MARK: - Step 1: Recipient Setup

struct GiftRecipientSetupView: View {
    let recipientType: GiftRecipientType
    @EnvironmentObject var auth: AuthService

    @State private var recipientName = ""
    @State private var selectedRelationship = ""
    @State private var selectedOccasion = ""
    @State private var userSearchQuery = ""
    @State private var selectedUser: CovetUser? = nil
    @State private var apiSearchResults: [CovetUser] = []
    @State private var isSearchingAPI = false

    @State private var navigateNext = false
    @State private var context = GiftContext(recipientType: .myself)

    private let occasions = ["Birthday", "Holiday", "Anniversary", "Just Because", "Thank You", "New Baby", "Wedding", "Graduation"]
    private let relationships = ["Mom", "Partner", "Best Friend", "Sister", "Brother", "Dad", "Coworker", "Friend"]

    private var networkUsers: [CovetUser] {
        let follows = auth.currentCovetUser?.follows?.map { $0.user } ?? []
        let followers = auth.currentCovetUser?.followers?.map { $0.user } ?? []
        var seen = Set<Int>()
        return (follows + followers).filter { seen.insert($0.id).inserted }
    }

    private var displayedUsers: [CovetUser] {
        let query = userSearchQuery.lowercased()
        let networkFiltered = query.isEmpty ? networkUsers : networkUsers.filter {
            $0.username.lowercased().contains(query) || ($0.name ?? "").lowercased().contains(query)
        }
        if query.isEmpty { return networkFiltered }
        let networkIds = Set(networkFiltered.map { $0.id })
        let extra = apiSearchResults.filter { !networkIds.contains($0.id) }
        return networkFiltered + extra
    }

    private var canContinue: Bool { true }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if recipientType == .anotherUser {
                    userSearchSection
                }
                if recipientType == .external {
                    externalSection
                }
                occasionSection
                continueButton
            }
            .padding(20)
        }
        .navigationTitle(recipientType == .myself ? "For Yourself" : "Who is it for?")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(destination: GiftInterestsView(context: context), isActive: $navigateNext) {
                EmptyView()
            }
        )
        .onChange(of: userSearchQuery) { query in
            guard query.count >= 2 else {
                apiSearchResults = []
                return
            }
            Task { await searchAPI(query: query) }
        }
    }

    private var userSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who are you gifting?")
                .font(.headline)

            if let user = selectedUser {
                HStack(spacing: 12) {
                    makeCovetC(size: 40, user: user)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let name = user.name, !name.isEmpty {
                            Text(name).font(.caption).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        selectedUser = nil
                        userSearchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(UIColor.systemGray3))
                    }
                }
                .padding(12)
                .background(Color.covetGreen().opacity(0.08))
                .cornerRadius(10)
            } else {
                TextField("Search by username...", text: $userSearchQuery)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                if !displayedUsers.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(displayedUsers.prefix(6)) { user in
                            Button {
                                selectedUser = user
                                userSearchQuery = ""
                                apiSearchResults = []
                            } label: {
                                HStack(spacing: 10) {
                                    makeCovetC(size: 36, user: user)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("@\(user.username)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        if let name = user.name, !name.isEmpty {
                                            Text(name).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            Divider().padding(.leading, 58)
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                }
            }
        }
    }

    private var externalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Their name (optional)")
                    .font(.headline)
                TextField("e.g. Sarah", text: $recipientName)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Relationship")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(relationships, id: \.self) { rel in
                        selectionChip(rel, selected: selectedRelationship == rel) {
                            selectedRelationship = rel
                        }
                    }
                }
            }
        }
    }

    private var occasionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Occasion")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(occasions, id: \.self) { occ in
                    selectionChip(occ, selected: selectedOccasion == occ) {
                        selectedOccasion = selectedOccasion == occ ? "" : occ
                    }
                }
            }
        }
    }

    private var continueButton: some View {
        Button {
            var ctx = GiftContext(recipientType: recipientType)
            ctx.selectedUser = selectedUser
            ctx.recipientName = recipientName
            ctx.relationship = selectedRelationship
            ctx.occasion = selectedOccasion
            context = ctx
            navigateNext = true
        } label: {
            Text("Continue")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(canContinue ? Color.covetGreen() : Color(UIColor.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!canContinue)
    }

    @MainActor
    private func searchAPI(query: String) async {
        isSearchingAPI = true
        if let result = try? await API.search(query: query, page: 1, pageSize: 10) {
            apiSearchResults = result.users
        }
        isSearchingAPI = false
    }
}

// MARK: - Step 2: Interests

struct GiftInterestsView: View {
    var context: GiftContext
    @EnvironmentObject var auth: AuthService

    @State private var selectedInterests: Set<String> = []
    @State private var customInput = ""
    @State private var additionalInfo = ""
    @State private var recipientProducts: [Product] = []
    @State private var navigateNext = false
    @State private var nextContext = GiftContext(recipientType: .myself)

    private let suggestedInterestsByRelationship: [String: [String]] = [
        "Mom":         ["gardening", "cooking", "wellness", "reading", "home decor", "yoga"],
        "Partner":     ["travel", "wine", "fitness", "music", "cooking", "art"],
        "Best Friend": ["skincare", "coffee", "fashion", "hiking", "photography", "candles"],
        "Sister":      ["fashion", "beauty", "music", "travel", "jewelry", "books"],
        "Brother":     ["gaming", "sports", "tech", "music", "outdoors", "food"],
        "Dad":         ["golf", "grilling", "tech", "sports", "reading", "coffee"],
        "Coworker":    ["coffee", "desk accessories", "books", "plants", "wellness"],
        "Friend":      ["coffee", "home decor", "skincare", "food", "books", "games"],
    ]

    private let generalSuggestions = ["fashion", "beauty", "home decor", "travel", "fitness", "reading",
                                       "coffee", "cooking", "art", "music", "outdoors", "tech", "wellness",
                                       "jewelry", "skincare", "candles", "yoga", "photography"]

    private var suggestions: [String] {
        let rel = context.relationship
        let base = suggestedInterestsByRelationship[rel] ?? generalSuggestions
        // Derive from products if available
        var extra: [String] = []
        if !recipientProducts.isEmpty {
            let categories = Set(recipientProducts.compactMap { guessCategory(for: $0) }.filter { $0 != "All" })
            extra = categories.map { $0.lowercased() }
        }
        var seen = Set<String>()
        return (extra + base).filter { seen.insert($0).inserted }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Heading
                VStack(alignment: .leading, spacing: 6) {
                    Text(context.recipientType == .myself ? "What are you into?" : "What are they into?")
                        .font(.headline)
                    Text("Tap to add or type your own")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Tag cloud
                let allTags = suggestions + Array(selectedInterests.filter { !suggestions.contains($0) })
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 85))], spacing: 10) {
                    ForEach(allTags, id: \.self) { tag in
                        interestChip(tag)
                    }
                }

                // Custom interest input
                HStack(spacing: 8) {
                    TextField("Add your own...", text: $customInput)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .onSubmit { addCustomInterest() }
                    Button(action: addCustomInterest) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.covetGreen())
                    }
                }

                // Free text
                VStack(alignment: .leading, spacing: 8) {
                    Text(context.recipientType == .myself ? "Anything specific you're looking for?" : "Anything else we should know?")
                        .font(.headline)
                    Text(context.recipientType == .myself ? "e.g. \"Looking for something cozy for winter\" or \"Want to upgrade my home office\"" : "e.g. \"She just moved to a new apartment\" or \"He's really into F1 this year\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $additionalInfo)
                        .frame(minHeight: 80)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }

                continueButton
            }
            .padding(20)
        }
        .navigationTitle(context.recipientType == .myself ? "Your Interests" : "Their Interests")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(destination: GiftBudgetView(context: nextContext), isActive: $navigateNext) {
                EmptyView()
            }
        )
        .task { await loadRecipientProducts() }
    }

    private func interestChip(_ tag: String) -> some View {
        let selected = selectedInterests.contains(tag)
        return Button {
            if selected { selectedInterests.remove(tag) } else { selectedInterests.insert(tag) }
        } label: {
            HStack(spacing: 4) {
                if selected {
                    Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                }
                Text(tag)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selected ? Color.covetGreen() : Color(UIColor.systemGray6))
            .foregroundColor(selected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var continueButton: some View {
        Button {
            var ctx = context
            ctx.interests = Array(selectedInterests)
            ctx.additionalInfo = additionalInfo
            nextContext = ctx
            navigateNext = true
        } label: {
            Text("Continue")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.covetGreen())
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    private func addCustomInterest() {
        let tag = customInput.trimmingCharacters(in: .whitespaces).lowercased()
        if !tag.isEmpty { selectedInterests.insert(tag) }
        customInput = ""
    }

    private func loadRecipientProducts() async {
        switch context.recipientType {
        case .myself:
            if let posts = auth.currentCovetUser?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .anotherUser:
            if let user = context.selectedUser,
               let resp = try? await API.getUser(user_id: user.id),
               let posts = resp.user?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .external:
            break
        }
    }
}

// MARK: - Step 3: Budget

struct GiftBudgetView: View {
    var context: GiftContext
    @EnvironmentObject var auth: AuthService

    @State private var selectedBudget = ""
    @State private var navigateToResults = false
    @State private var finalContext = GiftContext(recipientType: .myself)
    @State private var recipientProducts: [Product] = []

    private let budgets = ["Under $25", "$25–$50", "$50–$100", "$100–$200", "$200–$500", "$500+"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's your price range?")
                            .font(.headline)
                        Text(context.recipientType == .myself ? "We'll find things worth treating yourself to — skip to let AI decide" : "We'll tailor ideas to fit — skip to let AI decide")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(budgets, id: \.self) { budget in
                            Button {
                                selectedBudget = budget
                            } label: {
                                Text(budget)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(selectedBudget == budget ? Color.covetGreen() : Color(UIColor.systemGray6))
                                    .foregroundColor(selectedBudget == budget ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }

            VStack(spacing: 0) {
                Divider()
                Button {
                    var ctx = context
                    ctx.budget = selectedBudget
                    finalContext = ctx
                    navigateToResults = true
                } label: {
                    Text("Find Gift Ideas")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.covetGreen())
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle("Budget")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: GiftResultsView(context: finalContext),
                isActive: $navigateToResults
            ) { EmptyView() }
        )
        .task { await loadProducts() }
    }

    private func loadProducts() async {
        switch context.recipientType {
        case .myself:
            if let posts = auth.currentCovetUser?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .anotherUser:
            if let user = context.selectedUser,
               let resp = try? await API.getUser(user_id: user.id),
               let posts = resp.user?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .external:
            break
        }
    }
}

// MARK: - Step 4 & 5: Results (loading + display)

struct GiftResultsView: View {
    let context: GiftContext
    @EnvironmentObject var auth: AuthService

    @State private var ideas: [GiftIdea] = []
    @State private var styleSummary: String? = nil
    @State private var isLoading = true
    @State private var error: String? = nil
    @State private var loadingPhrase = ""
    @State private var recipientProducts: [Product] = []

    private let loadingPhrases = [
        "Thinking about what they'd love…",
        "Finding things that match their vibe…",
        "Checking what's popular right now…",
        "Putting together something special…",
        "Almost there…",
    ]

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let err = error {
                errorView(err)
            } else {
                resultsView
            }
        }
        .navigationTitle("Gift Ideas")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadEverything() }
    }

    private var loadingView: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.covetGreen().opacity(0.15 - Double(i) * 0.04))
                        .frame(width: CGFloat(80 + i * 28), height: CGFloat(80 + i * 28))
                }
                Image(systemName: "gift")
                    .font(.system(size: 34))
                    .foregroundColor(.covetGreen())
            }
            Text(loadingPhrase)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.5), value: loadingPhrase)
            Spacer()
        }
    }

    private func errorView(_ msg: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(msg)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                isLoading = true
                error = nil
                Task { await generateIdeas() }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.covetGreen())
            .foregroundColor(.white)
            .cornerRadius(10)
            Spacer()
        }
    }

    private var resultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Style summary card for "For Another User"
                if let summary = styleSummary, context.recipientType == .anotherUser {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.covetGreen())
                            Text("Style Profile")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.covetGreen())
                        }
                        Text(summary)
                            .font(.system(size: 14, weight: .regular, design: .serif))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.covetGreen().opacity(0.06))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                } else {
                    Text("\(ideas.count) ideas for \(context.displayName)\(context.occasion.isEmpty ? "" : " for \(context.occasion)")\(context.budget.isEmpty ? "" : ", \(context.budget)")")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                // "Go for a different direction" button
                NavigationLink(destination: GiftNewDirectionView(context: context, recipientProducts: recipientProducts)) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 14))
                        Text("Go for a different direction")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(ideas) { idea in
                        GiftIdeaCard(idea: idea)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private func loadEverything() async {
        // Start rotating phrases
        Task {
            for phrase in loadingPhrases {
                guard isLoading else { break }
                await MainActor.run { loadingPhrase = phrase }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        // Load recipient products
        switch context.recipientType {
        case .myself:
            if let posts = auth.currentCovetUser?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .anotherUser:
            if let user = context.selectedUser,
               let resp = try? await API.getUser(user_id: user.id),
               let posts = resp.user?.posts {
                recipientProducts = posts.compactMap { getProductForPost(post: $0) }
            }
        case .external:
            break
        }
        await generateIdeas()
    }

    private func generateIdeas() async {
        do {
            let result = try await GiftAIService.generateIdeas(context: context, userProducts: recipientProducts)
            await MainActor.run {
                ideas = result.ideas
                styleSummary = result.styleSummary
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
}

private struct GiftIdeaCard: View {
    let idea: GiftIdea
    @Environment(\.openURL) private var openURL

    private var resolvedUrl: URL? {
        if !idea.shopUrl.isEmpty, let u = URL(string: idea.shopUrl) { return u }
        let encoded = idea.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.amazon.com/s?k=\(encoded)")
    }

    private var iconName: String {
        let q = idea.searchQuery.lowercased() + " " + idea.name.lowercased()
        if q.contains("shoe") || q.contains("boot") || q.contains("sneaker") || q.contains("heel") { return "shoeprints.fill" }
        if q.contains("bag") || q.contains("purse") || q.contains("wallet") { return "bag.fill" }
        if q.contains("book") || q.contains("journal") { return "book.fill" }
        if q.contains("candle") || q.contains("fragrance") || q.contains("perfume") { return "flame.fill" }
        if q.contains("coffee") || q.contains("tea") || q.contains("mug") { return "cup.and.saucer.fill" }
        if q.contains("tech") || q.contains("phone") || q.contains("headphone") || q.contains("earbuds") { return "headphones" }
        if q.contains("jewelry") || q.contains("necklace") || q.contains("bracelet") || q.contains("ring") { return "sparkles" }
        if q.contains("yoga") || q.contains("fitness") || q.contains("workout") { return "figure.run" }
        if q.contains("skincare") || q.contains("beauty") || q.contains("makeup") { return "sparkle" }
        if q.contains("travel") || q.contains("luggage") || q.contains("suitcase") { return "airplane" }
        if q.contains("home") || q.contains("decor") || q.contains("pillow") || q.contains("candle") { return "house.fill" }
        return "gift"
    }

    var body: some View {
        Button {
            if let url = resolvedUrl { openURL(url) }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.covetGreen().opacity(0.08))
                        .aspectRatio(1.0, contentMode: .fit)
                    VStack(spacing: 6) {
                        Image(systemName: iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.covetGreen().opacity(0.7))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.covetGreen().opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(idea.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    Text(idea.reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    Text(idea.priceRange)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.covetGreen())
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 10)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - New Direction View

struct GiftNewDirectionView: View {
    let context: GiftContext
    let recipientProducts: [Product]

    @State private var direction = ""
    @State private var navigateToResults = false
    @State private var newContext = GiftContext(recipientType: .myself)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Describe the new direction")
                            .font(.headline)
                        Text("Be as specific or open as you like — vibe, theme, category, budget, anything.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    TextEditor(text: $direction)
                        .frame(minHeight: 140)
                        .padding(12)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Examples")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text("• \"Something more practical and wellness-focused\"")
                        Text("• \"Go more luxury — think timeless jewelry or cashmere\"")
                        Text("• \"She loves cooking, find something for her kitchen\"")
                        Text("• \"Experiences over things — spa, travel, or activities\"")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(20)
            }

            VStack(spacing: 0) {
                Divider()
                Button {
                    var ctx = context
                    ctx.additionalInfo = direction
                    ctx.interests = []
                    newContext = ctx
                    navigateToResults = true
                } label: {
                    Text("Find Gifts in This Direction")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(direction.trimmingCharacters(in: .whitespaces).isEmpty ? Color(UIColor.systemGray4) : Color.covetGreen())
                        .foregroundColor(.white)
                }
                .disabled(direction.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("New Direction")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(destination: GiftResultsView(context: newContext), isActive: $navigateToResults) {
                EmptyView()
            }
        )
    }
}

// MARK: - Helpers

private func selectionChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selected ? Color.covetGreen() : Color(UIColor.systemGray6))
            .foregroundColor(selected ? .white : .primary)
            .cornerRadius(20)
    }
    .buttonStyle(PlainButtonStyle())
}

