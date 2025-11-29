#!/bin/bash

# 使用 CRAB 在 T2_CN_Beijing 大量生產私有 MC 的 AOD step。
# 前置：
#   1. 已跑過 3_prepareConfig_*.sh，產生各 mass / fraction 的 3_AOD_fragment_* cfg。
#   2. 已在 ./crab/crabConfig_sim_template.py（或專用 AOD template）寫好共用 CRAB config。
#   3. 在 UI 節點上先執行: voms-proxy-init -voms cms -rfc

set -e

export X509_USER_PROXY=${X509_USER_PROXY:-/tmp/x509up_u$(id -u)}
voms-proxy-info -exists -hours 1 || { echo "Proxy invalid or missing"; exit 1; }

eraList=( "2022preEE" "2022postEE" "2023preBPix" "2023postBPix" )
massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )

CRAB_TMPL_DIR="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/crab"
# 這裡改成使用 AOD 專用的 template
CRAB_TMPL="${CRAB_TMPL_DIR}/3_crabConfig_AOD_template.py"

if [ ! -f "${CRAB_TMPL}" ]; then
    echo "Missing CRAB template: ${CRAB_TMPL}"
    exit 1
fi

# 確保放 AOD 專用 CRAB cfg 的子目錄存在
AOD_CFG_DIR="${CRAB_TMPL_DIR}/AOD"
mkdir -p "${AOD_CFG_DIR}"

# 供 template 使用的共通路徑（對應 3_prepareConfig_*.sh）
export CFG_BASE_DIR_12414="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_12_4_14_patch3/src"
export CFG_BASE_DIR_13013="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_13_0_13/src"
export CFG_BASE_DIR_13023="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_13_0_23/src"
# 注意：這裡是共同母目錄，實際輸出目錄由各 step 的 cfg/CRAB 決定，例如：
#   AOD     : ${OUT_BASE_DIR}/AOD/M${MASS}/${ERA}/...
#   MiniAOD : ${OUT_BASE_DIR}/MINIAOD/M${MASS}/${ERA}/...
#   NanoAOD : ${OUT_BASE_DIR}/NANOAOD/M${MASS}/${ERA}/...
export OUT_BASE_DIR="HZa/private_sig"

for era in "${eraList[@]}"; do
  # 根據 ERA 設定與 3_prepareConfig_*.sh 對應的 alias / 年份標籤 / CMSSW base
  case "${era}" in
    2022preEE)
      export ERA_ALIAS="Run3Summer22_2022preEE"
      export YEAR_TAG="2022"
      export CMSSW="${CFG_BASE_DIR_12414}"
      ;;
    2022postEE)
      export ERA_ALIAS="Run3Summer22_2022postEE"
      export YEAR_TAG="2022"
      export CMSSW="${CFG_BASE_DIR_12414}"
      ;;
    2023preBPix)
      export ERA_ALIAS="Run3Summer23_2023preBPix"
      export YEAR_TAG="2023"
      export CMSSW="${CFG_BASE_DIR_13023}"
      ;;
    2023postBPix)
      export ERA_ALIAS="Run3Summer23BPix_2023postBPix"
      export YEAR_TAG="2023"
      export CMSSW="${CFG_BASE_DIR_13023}"
      ;;
    *)
      echo "Unknown ERA: ${era}"
      exit 1
      ;;
  esac

  for mass in "${massList[@]}"; do

    export ERA="${era}"
    export MASS="${mass}"

    # AOD step
    export STEP="AOD"
    # AOD 輸出的邏輯目錄
    export OUT_DIR="${OUT_BASE_DIR}/AOD/M${MASS}/${ERA}"

    cfgName="crab_HZa_${era}_M${mass}_AOD.py"
    cfgPath="${AOD_CFG_DIR}/${cfgName}"

    cp "${CRAB_TMPL}" "${cfgPath}"

    echo "Submitting CRAB AOD task for ERA=${ERA} (${ERA_ALIAS}), M=${MASS}"
    crab submit -c "${cfgPath}"

    # 如需放慢提交速度可打開：
    # sleep 1
  done
done
