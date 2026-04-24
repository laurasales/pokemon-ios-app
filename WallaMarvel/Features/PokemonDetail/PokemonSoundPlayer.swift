//
//  PokemonSoundPlayer.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import AVFoundation
import Combine

@MainActor
final class PokemonSoundPlayer: ObservableObject {
    @Published private(set) var isPlaying = false

    private var player: AVPlayer?
    private var cancellable: AnyCancellable?

    func play(slug: String) {
        guard let url = URL(string: "https://play.pokemonshowdown.com/audio/cries/\(slug).mp3") else { return }

        player = AVPlayer(url: url)
        isPlaying = true

        cancellable = NotificationCenter.default.publisher(
            for: AVPlayerItem.didPlayToEndTimeNotification,
            object: player?.currentItem
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.isPlaying = false
        }

        player?.play()
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
