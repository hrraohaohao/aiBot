#!/bin/bash
flutter build apk --dart-define=API_BASE_URL=https://api.example.com --dart-define=ENVIRONMENT_NAME=生产环境 --split-per-abi 