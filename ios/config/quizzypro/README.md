# quizzypro Firebase config (iOS)

Place the **real** `GoogleService-Info.plist` for the `com.chechoora.quizzy.pro`
iOS app here:

    ios/config/quizzypro/GoogleService-Info.plist

Register that bundle id as a new iOS app inside the **existing "Quizzy AI"
Firebase project**, download its `GoogleService-Info.plist`, and drop it in this
folder. The `quizzy` flavor uses the bundled `ios/Runner/GoogleService-Info.plist`;
for any non-`quizzy` flavor the `Copy flavor GoogleService-Info.plist` build phase
overrides the bundled plist with `config/<flavor>/GoogleService-Info.plist`.

Until this file exists, `--flavor quizzypro` iOS builds will emit a warning and
Firebase will be unconfigured for the Pro flavor.
