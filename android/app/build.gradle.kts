import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de release (§5.5.5). android/key.properties está en .gitignore y
// apunta al keystore personal (fuera del repo). Si no existe, release se
// firma con la clave de debug y se muestra un aviso.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun keyProperty(name: String): String =
    keystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }
        ?: throw GradleException("android/key.properties: falta la propiedad '$name'.")

val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
if (!hasReleaseKey && isReleaseBuild) {
    logger.warn(
        """
        |⚠  AVISO: no existe android/key.properties.
        |⚠  El build release se firmará con la clave de DEBUG.
        |⚠  Una app instalada así NO se puede actualizar después con la clave real
        |⚠  sin desinstalarla (y perder sus datos). Ver §5.5.5.
        """.trimMargin(),
    )
}

android {
    namespace = "com.ascend.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // ID base; el flavor dev añade el sufijo ".dev" (§5.5.4).
        applicationId = "com.ascend.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // 26+ para compatibilidad con Health Connect (Fase 7).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Flavors (§5.5.4): se instalan lado a lado en el mismo celular.
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "Ascend Dev"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appLabel"] = "Ascend"
        }
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keyProperty("keyAlias")
                keyPassword = keyProperty("keyPassword")
                storePassword = keyProperty("storePassword")
                // Permite rutas con "~" (p. ej. ~/keys/ascend-release.jks).
                val storePath = keyProperty("storeFile")
                    .replaceFirst(Regex("^~"), System.getProperty("user.home"))
                storeFile = file(storePath)
                if (!storeFile!!.exists()) {
                    throw GradleException("Keystore no encontrado: $storePath (android/key.properties).")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
