#!/bin/bash

# 使用 CRAB 在 T2_CN_Beijing 大量生產私有 MC。
# 前置：
#   1. 已跑過 1_gen_fragment.sh 和 3_prepareConfig.sh，產生各 mass / fraction 的 cfg。
#   2. 已在 ./crab/crabConfig_template.py 寫好共用 CRAB config (Python)，讀取 ERA/MASS/FRACTION 等環境變數。
#   3. 在 UI 節點上先執行: voms-proxy-init -voms cms -rfc

set -e

export X509_USER_PROXY=${X509_USER_PROXY:-/tmp/x509up_u$(id -u)}
voms-proxy-info -exists -hours 1 || { echo "Proxy invalid or missing"; exit 1; }

# 同一支 script 同時支援四個 era 的 SIM
# eraList=( "2022preEE" "2022postEE" "2023preBPix" "2023postBPix" )
eraList=( "2022preEE" "2022postEE" )
# eraList=( "2023preBPix" "2023postBPix" )

massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )
fractions=( {1..10} )

CRAB_TMPL_DIR="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/crab"
CRAB_TMPL="${CRAB_TMPL_DIR}/crabConfig_sim_template.py"

if [ ! -f "${CRAB_TMPL}" ]; then
    echo "Missing CRAB template: ${CRAB_TMPL}"
    exit 1
fi

# 供 template 使用的共通路徑（對應 3_prepareConfig_*.sh）
export CFG_BASE_DIR_12414="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_12_4_14_patch3/src"
export CFG_BASE_DIR_13013="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_13_0_13/src"
export CFG_BASE_DIR_13023="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_13_0_23/src"
# 注意：這裡是共同母目錄，實際輸出目錄由各 step 的 cfg/CRAB 決定，例如：
#   AOD     : ${OUT_BASE_DIR}/HZaTo2l2g/AOD/M${MASS}/${ERA}/...
#   MiniAOD : ${OUT_BASE_DIR}/HZaTo2l2g/MINIAOD/M${MASS}/${ERA}/...
#   NanoAOD : ${OUT_BASE_DIR}/HZaTo2l2g/NANOAOD/M${MASS}/${ERA}/...
export OUT_BASE_DIR="/eos/home-p/pelai/HZa/private_mc/signal/run3"

for era in "${eraList[@]}"; do
  # 根據 ERA 設定與 3_prepareConfig_*.sh 對應的 alias / 年份標籤與 CMSSW base
  case "${era}" in
    2022preEE)
      export ERA_ALIAS="Run3Summer22_2022preEE"
      export YEAR_TAG="2022"
      export CFG_BASE_DIR="${CFG_BASE_DIR_12414}"
      ;;
    2022postEE)
      export ERA_ALIAS="Run3Summer22_2022postEE"
      export YEAR_TAG="2022"
      export CFG_BASE_DIR="${CFG_BASE_DIR_12414}"
      ;;
    2023preBPix)
      export ERA_ALIAS="Run3Summer23_2023preBPix"
      export YEAR_TAG="2023"
      export CFG_BASE_DIR="${CFG_BASE_DIR_13023}"
      ;;
    2023postBPix)
      export ERA_ALIAS="Run3Summer23BPix_2023postBPix"
      export YEAR_TAG="2023"
      export CFG_BASE_DIR="${CFG_BASE_DIR_13023}"
      ;;
    *)
      echo "Unknown ERA: ${era}"
      exit 1
      ;;
  esac

  for mass in "${massList[@]}"; do
    for fraction in "${fractions[@]}"; do

      export ERA="${era}"
      export MASS="${mass}"
      export FRACTION="${fraction}"

      export STEP="SIM"

      # 各 era 在 3_prepareConfig_*.sh 產生的 SIM cfg 命名規則統一：
      #   ${CFG_BASE_DIR}/HZaTo2l2g_M${MASS}/fraction${FRACTION}/1_sim_fragment_${ERA}_${FRACTION}.py
      export CFG_PATH="${CFG_BASE_DIR}/HZaTo2l2g_M${MASS}/fraction${FRACTION}/1_sim_fragment_${ERA}_${FRACTION}.py"

      export OUT_DIR="${OUT_BASE_DIR}/HZaTo2l2g/SIM/M${MASS}/${ERA}"

      cfgName="crab_HZa_${era}_M${mass}_frac${fraction}_SIM.py"
      cfgPath="${CRAB_TMPL_DIR}/${cfgName}"

      cp "${CRAB_TMPL}" "${cfgPath}"

      echo "Submitting CRAB SIM task for ERA=${ERA} (${ERA_ALIAS}), M=${MASS}, frac=${FRACTION}"
      echo "  using CFG_PATH=${CFG_PATH}"
      crab submit -c "${cfgPath}"

      # 如需放慢提交速度可打開：
      # sleep 1
    done
  done
done
