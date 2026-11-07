import Foundation

public struct VideoSize: Equatable, Sendable {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public struct MediaInfo: Equatable, Sendable {
    public let url: URL
    public let title: String?

    public init(url: URL, title: String? = nil) {
        self.url = url
        self.title = title
    }
}

public enum TrackKind: String, Sendable {
    case audio
    case video
    case subtitle
}

public struct TrackSelection: Equatable, Sendable {
    public let kind: TrackKind
    public let id: Int?

    public init(kind: TrackKind, id: Int?) {
        self.kind = kind
        self.id = id
    }
}

public struct PlaybackState: Equatable, Sendable {
    public var media: MediaInfo?
    public var isPaused: Bool
    public var position: Double?
    public var duration: Double?
    public var volume: Double?
    public var isMuted: Bool
    public var speed: Double
    public var videoSize: VideoSize?

    public init(
        media: MediaInfo? = nil,
        isPaused: Bool = true,
        position: Double? = nil,
        duration: Double? = nil,
        volume: Double? = nil,
        isMuted: Bool = false,
        speed: Double = 1,
        videoSize: VideoSize? = nil
    ) {
        self.media = media
        self.isPaused = isPaused
        self.position = position
        self.duration = duration
        self.volume = volume
        self.isMuted = isMuted
        self.speed = speed
        self.videoSize = videoSize
    }
}

public enum PlaybackError: Error, Equatable, Sendable {
    case invalidMedia(URL)
    case unavailable(String)
    case failed(String)
}

public enum PlaybackEvent: Sendable {
    case mediaLoaded(MediaInfo)
    case stateChanged(PlaybackState)
    case videoSizeChanged(VideoSize)
    case ended
    case failed(PlaybackError)
}
