#!/bin/bash
flutter build ios --dart-define=API_BASE_URL=https://api-dev.example.com --dart-define=ENVIRONMENT_NAME=测试环境 --no-codesign 