import SwiftUI

struct SettingsView: View {
    let savedItemCount: Int
    let hasSavedPlaylist: Bool
    let onClearPlaylist: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Playlist") {
                    LabeledContent("Itens carregados", value: "\\(savedItemCount)")
                    LabeledContent("Playlist salva", value: hasSavedPlaylist ? "Sim" : "Não")
                    if hasSavedPlaylist {
                        Button("Remover playlist salva", role: .destructive, action: onClearPlaylist)
                    }
                }
                Section("Sobre") {
                    LabeledContent("Aplicativo", value: "BRAV Player")
                    LabeledContent("Versão", value: "0.2.0 — desenvolvimento")
                }
                Section {
                    Text("Use playlists e transmissões para as quais você tenha autorização de acesso.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Configurações")
        }
    }
}
