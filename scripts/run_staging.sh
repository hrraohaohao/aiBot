#!/bin/bash
flutter run --dart-define=API_BASE_URL=https://api-staging.example.com --dart-define=ENVIRONMENT_NAME=预发环境 "$@" 