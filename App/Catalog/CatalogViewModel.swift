import Foundation
import SwiftUI

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var items: [CatalogItem] = []
    @Published var selectedCategory = "Todos"
    @Published var message = ""

    var categories: [String] {
        Array(Set(items.map(\.category))).sorted()
    }

    var filteredItems: [CatalogItem] {
        selectedCategory == "Todos" ? items : items.filter { $0.category == selectedCategory }
    }

    init() {
        loadBundledCatalog()
    }

    func loadPlaylist(from url: URL) async {
        message = "Carregando playlist..."
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let text = String(data: data, encoding: .utf8) else {
                message = "Não foi possível ler a playlist como texto UTF-8."
                return
            }
            applyPlaylist(text)
        } catch {
            message = "Falha ao carregar playlist: \(error.localizedDescription)"
        }
    }

    func importPlaylist(result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let granted = url.startAccessingSecurityScopedResource()
            defer { if granted { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            guard let text = String(data: data, encoding: .utf8) else {
                message = "O arquivo não está em UTF-8."
                return
            }
            applyPlaylist(text)
        } catch {
            message = "Não foi possível importar: \(error.localizedDescription)"
        }
    }

    private func applyPlaylist(_ text: String) {
        let parsed = M3UParser.parse(text)
        guard !parsed.isEmpty else {
            message = "Nenhuma transmissão HTTP/HTTPS válida foi encontrada."
            return
        }
        items = parsed
        selectedCategory = "Todos"
        message = "\(parsed.count) itens carregados."
    }

    private func loadBundledCatalog() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json", subdirectory: "Catalog"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([CatalogItem].self, from: data) else {
            items = [
                CatalogItem(
                    name: "Stream de demonstração",
                    streamURL: URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!,
                    category: "Demonstração",
                    logoURL: nil
                )
            ]
            return
        }
        items = decoded
    }
}
