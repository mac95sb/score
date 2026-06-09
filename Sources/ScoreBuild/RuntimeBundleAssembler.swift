import Foundation

/// Feature flags that control which JS runtime modules are included in the
/// output bundle.
///
/// Score emits 0 KB of JavaScript for purely static pages. Modules are
/// included only when the corresponding feature is used.
public struct FeatureFlags: Sendable, Equatable {
    /// Reactive `@State` / `@Binding` signals shim.
    public var signals: Bool
    /// `@Action` server-action bridge (fetch POST to action endpoint).
    public var actionBridge: Bool
    /// Typed `fetch` client for `@Action` HTTP calls.
    public var fetchClient: Bool
    /// WebSocket client for `WS()` routes.
    public var webSocket: Bool
    /// `IntersectionObserver` harness for `@State(.localFirst)` lazy loading.
    public var intersectionObserver: Bool
    /// View Transitions API shim for page navigation animations.
    public var viewTransitions: Bool
    /// IndexedDB adapter for `@State(.localFirst)` persistence.
    public var indexedDB: Bool
    /// Yjs-based CRDT engine for offline-first synchronisation.
    public var crdt: Bool
    /// Online/offline connectivity monitor.
    public var connectivity: Bool
    /// Development mode hot-reload via `EventSource`.
    public var devReload: Bool

    public init(
        signals: Bool = false,
        actionBridge: Bool = false,
        fetchClient: Bool = false,
        webSocket: Bool = false,
        intersectionObserver: Bool = false,
        viewTransitions: Bool = false,
        indexedDB: Bool = false,
        crdt: Bool = false,
        connectivity: Bool = false,
        devReload: Bool = false
    ) {
        self.signals = signals
        self.actionBridge = actionBridge
        self.fetchClient = fetchClient
        self.webSocket = webSocket
        self.intersectionObserver = intersectionObserver
        self.viewTransitions = viewTransitions
        self.indexedDB = indexedDB
        self.crdt = crdt
        self.connectivity = connectivity
        self.devReload = devReload
    }

    /// The maximum feature set — all modules enabled.
    public static let full = FeatureFlags(
        signals: true,
        actionBridge: true,
        fetchClient: true,
        webSocket: true,
        intersectionObserver: true,
        viewTransitions: true,
        indexedDB: true,
        crdt: true,
        connectivity: true,
        devReload: false
    )

    /// Development preset — all features plus hot-reload.
    public static let development = FeatureFlags(
        signals: true,
        actionBridge: true,
        fetchClient: true,
        webSocket: true,
        intersectionObserver: true,
        viewTransitions: true,
        indexedDB: true,
        crdt: true,
        connectivity: true,
        devReload: true
    )

    /// No JavaScript output (purely static).
    public static let none = FeatureFlags()

    /// Whether any module is enabled.
    public var isEmpty: Bool { self == .none }
}

/// Assembles the JavaScript runtime bundle by concatenating only the modules
/// required by the active ``FeatureFlags``.
///
/// The assembled bundle is a single IIFE-wrapped ES module that Score injects
/// via a `<script type="module">` tag.
///
/// ```swift
/// let assembler = RuntimeBundleAssembler()
/// let js = assembler.assemble(flags: .full, minify: true)
/// ```
public struct RuntimeBundleAssembler: Sendable {
    public init() {}

    /// Assemble the runtime bundle for the given feature flags.
    ///
    /// - Parameters:
    ///   - flags: Which modules to include.
    ///   - minify: Whether to strip comments and collapse whitespace.
    /// - Returns: The concatenated JavaScript string, or an empty string when
    ///   `flags.isEmpty` is `true`.
    public func assemble(flags: FeatureFlags, minify: Bool = false) -> String {
        guard !flags.isEmpty else { return "" }

        var modules: [String] = []

        if flags.signals        { modules.append(signalsModule) }
        if flags.actionBridge   { modules.append(actionBridgeModule) }
        if flags.fetchClient    { modules.append(fetchClientModule) }
        if flags.webSocket      { modules.append(webSocketModule) }
        if flags.intersectionObserver { modules.append(intersectionObserverModule) }
        if flags.viewTransitions { modules.append(viewTransitionsModule) }
        if flags.indexedDB      { modules.append(indexedDBModule) }
        if flags.crdt           { modules.append(crdtModule) }
        if flags.connectivity   { modules.append(connectivityModule) }
        if flags.devReload      { modules.append(devReloadModule) }

        var source = modules.joined(separator: "\n")
        if minify { source = minifyJS(source) }
        return source
    }

