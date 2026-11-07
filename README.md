# Vidp Engine

The reusable, platform-neutral playback engine for [Vidp](https://github.com/vidp-labs/vidp)
applications. `vidp-engine` owns playback commands, state, metadata, track
selection, and playback events so each Vidp application can provide its own
native interface and platform integration.

> Early development: the public API is being established before concrete
> platform backends are added.

## Scope

The engine provides the shared playback contract. Applications remain
responsible for:

- Native UI and video rendering surfaces
- Playlists, navigation, and filename presentation
- User preferences, branding, updates, signing, and packaging

The public API deliberately contains no AppKit, OpenGL, UIKit, WinUI, or
libmpv C types. Platform backends may use those technologies internally, but
they must remain implementation details behind this package.

## Development

Requirements:

- Swift 5.9 or newer
- Swift Package Manager

Run the test suite from the repository root:

```sh
swift test
```

## Related repositories

- [Vidp](https://github.com/vidp-labs/vidp) — the official Vidp application
- [Homebrew Vidp](https://github.com/vidp-labs/homebrew-vidp) — distribution

## License

MIT. See [LICENSE](LICENSE).
