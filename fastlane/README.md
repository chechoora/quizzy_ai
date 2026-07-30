fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### build_apk

```sh
[bundle exec] fastlane build_apk
```

Build Android APK. Params: flavor:quizzy|quizzypro mode:debug|release (default release)

### build_appbundle

```sh
[bundle exec] fastlane build_appbundle
```

Build Android App Bundle (release). Params: flavor:quizzy|quizzypro

### build_ipa

```sh
[bundle exec] fastlane build_ipa
```

Build iOS IPA (release). Params: flavor:quizzy|quizzypro

### release_all

```sh
[bundle exec] fastlane release_all
```

Build appbundle + ipa for one flavor. Params: flavor:quizzy|quizzypro

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
