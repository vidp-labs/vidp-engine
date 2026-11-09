import XCTest
@testable import VidpEngine

final class PlaybackEngineTests: XCTestCase {
    func testCommandsReportUnavailableUntilBackendIsConfigured() {
        let events = EventBox()
        let engine = PlaybackEngine { events.values.append($0) }
        let url = URL(fileURLWithPath: "/tmp/movie.mp4")

        XCTAssertThrowsError(try engine.load(url)) { error in
            XCTAssertEqual(error as? PlaybackError, .unavailable("No playback backend is configured"))
        }
        XCTAssertThrowsError(try engine.selectTrack(TrackSelection(kind: .audio, id: 1)))

        XCTAssertNil(engine.state.media)
        XCTAssertTrue(events.values.isEmpty)
    }

    func testCommandsUpdateStateAndClampValues() {
        let engine = PlaybackEngine(configuration: .init(initialVolume: 140, initialSpeed: -1))

        XCTAssertEqual(engine.state.volume, 100)
        XCTAssertEqual(engine.state.speed, 0)
    }

    func testEngineDelegatesCommandsToBackendAndReceivesEvents() throws {
        let backend = TestBackend()
        let events = EventBox()
        let engine = PlaybackEngine(backend: backend) { events.values.append($0) }
        let url = URL(fileURLWithPath: "/tmp/movie.mp4")

        try engine.load(url)
        try engine.seek(by: 10)
        try engine.setVolume(80)

        XCTAssertEqual(backend.loadedMedia?.url, url)
        XCTAssertEqual(backend.seekedBy, 10)
        XCTAssertEqual(backend.volume, 80)
        XCTAssertEqual(engine.state.media?.url, url)
        XCTAssertEqual(engine.state.volume, 80)
        XCTAssertEqual(events.values.count, 2)
    }

    func testPlaybackCommandsUpdateStateAndReachBackend() throws {
        let backend = TestBackend()
        let engine = PlaybackEngine(backend: backend)

        try engine.load(URL(fileURLWithPath: "/tmp/movie.mp4"))
        XCTAssertTrue(engine.state.isPaused)

        try engine.play()
        XCTAssertFalse(engine.state.isPaused)
        XCTAssertTrue(backend.isPlaying)

        try engine.pause()
        XCTAssertTrue(engine.state.isPaused)
        XCTAssertFalse(backend.isPlaying)

        try engine.togglePause()
        XCTAssertFalse(engine.state.isPaused)
        XCTAssertTrue(backend.isPlaying)

        engine.shutdown()
        XCTAssertEqual(backend.shutdownCount, 1)
        XCTAssertNil(backend.eventHandler)
    }

    func testSettingsClampBeforeReachingBackend() throws {
        let backend = TestBackend()
        let engine = PlaybackEngine(backend: backend)

        try engine.setVolume(150)
        try engine.setSpeed(-2)

        XCTAssertEqual(backend.volume, 100)
        XCTAssertEqual(backend.speed, 0)
        XCTAssertEqual(engine.state.volume, 100)
        XCTAssertEqual(engine.state.speed, 0)
    }

    func testBackendEventsUpdateStateAndReachEventHandler() throws {
        let backend = TestBackend()
        let events = EventBox()
        let engine = PlaybackEngine(backend: backend) { events.values.append($0) }
        let size = VideoSize(width: 1920, height: 1080)

        try engine.load(URL(fileURLWithPath: "/tmp/movie.mp4"))
        try engine.play()
        XCTAssertFalse(engine.state.isPaused)

        backend.eventHandler?(.videoSizeChanged(size))
        backend.eventHandler?(.ended)

        XCTAssertEqual(engine.state.videoSize, size)
        XCTAssertTrue(engine.state.isPaused)
        XCTAssertEqual(events.values.count, 4)

        var state = engine.state
        state.position = 42
        backend.eventHandler?(.stateChanged(state))

        XCTAssertEqual(engine.state.position, 42)
        XCTAssertEqual(events.values.count, 5)
    }
}

private final class EventBox: @unchecked Sendable {
    var values: [PlaybackEvent] = []
}

private final class TestBackend: PlaybackBackend {
    var eventHandler: (@Sendable (PlaybackEvent) -> Void)?
    var loadedMedia: MediaInfo?
    var seekedBy: Double?
    var volume: Double?
    var speed: Double?
    var isPlaying = false
    var shutdownCount = 0

    func load(_ media: MediaInfo) throws {
        loadedMedia = media
        eventHandler?(.mediaLoaded(media))
    }

    func stop() {}
    func play() throws { isPlaying = true }
    func pause() throws { isPlaying = false }
    func togglePause() throws { isPlaying.toggle() }

    func seek(by seconds: Double) throws {
        seekedBy = seconds
    }

    func seek(to seconds: Double) throws {}

    func setVolume(_ value: Double) throws {
        volume = value
    }

    func setMuted(_ muted: Bool) throws {}
    func setSpeed(_ value: Double) throws { speed = value }
    func selectTrack(_ track: TrackSelection) throws {}
    func shutdown() { shutdownCount += 1 }
}
