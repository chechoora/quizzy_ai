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
        versionCode = 14
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