    // MARK: - JS Module Sources

    private var signalsModule: String {
        """
        // Score Signals — reactive @State / @Binding
        (function() {
          'use strict';
          const _subscribers = new WeakMap();
          window.__score_signal = function(initial) {
            let _val = initial;
            const subs = new Set();
            return {
              get value() { return _val; },
              set value(v) {
                if (v === _val) return;
                _val = v;
                subs.forEach(fn => fn(v));
              },
              subscribe(fn) { subs.add(fn); return () => subs.delete(fn); }
            };
          };
          window.__score_effect = function(fn) {
            let cleanup;
            const run = () => { if (cleanup) cleanup(); cleanup = fn(); };
            run();
          };
        })();
        """
    }

    private var actionBridgeModule: String {
        """
        // Score Action Bridge — @Action server-action invocation
        (function() {
          'use strict';
          window.__score_action = async function(endpoint, payload) {
            const res = await fetch(endpoint, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
              body: JSON.stringify(payload)
            });
            if (!res.ok) throw new Error('Action failed: ' + res.status);
            const ct = res.headers.get('content-type') || '';
            return ct.includes('application/json') ? res.json() : res.text();
          };
        })();
        """
    }

    private var fetchClientModule: String {
        """
        // Score Fetch Client — typed HTTP requests
        (function() {
          'use strict';
          window.__score_fetch = async function(method, url, body, headers) {
            const opts = { method, headers: Object.assign({ 'Accept': 'application/json' }, headers) };
            if (body !== undefined) {
              opts.headers['Content-Type'] = 'application/json';
              opts.body = JSON.stringify(body);
            }
            const res = await fetch(url, opts);
            if (!res.ok) {
              const text = await res.text();
              throw Object.assign(new Error(text), { status: res.status });
            }
            const ct = res.headers.get('content-type') || '';
            return ct.includes('application/json') ? res.json() : res.text();
          };
        })();
        """
    }

    private var webSocketModule: String {
        """
        // Score WebSocket Client
        (function() {
          'use strict';
          window.__score_ws = function(url, handlers) {
            const ws = new WebSocket(url);
            ws.addEventListener('open',    e => handlers.onOpen   && handlers.onOpen(e));
            ws.addEventListener('message', e => handlers.onMessage && handlers.onMessage(e.data));
            ws.addEventListener('close',   e => handlers.onClose  && handlers.onClose(e));
            ws.addEventListener('error',   e => handlers.onError  && handlers.onError(e));
            return {
              send(data) { ws.send(typeof data === 'string' ? data : JSON.stringify(data)); },
              close(code, reason) { ws.close(code, reason); },
              get readyState() { return ws.readyState; }
            };
          };
        })();
        """
    }

    private var intersectionObserverModule: String {
        """
        // Score IntersectionObserver Harness — lazy loading triggers
        (function() {
          'use strict';
          window.__score_observe = function(selector, callback, options) {
            const io = new IntersectionObserver((entries) => {
              entries.forEach(entry => {
                if (entry.isIntersecting) callback(entry.target);
              });
            }, options || { rootMargin: '200px' });
            document.querySelectorAll(selector).forEach(el => io.observe(el));
            return () => io.disconnect();
          };
        })();
        """
    }

    private var viewTransitionsModule: String {
        """
        // Score View Transitions shim
        (function() {
          'use strict';
          if (!document.startViewTransition) {
            document.startViewTransition = function(cb) {
              const result = cb ? cb() : Promise.resolve();
              return { ready: Promise.resolve(), finished: Promise.resolve(result), updateCallbackDone: Promise.resolve() };
            };
          }
          document.querySelectorAll('a[data-transition]').forEach(function(a) {
            a.addEventListener('click', function(e) {
              const href = a.getAttribute('href');
              if (!href || href.startsWith('#') || href.startsWith('mailto:')) return;
              e.preventDefault();
              document.startViewTransition(() => { window.location.href = href; });
            });
          });
        })();
        """
    }

