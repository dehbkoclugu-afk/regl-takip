import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingReleaseSigningKeys = releaseSigningKeys.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val hasReleaseSigning = keystorePropertiesFile.exists() && missingReleaseSigningKeys.isEmpty()
val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true) || it.contains("bundle", ignoreCase = true)
}

if (isReleaseTask && !hasReleaseSigning) {
    error(
        "Release signing is not configured. Copy android/key.properties.example " +
            "to android/key.properties and provide the original Play Store upload key values. " +
            if (missingReleaseSigningKeys.isNotEmpty()) {
                "Missing: ${missingReleaseSigningKeys.joinToString()}"
            } else {
                "android/key.properties was not found."
            }
    )
}

android {
    namespace = "com.regl.regl_takip"
    compileSdk = flutter.compileSdkVersion
    // Flutter araç zincirinin NDK'sini kullan — elle pinlenen 27.0.12077973
    // bu makinede bozuk kurulumdu ve gradle otomatik indirmiyor
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.regl.regl_takip"
        // health (Health Connect) paketi minimum SDK 26 (Android 8.0) ister
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Release tasks are blocked above unless the original Play upload key exists.
            // The debug fallback only keeps non-release Gradle configuration usable in clean clones.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
