#!/bin/bash
flutter run --dart-define=API_BASE_URL=https://api.example.com --dart-define=ENVIRONMENT_NAME=生产环境 "$@" 