#!/bin/bash
flutter build apk --dart-define=API_BASE_URL=https://api-staging.example.com --dart-define=ENVIRONMENT_NAME=预发环境 --split-per-abi 