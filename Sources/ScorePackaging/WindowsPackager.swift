import Foundation

/// Generates a Windows desktop shell that hosts the Score app in a
/// WebView2 control (the Chromium-based WebView built into Windows 10/11).
///
/// The generated project is a C# WinForms application targeting .NET 8 and
/// builds with `dotnet build` — no Visual Studio project conversion needed.
/// Static exports are served through WebView2's virtual host mapping so
/// absolute paths (`/styles.css`) resolve exactly as they do on the web.
public struct WindowsPackager: WebViewPackager {
    public let platform: PackagingPlatform = .windows

    /// Virtual host the bundled static export is mapped to.
    static let virtualHost = "app.score"

    public init() {}

    public func package(config: PackagingConfig, into outputDirectory: URL) throws -> PackagedApp {
        var writer = try ProjectWriter(root: outputDirectory)
        let name = config.executableName

        try writer.write(csproj(config: config), to: "\(name).csproj")
        try writer.write(programCS(config: config), to: "Program.cs")
        try writer.write(mainFormCS(config: config), to: "MainForm.cs")
        try writer.write(containerfile(config: config), to: "Containerfile")
        try writer.write(makefile(config: config), to: "Makefile")

        if case .staticExport(let path) = config.source {
            try writer.copyStaticExport(from: path, to: "wwwroot")
        }

        let nextSteps = """
        Build on Windows (requires the .NET 8 SDK and the WebView2 Evergreen Runtime):
          cd \(outputDirectory.path)
          dotnet run

        Or cross-compile from any host with a container tool:
          make container-build                       # uses \(config.containerTool)
          make container-build CONTAINER=container   # apple/container
        Artifacts land in dist/.
        """
        try writer.write(readme(config: config, nextSteps: nextSteps), to: "README.md")

        return PackagedApp(
            platform: .windows,
            outputDirectory: outputDirectory,
            filesWritten: writer.written,
            nextSteps: nextSteps
        )
    }

    // MARK: - Templates

    private func csproj(config: PackagingConfig) -> String {
        let wwwrootItem: String
        if case .staticExport = config.source {
            wwwrootItem = """

              <ItemGroup>
                <Content Include="wwwroot\\**\\*" CopyToOutputDirectory="PreserveNewest" />
              </ItemGroup>
            """
        } else {
            wwwrootItem = ""
        }
        return """
        <Project Sdk="Microsoft.NET.Sdk">

          <PropertyGroup>
            <OutputType>WinExe</OutputType>
            <TargetFramework>net8.0-windows</TargetFramework>
            <UseWindowsForms>true</UseWindowsForms>
            <Nullable>enable</Nullable>
            <ImplicitUsings>enable</ImplicitUsings>
            <AssemblyName>\(config.executableName)</AssemblyName>
            <Version>\(config.version)</Version>
          </PropertyGroup>

          <ItemGroup>
            <PackageReference Include="Microsoft.Web.WebView2" Version="1.0.2592.51" />
          </ItemGroup>
        \(wwwrootItem)
        </Project>
        """
    }

    private func programCS(config: PackagingConfig) -> String {
        """
        namespace \(config.executableName);

        internal static class Program
        {
            [STAThread]
            static void Main()
            {
                ApplicationConfiguration.Initialize();
                Application.Run(new MainForm());
            }
        }
        """
    }

    private func mainFormCS(config: PackagingConfig) -> String {
        let navigation: String
        switch config.source {
        case .staticExport:
            navigation = """
                        var wwwroot = Path.Combine(AppContext.BaseDirectory, "wwwroot");
                        webView.CoreWebView2.SetVirtualHostNameToFolderMapping(
                            "\(Self.virtualHost)",
                            wwwroot,
                            CoreWebView2HostResourceAccessKind.Allow);
                        webView.CoreWebView2.Navigate("https://\(Self.virtualHost)/index.html");
            """
        case .remote(let url):
            navigation = """
                        webView.CoreWebView2.Navigate("\(url)");
            """
        }

        return """
        using Microsoft.Web.WebView2.Core;
        using Microsoft.Web.WebView2.WinForms;

        namespace \(config.executableName);

        public class MainForm : Form
        {
            private readonly WebView2 webView = new();

            public MainForm()
            {
                Text = "\(config.appName)";
                ClientSize = new Size(\(config.windowWidth), \(config.windowHeight));
                webView.Dock = DockStyle.Fill;
                Controls.Add(webView);

                Load += async (_, _) =>
                {
                    await webView.EnsureCoreWebView2Async();
        \(navigation)
                };
            }
        }
        """
    }

    private func containerfile(config: PackagingConfig) -> String {
        """
        # Cross-compiles the Windows WebView2 shell from any container host.
        # The produced binaries run on Windows only; the container is just the builder.
        FROM mcr.microsoft.com/dotnet/sdk:8.0
        WORKDIR /src
        COPY . .
        RUN dotnet publish \(config.executableName).csproj -c Release -r win-x64 \\
            --self-contained /p:EnableWindowsTargeting=true -o /out
        CMD ["cp", "-r", "/out/.", "/dist/"]
        """
    }

    private func makefile(config: PackagingConfig) -> String {
        """
        APP := \(config.binaryName)
        CONTAINER ?= \(config.containerTool)

        run: ## Build and run on Windows
        \tdotnet run

        publish: ## Self-contained Windows build (run on Windows)
        \tdotnet publish -c Release -r win-x64 --self-contained

        container-build: ## Cross-compile via $(CONTAINER) into dist/
        \t$(CONTAINER) build -t $(APP)-windows-build -f Containerfile .
        \tmkdir -p dist
        \t$(CONTAINER) run --rm -v "$$(pwd)/dist:/dist" $(APP)-windows-build

        clean:
        \trm -rf bin obj dist

        .PHONY: run publish container-build clean
        """
    }

    private func readme(config: PackagingConfig, nextSteps: String) -> String {
        """
        # \(config.appName) — Windows shell

        A native Windows application generated by `score package windows`.
        It hosts your Score app inside a WebView2 control.

        ## Building

        \(nextSteps)

        ## Container builds

        `make container-build` builds the app inside the official .NET 8 SDK
        image and copies the self-contained `win-x64` output to `dist/`. The
        `CONTAINER` variable selects the tool — `docker` (default), `container`
        (apple/container), or `podman` all work, as they share the same
        `build`/`run` CLI for the operations used here. The resulting
        executable requires Windows with the WebView2 Evergreen Runtime.

        ## Updating the bundled site

        Re-run `score build` in your Score project, then re-run
        `score package windows` to refresh the `wwwroot/` contents.
        """
    }
}
