## 1.2.0

No public API removals or signature changes. Several fixes change observable
behavior: read **Behavior changes** before upgrading.

### Behavior changes

* **Failures that 1.1.0 silently ignored are now reported in
  `response.error`** (`withError` assigned the error to itself, so it was
  always dropped):
  * HTTP errors with a JSON body and no endpoint-specific code (401 invalid
    token, 403, 422, 429 rate limit, …) → new `MapboxHttpError`
    (`statusCode`, `message`). Endpoint errors (`NavigationNoRouteError`,
    `GeocoderError`, …) still take precedence. If an error body cannot be
    parsed, the `MapboxHttpError` is kept.
  * Parse failures → the original `Error` (was `error == null`).
  * An endpoint without scheme or host, or a JSON body that is not an object
    → new `MapboxRequestError`.

  If you only checked `routes != null` / `features != null`, nothing changes.
  If you checked `error == null`, failures that looked like empty successes
  are now visible.
* **What threw in 1.1.0 still throws**, with the same types: network failures
  (`ClientException`, `SocketException`) and non-JSON bodies such as an HTML
  502 page (`FormatException`). Existing `try/catch` blocks keep working. A
  missing `accessToken` still throws before any request is sent, now as an
  `ArgumentError` (was a null-check `TypeError`).
* **Parameters that were silently ignored are now sent:** Directions
  `excludes` and `continueStraight` (only `true` is sent, since Mapbox's
  default differs per profile), Map Matching `timestamps`.
* **Separators follow the Mapbox docs:** `radiuses` and `waypoint_names` are
  `;`-separated (Directions, Map Matching, Optimization), as are Matrix
  `sources`/`destinations`. Multi-value requests sent with `,` were rejected
  or misread.
* **User text is percent-encoded** (search text, street names, waypoint names,
  language, country). Plain text gives an equivalent request (`,` and spaces
  are now encoded); text with `&`, `#`, `;`,
  `/` or `?` no longer changes the request (`#` used to drop the whole query
  string, including the access token).
* **Matrix:** `null` cells (no route between a pair) parse as
  `double.infinity` instead of failing the whole response (note:
  `jsonEncode` rejects infinity, so convert before serializing); omitting
  `destinations` no longer throws; `NoRoute` maps to `NavigationNoRouteError`;
  unsupported `speed`/`congestion` annotations are dropped instead of sent
  empty.
* **Optimization:** `distributions` separator and `overview=false` (trailing
  space) fixed; unsupported `congestion` annotation dropped.
* **Map Matching:** `null` tracepoints (unmatched points) become an empty
  `NavigationTracepoint` instead of failing the whole response; indexes still
  match the input coordinates.

### Fixes

* Isochrone responses never parsed (geometry coordinates are nested). New
  `NavigationFeatureGeometry.rawCoordinates` holds coordinates of any depth;
  `coordinates` is unchanged and only set for flat (Point) geometries.
* Integer values in responses (`573`, `[2, 48]`) no longer fail parsing.
* Geocoding `routable_points` are read from Mapbox's `{"coordinates": [...]}`
  objects (failed to parse in 1.1.0).
* `NavigationRoute.weightName` / `NavigationMatchRoute.weightName` read from
  `weight_name`, `NavigationIntersection.outIndex` from `out` (were always
  `null`).
* Navigation: parse documented maneuver/instruction values that were missing
  or misspelled (`slight right`, `sharp left`, `continue`, `end of road`,
  `new name`, `on ramp`, `rotary`, …) _([emmett-deen](https://github.com/stafyniaksacha/mapbox-api/pull/9))_
* The library no longer prints unknown values to stdout.

### Known issues

* Batch geocoding with two or more queries: Mapbox returns a JSON array of
  feature collections, which `GeocodingApiResponse` cannot hold. 1.1.0
  silently returned an empty response; 1.2.0 reports a `MapboxRequestError`
  in `error`.
  Single-query batch works.

### Additions

* `MapboxApi(client: ..., timeout: ...)`: optional `http.Client` reused for
  every request, and a per-request timeout (throws `TimeoutException`).
  Defaults keep the 1.1.0 behavior.
* `MapboxHttpError`, `MapboxRequestError` (both extend `Error`; their
  `toString()` never includes the request URL, which carries the token, and
  `MapboxHttpError.toString()` replaces URLs and redacts token-like values in
  the server message; the raw `message` is unchanged).
  Note: a thrown `ClientException` does include the URL and token in its
  `toString()`, as in 1.1.0; avoid logging it as is.
* `NavigationFeatureGeometry.rawCoordinates`.
* `NavigationManeuverType.UPDOWN/UTURN/CLOSE/FLAG` and
  `NavigationInstructionType.CONTINUE/END_OF_ROAD/NEW_NAME/NOTIFICATION/ON_RAMP/ROTARY/UPDOWN/UTURN/CLOSE/FLAG`.
  New members are appended, so existing `.index` values are unchanged.
  Exhaustive `switch` statements on these enums need a new case or a default.

### Dependencies and tooling

* Minimum Dart SDK is now 3.4. The previous `>=2.12.0` constraint was not
  resolvable below Dart 3.2 anyway, because `http ^1.2.0` requires it.
* Pub metadata: `repository`, `issue_tracker`, `topics`.
* Documentation: README rewritten (error handling, token security, client and
  timeout, Flutter guidance); dartdoc on every public type. The
  commented-out `mapbox_gl` example was removed.
* Test suite (URL goldens for every endpoint and enum value, response
  fixtures, enum compatibility), GitHub Actions CI (including a Dart 3.4
  consumer check and a public API check against 1.1.0), Dependabot.
* Internal: request URLs built with shared helpers; empty stub files removed;
  `lib/src/navigation/isochrome.dart` renamed to `isochrone.dart` (only
  affects direct `src/` imports, which are not supported); line endings
  normalized to LF.

## 1.1.0 2024-10-14

* Dependencies: updated `http` package _([KrohnMi](https://github.com/stafyniaksacha/mapbox-api/pull/8))_
* Upgrade max dart sdk to <4.0.0
* Replace `pedantic` with `lints` package

## 1.0.0 2021-05-30

* Breaking: upgrade min dart sdk to >=2.12 (null-safety)

## 0.3.0 2021-03-18

* Dependencies: updated `http` package _([MohsinN](https://github.com/MohsinN))_

## 0.2.3 2020-10-04

* Fix: Added "distance" support for Matrix API _([SaltySpaghetti](https://github.com/SaltySpaghetti))_
* Dependencies: updated `http` package

## 0.2.1 2020-07-12

* Fix: `instruction` in maneuver object (navigation API)
* Fix: updated `weight` datatype from `int` to `double` (navigation API)


## 0.2.0 2020-07-12

* Added `forwardGeocoding` API
* Added `reverseGeocoding` API
* Added `intersection` API
* Added `analysis_options.yml` and `pedantic` (1.9.2)
* Updated `README.md` and `example/` folder

## 0.1.2 2020-07-01

* Updated example folder

## 0.1.1 2020-07-01

* Added example folder

## 0.1.0 2020-07-01

* Initial release