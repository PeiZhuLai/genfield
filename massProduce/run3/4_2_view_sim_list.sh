#!/bin/bash

# Full Run
eraList=( "2022preEE" "2022postEE" "2023preBPix" "2023postBPix" ) 
# Test
# eraList=( "2022preEE" "2022postEE" )

# High Mass
massList=( 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )
# Low Mass
# massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 )

for era in "${eraList[@]}"; do
  for mA in "${massList[@]}"; do
    echo "Processing ERA: ${era}, Mass: ${mA}"

    LOG_FILE="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/crab_${era}/HZaTo2l2g_sim_M${mA}/crab_HZa_sim_${era}_M${mA}/crab.log"

    if [ ! -f "${LOG_FILE}" ]; then
      echo "Log file not found: ${LOG_FILE}"
      continue
    fi

    # Extract the output dataset line
    OUTPUT_DATASET_LINE=$(grep "Output dataset:" "${LOG_FILE}")
    if [ -z "${OUTPUT_DATASET_LINE}" ]; then
      echo "=================================================="
      echo "No output dataset found in log file: ${LOG_FILE}"
      echo "--------------------------------------------------"
      continue
    fi

    # Extract the dataset path
    DATASET_PATH=$(echo "${OUTPUT_DATASET_LINE}" | awk -F'[:\t]+' '{print $2}')
    echo "Found dataset: ${DATASET_PATH}"

    mkdir -p ./DAS_Names/sim
    # 直接把 DATASET_PATH 寫進檔案（只一行）
    echo "${DATASET_PATH}" > "./DAS_Names/sim/DAS_Names_${era}_M${mA}.txt"
    # echo "Dataset path saved to /DAS_Names/sim/DAS_Names_${era}_M${mA}.txt"

  done
done