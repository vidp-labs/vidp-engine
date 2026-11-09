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
}

private final class EventBox: @unchecked Sendable {
    var values: [PlaybackEvent] = []
}

private final class TestBackend: PlaybackBackend {
    var eventHandler: (@Sendable (PlaybackEvent) -> Void)?
    var loadedMedia: MediaInfo?
    var seekedBy: Double?
    var volume: Double?

    func load(_ media: MediaInfo) throws {
        loadedMedia = media
        eventHandler?(.mediaLoaded(media))
    }

    func stop() {}
    func play() throws {}
    func pause() throws {}
    func togglePause() throws {}

    func seek(by seconds: Double) throws {
        seekedBy = seconds
    }

    func seek(to seconds: Double) throws {}

    func setVolume(_ value: Double) throws {
        volume = value
    }

    func setMuted(_ muted: Bool) throws {}
    func setSpeed(_ value: Double) throws {}
    func selectTrack(_ track: TrackSelection) throws {}
    func shutdown() {}
}
