//
//  ExtensionPageScraper.swift
//  CovetButton
//
//  Direct HTTP scraper for the share extension — no external server needed.
//

import Foundation
import UIKit

struct ExtensionScrapedProduct {
    var title: String?
    var vendor: String?
    var price: String?
    var imageURL: String?
}

class ExtensionPageScraper {

    static func scrape(urlString: String) async -> ExtensionScrapedProduct? {
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

            // Try JSON-LD first (most reliable for Saks, Nordstrom, etc.)
            if let jsonLD = extractJSONLD(html) {
                let vendor = extractBrandFromJSONLD(jsonLD) ?? ogMeta(html, "product:brand")
                let rawTitle = jsonLD["name"] as? String ?? ogMeta(html, "og:title") ?? titleTag(html)
                // Strip brand from start of title if present (e.g. "Saint Laurent Kate Bag" → "Kate Bag")
                let title = stripBrandFromTitle(rawTitle, brand: vendor)
                let price  = extractPriceFromJSONLD(jsonLD) ?? ogMeta(html, "og:price:amount") ?? ogMeta(html, "product:price:amount") ?? extractPriceFromHTML(html)
                let image  = extractImageFromJSONLD(jsonLD) ?? ogMeta(html, "og:image")
                return ExtensionScrapedProduct(title: title, vendor: vendor, price: price, imageURL: image)
            }

            // Fallback to meta tags
            let title  = ogMeta(html, "og:title") ?? titleTag(html)
            let vendor = ogMeta(html, "og:site_name") ?? ogMeta(html, "product:brand")
            let price  = ogMeta(html, "og:price:amount") ?? ogMeta(html, "product:price:amount") ?? extractPriceFromHTML(html)
            let image  = ogMeta(html, "og:image")
            return ExtensionScrapedProduct(title: title, vendor: vendor, price: price, imageURL: image)
        } catch {
            return nil
        }
    }

    // MARK: - JSON-LD

    private static func extractJSONLD(_ html: String) -> [String: Any]? {
        let pattern = "<script[^>]+type=[\"']application/ld\\+json[\"'][^>]*>([\\s\\S]*?)</script>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        for match in matches {
            guard let range = Range(match.range(at: 1), in: html) else { continue }
            let jsonString = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) else { continue }
            // Handle array of JSON-LD objects
            if let array = json as? [[String: Any]] {
                for obj in array {
                    if let type_ = obj["@type"] as? String, type_.lowercased().contains("product") {
                        return obj
                    }
                }
            } else if let obj = json as? [String: Any] {
                if let type_ = obj["@type"] as? String, type_.lowercased().contains("product") {
                    return obj
                }
            }
        }
        return nil
    }

    private static func extractBrandFromJSONLD(_ json: [String: Any]) -> String? {
        if let brand = json["brand"] as? [String: Any] {
            return brand["name"] as? String
        }
        if let brand = json["brand"] as? String { return brand }
        return nil
    }

    private static func extractPriceFromJSONLD(_ json: [String: Any]) -> String? {
        if let offers = json["offers"] as? [String: Any] {
            if let price = offers["price"] as? Double { return String(price) }
            if let price = offers["price"] as? String { return price }
            if let price = offers["lowPrice"] as? Double { return String(price) }
            if let price = offers["lowPrice"] as? String { return price }
        }
        if let offers = json["offers"] as? [[String: Any]], let first = offers.first {
            if let price = first["price"] as? Double { return String(price) }
            if let price = first["price"] as? String { return price }
        }
        return nil
    }

    private static func extractImageFromJSONLD(_ json: [String: Any]) -> String? {
        if let image = json["image"] as? String { return image }
        if let images = json["image"] as? [String] { return images.first }
        if let image = json["image"] as? [String: Any] { return image["url"] as? String }
        return nil
    }

    private static func stripBrandFromTitle(_ title: String?, brand: String?) -> String? {
        guard let title = title, let brand = brand, !brand.isEmpty else { return title }
        // If title starts with brand name (case-insensitive), strip it
        let lower = title.lowercased()
        let brandLower = brand.lowercased()
        if lower.hasPrefix(brandLower) {
            let stripped = String(title.dropFirst(brand.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            return stripped.isEmpty ? title : stripped
        }
        return title
    }

    // MARK: - Meta tags

    private static func ogMeta(_ html: String, _ property: String) -> String? {
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

    private static func titleTag(_ html: String) -> String? {
        let pattern = "<title[^>]*>([^<]+)</title>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
           let range = Range(match.range(at: 1), in: html) {
            return String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private static func extractPriceFromHTML(_ html: String) -> String? {
        let patterns = [
            "\"salePrice\":\\s*([0-9]+(?:\\.[0-9]{1,2})?)[^0-9]",
            "\"currentPrice\":\\s*([0-9]+(?:\\.[0-9]{1,2})?)[^0-9]",
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
}
