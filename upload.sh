#!/bin/zsh
# Usage: ./upload.sh <file>   Copies a public image/video into this repo, commits, pushes, prints its permanent URL.
set -e
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
src="$1"; [[ -f "$src" ]] || { echo "No such file: $src" >&2; exit 1; }
size=$(stat -f%z "$src"); (( size < 95000000 )) || { echo "Too big for GitHub (100 MB cap): $size bytes" >&2; exit 1; }
cd "${0:A:h}"
ext="${src:e:l}"
case "$ext" in png|jpg|jpeg|gif|webp) dir=images;; mp4|mov|webm) dir=videos;; *) echo "Not an image or video: $src" >&2; exit 1;; esac
dest="$dir/$(date +%Y/%m)/${src:t}"
if [[ -e "$dest" ]]; then dest="${dest:r}-$(date +%H%M%S).$ext"; fi
mkdir -p "${dest:h}"; cp "$src" "$dest"
git pull -q --rebase origin main 2>/dev/null || true
git add "$dest" && git commit -qm "Add $dest" && git push -q origin HEAD:main
echo "https://raw.githubusercontent.com/mandalarules/post-media/main/$dest"
echo "https://mandalarules.github.io/post-media/$dest  (Pages, live ~1 min after push; use this for video)"
