# Score Security Audit

Audit of the Score framework core and its module "plugins" (`ScoreHTTP`,
`ScoreRouter`, `ScoreData`, `ScoreCore`, `ScoreSSG`, `ScoreBuild`,
`ScorePackaging`, `ScoreCLI`). Findings are ordered by severity. Each entry
notes whether a fix is included in this branch.

## Summary

| # | Severity | Area | Issue | Fixed |
|---|----------|------|-------|-------|
| 1 | Critical | ScoreHTTP | Path traversal in static file serving | ✅ |
| 2 | High | ScoreHTTP | HTTP response splitting via response headers (incl. `redirect` Location) | ✅ |
| 3 | High | ScoreHTTP | Unbounded request body buffering (memory-exhaustion DoS) | ✅ |
| 4 | High | ScoreCore | Stored XSS via `javascript:`/`data:` URLs in markdown links | ✅ |
| 5 | Medium | ScoreCore | CSS injection via custom theme tokens (documented invariant not enforced) | ✅ |
| 6 | Medium | ScoreCore | CSS selector injection via custom theme names | ✅ |
| 7 | Medium | ScoreData | SQL identifier / JSON-path interpolation without quoting (defense-in-depth) | ✅ |
| 8 | Medium | ScoreCLI | Unvalidated project/generator name → path & template injection | ✅ |
| 9 | Low | ScoreHTTP | `remoteAddress` trusts spoofable `X-Forwarded-For` | ⚠️ documented |
| 10 | Low | ScorePackaging | `appName` interpolated raw into generated templates | ⚠️ noted |

False positives that were investigated and dismissed are listed at the end.

---

## 1. Path traversal in static file serving — Critical (fixed)

`ScoreHTTP/NIOServer.swift` mapped the request path straight onto the static
directory:

```swift
let rel = urlPath == "/" ? "index.html" : String(urlPath.drop(while: { $0 == "/" }))
let fileURL = URL(fileURLWithPath: staticDir).appendingPathComponent(rel)
```

`URI.path` comes from `URLComponents`, which **percent-decodes** the path, so a
request for `/..%2f..%2f..%2fetc%2fpasswd` arrives here as literal `../../../etc/passwd`.
Neither `appendingPathComponent` nor `Data(contentsOf:)` resolves `..`, so the
server would happily read and return arbitrary files outside the static root.

**Fix:** added `resolveStaticFile(path:in:)` which rejects `..` segments and
absolute paths, canonicalises both the root and the candidate with
`standardizedFileURL.resolvingSymlinksInPath()`, and requires the resolved file
to remain under the root before serving. `serveStaticFile` now also refuses
directories and non-regular files.

## 2. HTTP response splitting — High (fixed)

Response headers were copied verbatim into the wire response:

```swift
for (name, value) in response.headers { headers.add(name: name, value: value) }
```

A CR/LF in any header name or value — most reachably the `Location` produced by
`Response.redirect(to:)` when the target is user-derived — lets an attacker
smuggle extra headers or split the response (`Set-Cookie`, cache poisoning,
reflected content).

**Fix:** `writeResponse` now drops any header whose name or value contains CR,
LF, or NUL, and `Response.redirect(to:)` returns `400` when the location
contains those bytes.

## 3. Unbounded request body buffering — High (fixed)

`ScoreHTTPHandler` accumulated every `.body` part into a `ByteBuffer` with no
cap, so a single client could stream an arbitrarily large body and exhaust
server memory.

**Fix:** bodies are counted as they arrive; once they exceed 16 MB the buffer is
dropped and the request is answered with `413 Payload Too Large`
(`HTTPStatus.payloadTooLarge` was added).

## 4. Stored XSS via markdown link URLs — High (fixed)

`ScoreCore/Elements/Content/RichText.inlineMarkdown` rendered `[text](url)` by
substituting the captured URL straight into an `href`. HTML-escaping the text
first stops attribute breakout, but not dangerous **schemes**: markdown such as
`[click](javascript:alert(document.cookie))` produced a working
`javascript:` link. Any app rendering user-authored markdown (comments, posts)
was exposed to stored XSS on click.

