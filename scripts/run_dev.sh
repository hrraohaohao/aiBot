#!/bin/bash
flutter run --dart-define=API_BASE_URL=https://api-dev.example.com --dart-define=ENVIRONMENT_NAME=测试环境 "$@" 