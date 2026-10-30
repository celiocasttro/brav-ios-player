import Foundation

enum M3UParser {
    static func parse(_ text: String) -> [CatalogItem] {
        let lines = text.components(separatedBy: .newlines)
        var pendingName: String?
        var pendingCategory = "Outros"
        var pendingLogo: URL?
        var items: [CatalogItem] = []

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if line.hasPrefix("#EXTINF") {
                pendingName = line.components(separatedBy: ",").last?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                pendingCategory = attribute("group-title", in: line) ?? "Outros"
                if let logo = attribute("tvg-logo", in: line) {
                    pendingLogo = URL(string: logo)
                } else {
                    pendingLogo = nil
                }
            } else if !line.hasPrefix("#"), let stream = URL(string: line),
                      let scheme = stream.scheme?.lowercased(),
                      ["http", "https"].contains(scheme) {
                let name = pendingName?.isEmpty == false ? pendingName! : stream.host ?? "Transmissão"
                items.append(CatalogItem(
                    name: name,
                    streamURL: stream,
                    category: pendingCategory,
                    logoURL: pendingLogo
                ))
                pendingName = nil
                pendingCategory = "Outros"
                pendingLogo = nil
            }
        }
        return items
    }

    private static func attribute(_ key: String, in line: String) -> String? {
        let pattern = #"(?:^|\s)\#(key)="([^"]*)""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else { return nil }
        return String(line[range])
    }
}
