import Foundation

/// Generates a Linux desktop shell that hosts the Score app in a
/// WebKitGTK web view.
///
/// The generated project is a single C source file plus a Makefile and a
/// `.desktop` launcher. It targets GTK 4 with WebKitGTK 6.0 (the current
/// API) and builds with `make` using `pkg-config` for flags.
public struct LinuxPackager: WebViewPackager {
    public let platform: PackagingPlatform = .linux

    public init() {}

    public func package(config: PackagingConfig, into outputDirectory: URL) throws -> PackagedApp {
        var writer = try ProjectWriter(root: outputDirectory)
        let binary = config.binaryName

        try writer.write(mainC(config: config), to: "main.c")
        try writer.write(makefile(config: config), to: "Makefile")
        try writer.write(containerfile(config: config), to: "Containerfile")
        try writer.write(desktopEntry(config: config), to: "\(binary).desktop")

        if case .staticExport(let path) = config.source {
            try writer.copyStaticExport(from: path, to: "www")
        }

        let nextSteps = """
        Build natively (requires GTK 4 and WebKitGTK 6.0 development packages —
        on Debian/Ubuntu: sudo apt install libgtk-4-dev libwebkitgtk-6.0-dev):
          cd \(outputDirectory.path)
          make
          ./\(binary)

        Or build in a container (no local GTK toolchain needed):
          make container-build                    # uses \(config.containerTool)
          make container-build CONTAINER=docker   # or podman
        Artifacts land in dist/.
        """
        try writer.write(readme(config: config, nextSteps: nextSteps), to: "README.md")

        return PackagedApp(
            platform: .linux,
            outputDirectory: outputDirectory,
            filesWritten: writer.written,
            nextSteps: nextSteps
        )
    }

    // MARK: - Templates

    private func mainC(config: PackagingConfig) -> String {
        let loading: String
        switch config.source {
        case .staticExport:
            loading = """
                /* Resolve www/index.html relative to the executable's directory so the
                 * app can be launched from anywhere. */
                gchar *exe_path = g_file_read_link("/proc/self/exe", NULL);
                gchar *exe_dir = exe_path != NULL ? g_path_get_dirname(exe_path) : g_get_current_dir();
                gchar *index_path = g_build_filename(exe_dir, "www", "index.html", NULL);
                gchar *uri = g_filename_to_uri(index_path, NULL, NULL);
                webkit_web_view_load_uri(web_view, uri);
                g_free(uri);
                g_free(index_path);
                g_free(exe_dir);
                g_free(exe_path);
            """
        case .remote(let url):
            loading = """
                webkit_web_view_load_uri(web_view, "\(url)");
            """
        }

        return """
        #include <gtk/gtk.h>
        #include <webkit/webkit.h>

        #define APP_ID "\(config.identifier)"
        #define APP_TITLE "\(config.appName)"
        #define WINDOW_WIDTH \(config.windowWidth)
        #define WINDOW_HEIGHT \(config.windowHeight)

        static void activate(GtkApplication *app, gpointer user_data) {
            GtkWidget *window = gtk_application_window_new(app);
            gtk_window_set_title(GTK_WINDOW(window), APP_TITLE);
            gtk_window_set_default_size(GTK_WINDOW(window), WINDOW_WIDTH, WINDOW_HEIGHT);

            WebKitWebView *web_view = WEBKIT_WEB_VIEW(webkit_web_view_new());
            gtk_window_set_child(GTK_WINDOW(window), GTK_WIDGET(web_view));

        \(loading)

            gtk_window_present(GTK_WINDOW(window));
        }

        int main(int argc, char *argv[]) {
            GtkApplication *app = gtk_application_new(APP_ID, G_APPLICATION_DEFAULT_FLAGS);
            g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
            int status = g_application_run(G_APPLICATION(app), argc, argv);
            g_object_unref(app);
            return status;
        }
        """
    }

    private func makefile(config: PackagingConfig) -> String {
        """
        APP := \(config.binaryName)
        CONTAINER ?= \(config.containerTool)
        WEBKIT_PKG ?= webkitgtk-6.0
        CFLAGS += $(shell pkg-config --cflags gtk4 $(WEBKIT_PKG))
        LIBS := $(shell pkg-config --libs gtk4 $(WEBKIT_PKG))

        $(APP): main.c
        \t$(CC) $(CFLAGS) -o $@ $< $(LIBS)

        run: $(APP)
        \t./$(APP)

        container-build: ## Build via $(CONTAINER) into dist/ (no local GTK toolchain needed)
        \t$(CONTAINER) build -t $(APP)-linux-build -f Containerfile .
        \tmkdir -p dist
        \t$(CONTAINER) run --rm -v "$$(pwd)/dist:/dist" $(APP)-linux-build

        clean:
        \trm -f $(APP)
        \trm -rf dist

        .PHONY: run container-build clean
        """
    }

    private func containerfile(config: PackagingConfig) -> String {
        let exportArtifacts: String
        if case .staticExport = config.source {
            exportArtifacts = #"CMD ["sh", "-c", "cp \#(config.binaryName) /dist/ && cp -r www /dist/"]"#
        } else {
            exportArtifacts = #"CMD ["sh", "-c", "cp \#(config.binaryName) /dist/"]"#
        }
        return """
        # Builds the Linux WebKitGTK shell without a local GTK toolchain.
        FROM ubuntu:24.04
        RUN apt-get update && apt-get install -y --no-install-recommends \\
            build-essential pkg-config libgtk-4-dev libwebkitgtk-6.0-dev \\
            && rm -rf /var/lib/apt/lists/*
        WORKDIR /src
        COPY . .
        RUN make \(config.binaryName)
        \(exportArtifacts)
        """
    }

    private func desktopEntry(config: PackagingConfig) -> String {
        """
        [Desktop Entry]
        Type=Application
        Name=\(config.appName)
        Exec=\(config.binaryName)
        Categories=Network;
        Terminal=false
        """
    }

    private func readme(config: PackagingConfig, nextSteps: String) -> String {
        """
        # \(config.appName) — Linux shell

        A native Linux application generated by `score package linux`.
        It hosts your Score app inside a WebKitGTK web view.

        ## Building

        \(nextSteps)

        Note: the project targets the GTK 4 API (webkitgtk-6.0). Distributions
        that only ship the GTK 3-based webkit2gtk-4.x API are not supported by
        this template without porting the window code to GTK 3.

        ## Container builds

        `make container-build` compiles the shell inside an Ubuntu 24.04 image
        with the GTK 4/WebKitGTK toolchain preinstalled and copies the binary
        (plus `www/` when bundling a static export) to `dist/`. The `CONTAINER`
        variable selects the tool — `container` (apple/container, the
        default), `docker`, or `podman` all work, as they share the same
        `build`/`run` CLI for the operations used here. The binary links
        against the image's glibc/GTK, so run it on a comparable distribution
        (Ubuntu 24.04+).

        ## Updating the bundled site

        Re-run `score build` in your Score project, then re-run
        `score package linux` to refresh the `www/` contents.
        """
    }
}
