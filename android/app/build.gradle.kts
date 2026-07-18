import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val playStoreProperties = Properties()
val playStorePropertiesFile = rootProject.file("release_key.properties")
if (playStorePropertiesFile.exists()) {
    playStoreProperties.load(playStorePropertiesFile.inputStream())
}

android {
    namespace = "com.chechoora.quizzy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.chechoora.quizzy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 24
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = playStoreProperties["keyAlias"] as String?
            keyPassword = playStoreProperties["keyPassword"] as String?
            storeFile = playStoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = playStoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // Support 16 KB memory page sizes (required by Google Play for Android 15+).
    // The `onnxruntime` Flutter plugin (v1.4.1) bundles an old, 4 KB-aligned
    // libonnxruntime.so. We ship a 16 KB-aligned build (ONNX Runtime 1.20.0) in
    // this module's jniLibs and let it win the merge over the plugin's copy.
    packaging {
        jniLibs {
            useLegacyPackaging = false
            pickFirsts += setOf(
                "lib/arm64-v8a/libonnxruntime.so",
                "lib/armeabi-v7a/libonnxruntime.so",
            )
        }
    }
}

flutter {
    source = "../.."
}
