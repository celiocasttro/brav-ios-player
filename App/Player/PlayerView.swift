import AVKit
import SwiftUI

struct PlayerView: View {
    let item: CatalogItem
    @StateObject private var manager: PlayerManager
    @Environment(\.dismiss) private var dismiss

    init(item: CatalogItem) {
        self.item = item
        _manager = StateObject(wrappedValue: PlayerManager(url: item.streamURL))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 16) {
                    VideoPlayer(player: manager.player)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .background(.black)
                    Text(item.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Text(item.streamURL.host ?? item.streamURL.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 12)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") {
                        manager.pause()
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { manager.play() }
            .onDisappear { manager.pause() }
        }
        .preferredColorScheme(.dark)
    }
}
