#!/bin/bash

# Run tests with coverage
flutter test --coverage

# Generate HTML report (install lcov if needed)
if ! command -v genhtml &> /dev/null
then
    echo "lcov is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install lcov
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu/Debian
        sudo apt-get install lcov
    else
        # Windows
        echo "Please install lcov manually on Windows or use WSL"
    fi
fi

# Generate HTML report from coverage data
genhtml coverage/lcov.info -o coverage/html

# Open the report
if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage/html/index.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open coverage/html/index.html
else
    # Windows
    start coverage/html/index.html
fi

echo "Coverage report generated at coverage/html/index.html" 