import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val playStoreProperties = Properties()
val playStorePropertiesFile = rootProject.file("release_key.properties")
if (playStorePropertiesFile.exists()) {
    playStoreProperties.load(playStorePropertiesFile.inputStream())
}

android {
    namespace = "com.chechoora.poc_ai_quiz"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.chechoora.poc_ai_quiz"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 2
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
}

flutter {
    source = "../.."
}
