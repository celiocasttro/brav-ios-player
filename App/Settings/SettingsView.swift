import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Sobre") {
                LabeledContent("Aplicativo", value: "BRAV Player")
                LabeledContent("Versão", value: "0.1.0 — desenvolvimento")
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
