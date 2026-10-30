import Foundation

enum M3UParser {
    static func parse(_ text: String) -> [CatalogItem] {
        var pendingName: String?
        var pendingCategory = "Outros"
        var pendingLogo: URL?
        var items: [CatalogItem] = []
        var seenURLs = Set<String>()

        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if line.uppercased().hasPrefix("#EXTINF:") {
                let parts = line.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
                pendingName = parts.count == 2
                    ? String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                    : nil
                pendingCategory = attribute("group-title", in: line)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .nilIfEmpty ?? "Outros"
                pendingLogo = attribute("tvg-logo", in: line).flatMap(validHTTPURL)
            } else if !line.hasPrefix("#"), let stream = validHTTPURL(line) {
                let key = stream.absoluteString
                if seenURLs.insert(key).inserted {
                    let name = pendingName?.nilIfEmpty ?? stream.host ?? "Transmissão"
                    items.append(CatalogItem(
                        name: name,
                        streamURL: stream,
                        category: pendingCategory,
                        logoURL: pendingLogo
                    ))
                }
                pendingName = nil
                pendingCategory = "Outros"
                pendingLogo = nil
            }
        }
        return items
    }

    private static func attribute(_ key: String, in line: String) -> String? {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let pattern = "(?:^|\\\\s)\(escapedKey)=\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else { return nil }
        return String(line[range])
    }

    private static func validHTTPURL(_ value: String) -> URL? {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else { return nil }
        return url
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
