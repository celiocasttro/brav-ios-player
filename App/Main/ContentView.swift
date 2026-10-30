import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var catalog = CatalogViewModel()
    @State private var playlistAddress = ""
    @State private var showingImporter = false
    @State private var selectedItem: CatalogItem?
    @State private var showingPlayer = false

    private let background = Color(red: 0.025, green: 0.025, blue: 0.03)
    private let accent = Color(red: 0.90, green: 0.05, blue: 0.10)

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    importPanel
                    if !catalog.message.isEmpty {
                        Text(catalog.message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    categoryPicker
                    catalogList
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.plainText, .data],
                allowsMultipleSelection: false,
                onCompletion: catalog.importPlaylist
            )
            .sheet(isPresented: $showingPlayer) {
                if let selectedItem {
                    PlayerView(item: selectedItem)
                }
            }
        }
        .tint(accent)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("BRAV")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white)
                Text("PLAYER")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(accent)
            }
            Spacer()
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.title2)
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private var importPanel: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)
                TextField("Cole o endereço da playlist M3U", text: $playlistAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .onSubmit(loadRemotePlaylist)
                Button(action: loadRemotePlaylist) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(accent)
                }
                .disabled(playlistAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))

            Button {
                showingImporter = true
            } label: {
                Label("Importar playlist do iPhone", systemImage: "folder")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 16)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryButton("Todos")
                ForEach(catalog.categories, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private func categoryButton(_ category: String) -> some View {
        Button {
            catalog.selectedCategory = category
        } label: {
            Text(category)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(catalog.selectedCategory == category ? .white : .secondary)
                .background(
                    catalog.selectedCategory == category ? accent : Color.white.opacity(0.07),
                    in: Capsule()
                )
        }
    }

    private var catalogList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if catalog.filteredItems.isEmpty {
                    ContentUnavailableView(
                        "Nenhum conteúdo",
                        systemImage: "play.rectangle",
                        description: Text("Importe uma playlist M3U ou adicione uma lista de demonstração ao catálogo.")
                    )
                    .padding(.top, 55)
                } else {
                    ForEach(catalog.filteredItems) { item in
                        Button {
                            selectedItem = item
                            showingPlayer = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(Color.white.opacity(0.08))
                                    if let logo = item.logoURL {
                                        AsyncImage(url: logo) { image in
                                            image.resizable().scaledToFit().padding(5)
                                        } placeholder: {
                                            Image(systemName: "tv")
                                                .foregroundStyle(.secondary)
                                        }
                                    } else {
                                        Image(systemName: "play.rectangle")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 58, height: 48)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                    Text(item.category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                    .foregroundStyle(accent)
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private func loadRemotePlaylist() {
        guard let url = URL(string: playlistAddress.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme == "https" || url.scheme == "http" else {
            catalog.message = "Informe um endereço HTTP ou HTTPS válido."
            return
        }
        Task { await catalog.loadPlaylist(from: url) }
        playlistAddress = ""
    }
}
