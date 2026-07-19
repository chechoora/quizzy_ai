# quizzypro Firebase config (Android)

Place the **real** `google-services.json` for the `com.chechoora.quizzy.pro`
Android app here:

    android/app/src/quizzypro/google-services.json

Register that package name as a new Android app inside the **existing
"Quizzy AI" Firebase project**, download its `google-services.json`, and drop it
in this flavor source set. The `com.google.gms.google-services` Gradle plugin
picks it up automatically for the `quizzypro` flavor.

Until this file exists, `--flavor quizzypro` Android builds will fail at the
`processQuizzyproDebugGoogleServices` step with
"No matching client found for package name 'com.chechoora.quizzy.pro'".
The `quizzy` flavor keeps using `android/app/google-services.json`.
