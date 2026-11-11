# mapbox_api — modernization audit & plan

Audit date: 2026-11-11 · Toolchain used: Dart 3.11.1 · Baseline: **published 1.1.0** (pub.dev, 2024-10-14)

## Goal and constraint

Bring the package to current Dart practices **without breaking the public API of 1.1.0**.
Dependency-level breaks (e.g. raising the SDK floor) are acceptable.

"Public API" = everything exported from `package:mapbox_api/mapbox_api.dart`:
class/enum/member names, constructor and method signatures, field types and nullability,
enum members, and observable behavior users may rely on.

---

## 1. Audit

### 1.1 State of the repo

| Item | Finding |
|---|---|
| Size | ~3.7k lines, 3 API families implemented (navigation, search), maps/accounts are empty `// todo` stubs |
| Runtime deps | `http: ^1.2.0` only (README promises http as the sole dependency — keep it that way) |
| Dev deps | `lints: ^5.0.0` (latest 6.1.0) |
| SDK constraint | `'>=2.12.0 <4.0.0'` — **fiction**: `http ^1.2.0` already requires Dart `^3.2.0`, so nobody below 3.2 can resolve this package today |
| `dart analyze` | clean at language 2.12 |
| `dart format` | 1 file not formatted (`lib/src/navigation/matrix.dart`) |
| Tests | **none** |
| CI | **none** (no `.github/workflows`) |
| pub.dev | 150/160 points, ~176 downloads/30d, 26 likes — still used |
| Flutter | pure Dart package (correct). Only "Flutter" content is a commented-out example using the community `mapbox_gl` plugin; the official plugin is now `mapbox_maps_flutter` (3.x) |

Measured modernization delta (scratch copy, `lints ^6`):

| SDK floor | analyzer issues | `dart fix` | formatter |
|---|---|---|---|
| `^3.2.0` | 10 × `use_super_parameters` (all in `navigation/globals.dart`) | fixes all 10 | 1 file changed |
| `^3.8.0` | same 10 | fixes all 10 | **15 files changed** (tall style, language ≥ 3.7) |

→ The lint/format upgrade itself is cheap.

### 1.2 Regression on `master` (unreleased) — fix before anything else

