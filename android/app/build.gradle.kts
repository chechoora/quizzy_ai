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
        applicationId = "com.chechoora.quizzy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 3
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
