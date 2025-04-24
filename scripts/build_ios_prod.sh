#!/bin/bash
flutter build ios --dart-define=API_BASE_URL=https://api.example.com --dart-define=ENVIRONMENT_NAME=生产环境 --no-codesign 