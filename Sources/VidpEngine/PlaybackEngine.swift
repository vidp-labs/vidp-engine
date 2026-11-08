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

    public func load(_ media: URL) throws {
        _ = media
        throw PlaybackError.unavailable("No playback backend is configured")
    }

    public func stop() {
        let next = lock.withLock { () -> PlaybackState in
            currentState.media = nil
            currentState.isPaused = true
            currentState.position = nil
            currentState.duration = nil
            currentState.videoSize = nil
            return currentState
        }
        emit(.stateChanged(next))
    }

    public func play() throws { throw unavailable() }
    public func pause() throws { throw unavailable() }

    public func togglePause() throws {
        throw unavailable()
    }

    public func seek(by seconds: Double) throws {
        _ = seconds
        throw unavailable()
    }

    public func seek(to seconds: Double) throws {
        _ = seconds
        throw unavailable()
    }

    public func setVolume(_ value: Double) throws {
        _ = value
        throw unavailable()
    }

    public func setMuted(_ muted: Bool) throws {
        _ = muted
        throw unavailable()
    }

    public func setSpeed(_ value: Double) throws {
        _ = value
        throw unavailable()
    }

    public func selectTrack(_ track: TrackSelection) throws {
        _ = track
        throw unavailable()
    }

    public func shutdown() { stop() }

    private func unavailable() -> PlaybackError {
        .unavailable("No playback backend is configured")
    }

    private func emit(_ event: PlaybackEvent) {
        eventHandler?(event)
    }
}
