# Release Versions

Single source of truth for the current version/build number of each flavor is
[`versions.json`](versions.json) (read directly by `fastlane`, see
[`fastlane/Fastfile`](fastlane/Fastfile)). This file documents the same numbers for
humans — the two must be bumped together.

`quizzy` and `quizzypro` are versioned independently — bump the numbers in both files
**before** cutting a release, then run the matching `fastlane` command below.

See [CLAUDE.md § Release Versioning](CLAUDE.md#release-versioning) for how these
flags are wired into Android/iOS.

## Current versions

| Flavor      | Version (`--build-name`) | Build number (`--build-number`) |
|-------------|--------------------------|---------------------------------|
| `quizzy`    | `1.2.8`                  | `48`                            |
| `quizzypro` | `1.0.0`                  | `18`                            |

## Fastlane commands

One-time setup: `bundle install` (installs Fastlane per the root `Gemfile`).

Build outputs land in `builds/<flavor>/` (gitignored), named
`<flavor>-<version>+<build>[.-mode].<ext>`.

### quizzy

```bash
bundle exec fastlane release_all flavor:quizzy   # appbundle + ipa
bundle exec fastlane build_apk       flavor:quizzy mode:release   # or mode:debug
bundle exec fastlane build_appbundle flavor:quizzy
bundle exec fastlane build_ipa       flavor:quizzy
```

### quizzypro

```bash
bundle exec fastlane release_all flavor:quizzypro   # appbundle + ipa
bundle exec fastlane build_apk       flavor:quizzypro mode:release   # or mode:debug
bundle exec fastlane build_appbundle flavor:quizzypro
bundle exec fastlane build_ipa       flavor:quizzypro
```

## Bumping a version

1. Edit the table above **and** [`versions.json`](versions.json) with the new
   version/build number for the flavor you're releasing — they must match.
2. Run the `fastlane` command(s) for the output(s) you need (`apk` for sideloading,
   `appbundle` for Play Store, `ipa` for App Store/TestFlight), or `release_all` for
   appbundle + ipa.
3. Commit the change to both files so the next release starts from the right number.
