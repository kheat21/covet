//
//  SearchView.swift
//  Covet
//

import AlertToast
import Kingfisher
import SwiftUI
import WebKit

// MARK: - URL Metadata Scraper

struct ScrapedURLProduct {
    var title: String?
    var vendor: String?
    var price: String?
    var imageURL: String?
    var sourceURL: String
}

class URLMetadataScraper {
    static func scrape(urlString: String) async -> ScrapedURLProduct? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let html = String(data: data, encoding: .utf8)
                         ?? String(data: data, encoding: .isoLatin1) else { return nil }

            let title  = ogMeta(html, "og:title")
            let image  = ogMeta(html, "og:image")
            let price  = ogMeta(html, "og:price:amount")
                      ?? ogMeta(html, "product:price:amount")
                      ?? ogMeta(html, "twitter:data1")
                      ?? extractPriceFromHTML(html)
            let vendor = ogMeta(html, "og:site_name")

            return ScrapedURLProduct(
                title: title,
                vendor: vendor,
                price: price,
                imageURL: image,
                sourceURL: urlString
            )
        } catch {
            return nil
        }
    }

    // Fallback: scan for JSON-LD or data attributes when og:price is absent
    static func extractPriceFromHTML(_ html: String) -> String? {
        let patterns = [
            "\"price\":\\s*\"([0-9]+(?:\\.[0-9]{1,2})?)\"",
            "\"price\":\\s*([0-9]+(?:\\.[0-9]{1,2})?)[^0-9]",
            "data-price=[\"']([0-9]+(?:\\.[0-9]{1,2})?)[\"']",
            "itemprop=[\"']price[\"'][^>]+content=[\"']([0-9]+(?:\\.[0-9]{1,2})?)[\"']",
            "content=[\"']([0-9]+(?:\\.[0-9]{1,2})?)[\"'][^>]+itemprop=[\"']price[\"']",
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                let val = String(html[range])
                if let d = Double(val), d > 0 { return val }
            }
        }
        return nil
    }

    static func ogMeta(_ html: String, _ property: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: property)
        let patterns = [
            "<meta[^>]+property=[\"']\(escaped)[\"'][^>]+content=[\"']([^\"'<]+)[\"']",
            "<meta[^>]+content=[\"']([^\"'<]+)[\"'][^>]+property=[\"']\(escaped)[\"']",
            "<meta[^>]+name=[\"']\(escaped)[\"'][^>]+content=[\"']([^\"'<]+)[\"']",
            "<meta[^>]+content=[\"']([^\"'<]+)[\"'][^>]+name=[\"']\(escaped)[\"']",
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                return String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}

// MARK: - JS-Rendered Scraper (for sites like Net-a-Porter that require JavaScript)

