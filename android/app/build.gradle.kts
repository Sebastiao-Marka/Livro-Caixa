import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
      namespace = "com.livro.caixa.fsanf.ba.br"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

   defaultConfig {
        applicationId = "com.livro.caixa.fsanf.ba.br"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
        keyAlias      = keystoreProperties["keyAlias"] as String      // ← chave correta
        keyPassword   = keystoreProperties["keyPassword"] as String   // ← chave correta
        storeFile     = file(keystoreProperties["storeFile"] as String) // ← chave correta
        storePassword = keystoreProperties["storePassword"] as String // ← chave correta
    }
    }

    buildTypes {
        release {
            signingConfig     = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}