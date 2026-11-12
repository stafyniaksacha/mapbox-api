## What

<!-- What does this PR change? -->

## Why

<!-- Why is it needed? Link the issue or plan item (docs/modernization-plan.md). -->

## Regression-test checklist

<!-- Tick each box, or write "n/a" with a reason. -->

- [ ] A failing test was written first, and the fix is in the same commit as its test.
- [ ] Request-URL changes add or update a golden in `test/url_golden_test.dart` + `test/support/url_cases.dart`, with the reason stated (commit and CHANGELOG).
- [ ] Parsing changes add a fixture-based test (`test/fixtures/`).
- [ ] No public API break vs 1.1.0: additive only, enum members appended at the end.
- [ ] The 1.1.0 error contract is kept (what threw still throws, with the same types; what was swallowed goes to `response.error`).
- [ ] Mapbox parameter names, separators and formats were checked against docs.mapbox.com.
- [ ] `CHANGELOG.md` is updated.
- [ ] No request URL or access token is logged.
