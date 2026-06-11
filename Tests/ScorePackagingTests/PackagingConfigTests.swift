import Foundation
import Testing
@testable import ScorePackaging

@Suite("PackagingConfig")
struct PackagingConfigTests {

    @Test("derives a default identifier from the app name")
    func defaultIdentifier() throws {
        let config = try PackagingConfig(appName: "My App", source: .remote(url: "https://example.com"))
        #expect(config.identifier == "com.example.myapp")
    }

    @Test("derives executable and binary names")
    func derivedNames() throws {
        let config = try PackagingConfig(appName: "my cool-app", source: .remote(url: "https://example.com"))
        #expect(config.executableName == "MyCoolApp")
        #expect(config.binaryName == "mycoolapp")
    }

    @Test("rejects an empty app name")
    func emptyName() {
        #expect(throws: PackagingError.invalidAppName("  ")) {
            _ = try PackagingConfig(appName: "  ", source: .remote(url: "https://example.com"))
        }
    }

    @Test("rejects a single-segment identifier")
    func badIdentifier() {
        #expect(throws: PackagingError.invalidIdentifier("myapp")) {
            _ = try PackagingConfig(
                appName: "MyApp",
                identifier: "myapp",
                source: .remote(url: "https://example.com")
            )
        }
    }

    @Test("rejects a non-http remote URL")
    func badRemoteURL() {
        #expect(throws: PackagingError.invalidRemoteURL("ftp://example.com")) {
            _ = try PackagingConfig(appName: "MyApp", source: .remote(url: "ftp://example.com"))
        }
    }

    @Test("android package replaces invalid characters")
    func androidPackage() throws {
        let config = try PackagingConfig(
            appName: "MyApp",
            identifier: "com.my-org.1app",
            source: .remote(url: "https://example.com")
        )
        #expect(config.androidPackage == "com.my_org._1app")
    }
}