    private var indexedDBModule: String {
        """
        // Score IndexedDB Adapter — @State(.localFirst) persistence
        (function() {
          'use strict';
          window.__score_db = {
            _dbs: {},
            open(name, version, stores) {
              return new Promise((resolve, reject) => {
                const req = indexedDB.open(name, version);
                req.onupgradeneeded = e => {
                  const db = e.target.result;
                  stores.forEach(s => {
                    if (!db.objectStoreNames.contains(s)) db.createObjectStore(s, { keyPath: 'id' });
                  });
                };
                req.onsuccess = e => { this._dbs[name] = e.target.result; resolve(e.target.result); };
                req.onerror = e => reject(e.target.error);
              });
            },
            get(dbName, store, key) {
              return new Promise((resolve, reject) => {
                const tx = this._dbs[dbName].transaction(store, 'readonly');
                const req = tx.objectStore(store).get(key);
                req.onsuccess = e => resolve(e.target.result);
                req.onerror = e => reject(e.target.error);
              });
            },
            put(dbName, store, value) {
              return new Promise((resolve, reject) => {
                const tx = this._dbs[dbName].transaction(store, 'readwrite');
                const req = tx.objectStore(store).put(value);
                req.onsuccess = e => resolve(e.target.result);
                req.onerror = e => reject(e.target.error);
              });
            },
            delete(dbName, store, key) {
              return new Promise((resolve, reject) => {
                const tx = this._dbs[dbName].transaction(store, 'readwrite');
                const req = tx.objectStore(store).delete(key);
                req.onsuccess = e => resolve(e.target.result);
                req.onerror = e => reject(e.target.error);
              });
            }
          };
        })();
        """
    }

    private var crdtModule: String {
        """
        // Score CRDT Engine — LWW-Map for offline-first sync
        (function() {
          'use strict';
          // Lightweight Last-Write-Wins Map CRDT
          window.__score_crdt = function(nodeId) {
            const _state = {};   // key → { value, timestamp, nodeId }
            const _listeners = new Map();
            function notify(key, value) {
              (_listeners.get(key) || []).forEach(fn => fn(value));
              (_listeners.get('*') || []).forEach(fn => fn(key, value));
            }
            return {
              set(key, value) {
                const ts = Date.now();
                _state[key] = { value, ts, nodeId };
                notify(key, value);
              },
              get(key) { return _state[key]?.value; },
              merge(remote) {
                for (const [key, entry] of Object.entries(remote)) {
                  const local = _state[key];
                  if (!local || entry.ts > local.ts || (entry.ts === local.ts && entry.nodeId > local.nodeId)) {
                    _state[key] = entry;
                    notify(key, entry.value);
                  }
                }
              },
              snapshot() { return JSON.parse(JSON.stringify(_state)); },
              on(key, fn) {
                if (!_listeners.has(key)) _listeners.set(key, []);
                _listeners.get(key).push(fn);
                return () => { const a = _listeners.get(key); if (a) { const i = a.indexOf(fn); if (i >= 0) a.splice(i, 1); } };
              }
            };
          };
        })();
        """
    }

    private var connectivityModule: String {
        """
        // Score Connectivity Monitor
        (function() {
          'use strict';
          const _signal = window.__score_signal ? window.__score_signal(navigator.onLine ? 'online' : 'offline') : null;
          function update() {
            const state = navigator.onLine ? 'online' : 'offline';
            if (_signal) _signal.value = state;
            document.dispatchEvent(new CustomEvent('score:connectivity', { detail: { state } }));
          }
          window.addEventListener('online', update);
          window.addEventListener('offline', update);
          window.__score_connectivity = _signal;
        })();
        """
    }

    private var devReloadModule: String {
        """
        // Score Dev Hot-Reload (development only)
        (function() {
          'use strict';
          const es = new EventSource('/__score/dev');
          es.addEventListener('reload', function() { location.reload(); });
          es.addEventListener('css-update', function(e) {
            const href = e.data;
            document.querySelectorAll('link[rel=stylesheet]').forEach(function(el) {
              if (el.getAttribute('href') === href) {
                el.setAttribute('href', href + '?t=' + Date.now());
              }
            });
          });
          es.onerror = function() { setTimeout(function() { location.reload(); }, 2000); };
        })();
        """
    }

    // MARK: - Minification

    private func minifyJS(_ js: String) -> String {
        var result = js
        // Strip single-line comments (careful with URLs)
        var lines = result.components(separatedBy: "\n")
        lines = lines.map { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") { return "" }
            return line
        }
        result = lines.joined(separator: "\n")
        // Collapse blank lines
        while result.contains("\n\n") {
            result = result.replacingOccurrences(of: "\n\n", with: "\n")
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
