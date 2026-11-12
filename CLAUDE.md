# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`mapbox_api` is a pure-Dart, unofficial SDK for the Mapbox web services. The
version in `pubspec.yaml` is 1.2.0 (merged, not yet published). The published
baseline is **1.1.0**. The hard requirement is **maximum compatibility**: every
change needs a regression test. Audit, phases and open items live in
`docs/modernization-plan.md`.

## Compatibility rules (read first)

- **Public API** = everything exported from `package:mapbox_api/mapbox_api.dart`.
  It must not break compared with published 1.1.0. CI job "public API vs 1.1.0"
  runs `dart-apitool diff --old pub://mapbox_api/1.1.0 --new . --version-check-mode=onlyBreakingChanges`
  (package `dart_apitool`, executable `dart-apitool`).
- **Additive only:** new optional named parameters, new classes and fields, new
  enum members **appended at the end**. Never remove or reorder enum members:
  `test/enum_compat_test.dart` checks every 1.1.0 member keeps its index.
- **Error contract (1.2.0):** what threw in 1.1.0 still throws, with the same types:
  - network exceptions (`ClientException`, `SocketException`) are rethrown unchanged;
  - a non-JSON body throws `FormatException`;
  - a timeout throws `TimeoutException`;
  - a missing access token, or invalid `DirectionsEvOptions`, throws
    `ArgumentError` before any request is sent.
- **Swallowed failures:** what 1.1.0 silently swallowed now goes into `response.error`:
  - `MapboxHttpError(statusCode, message)` for non-2xx responses without an
    endpoint-specific error;
  - `MapboxRequestError` for an invalid endpoint or non-object JSON;
  - otherwise the parse error;
  - on non-2xx, a parse failure keeps the `MapboxHttpError`, and endpoint errors
    (`NavigationNoRouteError`, …) take precedence.
- **Geocoding and Isochrone** keep 1.1.0 behavior: an error body with a
  `message` becomes `GeocoderError` / `NavigationError`, with no status code
  (adding one is plan item B17).
- **Kept until 2.0:** `SCREAMING_CASE` enum and constant names
  (`constant_identifier_names` is disabled in `analysis_options.yaml`), the
  `NavigationStepMode.CYLCING` typo, the `Error? error` field type, mutable and
  nullable `MapboxApi` fields, and `[latitude, longitude]` input order. The
  `LATITUDE`/`LONGITUDE` constants apply to inputs only; responses are `[lon, lat]`.

## Regression-test rules

- **Test first:** write a failing test before the fix; commit the fix with its test.
- **URL goldens:** any request-URL change adds or updates a golden.
  - Cases: `test/support/url_cases.dart`. Base cases first; `_edgeCases()`
    generates one case per enum value per endpoint.
  - Expected URLs: `test/url_golden_test.dart`. Its header comment lists the
    request fixes made in 1.2.0 and intentional 1.1.0 quirks.
  - Edit goldens only deliberately, with the reason in the commit and `CHANGELOG.md`.
- **Parsing:** test against fixtures in `test/fixtures/`, hand-written from
  docs.mapbox.com (not recorded live).
- **Known bugs:** still-open bugs stay pinned in a `known bugs (still open)`
  group (`test/response_parsing_test.dart`) until fixed, e.g. multi-query batch
  geocoding returning a JSON array (plan B16).
- **No-network helper:** `test/support/fake_http.dart`.
  `capture(body, responseBody:, statusCode:, throwOnSend:)` uses
  `http.runWithClient` + `MockClient`, so library code runs unchanged;
  `fixture(name)` reads `test/fixtures/<name>`.
- Other test files: `response_parsing_test.dart`, `review_fixes_test.dart`,
  `client_options_test.dart`, `ev_routing_test.dart`.
- **Check Mapbox facts:** verify every parameter name, separator and format
  against docs.mapbox.com before coding it. Separators: `;` for radiuses,
  waypoint_names, timestamps, bearings, approaches, matrix sources/destinations;
  `,` for annotations, exclude, include and types.

