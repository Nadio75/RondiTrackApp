import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningProperties = Properties()
val releaseSigningFile = rootProject.file("key.properties")

if (releaseSigningFile.isFile) {
    FileInputStream(releaseSigningFile).use {
        releaseSigningProperties.load(it)
    }
}

val releaseSigningReady =
    releaseSigningFile.isFile &&
    listOf(
        "storeFile",
        "storePassword",
        "keyAlias",
        "keyPassword"
    ).all {
        !releaseSigningProperties.getProperty(it).isNullOrBlank()
    } &&
    rootProject.file(
        releaseSigningProperties.getProperty("storeFile", "")
    ).isFile

android {
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appLabel"] = "RondiTrack Dev"
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appLabel"] = "RondiTrack Staging"
        }

        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "RondiTrack"
        }
    }

    namespace = "za.co.maja.ronditrack"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "za.co.maja.ronditrack"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningReady) {
                storeFile = rootProject.file(
                    releaseSigningProperties.getProperty("storeFile")
                )
                storePassword =
                    releaseSigningProperties.getProperty("storePassword")
                keyAlias =
                    releaseSigningProperties.getProperty("keyAlias")
                keyPassword =
                    releaseSigningProperties.getProperty("keyPassword")
                storeType = "PKCS12"
            }
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


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}


gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any {
        it.project.path == project.path &&
        it.name.contains("Release", ignoreCase = true)
    }

    if (releaseRequested && !releaseSigningReady) {
        throw GradleException(
            "Release signing refused: valid key.properties " +
            "and upload keystore are required."
        )
    }
}