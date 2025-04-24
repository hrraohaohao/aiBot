#!/bin/bash
flutter build ios --dart-define=API_BASE_URL=https://api-staging.example.com --dart-define=ENVIRONMENT_NAME=预发环境 --no-codesign 