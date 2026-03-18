//
//  FAQView.swift
//  Covet
//

import SwiftUI

struct FAQView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header — deck style
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        Text("covet")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)
                        Text(".")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color.covetGreen())
                    }
                    Text("Take the \(Text("if").italic().foregroundColor(Color.covetGreen())) out of gift giving.")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 32)

                // How It Works section
                FAQSectionHeader(title: "How It Works")

                FAQItem(
                    question: "What is covet.?",
                    answer: "covet. is a wishlist, social shopping, and gifting app. Save items you love from any website, follow friends to see what they're coveting, and use our AI gifting tool to find the perfect gift for anyone — based on their covet list."
                )
                FAQItem(
                    question: "How do I add items to my covet list?",
                    answer: "Use the covet. Safari Extension to save any product while browsing the web.\n\n1. Open Safari and go to any product page.\n2. Tap the Share button (□↑) in Safari.\n3. Scroll and tap \"covet.\" in the share sheet.\n4. The item will be added to your covet list automatically."
                )
                FAQItem(
                    question: "Who can see my covet list?",
                    answer: "Anyone who follows you can see your covet list — that's the magic. Friends and family can browse what you actually want, making gifting effortless. You control who follows you in Privacy settings."
                )

                // Understanding the Buttons section
                FAQSectionHeader(title: "Understanding the Buttons")

                FAQItem(
                    question: "What does the ✓ checkbox mean? (Coveted)",
                    answer: "The checkbox marks an item as \"coveted\" — meaning you've actually purchased or received it. Only you can see and toggle your own checkbox.\n\nWhen browsing your feed, items with a ✓ checkmark in the top corner belong to posts the owner has marked as coveted. It's a subtle signal of items that made it off the wishlist and into real life."
                )
                FAQItem(
                    question: "What is Recovet (the C. button on a post)?",
                    answer: "Recoveting lets you save someone else's item to your own covet list. Think of it like a repost — you saw something on a friend's list and want it too.\n\nTap the C. button on any post to recovet it. It will appear on your covet list and link back to the original product."
                )
                FAQItem(
                    question: "What does the ♡ heart button do?",
                    answer: "The heart likes a post — similar to liking on Instagram. It lets the poster know you're into their taste. Likes are visible to the person who posted the item."
                )
                FAQItem(
                    question: "What does the ↑ share button do?",
                    answer: "The share button opens the iOS share sheet so you can send a product link to anyone — via iMessage, email, or any other app. Great for forwarding something you spotted to a friend."
                )
                FAQItem(
                    question: "What does the 🚩 flag button do?",
                    answer: "The flag reports a post that violates community guidelines. Use it if you see spam, inappropriate content, or anything that shouldn't be on covet."
                )
                // Gifting section
                FAQSectionHeader(title: "AI Gifting")

                FAQItem(
                    question: "How does AI gift recommendations work?",
                    answer: "Our gifting tool uses AI to suggest personalized gift ideas. Choose who you're gifting:\n\n• For Myself — based on items on your own covet list\n• For Another User — analyzes their covet list for style cues\n• For Someone Not On The App — describe them and we'll figure it out\n\nThen select their interests, occasion, and budget. The AI generates specific, thoughtful gift ideas with a price range and a link to shop."
                )
                FAQItem(
                    question: "Can the gift recipient see that I'm shopping for them?",
                    answer: "No. When you use the gifting tool to browse someone's covet list, they have no idea. The coveted ✓ checkbox is only visible to the item's owner — so your gift research stays completely private."
                )

                // Managing Your List section
                FAQSectionHeader(title: "Managing Your List")

                FAQItem(
                    question: "How do I remove an item from my covet list?",
                    answer: "Open the item by tapping it from your profile, then tap the 🗑 trash icon in the top action bar. You'll be asked to confirm before it's deleted."
                )
                FAQItem(
                    question: "How do I follow someone?",
                    answer: "Go to their profile (search by username in the Search tab) and tap the Follow button. If their account is private, your request will be pending until they approve it."
                )
                FAQItem(
                    question: "How do I approve follow requests?",
                    answer: "Tap the ☰ menu in the top right of your Profile tab. If you have pending requests, you'll see a !! badge. Tap \"Follow and Friend Requests\" to approve or decline."
                )
                FAQItem(
                    question: "How do I edit my profile or add my sizes?",
                    answer: "Tap \"Edit Profile\" on your profile page. You can update your username, name, and clothing sizes (shoe, ring, jeans, dress, top). Friends who follow you can see your sizes to make gifting easier."
                )

                // Troubleshooting section
                FAQSectionHeader(title: "Troubleshooting")

                FAQItem(
                    question: "An item's image isn't showing. What do I do?",
                    answer: "Sometimes product images expire or move. The app will automatically try to re-fetch the image from the original product link. If it continues to fail, the item will be hidden from the feed to keep things looking clean. The item still exists on your profile."
                )
                FAQItem(
                    question: "The Safari Extension isn't working. Help!",
                    answer: "Make sure the covet. extension is enabled:\n\n1. Open iPhone Settings → Safari → Extensions.\n2. Make sure covet. is toggled on.\n3. Also ensure covet. has permission to read page content (required to pull product info).\n\nIf it still doesn't work, try force-quitting and reopening Safari."
                )
                FAQItem(
                    question: "I can't log in. What should I do?",
                    answer: "Try logging out and back in from the ☰ menu on your Profile tab. If you've forgotten your credentials, use the \"Forgot Password\" option on the login screen. Still stuck? Email us."
                )
                FAQItem(
                    question: "How do I delete my account?",
                    answer: "Go to your Profile tab → ☰ menu → scroll to the bottom → \"Delete my account.\" This is permanent and cannot be undone. All your posts and data will be removed."
                )

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Section Header

private struct FAQSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.covetGreen())
                .frame(width: 3, height: 16)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.2)
                .foregroundColor(Color.covetGreen())
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 8)
    }
}

// MARK: - FAQ Accordion Item

private struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text(question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isExpanded ? Color.covetGreen() : Color(UIColor.systemGray3))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                Text(answer)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
                .padding(.leading, 20)
        }
        .background(
            isExpanded ? Color.covetGreen().opacity(0.03) : Color.clear
        )
    }
}