**Fix:** link substitution now runs through `replaceLinks`/`safeLinkURL`, which
allow only `http`, `https`, `mailto`, `tel`, `ftp`, and relative/anchor URLs;
anything else is replaced with `#`.

## 5. CSS injection via custom theme tokens — Medium (fixed)

`SiteTheme.cssVariables()` emitted custom tokens raw:

```swift
for token in tokens { out += "\(token.name):\(token.value);" }
```

A token value containing `}` could close `:root{ … }` and inject arbitrary
rules. This also contradicted both `AGENTS.md` ("Custom `ThemeToken`s are
sanitised on emission") and an existing test (`ComponentThemeTests.tokenSanitization`)
that asserts the sanitised output — the production code simply never applied it.

**Fix:** token names now go through `cssPropertySanitize` and values through
`cssValueSanitize`, matching the documented guarantee and the test.

## 6. CSS selector injection via custom theme names — Medium (fixed)

Custom theme names were interpolated into a selector unescaped:

```swift
out += "[data-theme=\"\(themeName)\"]{ … }"
```

A name containing `"]{…}` could break out of the attribute selector and inject
rules. **Fix:** theme names are restricted to identifier characters via the new
`cssIdentifierSanitize` before they reach the selector.

## 7. SQL identifier / JSON-path interpolation — Medium (fixed)

`ScoreData` interpolated `R.tableName` into DDL/DML and property names into
`json_extract(data, '$.<name>')`. These names derive from compile-time types and
key paths today, so this is defense-in-depth rather than a live injection, but
the builder offered no safety net if a name ever carried a quote or JSON-path
metacharacter (`'`, `"`, `.`, `[`).

**Fix:** table/index names are emitted through `Record.quotedTableName` /
`quotedIndexName` (double-quoted, internal quotes doubled), and JSON paths are
built with `jsonExtractPath(forKey:)`, which double-quotes the key and escapes
embedded quotes. Value binding was already correctly parameterised and is
unchanged.

## 8. Unvalidated CLI names — Medium (fixed)

`score new <name>` and `score generate <type> <name>` interpolated the name into
a filesystem path and into generated `Package.swift`/Swift source with no
validation, allowing odd paths or broken/injected manifests (self-targeting, but
still a footgun).

**Fix:** added `validateName` (`^[A-Za-z][A-Za-z0-9_-]*$`), called at the top of
both commands.

## 9. `remoteAddress` trusts `X-Forwarded-For` — Low (documented)

`Request.remoteAddress` returns the client-controlled `X-Forwarded-For` /
`X-Real-IP` headers. Anything using it for security decisions (rate limiting,
allow-lists) can be trivially spoofed. Not changed in code to avoid breaking
deployments behind a trusted proxy; callers should only trust these headers when
the proxy is known to set them.

## 10. `appName` in generated templates — Low (noted)

`ScorePackaging` interpolates the developer-supplied `appName` raw into generated
C strings, `.desktop` entries, and manifests. `binaryName`/`executableName` are
safe (strictly alphanumeric), so this is limited to the human-readable name and
is self-targeting, but those templates should escape per-format before launch.

---

## Investigated and dismissed (false positives)

- **"Command injection in Linux/Windows Containerfile via `binaryName`/
  `executableName`."** Both are derived through `lowercasedAlphanumeric` (letters
  and digits only) or letter/number splitting, so they cannot contain shell or
  Dockerfile metacharacters.
- **CSS value `url()` exfiltration through `cssValueSanitize`.** Because `;`,
  `{`, `}` are stripped, a token value cannot open a new declaration or rule;
  it remains a single property value. Worth tightening further pre-launch, but
  not a breakout.
- **`ThemeSelector` inline-JS injection via `id`.** `id` is HTML-escaped, and
  `<script>` content is not entity-decoded, so an escaped quote cannot break out
  of the JS string and `</script>` cannot close the tag. Safe as written.