@MainActor
class JSWebScraper: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<ScrapedURLProduct?, Never>?
    private var timer: Timer?

    static func scrape(urlString: String) async -> ScrapedURLProduct? {
        await JSWebScraper().run(urlString: urlString)
    }

    private func run(urlString: String) async -> ScrapedURLProduct? {
        guard let url = URL(string: urlString) else { return nil }
        return await withCheckedContinuation { cont in
            self.continuation = cont
            let config = WKWebViewConfiguration()
            config.websiteDataStore = .nonPersistent()
            let wv = WKWebView(frame: .zero, configuration: config)
            wv.navigationDelegate = self
            self.webView = wv
            var req = URLRequest(url: url)
            req.setValue(
                "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
                forHTTPHeaderField: "User-Agent"
            )
            wv.load(req)
            // Timeout after 12s
            self.timer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { [weak self] _ in
                self?.finish(result: nil)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Wait 2s for JS to render prices
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.extractFromWebView(webView)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish(result: nil)
    }

    private func extractFromWebView(_ webView: WKWebView) {
        let js = """
        (function() {
            var price = null;
            var title = document.title || '';
            var image = '';
            var vendor = '';
            // og tags
            var metas = document.querySelectorAll('meta');
            metas.forEach(function(m) {
                var prop = m.getAttribute('property') || m.getAttribute('name') || '';
                var content = m.getAttribute('content') || '';
                if (prop === 'og:price:amount' || prop === 'product:price:amount') price = content;
                if (prop === 'og:title' && !title) title = content;
                if (prop === 'og:image') image = content;
                if (prop === 'og:site_name') vendor = content;
            });
            // JSON-LD
            if (!price) {
                var scripts = document.querySelectorAll('script[type="application/ld+json"]');
                scripts.forEach(function(s) {
                    try {
                        var obj = JSON.parse(s.textContent);
                        if (obj.offers && obj.offers.price) price = String(obj.offers.price);
                        else if (obj.price) price = String(obj.price);
                    } catch(e) {}
                });
            }
            return JSON.stringify({price: price, title: title, image: image, vendor: vendor});
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let jsonStr = result as? String,
                  let data = jsonStr.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                self?.finish(result: nil)
                return
            }
            let product = ScrapedURLProduct(
                title: obj["title"] as? String,
                vendor: obj["vendor"] as? String,
                price: obj["price"] as? String,
                imageURL: obj["image"] as? String,
                sourceURL: self?.webView?.url?.absoluteString ?? ""
            )
            self?.finish(result: product)
        }
    }

    private func finish(result: ScrapedURLProduct?) {
        timer?.invalidate()
        timer = nil
        webView?.navigationDelegate = nil
        webView = nil
        continuation?.resume(returning: result)
        continuation = nil
    }
}

// Decides which scraper to use based on the URL
func scrapeProduct(urlString: String) async -> ScrapedURLProduct? {
    let jsRequiredHosts = ["net-a-porter.com", "netaporter.com", "mrporter.com", "ssense.com", "mytheresa.com"]
    let host = URL(string: urlString)?.host?.lowercased() ?? ""
    if jsRequiredHosts.contains(where: { host.contains($0) }) {
        return await JSWebScraper.scrape(urlString: urlString)
    }
    return await URLMetadataScraper.scrape(urlString: urlString)
}

// MARK: - Price Filter

private enum PriceFilter: String, CaseIterable {
    case all        = "All"
    case under500   = "Under $500"
    case mid        = "$500–$1K"
    case upper      = "$1K–$5K"
    case luxury     = "Over $5K"

    func matches(_ price: Double?) -> Bool {
        guard let p = price else { return self == .all }
        switch self {
        case .all:      return true
        case .under500: return p < 500
        case .mid:      return p >= 500 && p < 1000
        case .upper:    return p >= 1000 && p < 5000
        case .luxury:   return p >= 5000
        }
    }
}

// MARK: - SearchView

struct SearchView: View {

    @State private var searchText: String = ""
    @State private var results: UnifiedSearchResult? = nil
    @State private var isSearching: Bool = false
    @State private var searchError: Bool = false
    @State private var navigateToPost: Post? = nil
    @State private var priceFilter: PriceFilter = .all

    // URL scraping state
    @State private var isScraping: Bool = false
    @State private var scrapedProduct: ScrapedURLProduct? = nil
    @State private var scrapeError: Bool = false
    @State private var scrapeErrorMessage: String = ""

    private var isURL: Bool {
        searchText.hasPrefix("http://") || searchText.hasPrefix("https://")
    }

    private var filteredPosts: [Post] {
        guard let r = results else { return [] }
        if priceFilter == .all { return r.posts }
        return r.posts.filter { post in
            guard let product = getProductForPost(post: post) else { return false }
            return priceFilter.matches(product.price)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 8) {
                    TextField("Search people, products, brands…", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .submitLabel(isURL ? .go : .search)
                        .onSubmit { handleSubmit() }

                    if isURL {
                        Button(action: scrapeURL) {
                            Text("Fetch")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.covetGreen())
                                .cornerRadius(8)
                        }
                    } else {
                        Button("Search") {
                            if !isSearching { handleSubmit() }
                        }
                        .disabled(searchText.isEmpty || isSearching)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Content
                if isURL {
                    urlScrapeContent
                } else if let r = results {
                    searchResultsContent(results: r)
                } else if !isSearching {
                    emptySearchPrompt
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toast(isPresenting: $isSearching) {
                AlertToast(displayMode: .alert, type: .loading)
            }
            .toast(isPresenting: $isScraping) {
                AlertToast(displayMode: .alert, type: .loading, title: "Fetching details…")
            }
            .toast(isPresenting: $searchError) {
                AlertToast(displayMode: .hud, type: .error(.red), title: "Search failed", subTitle: "Try again")
            }
            .toast(isPresenting: $scrapeError) {
                AlertToast(displayMode: .hud, type: .error(.red), title: "Could not fetch", subTitle: scrapeErrorMessage)
            }
            .sheet(item: $navigateToPost, onDismiss: nil) { post in
                PostView(post: post)
            }
        }
    }

    // MARK: - URL Scrape Content

    @ViewBuilder
    private var urlScrapeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Product Details")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                if let product = scrapedProduct {
                    scrapedProductCard(product: product)
                        .padding(.horizontal, 16)
                } else if !isScraping {
                    Text("Paste a product URL above and tap Fetch to look up its price and details.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private func scrapedProductCard(product: ScrapedURLProduct) -> some View {
        HStack(alignment: .top, spacing: 14) {
            if let imageStr = product.imageURL, let imageURL = URL(string: imageStr) {
                KFImage(imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 130)
                    .clipped()
                    .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 130)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                if let vendor = product.vendor, !vendor.isEmpty {
                    Text(vendor.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                Text(product.title ?? "Unknown Product")
                    .font(.subheadline)
                    .lineLimit(3)

                if let priceStr = product.price, !priceStr.isEmpty {
                    let formatted = formatScrapedPrice(priceStr)
                    Text(formatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.covetGreen())
                } else {
                    Text("Price not available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let host = URL(string: product.sourceURL)?.host {
                    Text(host.replacingOccurrences(of: "www.", with: ""))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Search Results Content

    @ViewBuilder
    private func searchResultsContent(results: UnifiedSearchResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Price filter chips
                if !results.posts.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PriceFilter.allCases, id: \.self) { filter in
                                Button(action: { priceFilter = filter }) {
                                    Text(filter.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(priceFilter == filter ? Color.covetGreen() : Color(.systemGray6))
                                        .foregroundColor(priceFilter == filter ? .white : .primary)
                                        .cornerRadius(20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 10)
                }

                // Users section
                if !results.users.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("People")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 6)
                            .padding(.top, 4)

                        ForEach(results.users.prefix(5)) { user in
                            UserListItem(user: user)
                        }
                    }
                    .padding(.bottom, 16)
                }

                // Posts/products section
                if filteredPosts.isEmpty && results.posts.isEmpty && results.users.isEmpty {
                    noResultsView
                } else if filteredPosts.isEmpty && results.users.isEmpty {
                    Text("No products found for \"\(searchText)\".")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(32)
                        .frame(maxWidth: .infinity)
                } else if !filteredPosts.isEmpty {
                    Text("Products")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(filteredPosts, id: \.id) { post in
                            if let product = getProductForPost(post: post) {
                                SearchResultCard(product: product)
                                    .onTapGesture { navigateToPost = post }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Empty / Prompt States

    private var emptySearchPrompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            Text("Search for people or products")
                .font(.headline)
            Text("Try a name, brand, or paste a product URL to look up its price.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }

    private var noResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            Text("No results for \"\(searchText)\"")
                .font(.headline)
            Text("Try a different search or paste a product URL.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }

    // MARK: - Actions

    private func handleSubmit() {
        guard !searchText.isEmpty, !isSearching else { return }
        KeyboardHelper.hideKeyboard()
        priceFilter = .all
        results = nil
        isSearching = true
        let query = searchText
        Task.detached {
            let r = try? await API.search(query: query, page: 1)
            await updateSearchResults(r)
        }
    }

    @MainActor
    private func updateSearchResults(_ r: UnifiedSearchResult?) {
        results = r
        isSearching = false
        searchError = r == nil
    }

    private func scrapeURL() {
        guard isURL, !isScraping else { return }
        KeyboardHelper.hideKeyboard()
        scrapedProduct = nil
        isScraping = true
        scrapeError = false
        let urlString = searchText
        Task.detached {
            let product = await scrapeProduct(urlString: urlString)
            await updateScrapeResult(product)
        }
    }

    @MainActor
    private func updateScrapeResult(_ product: ScrapedURLProduct?) {
        isScraping = false
        if let p = product {
            scrapedProduct = p
        } else {
            scrapeErrorMessage = "Could not fetch details for this URL."
            scrapeError = true
        }
    }

    private func formatScrapedPrice(_ raw: String) -> String {
        // If it's a plain number like "99.95", format as currency
        if let num = Double(raw) {
            return String(format: "$%.0f", num)
        }
        // Otherwise return as-is (already has $ or currency symbol)
        return raw.hasPrefix("$") ? raw : "$\(raw)"
    }
}

// MARK: - Search Result Card

private struct SearchResultCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Color.clear
                .aspectRatio(0.8, contentMode: .fit)
                .overlay(
                    KFImage(URL(string: product.image_url))
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .cornerRadius(6)
                .clipped()

            let parsed = parseProductDisplay(name: product.name, vendor: product.vendor)
            VStack(alignment: .leading, spacing: 2) {
                if let brand = parsed.brand, !brand.isEmpty {
                    Text(brand.uppercased())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
                Text(parsed.cleanName)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                if let priceStr = formatPrice(product.price) {
                    Text(priceStr)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 6)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}
