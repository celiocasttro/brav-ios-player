import Foundation
import SwiftUI

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var items: [CatalogItem] = []
    @Published var selectedCategory = "Todos"
    @Published var message = ""
    @Published private(set) var hasSavedPlaylist = false

    private let savedPlaylistKey = "brav.savedPlaylist.v1"
    private let maximumPlaylistSize = 20 * 1024 * 1024

    var categories: [String] {
        Array(Set(items.map(\.category))).sorted()
    }

    var filteredItems: [CatalogItem] {
        selectedCategory == "Todos" ? items : items.filter { $0.category == selectedCategory }
    }

    init() {
        if !restoreSavedPlaylist() {
            loadBundledCatalog()
        }
    }

    func loadPlaylist(from url: URL) async {
        message = "Carregando playlist..."
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 45
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                message = "O servidor respondeu com erro HTTP \(http.statusCode)."
                return
            }
            guard data.count <= maximumPlaylistSize else {
                message = "A playlist ultrapassa o limite de 20 MB."
                return
            }
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
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? NSNumber, size.intValue > maximumPlaylistSize {
                message = "O arquivo ultrapassa o limite de 20 MB."
                return
            }
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

    func clearSavedPlaylist() {
        UserDefaults.standard.removeObject(forKey: savedPlaylistKey)
        hasSavedPlaylist = false
        loadBundledCatalog()
        message = "Playlist salva removida."
    }

    private func applyPlaylist(_ text: String) {
        let parsed = M3UParser.parse(text)
        guard !parsed.isEmpty else {
            message = "Nenhuma transmissão HTTP/HTTPS válida foi encontrada."
            return
        }
        do {
            let data = try JSONEncoder().encode(parsed)
            UserDefaults.standard.set(data, forKey: savedPlaylistKey)
            items = parsed
            hasSavedPlaylist = true
            selectedCategory = "Todos"
            message = "\(parsed.count) itens carregados e salvos neste iPhone."
        } catch {
            items = parsed
            message = "\(parsed.count) itens carregados, mas não foi possível salvá-los."
        }
    }

    @discardableResult
    private func restoreSavedPlaylist() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: savedPlaylistKey),
              let savedItems = try? JSONDecoder().decode([CatalogItem].self, from: data),
              !savedItems.isEmpty else { return false }
        items = savedItems
        hasSavedPlaylist = true
        message = "Playlist anterior restaurada (\(savedItems.count) itens)."
        return true
    }

    private func loadBundledCatalog() {
        hasSavedPlaylist = false
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
