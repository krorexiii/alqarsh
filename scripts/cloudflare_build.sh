#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  export FLUTTER_HOME="${HOME}/flutter"
  if [ ! -d "${FLUTTER_HOME}/bin" ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_HOME}"
  fi
  export PATH="${FLUTTER_HOME}/bin:${PATH}"
fi

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --base-href /
