#!/usr/bin/env bash
# Build labels.pdf from spices.toml.
#
#   ./build.sh                  all labels
#   ./build.sh paprika cumin    only labels whose name contains one of these words
#   PNG=1 ./build.sh            also render preview/page-N.png
set -euo pipefail
cd "$(dirname "$0")"

export TYPST_FONT_PATHS="${TYPST_FONT_PATHS:-$HOME/.nix-profile/share/fonts:/run/current-system/sw/share/fonts}"
if command -v typst >/dev/null 2>&1; then
  typst=(typst)
else
  typst=(nix shell nixpkgs#typst -c typst)
fi

args=()
if [[ $# -gt 0 ]]; then args+=(--input "only=$(IFS=,; echo "$*")"); fi

"${typst[@]}" compile "${args[@]}" labels.typ labels.pdf
echo "wrote labels.pdf"

if [[ -n ${PNG:-} ]]; then
  mkdir -p preview && rm -f preview/page-*.png
  "${typst[@]}" compile "${args[@]}" --format png --ppi 120 labels.typ 'preview/page-{p}.png'
  echo "wrote preview/page-*.png"
fi
