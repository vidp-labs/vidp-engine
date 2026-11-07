import XCTest
@testable import VidpEngine

final class PlaybackEngineTests: XCTestCase {
    func testLoadPublishesMediaAndState() {
        let events = EventBox()
        let engine = PlaybackEngine { events.values.append($0) }
        let url = URL(fileURLWithPath: "/tmp/movie.mp4")

        engine.load(url)

        XCTAssertEqual(engine.state.media, MediaInfo(url: url))
        XCTAssertFalse(engine.state.isPaused)
        XCTAssertEqual(engine.state.position, 0)
        XCTAssertTrue(events.values.contains { event in
            guard case .mediaLoaded(MediaInfo(url: url, title: nil)) = event else { return false }
            return true
        })
    }

    func testCommandsUpdateStateAndClampValues() {
        let engine = PlaybackEngine()
        engine.load(URL(fileURLWithPath: "/tmp/movie.mp4"))
        engine.setVolume(140)
        engine.setSpeed(-1)
        engine.seek(to: -4)

        XCTAssertEqual(engine.state.volume, 100)
        XCTAssertEqual(engine.state.speed, 0)
        XCTAssertEqual(engine.state.position, 0)
    }
}

private final class EventBox: @unchecked Sendable {
    var values: [PlaybackEvent] = []
}
