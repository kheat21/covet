//
//  ProductNameParser.swift
//  Covet
//
//  Parses raw scraped product names (e.g. "Saint Laurent Wrap Pencil Skirt in Lace | Saks Fifth Avenue")
//  into a clean brand + item name for display.
//

import Foundation

// MARK: - Known Brands

private let knownBrands: [String] = [
    // French
    "Yves Saint Laurent", "Saint Laurent",
    "Hermès", "Hermes",
    "Louis Vuitton",
    "Chanel",
    "Balenciaga",
    "Givenchy",
    "Christian Dior", "Dior",
    "Céline", "Celine",
    "Loewe",
    "Jacquemus",
    "Isabel Marant",
    "Sandro",
    "Maje",
    "A.P.C.", "APC",
    // Italian
    "Gucci",
    "Prada",
    "Versace",
    "Valentino",
    "Bottega Veneta",
    "Fendi",
    "Miu Miu",
    "Brunello Cucinelli",
    "Loro Piana",
    "Dolce & Gabbana", "Dolce&Gabbana",
    "Giorgio Armani", "Emporio Armani", "Armani",
    "Salvatore Ferragamo", "Ferragamo",
    "Tod's", "Tods",
    "Missoni",
    "Max Mara",
    "Marni",
    "Emilio Pucci", "Pucci",
    "Etro",
    "Moschino",
    // British / Scandinavian / Other European
    "Burberry",
    "Alexander McQueen",
    "Stella McCartney",
    "Vivienne Westwood",
    "Mulberry",
    "Acne Studios",
    "Toteme",
    "Nanushka",
    "Ganni",
    "By Malene Birger",
    // American
    "Tom Ford",
    "Polo Ralph Lauren", "Ralph Lauren",
    "Michael Kors Collection", "Michael Kors",
    "Tory Burch",
    "Kate Spade",
    "Marc Jacobs",
    "Diane von Furstenberg", "DVF",
    "Theory",
    "Vince",
    "Veronica Beard",
    "Ulla Johnson",
    "A.L.C.", "ALC",
    "STAUD", "Staud",
    "Rag & Bone",
    // Australian
    "Zimmermann",
    // Shoes
    "Manolo Blahnik",
    "Christian Louboutin",
    "Jimmy Choo",
    "Aquazzura",
    "Gianvito Rossi",
    "Stuart Weitzman",
    "Golden Goose",
    "Sam Edelman",
    "Steve Madden",
    // Jewelry / Watches
    "Cartier",
    "Tiffany & Co.", "Tiffany",
    "Van Cleef & Arpels", "Van Cleef",
    "Bvlgari", "Bulgari",
    "Rolex",
    "Audemars Piguet",
    "Patek Philippe",
    "David Yurman",
]

// MARK: - Known Retailer Domains (vendor field is retailer, not brand)

private let retailerDomains: Set<String> = [
    "saksfifthavenue", "saks",
    "neimanmarcus", "neimanmarcusgroup",
    "bergdorfgoodman", "bergdorf",
    "nordstrom", "nordstromrack",
    "netaporter", "net-a-porter",
    "mytheresa",
    "farfetch",
    "matchesfashion", "matches",
    "revolve",
    "shopbop",
    "bloomingdales", "bloomingdale",
    "modaoperandi",
    "ssense",
    "24s", "24sevres",
    "amazon",
    "target", "walmart",
    "zappos", "macys",
    "share",   // "SHARE" appears when sharing from Google Images
]

// MARK: - Parser

struct ParsedProduct {
    let brand: String?
    let cleanName: String
}

func parseProductDisplay(name: String, vendor: String?) -> ParsedProduct {
    // 1. Strip store suffix: "Product | Store" or "Product - Store"
    var cleanName = name
    for sep in [" | ", " – ", " — ", " - "] {
        if let range = cleanName.range(of: sep) {
            cleanName = String(cleanName[..<range.lowerBound])
                .trimmingCharacters(in: .whitespaces)
            break
        }
    }

    // 2. Try to match a known brand at the start (longest match first)
    for brand in knownBrands.sorted(by: { $0.count > $1.count }) {
        let needle = brand.lowercased()
        let haystack = cleanName.lowercased()
        if haystack.hasPrefix(needle) {
            // Make sure we're not just matching a partial word
            let afterBrand = cleanName.dropFirst(brand.count)
            if afterBrand.first == " " || afterBrand.isEmpty {
                let itemName = afterBrand.trimmingCharacters(in: .whitespaces)
                if !itemName.isEmpty {
                    return ParsedProduct(brand: brand, cleanName: itemName)
                }
            }
        }
    }

    // 3. If vendor is a real brand (not a known retailer domain), use it
    if let v = vendor, !v.isEmpty {
        let normalized = v.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        if !retailerDomains.contains(normalized) && !retailerDomains.contains(v.lowercased()) {
            // Looks like a real brand name
            return ParsedProduct(brand: v, cleanName: cleanName)
        }
    }

    return ParsedProduct(brand: nil, cleanName: cleanName)
}

// MARK: - Price Formatting

func formatPrice(_ price: Double?) -> String? {
    guard let p = price, p > 0 else { return nil }
    if p >= 1000 {
        return "$\(String(format: "%.0f", p))"
    }
    // Show cents if non-zero
    let rounded = String(format: "%.0f", p)
    return "$\(rounded)"
}
