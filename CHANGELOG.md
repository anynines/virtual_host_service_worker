## 0.4.2

### Security updates

The following findings are resolved in the updated dependency lockfile:

| CVE/GHSA | Actual severity | Exploitability in this service |
|---|---|---|
| [GHSA-5v64-555j-wjxm](https://github.com/advisories/GHSA-5v64-555j-wjxm) | None | Rack 3.2.8 resolves the multipart DoS finding. Rack is transitive through development/test tooling; no multipart parser path found in service code. Deployed bundle not verified. |
| [GHSA-wvg4-6p58-3gh3](https://github.com/advisories/GHSA-wvg4-6p58-3gh3) | None | Rack 3.2.8 resolves the static-header bypass finding. No Rack static-serving path found; Rack is transitive through development/test tooling. Deployed bundle not verified. |
| [GHSA-2j8w-xcrc-x985](https://github.com/advisories/GHSA-2j8w-xcrc-x985) | None | Rack 3.2.8 resolves the invalid Host-header finding. Worker has no Rack request-handling path; Rack is transitive through development/test tooling. Deployed bundle not verified. |
| [GHSA-p8x9-v4hv-2w4g](https://github.com/advisories/GHSA-p8x9-v4hv-2w4g) | None | Rack 3.2.8 resolves the multipart-boundary finding. No HTTP upload or Rack multipart path found; Rack is transitive through development/test tooling. Deployed bundle not verified. |
| [GHSA-9hj4-r449-hfvc](https://github.com/advisories/GHSA-9hj4-r449-hfvc) | None | Worker uses `JSON.parse` for AMQP payloads, not `JSON::ResumableParser`. Target Ruby's default JSON is 2.9.1, below the affected range; locked development JSON is 3.1.0, above the fix. Deployed runtime not verified. |

### Runtime

Ruby updated from 3.1.2 to 3.4.12 in `.ruby-version`, `Gemfile`, `Gemfile.lock`, and `config/environment.rb`.

The following runtime findings are fixed in the target Ruby/default-gem versions:

| CVE/GHSA | Actual severity | Exploitability in this service |
|---|---|---|
| [CVE-2021-33621](https://www.ruby-lang.org/en/news/2022/11/22/http-response-splitting-in-cgi-cve-2021-33621/) | None | CGI 0.4.2 exceeds the fixed version. No CGI request/response path found in the worker. |
| [CVE-2023-28755](https://www.ruby-lang.org/en/news/2023/03/28/redos-in-uri-cve-2023-28755/) | None | Runtime URI 1.0.4 and locked URI 1.1.2 exceed affected versions. No untrusted URI parsing path found in service code. |
| [CVE-2023-36617](https://www.ruby-lang.org/en/news/2023/06/29/redos-in-uri-CVE-2023-36617/) | None | Runtime URI 1.0.4 exceeds the fixed version. No untrusted URI parsing path found in service code. |
| [CVE-2024-27280](https://www.ruby-lang.org/en/news/2024/03/21/buffer-overread-cve-2024-27280/) | None | Ruby 3.4.12 includes StringIO 3.1.2; issue affects Ruby through 3.1.4. No StringIO path found in service code. |
| [CVE-2024-27281](https://www.ruby-lang.org/en/news/2024/03/21/rce-rdoc-cve-2024-27281/) | None | Target RDoc 6.14.0 exceeds the fixed version. Worker does not process RDoc input or load untrusted `.rdoc_options`. |
| [CVE-2024-27282](https://www.ruby-lang.org/en/news/2024/04/23/arbitrary-memory-address-read-regexp-cve-2024-27282/) | None | Ruby 3.4.12 is beyond the affected Ruby versions. No attacker-controlled Regexp search path found. |
| [CVE-2025-27219](https://www.ruby-lang.org/en/news/2025/02/26/security-advisories/) | None | CGI 0.4.2 meets the fixed version. No CGI cookie parsing path found. |
| [CVE-2025-27220](https://www.ruby-lang.org/en/news/2025/02/26/security-advisories/) | None | CGI 0.4.2 meets the fixed version. No `CGI::Util#escapeElement` path found. |
| [CVE-2025-27221](https://www.ruby-lang.org/en/news/2025/02/26/security-advisories/) | None | Runtime URI 1.0.4 meets the fixed version. No untrusted URI joining path found. |
| [CVE-2025-61594](https://www.ruby-lang.org/en/news/2025/10/07/uri-cve-2025-61594/) | None | Runtime URI 1.0.4 meets the fixed version. No URI credential-handling path found in service code. |
| [CVE-2026-27820](https://www.ruby-lang.org/en/news/2026/03/05/buffer-overflow-zlib-cve-2026-27820/) | None | Target zlib 3.2.3 meets the fixed version. No `Zlib::GzipReader` path found. |
| [CVE-2026-41316](https://www.ruby-lang.org/en/news/2026/04/21/erb-cve-2026-41316/) | None | Target ERB 4.0.4.1 meets the fixed version. Worker uses Erubis, not ERB; no untrusted `Marshal.load` path found. |
| [CVE-2025-24294](https://www.ruby-lang.org/en/news/2025/07/08/dos-resolv-cve-2025-24294/) | Unknown | Target Resolv 0.7.2 exceeds the affected range. No direct `Resolv`/`resolv-replace` use found; resolver path through AMQP dependencies and deployed runtime not verified. |
| [CVE-2026-80212](https://www.ruby-lang.org/en/news/2026/08/27/multiple-vulnerabilities-in-resolv/) | Unknown | Target Resolv 0.7.2 is newer than affected 0.7.1. No direct `Resolv`/`resolv-replace` use found; resolver path through AMQP dependencies and deployed runtime not verified. |
| [CVE-2026-80213](https://www.ruby-lang.org/en/news/2026/08/27/multiple-vulnerabilities-in-resolv/) | Unknown | Target Resolv 0.7.2 is newer than affected 0.7.1. No direct `Resolv`/`resolv-replace` use found; resolver path through AMQP dependencies and deployed runtime not verified. |

Not counted as newly fixed:

- Already fixed in the baseline: [CVE-2022-28738](https://www.ruby-lang.org/en/news/2022/04/12/double-free-in-regexp-compilation-cve-2022-28738/) and [CVE-2022-28739](https://www.ruby-lang.org/en/news/2022/04/12/buffer-overrun-in-string-to-float-cve-2022-28739/); Ruby 3.1.2 contains both fixes.
- Not affected in the baseline: [CVE-2023-28756](https://www.ruby-lang.org/en/news/2023/03/30/redos-in-time-cve-2023-28756/); baseline Time gem was 0.2.0, outside the advisory's affected versions.
- Target fix confirmed, baseline applicability not established: [CVE-2026-89078](https://www.cve.org/CVERecord?id=CVE-2026-89078), [CVE-2026-93577](https://www.cve.org/CVERecord?id=CVE-2026-93577), [CVE-2026-97229](https://www.cve.org/CVERecord?id=CVE-2026-97229), and [CVE-2026-110264](https://www.cve.org/CVERecord?id=CVE-2026-110264). Ruby 3.4.12 fixes the underlying Regexp bugs; Ruby's release note does not establish whether Ruby 3.1.2 was affected. No attacker-controlled Regexp compilation path found in repository code.
- Outside the current application lockfile and manifest: REXML findings [CVE-2024-35176](https://www.ruby-lang.org/en/news/2024/05/16/dos-rexml-cve-2024-35176/), [CVE-2024-39908](https://www.ruby-lang.org/en/news/2024/07/16/dos-rexml-cve-2024-39908/), [CVE-2024-41123](https://www.ruby-lang.org/en/news/2024/08/01/dos-rexml-cve-2024-41123/), [CVE-2024-41946](https://www.ruby-lang.org/en/news/2024/08/01/dos-rexml-cve-2024-41946/), [CVE-2024-43398](https://www.ruby-lang.org/en/news/2024/08/22/dos-rexml-cve-2024-43398/), [CVE-2024-49761](https://www.ruby-lang.org/en/news/2024/10/28/redos-rexml-cve-2024-49761/), and [CVE-2025-58767](https://www.ruby-lang.org/en/news/2025/09/18/dos-rexml-cve-2025-58767/); no XML parsing path found. The target Ruby 3.4 series is outside the affected Ruby versions for the final advisory. Deployed gem set not verified.
- Outside the current application lockfile and manifest: net-imap findings [CVE-2025-25186](https://www.ruby-lang.org/en/news/2025/02/10/dos-net-imap-cve-2025-25186/), [CVE-2025-43857](https://www.ruby-lang.org/en/news/2025/04/28/dos-net-imap-cve-2025-43857/), [CVE-2026-42245](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-42246](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-42256](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-42257](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-42258](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-47240](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), [CVE-2026-47241](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/), and [CVE-2026-47242](https://www.ruby-lang.org/en/news/2026/07/16/ruby-3-3-12-released/); no IMAP client path found. Deployed gem set not verified.
- Not affected by the target runtime: [CVE-2026-46727](https://www.ruby-lang.org/en/news/2026/05/20/getaddrinfo-cve-2026-46727/); advisory excludes Ruby 3.4 and earlier.
