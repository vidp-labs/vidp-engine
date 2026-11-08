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
}

private final class EventBox: @unchecked Sendable {
    var values: [PlaybackEvent] = []
}
