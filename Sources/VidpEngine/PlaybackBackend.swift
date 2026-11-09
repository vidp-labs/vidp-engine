import Foundation

/// A concrete playback implementation supplied by an application.
///
/// The backend owns platform and decoder details. The engine owns the public
/// command surface and state/event contract, so an application can replace
/// libmpv with another backend without changing its UI-facing API.
///
/// The engine sets `eventHandler` when it is initialized and treats it as its
/// own. A backend must send all events through that handler, and must emit
/// `.stateChanged` when a command changes position or duration, which the
/// engine cannot infer itself.
///
/// Commands may arrive from any thread and the handler may be called from any
/// thread, so implementations must synchronize access to their player state.
public protocol PlaybackBackend: AnyObject {
    var eventHandler: (@Sendable (PlaybackEvent) -> Void)? { get set }

    func load(_ media: MediaInfo) throws
    func stop()
    func play() throws
    func pause() throws
    func togglePause() throws
    func seek(by seconds: Double) throws
    func seek(to seconds: Double) throws
    func setVolume(_ value: Double) throws
    func setMuted(_ muted: Bool) throws
    func setSpeed(_ value: Double) throws
    func selectTrack(_ track: TrackSelection) throws
    func shutdown()
}
