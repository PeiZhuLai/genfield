#!/usr/bin/env bash
set -euo pipefail

eraList=( "2022preEE" "2022postEE" "2023preBPix" "2023postBPix" )
massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )

DASFILEBASE="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/DAS_Names/sim"

DRY_RUN=1
if [[ "${1:-}" == "--execute" ]]; then
  DRY_RUN=0
fi

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

require_cmd dasgoclient
require_cmd dbs

invalidate_dataset() {
  local ds="$1"
  [[ -n "$ds" ]] || { echo "[error] Empty dataset name" >&2; return 2; }

  echo "== Dataset: $ds"

  # 展開 dataset -> LFN 清單（逐檔 invalidate）
  # 保留錯誤輸出：避免把「查詢失敗」誤判成「沒有檔案」
  local -a lfns=()
  if mapfile -t lfns < <(dasgoclient -query="file dataset=${ds}"); then
    :
  else
    echo "  [warn] DAS query failed for dataset: $ds" >&2
    lfns=()
  fi

  if (( ${#lfns[@]} == 0 )); then
    echo "  [warn] No files found for dataset: $ds" >&2
    return 0
  fi

  local lfn
  for lfn in "${lfns[@]}"; do
    [[ -z "$lfn" ]] && continue
    run dbs invalidate file --logical_file_name "$lfn"
  done
}