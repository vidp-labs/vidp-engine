import Foundation

/// Platform-neutral playback lifecycle and state API.
///
/// Rendering surfaces, AppKit/UIKit/WinUI views, and the concrete media backend
/// belong to platform adapters and are intentionally not part of this module.
public final class PlaybackEngine: @unchecked Sendable {
    public struct Configuration: Equatable, Sendable {
        public var initialVolume: Double
        public var initialSpeed: Double

        public static let `default` = Configuration(initialVolume: 100, initialSpeed: 1)

        public init(initialVolume: Double = 100, initialSpeed: Double = 1) {
            self.initialVolume = initialVolume
            self.initialSpeed = initialSpeed
        }
    }

    private let lock = NSLock()
    private let eventHandler: (@Sendable (PlaybackEvent) -> Void)?
    private var currentState: PlaybackState

    public init(
        configuration: Configuration = .default,
        eventHandler: (@Sendable (PlaybackEvent) -> Void)? = nil
    ) {
        self.eventHandler = eventHandler
        self.currentState = PlaybackState(
            volume: configuration.initialVolume,
            speed: configuration.initialSpeed
        )
    }

    public var state: PlaybackState {
        lock.withLock { currentState }
    }

    public func load(_ media: URL) {
        let info = MediaInfo(url: media)
        update { state in
            state.media = info
            state.isPaused = false
            state.position = 0
            state.duration = nil
            state.videoSize = nil
        }
        emit(.mediaLoaded(info))
    }

    public func stop() {
        update { state in
            state.media = nil
            state.isPaused = true
            state.position = nil
            state.duration = nil
            state.videoSize = nil
        }
    }

    public func play() { setPaused(false) }
    public func pause() { setPaused(true) }

    public func togglePause() {
        update { $0.isPaused.toggle() }
    }

    public func seek(by seconds: Double) {
        update { state in
            guard let position = state.position else { return }
            state.position = max(0, position + seconds)
        }
    }

    public func seek(to seconds: Double) {
        update { $0.position = max(0, seconds) }
    }

    public func setVolume(_ value: Double) {
        update { $0.volume = min(max(value, 0), 100) }
    }

    public func setMuted(_ muted: Bool) { update { $0.isMuted = muted } }
    public func setSpeed(_ value: Double) { update { $0.speed = max(value, 0) } }

    public func selectTrack(_ track: TrackSelection) {
        // Track routing is implemented by the concrete platform backend.
        _ = track
    }

    public func shutdown() { stop() }

    private func setPaused(_ paused: Bool) {
        update { $0.isPaused = paused }
    }

    @discardableResult
    private func update(_ changes: (inout PlaybackState) -> Void) -> PlaybackState {
        let next = lock.withLock { () -> PlaybackState in
            changes(&currentState)
            return currentState
        }
        emit(.stateChanged(next))
        return next
    }

    private func emit(_ event: PlaybackEvent) {
        eventHandler?(event)
    }
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