## Commands

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test                                          # 187 tests, no network
dart test test/url_golden_test.dart                # one file
dart test test/url_golden_test.dart --name directions   # tests matching a name
dart doc --dry-run                                 # must report 0 warnings
```

## Architecture

- **Entry point:** `lib/mapbox_api.dart` exports everything.
  `MapboxApi(accessToken, client?, timeout?)` holds one `*Api` per endpoint
  (`directions`, `mapMatching`, `isochrone`, `matrix`, `optimization`,
  `forwardGeocoding`, `reverseGeocoding`, `intersection`). Each `request()`
  builds a URL string, calls `fetchJson`, then parses into a response object.
- **Navigation** (`lib/src/navigation/`): `directions.dart`, `isochrone.dart`,
  `map_matching.dart`, `matrix.dart`, `optimization.dart`, `ev.dart`
  (`DirectionsEvOptions`, EV enums), `globals.dart` (shared enums and response models).
- **Search** (`lib/src/search/`): Geocoding v5 forward, reverse and
  intersection, plus `globals.dart`.
- **Internal helpers (not exported):**
  - `lib/src/url_helpers.dart`: enum-to-wire-value extensions (switch
    expressions), `listParam`, `lonLat`, `encode` (`Uri.encodeComponent` for
    user text), `profilePath`, `mapboxDateTime` (UTC, no milliseconds),
    `numValue`, `evQuery`, `checkEvOptions`.
  - `lib/src/http_helpers.dart`: `fetchJson(api, url)` applies client, timeout
    and the error contract above.
  - `lib/src/json_helpers.dart`: `doubleList`, `matrixRow` (null →
    `double.infinity`), `coordinatesOfAnyDepth` (typed nested lists).
- **Errors:** `lib/src/errors.dart` holds `MapboxHttpError` and
  `MapboxRequestError`. Their `toString()` never includes the request URL or
  token (URLs become `<url>`; `access_token=`/`pk.`/`sk.` values are redacted).
  The raw `message` and `cause` fields are not sanitized.
- **Deliberate quirks:** Matrix sends only duration/distance annotations;
  Optimization only duration/distance/speed; Map Matching only the original four
  (duration, distance, speed, congestion); Directions sends `continueStraight`
  only when true.

## Tooling and conventions

- Dart `^3.4.0`. `http: ^1.2.0` is the **only** runtime dependency; keep it so.
  Dev deps: `lints ^5`, `test ^1.25`. `lints` 6 needs Dart 3.8, so it is not
  adopted and Dependabot ignores it.
- CI (`.github/workflows/ci.yaml`, actions pinned by SHA):
  - tests + `analyze --fatal-infos` on Dart 3.5.0 (with `pub downgrade http`)
    and on stable; format check on stable;
  - consumer package on Dart 3.4.0 with upgrade and downgrade (checks the SDK floor);
  - the public API diff; `pana` (informational).
- Every public type has dartdoc.
- LF line endings (`.gitattributes`); `.git-blame-ignore-revs` lists the
  normalization commit.
- PRs use merge commits and the template in `.github/pull_request_template.md`.
  Stacked PRs use the `gh stack` extension, always non-interactively:
  `gh stack view --json`, `gh stack submit --auto --open`,
  `gh stack merge --yes --merge`. CodeRabbit reviews every PR.
- On the maintainer's machine `cp`, `mv` and `rm` prompt before overwriting:
  in scripts use `/bin/cp`, `/bin/mv`, `/bin/rm`.

## Security

- Mapbox only accepts the token as a query parameter, so **never log request URLs**.
- Token advice: restrict browser tokens to your URLs; native mobile apps need a
  separate public token with **no** URL restrictions and minimal scopes. Never
  ship `sk.` tokens.
- EV station data and provider names come from a third party: validate them
  before acting on them.

## Open items

See `docs/modernization-plan.md` rather than duplicating it: B16 (multi-query
batch geocoding), B17 (status code on legacy errors), Phase 5c (Geocoding v6 as
a new API), the "Parked for 2.0" list, and publishing 1.2.0 via pub.dev
automated publishing from CI (not set up yet).
