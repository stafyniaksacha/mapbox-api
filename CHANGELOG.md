## Unreleased

* Navigation: parse documented maneuver/instruction values that were missing
  or misspelled (`slight right`, `sharp left`, `continue`, `end of road`,
  `new name`, `on ramp`, `rotary`, …) _([emmett-deen](https://github.com/stafyniaksacha/mapbox-api/pull/9))_
* Navigation: new enum members `NavigationManeuverType.UPDOWN/UTURN/CLOSE/FLAG`
  and `NavigationInstructionType.CONTINUE/END_OF_ROAD/NEW_NAME/NOTIFICATION/ON_RAMP/ROTARY/UPDOWN/UTURN/CLOSE/FLAG`.
  New members are appended, so existing `.index` values are unchanged.
  Exhaustive `switch` statements on these enums need a new case or a default.
* Fix (unreleased regression): restore `NavigationManeuverType.ROUNDABOUT_TURN`,
  `EXIT_ROUNDABOUT` and `EXIT_ROTARY` and their parsing
* Fix (unreleased regression): the library no longer prints unknown values to stdout
* Tooling: test suite (URL goldens, response fixtures, enum compatibility),
  GitHub Actions CI, public API check against 1.1.0, Dependabot
* Breaking (dependencies only): minimum Dart SDK is now 3.4. The previous
  `>=2.12.0` constraint was not resolvable below Dart 3.2 anyway, because
  `http ^1.2.0` requires it. No public API change.
* Pub metadata: `repository`, `issue_tracker`, `topics`
* Internal: removed empty stub files under `lib/src/maps` and
  `lib/src/accounts`; renamed `lib/src/navigation/isochrome.dart` to
  `isochrone.dart`. Only affects code importing `src/` files directly,
  which is not supported; import `package:mapbox_api/mapbox_api.dart`.
* Internal: line endings normalized to LF (`.gitattributes`)
* Internal: request URLs are built with shared helpers instead of duplicated
  `switch` blocks. Request URLs are byte-for-byte unchanged (pinned by tests).

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