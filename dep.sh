#!/usr/bin/env bash
set -euo pipefail

org="${1:-}"
[[ -z "$org" ]] && { echo "Usage: $0 <github-org>"; exit 1; }

need() { command -v "$1" >/dev/null || { echo "Missing $1"; exit 1; }; }
need gh; need jq; need curl; need confused

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT
list_tsv="$tmpdir/repo_paths.tsv"; >"$list_tsv"

echo "[*] Enumerating repos for $org ..."
repos=$(gh repo list "$org" --limit 1000 --json nameWithOwner,defaultBranchRef --jq '.[] | [.nameWithOwner, .defaultBranchRef.name] | @tsv')

while IFS=$'\t' read -r repo defbranch; do
  [[ -z "$defbranch" || "$defbranch" == "null" ]] && defbranch="main"

  echo "  -> Scanning $repo ($defbranch)"

  tree=$(gh api "repos/$repo/git/trees/$defbranch?recursive=1" --jq '.tree[] | select(.type=="blob") | .path' || true)

  while IFS= read -r path; do
    if [[ "$path" =~ package\.json$ ]]; then
      echo -e "$repo\t$defbranch\t$path" >> "$list_tsv"
    fi
  done <<<"$tree"
done <<<"$repos"

if [[ ! -s "$list_tsv" ]]; then
  echo "[!] No package.json files found."
  exit 0
fi

echo "[*] Found $(wc -l < "$list_tsv") package.json files."

echo
echo "==== RESULTS ===="
echo -e "STATUS\trepo\tpath\traw_url"
echo "==============="

while IFS=$'\t' read -r repo branch path; do
  raw="https://raw.githubusercontent.com/$repo/$branch/$path"
  local_pkg="$tmpdir/$(basename $repo)-$(basename $path)"
  if ! curl -fsSL "$raw" -o "$local_pkg"; then
    echo -e "ERROR\t$repo\t$path\t$raw"
    continue
  fi

  out="$tmpdir/out.txt"
  if ! confused -l npm "$local_pkg" >"$out" 2>&1; then :; fi

  if grep -q "Issues found" "$out"; then
    echo -e "POTENTIAL_DEP_CONFUSION\t$repo\t$path\t$raw"
  else
    echo -e "PUBLICLY_ACCESSIBLE\t$repo\t$path\t$raw"
  fi
done < "$list_tsv
