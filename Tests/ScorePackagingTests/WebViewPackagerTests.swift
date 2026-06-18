import Foundation
import Testing

@testable import ScorePackaging

@Suite("WebViewPackagers")
struct WebViewPackagerTests {

    private func tempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("score-packaging-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func remoteConfig() throws -> PackagingConfig {
        try PackagingConfig(
            appName: "Demo App",
            source: .remote(url: "https://demo.example.com")
        )
    }

    private func contents(of file: String, in directory: URL) throws -> String {
        try String(contentsOf: directory.appendingPathComponent(file), encoding: .utf8)
    }

    @Test("windows packager generates a buildable WebView2 project")
    func windows() throws {
        let output = try tempDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let result = try WindowsPackager().package(config: try remoteConfig(), into: output)
        #expect(result.filesWritten.contains("DemoApp.csproj"))
        #expect(result.filesWritten.contains("MainForm.cs"))
        #expect(result.filesWritten.contains("Containerfile"))
        #expect(result.filesWritten.contains("Makefile"))

        let csproj = try contents(of: "DemoApp.csproj", in: output)
        #expect(csproj.contains("Microsoft.Web.WebView2"))
        #expect(csproj.contains("net8.0-windows"))

        let form = try contents(of: "MainForm.cs", in: output)
        #expect(form.contains("Navigate(\"https://demo.example.com\")"))
        #expect(!form.contains("SetVirtualHostNameToFolderMapping"))

        let containerfile = try contents(of: "Containerfile", in: output)
        #expect(containerfile.contains("EnableWindowsTargeting=true"))

        let makefile = try contents(of: "Makefile", in: output)
        #expect(makefile.contains("CONTAINER ?= container"))
        #expect(makefile.contains("container-build:"))
    }

    @Test("windows packager bundles the static export via virtual host")
    func windowsStatic() throws {
        let output = try tempDirectory()
        let export = try tempDirectory()
        defer {
            try? FileManager.default.removeItem(at: output)
            try? FileManager.default.removeItem(at: export)
        }
        try "<html></html>".write(
            to: export.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)

        let config = try PackagingConfig(
            appName: "Demo",
            source: .staticExport(path: export.path)
        )
        let result = try WindowsPackager().package(config: config, into: output)
        #expect(result.filesWritten.contains("wwwroot/"))

        let form = try contents(of: "MainForm.cs", in: output)
        #expect(form.contains("SetVirtualHostNameToFolderMapping"))
        let copied = output.appendingPathComponent("wwwroot/index.html")
        #expect(FileManager.default.fileExists(atPath: copied.path))
    }

    @Test("missing static export throws a helpful error")
    func missingExport() throws {
        let output = try tempDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let config = try PackagingConfig(
            appName: "Demo",
            source: .staticExport(path: "/nonexistent/score-build")
        )
        #expect(throws: PackagingError.staticExportMissing("/nonexistent/score-build")) {
            _ = try WindowsPackager().package(config: config, into: output)
        }
    }

    @Test("android packager generates a Gradle project with WebViewAssetLoader")
    func android() throws {
        let output = try tempDirectory()
        let export = try tempDirectory()
        defer {
            try? FileManager.default.removeItem(at: output)
            try? FileManager.default.removeItem(at: export)
        }
        try "<html></html>".write(
            to: export.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)

        let config = try PackagingConfig(
            appName: "Demo App",
            identifier: "com.demo.app",
            source: .staticExport(path: export.path)
        )
        let result = try AndroidPackager().package(config: config, into: output)
        #expect(result.filesWritten.contains("app/build.gradle.kts"))
        #expect(result.filesWritten.contains("app/src/main/java/com/demo/app/MainActivity.kt"))
        #expect(result.filesWritten.contains("app/src/main/assets/site/"))

        let activity = try contents(of: "app/src/main/java/com/demo/app/MainActivity.kt", in: output)
        #expect(activity.contains("package com.demo.app"))
        #expect(activity.contains("WebViewAssetLoader"))
        #expect(activity.contains("https://appassets.androidplatform.net/site/index.html"))
    }

    @Test("linux packager generates a WebKitGTK project")
    func linux() throws {
        let output = try tempDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let result = try LinuxPackager().package(config: try remoteConfig(), into: output)
        #expect(result.filesWritten.contains("main.c"))
        #expect(result.filesWritten.contains("Makefile"))
        #expect(result.filesWritten.contains("Containerfile"))
        #expect(result.filesWritten.contains("demoapp.desktop"))

        let main = try contents(of: "main.c", in: output)
        #expect(main.contains("webkit_web_view_load_uri(web_view, \"https://demo.example.com\")"))
        #expect(main.contains("#define APP_ID \"com.example.demoapp\""))

        let makefile = try contents(of: "Makefile", in: output)
        #expect(makefile.contains("webkitgtk-6.0"))
        #expect(makefile.contains("gtk4"))
        #expect(makefile.contains("container-build:"))

        let containerfile = try contents(of: "Containerfile", in: output)
        #expect(containerfile.contains("libwebkitgtk-6.0-dev"))
    }

    @Test("container tool is configurable in generated Makefiles")
    func containerTool() throws {
        let output = try tempDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let config = try PackagingConfig(
            appName: "Demo App",
            source: .remote(url: "https://demo.example.com"),
            containerTool: "docker"
        )
        _ = try LinuxPackager().package(config: config, into: output)
        let makefile = try contents(of: "Makefile", in: output)
        #expect(makefile.contains("CONTAINER ?= docker"))
    }
}
