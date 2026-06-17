import Foundation

/// Generates an Android application that hosts the Score app in a
/// system `WebView`.
///
/// The generated project is a standard Gradle (Kotlin DSL) project. Static
/// exports are bundled as assets and served through AndroidX
/// `WebViewAssetLoader`, which exposes them over
/// `https://appassets.androidplatform.net/` so absolute paths and same-origin
/// rules behave like a real deployment.
public struct AndroidPackager: WebViewPackager {
    public let platform: PackagingPlatform = .android

    public init() {}

    public func package(config: PackagingConfig, into outputDirectory: URL) throws -> PackagedApp {
        var writer = try ProjectWriter(root: outputDirectory)
        let pkg = config.androidPackage
        let pkgPath = pkg.replacingOccurrences(of: ".", with: "/")

        try writer.write(settingsGradle(config: config), to: "settings.gradle.kts")
        try writer.write(rootBuildGradle(), to: "build.gradle.kts")
        try writer.write(gradleProperties(), to: "gradle.properties")
        try writer.write(appBuildGradle(config: config), to: "app/build.gradle.kts")
        try writer.write(manifest(config: config), to: "app/src/main/AndroidManifest.xml")
        try writer.write(mainActivity(config: config), to: "app/src/main/java/\(pkgPath)/MainActivity.kt")

        if case .staticExport(let path) = config.source {
            try writer.copyStaticExport(from: path, to: "app/src/main/assets/site")
        }

        let nextSteps = """
        Build (requires the Android SDK; easiest via Android Studio):
          cd \(outputDirectory.path)
          gradle wrapper && ./gradlew assembleDebug

        Or open the directory in Android Studio and press Run.
        The APK is written to app/build/outputs/apk/debug/.
        """
        try writer.write(readme(config: config, nextSteps: nextSteps), to: "README.md")

        return PackagedApp(
            platform: .android,
            outputDirectory: outputDirectory,
            filesWritten: writer.written,
            nextSteps: nextSteps
        )
    }

    // MARK: - Templates

    private func settingsGradle(config: PackagingConfig) -> String {
        """
        pluginManagement {
            repositories {
                google()
                mavenCentral()
                gradlePluginPortal()
            }
        }

        dependencyResolutionManagement {
            repositories {
                google()
                mavenCentral()
            }
        }

        rootProject.name = "\(config.executableName)"
        include(":app")
        """
    }

    private func rootBuildGradle() -> String {
        """
        plugins {
            id("com.android.application") version "8.5.2" apply false
            id("org.jetbrains.kotlin.android") version "2.0.20" apply false
        }
        """
    }

    private func gradleProperties() -> String {
        """
        android.useAndroidX=true
        org.gradle.jvmargs=-Xmx2g
        """
    }

    private func appBuildGradle(config: PackagingConfig) -> String {
        """
        plugins {
            id("com.android.application")
            id("org.jetbrains.kotlin.android")
        }

        android {
            namespace = "\(config.androidPackage)"
            compileSdk = 34

            defaultConfig {
                applicationId = "\(config.androidPackage)"
                minSdk = 24
                targetSdk = 34
                versionCode = 1
                versionName = "\(config.version)"
            }

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }

            kotlinOptions {
                jvmTarget = "17"
            }
        }

        dependencies {
            implementation("androidx.webkit:webkit:1.11.0")
        }
        """
    }

    private func manifest(config: PackagingConfig) -> String {
        """
        <?xml version="1.0" encoding="utf-8"?>
        <manifest xmlns:android="http://schemas.android.com/apk/res/android">

            <uses-permission android:name="android.permission.INTERNET" />

            <application android:label="\(config.appName)">
                <activity
                    android:name=".MainActivity"
                    android:exported="true">
                    <intent-filter>
                        <action android:name="android.intent.action.MAIN" />
                        <category android:name="android.intent.category.LAUNCHER" />
                    </intent-filter>
                </activity>
            </application>

        </manifest>
        """
    }

    private func mainActivity(config: PackagingConfig) -> String {
        let loading: String
        switch config.source {
        case .staticExport:
            loading = """
                    val assetLoader = WebViewAssetLoader.Builder()
                        .addPathHandler("/", WebViewAssetLoader.AssetsPathHandler(this))
                        .build()

                    webView.webViewClient = object : WebViewClient() {
                        override fun shouldInterceptRequest(
                            view: WebView,
                            request: WebResourceRequest
                        ): WebResourceResponse? {
                            return assetLoader.shouldInterceptRequest(request.url)
                        }
                    }

                    webView.loadUrl("https://appassets.androidplatform.net/site/index.html")
            """
        case .remote(let url):
            loading = """
                    webView.webViewClient = WebViewClient()
                    webView.loadUrl("\(url)")
            """
        }

        return """
        package \(config.androidPackage)

        import android.annotation.SuppressLint
        import android.app.Activity
        import android.os.Bundle
        import android.webkit.WebResourceRequest
        import android.webkit.WebResourceResponse
        import android.webkit.WebView
        import android.webkit.WebViewClient
        import androidx.webkit.WebViewAssetLoader

        class MainActivity : Activity() {

            @SuppressLint("SetJavaScriptEnabled")
            override fun onCreate(savedInstanceState: Bundle?) {
                super.onCreate(savedInstanceState)

                val webView = WebView(this)
                webView.settings.javaScriptEnabled = true
                webView.settings.domStorageEnabled = true

        \(loading)

                setContentView(webView)
            }
        }
        """
    }

    private func readme(config: PackagingConfig, nextSteps: String) -> String {
        """
        # \(config.appName) — Android shell

        A native Android application generated by `score package android`.
        It hosts your Score app inside a system WebView.

        ## Building

        \(nextSteps)

        ## Updating the bundled site

        Re-run `score build` in your Score project, then re-run
        `score package android` to refresh `app/src/main/assets/site/`.
        """
    }
}
