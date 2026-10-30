import AVKit
import Foundation

@MainActor
final class PlayerManager: ObservableObject {
    @Published private(set) var player: AVPlayer

    init(url: URL) {
        player = AVPlayer(url: url)
        player.automaticallyWaitsToMinimizeStalling = true
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}
