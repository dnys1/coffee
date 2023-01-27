#!/usr/bin/env bash
set -eo pipefail

if ! command -v lcov &> /dev/null
then
    echo "Installing lcov..."
    brew install lcov
fi

echo "Running unit tests..."
flutter test --coverage --coverage-path=coverage/lcov.base.info

echo "Running integration tests (macOS)..."
flutter test --merge-coverage -d macos integration_test/main_test.dart

echo "Running integration tests (Chrome)..."
chromedriver --port=4444 &
trap "kill $!" EXIT
flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/main_test.dart \
    -d chrome

lcov --list coverage/lcov.info
echo "All tests passed."
