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

index_file="web/index.html"
index_backup="$(mktemp)"
cp "${index_file}" "${index_backup}"
restore_index() {
  cp "${index_backup}" "${index_file}"
  rm -f "${index_backup}"
}
trap restore_index EXIT

if ! grep -q '\$FLUTTER_BASE_HREF' "${index_file}"; then
  perl -0pi -e 's#<base href="/">#<base href="\$FLUTTER_BASE_HREF">#' "${index_file}"
fi

flutter build web --release --base-href /
