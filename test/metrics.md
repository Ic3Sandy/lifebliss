# Test Coverage Metrics

## Current Test Coverage

| Category      | Tests | Features Covered                            |
|---------------|-------|---------------------------------------------|
| Presentation  | 17    | LoadingPage, HomePage                       |
| Domain        | 6     | ColorService                                |
| Integration   | 1     | Full app navigation flow                    |
| **Total**     | 24    |                                             |

## Coverage Targets

For the project, we aim to maintain the following coverage targets:

- Presentation layer: ≥ 85%
- Domain layer: ≥ 90%
- Data layer: ≥ 80%
- Core utilities: ≥ 80%

## How to Run Coverage Report

```bash
# Generate coverage data
flutter test --coverage

# Generate HTML report (if lcov is installed)
genhtml coverage/lcov.info -o coverage/html

# Or use the convenience script
./run_coverage.sh
```

## Areas for Improvement

- Add more tests for WebView JavaScript interactions
- Add tests for data repositories when implemented
- Add more edge case tests for error handling 