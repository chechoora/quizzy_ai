# Release Versions

Single source of truth for the current version/build number of each flavor.
`quizzy` and `quizzypro` are versioned independently — bump the numbers here
**before** cutting a release, then copy the matching command block below.

See [CLAUDE.md § Release Versioning](CLAUDE.md#release-versioning) for how these
flags are wired into Android/iOS.

## Current versions

| Flavor      | Version (`--build-name`) | Build number (`--build-number`) |
|-------------|-----------------------|---------------------------------|
| `quizzy`    | `1.2.5`               | `45`                            |
| `quizzypro` | `1.0.0`               | `14`                            |

## Copy-paste commands

### quizzy

```bash
fvm flutter build apk       --flavor quizzy -t lib/main_quizzy.dart --release --build-name=1.2.5 --build-number=45
fvm flutter build appbundle --flavor quizzy -t lib/main_quizzy.dart --release --build-name=1.2.5 --build-number=45
fvm flutter build ipa       --flavor quizzy -t lib/main_quizzy.dart --build-name=1.2.5 --build-number=45 --export-options-plist=ios/ExportOptions.plist
```

### quizzypro
 
```bash
fvm flutter build apk       --flavor quizzypro -t lib/main_quizzypro.dart --release --build-name=1.0.0 --build-number=14
fvm flutter build appbundle --flavor quizzypro -t lib/main_quizzypro.dart --release --build-name=1.0.0 --build-number=14
fvm flutter build ipa       --flavor quizzypro -t lib/main_quizzypro.dart --build-name=1.0.0 --build-number=14 --export-options-plist=ios/ExportOptions.plist
```

## Bumping a version

1. Edit the table above with the new version/build number for the flavor you're releasing.
2. Update the matching command block's `--build-name`/`--build-number` values to match.
3. Copy-paste the command(s) for the output(s) you need (`apk` for sideloading,
   `appbundle` for Play Store, `ipa` for App Store/TestFlight).
4. Commit the change to this file so the next release starts from the right number.
