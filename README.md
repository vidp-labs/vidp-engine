# Vidp Engine

The reusable, platform-neutral playback engine for [Vidp](https://github.com/vidp-labs/vidp)
applications. `vidp-engine` owns playback commands, state, metadata, track
selection, and playback events so each Vidp application can provide its own
native interface and platform integration.

> Early development: the public API is being established before concrete
> platform backends are added.

Until a backend is configured, playback commands report
`PlaybackError.unavailable` rather than claiming that media has loaded.

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

## Releases

Engine releases use semantic versioning. The `VERSION` file records the
version being released, and the release workflow creates a matching immutable
Git tag such as `v0.1.0` after the generated version PR is merged. Applications
must select an explicit engine version; a released tag is never moved to a
different commit.

Use the **Release** workflow in GitHub Actions to choose a patch, minor, or
major release. Breaking public API changes require a new major version.

For the first release, run the workflow with exact version `0.1.0`; because
that version is already recorded in `VERSION`, the workflow tags the current
`main` commit directly. Later releases create and auto-merge a version PR
before tagging.

The release workflow uses a dedicated GitHub App so the generated release PR
can run the same required CI check as every other pull request. Repository
secrets `RELEASE_APP_ID` and `RELEASE_APP_PRIVATE_KEY` must be configured for
the release workflow. The App needs Contents: write (push the version branch
and tag, create the release), Pull requests: write (create and merge the
version PR), and Issues: write (apply the `release-bump` label).

If a release fails after its tag is pushed, run the workflow again with that
exact version. The workflow keeps the existing tag and only creates the
missing release.

## Contributing

Contributions and issues are welcome. `main` is branch-protected; please open
a pull request with changes.

## Related repositories

- [Vidp](https://github.com/vidp-labs/vidp) — the official Vidp application
- [Homebrew Vidp](https://github.com/vidp-labs/homebrew-vidp) — distribution

## License

Starting with the next engine release, this repository is licensed under the
Apache License 2.0. See [LICENSE](LICENSE).

The existing `v0.1.0` release was published under MIT and remains available
under those terms.
