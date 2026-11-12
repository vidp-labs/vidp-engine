# Contributing to Vingine

Contributions and issues are welcome. Please open an issue before starting a
large change so the API and platform boundaries can be discussed first.

## Contribution policy

Vingine uses the [Developer Certificate of Origin](DCO) instead of a CLA.
By contributing, you confirm that you have the right to submit the work under
the Apache License 2.0. Read the full DCO in [DCO](DCO).

Every commit in a pull request must include a sign-off line:

```text
Signed-off-by: Full Name <email@example.com>
```

Create signed commits with:

```sh
git commit -s
```

If a commit is already created, add the sign-off with:

```sh
git commit --amend --signoff
```

To sign off every commit on the branch at once:

```sh
git rebase --signoff origin/main
```

Use your real name and an email address you control. Do not sign a commit for
someone else's work unless the DCO permits it.

## Pull requests

- Keep the public API platform-neutral.
- Add or update tests for behavior changes.
- Run `swift test` before opening the pull request.
- Explain breaking API changes and update the versioning notes when needed.
- Ensure every commit in the pull request is signed off.
