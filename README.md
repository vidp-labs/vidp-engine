# Vidp Engine

`vidp-engine` is the platform-neutral playback layer for Vidp applications.
It owns playback commands, state, metadata, track selection, and playback
events. Applications own their user interface, playlists, preferences,
branding, packaging, and native video rendering adapters.

The public API deliberately contains no AppKit, OpenGL, UIKit, WinUI, or
libmpv C types. A concrete backend can be added behind this API for macOS,
Windows, Linux, or another platform without making the application UI part of
the engine.

## Development

```sh
swift test
```

## License

MIT. See [LICENSE](LICENSE).
