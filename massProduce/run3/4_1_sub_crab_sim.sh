#!/bin/bash

# 使用 CRAB 在 T2_CN_Beijing 大量生產私有 MC。
# 前置：
#   1. 已跑過 1_gen_fragment.sh 和 3_prepareConfig.sh，產生各 mass / fraction 的 cfg。
#   2. 已在 ./crab/crabConfig_template.py 寫好共用 CRAB config (Python)，讀取 ERA/MASS/FRACTION 等環境變數。
#   3. 在 UI 節點上先執行: voms-proxy-init -voms cms -rfc

set -e

# CRAB_RESUBMIT: 
# 1 表示只做 Resubmit；
# 0 或未設則做 Nominal Submit
CRAB_RESUBMIT=0
CRAB_RESUBMIT="${CRAB_RESUBMIT:-0}"

export X509_USER_PROXY=${X509_USER_PROXY:-/tmp/x509up_u$(id -u)}
voms-proxy-info -exists -hours 1 || { echo "Proxy invalid or missing"; exit 1; }

#===================================================================================
# === Configuration block: choose ONE scenario below ===============================
#
# Usage rule:
#   - Only ONE "eraList + massList" block should be active at a time
#   - Comment out all other blocks
#
#===================================================================================
#-----------------------------------------------------------------------------------
# [Scenario A] Run-2 / Run-3 (2022) SIM production
#   - CMSSW release: CMSSW_12_4_14_patch3
#   - Applicable eras: 2022preEE, 2022postEE
#   - Mass points: high-mass scan
#-----------------------------------------------------------------------------------
eraList=( "2022preEE" "2022postEE" )
massList=( 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )

#-----------------------------------------------------------------------------------
# [Scenario B] Run-3 (2023) SIM production
#   - CMSSW release: CMSSW_13_0_23
#   - Applicable eras: 2023preBPix, 2023postBPix
#   - Mass points: high-mass scan
#-----------------------------------------------------------------------------------
# eraList=( "2023preBPix" "2023postBPix" )
# massList=( 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )

#-----------------------------------------------------------------------------------
# [Scenario C] Resubmission (debug / partial rerun)
#   - Use this block ONLY for failed jobs
#   - Keep eraList and massList minimal
#-----------------------------------------------------------------------------------
# eraList=( "2022postEE" )
# massList=( 7 )

#-----------------------------------------------------------------------------------
# [Scenario D] Future low-mass scan (not yet enabled)
#   - Note: low-mass points use 'p' notation (e.g. 0p5 = 0.5 GeV)
#   - Enable ONLY when low-mass gridpacks & configs are ready
#-----------------------------------------------------------------------------------
# massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 )


CRAB_TMPL_DIR="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/crab"
CRAB_TMPL="${CRAB_TMPL_DIR}/1_crabConfig_sim_template.py"

if [ ! -f "${CRAB_TMPL}" ]; then
    echo "Missing CRAB template: ${CRAB_TMPL}"
    exit 1
fi

# 確保放 SIM 專用 CRAB cfg 的子目錄存在
SIM_CFG_DIR="${CRAB_TMPL_DIR}/sim"
mkdir -p "${SIM_CFG_DIR}"

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
  # 根據 ERA 設定與 3_prepareConfig_*.sh 對應的 alias / 年份標籤與 CMSSW base
  case "${era}" in
    2022preEE)
      export YEAR_TAG="2022"
      export CMSSW="${CFG_BASE_DIR_12414}"
      ;;
    2022postEE)
      export YEAR_TAG="2022"
      export CMSSW="${CFG_BASE_DIR_12414}"
      ;;
    2023preBPix)
      export YEAR_TAG="2023"
      export CMSSW="${CFG_BASE_DIR_13023}"
      ;;
    2023postBPix)
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
    export STEP="sim"
    export OUT_DIR="${OUT_BASE_DIR}/SIM/M${MASS}/${ERA}"

    cfgName="crab_HZa_${era}_M${mass}_sim.py"
    cfgPath="${SIM_CFG_DIR}/${cfgName}"

    if [ "${CRAB_RESUBMIT}" = "1" ]; then
      echo "Resubmitting CRAB SIM task for ERA=${ERA}, M=${MASS}"
      if ! crab resubmit -d "crab_${ERA}/HZaTo2l2g_${STEP}_M${MASS}/crab_HZa_${STEP}_${ERA}_M${MASS}"; then
        echo "  -> No failed jobs to resubmit for ERA=${ERA}, M=${MASS}，跳過。"
      fi
    else
      echo "Submitting CRAB SIM task for ERA=${ERA}, M=${MASS}"
      rm -f "${cfgPath}"
      cp "${CRAB_TMPL}" "${cfgPath}"
      crab submit -c "${cfgPath}"
    fi
  done
done