Commits `d146d37` and `de82388` (PR #9, Dec 2024, not yet released) changed `NavigationManeuverType`:

- **Removed** `EXIT_ROTARY`, `EXIT_ROUNDABOUT`, `ROUNDABOUT_TURN` and their parse cases.
  These are **real Mapbox maneuver types** (`exit rotary`, `exit roundabout`, `roundabout turn`).
  Removing them is a source break vs 1.1.0, *and* those maneuvers now parse to `type == null`.
- **Added** `UPDOWN`, `UTURN`, `CLOSE`, `FLAG` — these are not documented Mapbox maneuver types
  (look like modifiers/other fields mixed in). Harmless to keep (additive), but worth a doc check.
- Added `print('Unknown type: …')` / `print('Unknown modifier: …')` in library code (4 places) —
  libraries must not print to stdout.
- Reordered enum members → `.index` values changed (only matters if someone persisted indexes).

Additions to enums are *technically* breaking for users who `switch` exhaustively on them (Dart 3),
but that is the accepted norm for "minor" releases of API-mirroring enums — call it out in the CHANGELOG.

### 1.3 Bugs found in the 1.1.0 implementation

| # | Bug | Where | Impact |
|---|---|---|---|
| B1 | `XxxResponse.withError(Error error) { error = error; }` assigns the parameter to itself — the field is **never set** | all 6 response classes (`directions`, `matrix`, `optimization`, `isochrome`, `map_matching`, `search/globals`) | any caught error returns a response with `error == null` — failures look like empty successes |
| B2 | `on Error catch` only catches `Error` (e.g. `TypeError`). Network failures (`ClientException`, `SocketException`), and `FormatException` from `jsonDecode` (non-JSON body, e.g. HTML 5xx) are **`Exception`s** and escape as thrown futures | every `request`/`batch` | inconsistent error contract: some failures throw, some (should) set `.error` |
| B3 | HTTP status never checked. A 401/403/422/429 returns `{"message": …}` without `code` → `fromJson` sets nothing | every request | invalid token / rate limit = silent empty result |
| B4 | Parameters accepted but never sent: `continueStraight`, `excludes` (Directions), `timestamps` (Map Matching) | `directions.dart`, `map_matching.dart` | users believe tolls/motorways are excluded when they are not |
| B5 | No URL encoding: user strings (`searchText`, `waypointNames`, …) are concatenated raw into the URL | all search + directions | `&`, `#`, `?`, `/`, `;` in a search text corrupt or inject query parameters |
| B6 | `api.accessToken!` evaluated **outside** the `try` | every request | null token throws instead of returning an error |
| B7 | Library `print` calls (see 1.2) | `navigation/globals.dart` | stdout noise in apps — **fixed in Phase 1** |

Found while writing the Phase 0 tests (each one is pinned in `test/` under "known 1.1.0 bugs"):

| # | Bug | Where | Impact |
|---|---|---|---|
| B8 | `destinations!` on a nullable parameter with no default | `matrix.dart` | `matrix.request()` without `destinations` throws |
| B9 | Trailing `;` after `distributions` | `optimization.dart` | malformed parameter |
| B10 | `weightName` read from `json['weightName']`; Mapbox sends `weight_name` | `NavigationRoute`, `NavigationMatchRoute` | always `null` |
| B11 | `outIndex` read from `json['outIndex']`; Mapbox sends `out` | `NavigationIntersection` | always `null` |
| B12 | `List<double>.from(...)` on JSON numbers that may be integers (`0`, `573`) or `null` (unreachable pairs, unmatched tracepoints) | matrix `durations`/`distances`, map matching `tracepoints`, every `location` | throws `TypeError` → swallowed by B1 → whole response empty |
| B13 | `NavigationFeatureGeometry.coordinates` typed `List<double>`; isochrone geometries are always nested | `navigation/globals.dart` | **every real isochrone response parses to `features == null`**. Fix needs a public type change → 2.0, or a new additive field in 1.x |
| B5′ | `#` in user text starts a URL fragment | geocoding | the query string, **including the access token**, is never sent |

pana (CI): 150/160. The 10 missing points come from documentation: only 42 of 390 public API elements (10.8 %)
have dartdoc comments, and pub.dev wants 20 %. Documenting the main entry points (`MapboxApi`, each
`*Api.request`, response classes) fixes it with no code change.

B17 (open): Geocoding and Isochrone map an error body's `message` to `GeocoderError` /
`NavigationError` (1.1.0 behavior kept), which carry no HTTP status, so callers can't detect
429 there. Additive fix: an `int? statusCode` field on those error classes.

B16 (open): v5 batch geocoding with ≥ 2 queries returns a JSON **array** of feature collections;
`GeocodingApiResponse` holds one. Needs an additive API (e.g. `batchAll()` returning
`List<GeocodingApiResponse>`) — Phase 5, or moot if Geocoding v6 replaces it.

Also: line endings are mixed (`lib/src/navigation/*` CRLF, rest LF) — add a `.gitattributes` (`* text=auto eol=lf`) and normalize in one dedicated commit in Phase 2.

### 1.4 Practice gaps (non-bugs)

- No injectable `http.Client`: each call uses the top-level `get()` (new client, no connection reuse,
  no timeout, untestable without network).
- No timeouts / cancellation.
- URLs built by string concatenation with manual `if (i == 0) …; if (i != last) …` loops instead of
  `Uri.https(..., queryParameters)` and `join`.
- Long `switch` blocks mapping enum ↔ API string; Dart 3 enhanced enums can carry the wire value.
- Legacy `switch` statements with `break` (Dart 3 has no fall-through; switch expressions available).
- Empty stub files under `lib/src/maps` and `lib/src/accounts`; file typo `isochrome.dart`.
- No `repository`, `issue_tracker`, `topics` in pubspec; CHANGELOG lacks the unreleased entries.
- Search uses **Geocoding v5**, which Mapbox now labels legacy; **Geocoding v6** is the current API.
- README examples use lat/lon order while Mapbox/GeoJSON use lon/lat (the package swaps internally via
  `LATITUDE=0 / LONGITUDE=1` — fine, but must stay as is).

### 1.5 Security notes

- The access token goes in the query string (Mapbox's only supported mode). Consequences: never log
  request URLs, and since B3/B1 make errors invisible, don't "fix" by logging the full URL.
- Recommend in README: use a **public (`pk.`) token with URL restrictions** in apps; secret (`sk.`)
  tokens must never ship in a client.
- B5 is a (low-severity) parameter injection: an end-user search string can append arbitrary query
  parameters to the request made with your token.
- Supply chain: single runtime dep (`http`, Dart team) — good; add Dependabot for `pub` + Actions,
  pin Actions by SHA, publish from CI with pub.dev automated publishing (OIDC), no long-lived token.

### 1.6 Things deliberately **not** changed (would break the 1.1.0 API) — park for 2.0

| Item | Why it's breaking |
|---|---|
| `SCREAMING_CAPS` enum members & `LATITUDE`/`LONGITUDE` → lowerCamelCase | renames every public identifier (could add aliases, but enums can't have alias members) |
| `Error? error` field type → `Object?` / sealed `MapboxException` | changes field type; it's also why B2 can't be fixed by just catching `Exception` into that field |
| `MapboxApi` fields: mutable, mix of `late` and nullable (`MapMatchingApi?` …) → `final` non-nullable | users may assign them / rely on nullability |
| Class modifiers (`final class`, `base`) | prevents users extending/implementing |
| Typo `NavigationStepMode.CYLCING` | rename = break (can add `CYCLING` and deprecate in 1.x though) |
| Throwing on errors instead of `.error` field | changes contract |
| Exceptions-vs-`.error` unification, Result types | changes contract |
| Default Geocoding v5 → v6 | different response schema |

---

## 2. Plan

Three buckets. Each phase = one PR, mergeable on its own.

### Phase 0 — Safety net (prerequisite, no lib change)

> **Status:** done (PR #11).

Without tests, "non-breaking" is unenforceable.

1. Add `dev_dependencies: test` and a `test/` folder.
2. Intercept HTTP **without changing the API** using `http`'s `runWithClient(() => …, () => MockClient(...))`
   (top-level `get()` honors the zone client; verify at the chosen `http` floor).
3. **URL golden tests** per endpoint: record the exact URL 1.1.0 produces for a representative
   set of parameter combinations. These lock behavior before any refactor (moving to `Uri` builders
   changes encoding — goldens make every change deliberate).
4. **JSON fixture tests**: real Mapbox responses (directions w/ steps+banners+voice, matrix, isochrone,
   optimization, map matching, forward/reverse/batch/intersection, error bodies 401/422/429/NoRoute).
5. **Public API diff gate**: run an API diff of the branch against published 1.1.0
   (e.g. `dart_apitool diff --old pub://mapbox_api/1.1.0 --new .` — verify invocation) in CI.
6. CI (GitHub Actions): `dart pub get` → `format --set-exit-if-changed` → `analyze --fatal-infos`
   → `test`, matrix **{SDK floor, stable}**, plus `pub downgrade` job on the floor and `pana`
   (find the missing 10 pub points). Dependabot for pub + github-actions.

### Phase 1 — Restore master to non-breaking

> **Status:** done (PR #11).

1. Re-add `EXIT_ROTARY`, `EXIT_ROUNDABOUT`, `ROUNDABOUT_TURN` to `NavigationManeuverType` with parse cases.
2. Keep PR #9's additions (additive), but double-check `UPDOWN/UTURN/CLOSE/FLAG` against Mapbox docs.
3. Remove the 4 `print` calls (unknown values → `null`, as in 1.1.0).
4. Fill the CHANGELOG `Unreleased` section.

### Phase 2 — Tooling & metadata (safe)

> **Status:** done, using the recommended defaults: SDK `^3.4.0`, `lints` kept on `^5` (D1). Super
> parameters were applied only where they don't change defaults (`NavigationTracepoint` and
> `NavigationMatchRoute` are kept explicit and pinned by tests). Tall-style reformatting does not
> apply below language 3.7.

1. `environment: sdk: ^3.4.0` (recommended — see decision D1), `http: ^1.2.0` kept as lower bound
   (widest compatibility; `^1.4.0` only if a newer http API is needed).
2. `lints: ^6.0.0` → requires dev SDK ≥ 3.8 for *contributors only*; consumers are unaffected by dev deps.
   **Same PR:** move the CI floor job (`sdk: '3.5.0'`) to ≥ 3.8, since that job must resolve the dev
   deps. Consumer support for 3.4–3.7 is then no longer tested in CI. If that matters, keep `lints ^5`
   until the SDK floor reaches 3.8.
   Optionally stricter rules (`prefer_final_locals`, `unawaited_futures`, `public_member_api_docs` as info).
3. `dart fix --apply` (10 × `use_super_parameters`) — no API change.
4. `dart format` — if the language floor is ≥ 3.7, this is the tall style rewrite of 15 files:
   **its own commit**, add it to `.git-blame-ignore-revs`.
5. pubspec: `repository`, `issue_tracker`, `topics: [mapbox, maps, geocoding, navigation]`.
6. Delete empty `// todo` stubs (never exported → not API). Rename `isochrome.dart` → `isochrone.dart`
   (under `src/`, not API).

### Phase 3 — Internal refactor, behavior-preserving (safe, guarded by goldens)

> **Status:** request side done: helpers in `lib/src/url_helpers.dart` (internal extensions, so the
> enums get no new public member), and goldens for every enum value in every endpoint. Not done on
> purpose: `Uri` builders (they change encoding, so that belongs with B5 in Phase 4), and the
> response-parsing `switch`es (less test coverage; revisit with Phase 4 fixtures).

1. Give enums an internal wire value (Dart 3 enhanced enums: `NavigationProfile.DRIVING('driving')`)
   — adding a field/constructor to an enum is non-breaking — and replace the big `switch`es.
   Keep member names and order.
2. Replace manual join loops with `list.map(...).join(';')`.
3. Build URLs with `Uri.https` / `Uri.replace(queryParameters: …)` **only where goldens stay equal**
   (encoding of user text is covered in Phase 4 as a behavior change).
4. Switch statements → switch expressions where clearer.

### Phase 4 — Behavior-changing bug fixes (non-breaking in API, but **your call** — decision D2)

> **Status:** done for 1.2.0 (D2 = yes; D3 = **keep throwing**: what threw in 1.1.0 still throws
> with the same types, only what 1.1.0 swallowed is reported in `.error`). Fixed: B1–B6, B8–B13, plus B15
> (`;` separators for radiuses / waypoint_names / matrix sources+destinations, found against the
> docs). Choices: matrix `null` cells → `double.infinity`; unmatched tracepoints → empty
> `NavigationTracepoint`; isochrone geometry via additive `rawCoordinates`; `continueStraight` sends
> only `true`.

These change observable behavior (in the direction of correctness). Ship as a minor release with
clear CHANGELOG entries.

1. **B1** `withError`: `this.error = error`. After this, users who only checked `routes != null` are
   unaffected; users checking `error == null` now correctly see failures.
2. **B6** move the token null-check inside `try` → returns `.error` instead of throwing.
3. **B3** non-2xx with a `message` → populate `.error` with a new public `MapboxHttpError extends Error`
   (`statusCode`, `message`) — additive class, fits the existing `Error?` type.
4. **B2** wrap `ClientException` / `FormatException` into an `Error` subclass (`MapboxNetworkError`)
   so the `.error` contract becomes consistent — *or* keep them throwing and document it. (Decision D3.)
5. **B4** actually send `continue_straight`, `exclude`, `timestamps`, with the URL unchanged when
   the user doesn't pass them (`exclude` and `timestamps` default to empty lists, so this is free).
   `continueStraight` is declared `bool continueStraight = false`, so an omitted argument and an
   explicit `false` can't be told apart, and Mapbox's own default differs by profile. Compatible
   option for 1.x: send `continue_straight=true` only when the value is `true`, and document that
   `false` means "Mapbox default". Being able to force `false` needs `bool? continueStraight`
   (default `null`). Callers that pass a `bool` keep compiling; only code that subclasses or
   implements `DirectionsApi`, or stores `request` as a typed function, breaks. Low risk, but it is
   a public signature change → 2.0, or 1.x only if the API check accepts it.
6. **B5** percent-encode user-provided path/query values (`Uri.encodeComponent`). Plain ASCII queries
   produce identical URLs; only strings with reserved chars change (they were broken before).

### Phase 5 — Additive features (optional, non-breaking)

> **Status:** split into three PRs.
> - **5a (done):** `client` + `timeout`, README, dartdoc on every public type.
> - **5b:** newer Directions params incl. EV routing.
> - **5c:** Geocoding v6 as a new API, which also resolves B16.
>
> Dropped from 1.x: `CYCLING` alias, because parsing can't switch values without a behavior break → 2.0.

1. Optional `http.Client? client` and `Duration? timeout` named params on `MapboxApi(...)`
   (additive, defaults keep current behavior). Enables connection reuse and testing.
2. `NavigationStepMode.CYCLING` added, `CYLCING` `@Deprecated`.
3. Geocoding **v6** as a *new* `mapbox.geocodingV6` API object (new response classes; v5 untouched).
4. Newer Directions params (`max_height`, `max_width`, `max_weight`, `depart_at`, `arrive_by`,
   `annotations=maxspeed/closure`, EV routing params `engine=electric`, `ev_*` — relevant for EV use cases).
5. README: token-security section, update Flutter example to `mapbox_maps_flutter` (or keep library-agnostic
   `polyline` example), lon/lat note.

### Release

- Phase 1–4 → **1.2.0** (minor; additive enums + bug fixes, highlighted in CHANGELOG).
- Phase 5 → 1.3.0+.
- Publish via GitHub Actions automated publishing (tag `v*`), not a local token.

### Parked for 2.0 (see 1.6)

lowerCamelCase names, `Object?`/sealed errors or throwing, `final` non-nullable `MapboxApi` fields,
class modifiers, Geocoding v6 as default, removal of deprecated members.

---

## 3. Decisions needed

- **D1 – SDK floor.** `^3.2.0` (honest minimum, excludes nobody) vs `^3.4.0` (allows newest `http` 1.4+,
  still old) vs `^3.7/3.8` (tall formatter, newest language features; excludes Flutter < 3.29).
  Recommendation: **`^3.4.0`**.
- **D2 – Ship the behavior fixes (Phase 4) in 1.x?** Recommendation: **yes**, they fix silent failures.
- **D3 – Network/parse exceptions:** decided: **keep throwing** (status quo), to keep upgrades
  painless; only failures 1.1.0 swallowed go to `.error`.
