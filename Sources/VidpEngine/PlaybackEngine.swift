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
            self.initialVolume = min(max(initialVolume, 0), 100)
            self.initialSpeed = max(initialSpeed, 0)
        }
    }

    private let lock = NSLock()
    private let backend: PlaybackBackend?
    private let eventHandler: (@Sendable (PlaybackEvent) -> Void)?
    private var currentState: PlaybackState

    public init(
        backend: PlaybackBackend? = nil,
        configuration: Configuration = .default,
        eventHandler: (@Sendable (PlaybackEvent) -> Void)? = nil
    ) {
        self.backend = backend
        self.eventHandler = eventHandler
        self.currentState = PlaybackState(
            volume: configuration.initialVolume,
            speed: configuration.initialSpeed
        )
        backend?.eventHandler = { [weak self] event in
            self?.receive(event)
        }
    }

    public var state: PlaybackState {
        lock.withLock { currentState }
    }

    public func load(_ media: URL) throws {
        guard let backend else { throw unavailable() }
        try backend.load(MediaInfo(url: media))
    }

    public func stop() {
        backend?.stop()
        updateState { state in
            state.media = nil
            state.isPaused = true
            state.position = nil
            state.duration = nil
            state.videoSize = nil
        }
    }

    public func play() throws {
        guard let backend else { throw unavailable() }
        try backend.play()
        updateState { state in
            state.isPaused = false
        }
    }

    public func pause() throws {
        guard let backend else { throw unavailable() }
        try backend.pause()
        updateState { state in
            state.isPaused = true
        }
    }

    public func togglePause() throws {
        guard let backend else { throw unavailable() }
        try backend.togglePause()
        updateState { state in
            state.isPaused.toggle()
        }
    }

    public func seek(by seconds: Double) throws {
        guard let backend else { throw unavailable() }
        try backend.seek(by: seconds)
    }

    public func seek(to seconds: Double) throws {
        guard let backend else { throw unavailable() }
        try backend.seek(to: seconds)
    }

    public func setVolume(_ value: Double) throws {
        guard let backend else { throw unavailable() }
        let clamped = min(max(value, 0), 100)
        try backend.setVolume(clamped)
        updateState { state in
            state.volume = clamped
        }
    }

    public func setMuted(_ muted: Bool) throws {
        guard let backend else { throw unavailable() }
        try backend.setMuted(muted)
        updateState { state in
            state.isMuted = muted
        }
    }

    public func setSpeed(_ value: Double) throws {
        guard let backend else { throw unavailable() }
        let clamped = max(value, 0)
        try backend.setSpeed(clamped)
        updateState { state in
            state.speed = clamped
        }
    }

    public func selectTrack(_ track: TrackSelection) throws {
        guard let backend else { throw unavailable() }
        try backend.selectTrack(track)
    }

    public func shutdown() {
        stop()
        backend?.eventHandler = nil
        backend?.shutdown()
    }

    private func receive(_ event: PlaybackEvent) {
        lock.withLock {
            switch event {
            case .mediaLoaded(let media):
                currentState.media = media
                currentState.isPaused = true
            case .stateChanged(let state):
                currentState = state
            case .videoSizeChanged(let size):
                currentState.videoSize = size
            case .ended:
                currentState.isPaused = true
            case .failed:
                break
            }
        }
        eventHandler?(event)
    }

    private func unavailable() -> PlaybackError {
        .unavailable("No playback backend is configured")
    }

    private func updateState(_ update: (inout PlaybackState) -> Void) {
        let next = lock.withLock { () -> PlaybackState in
            update(&currentState)
            return currentState
        }
        emit(.stateChanged(next))
    }

    private func emit(_ event: PlaybackEvent) {
        eventHandler?(event)
    }
}
