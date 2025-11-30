#!/bin/bash

eraList=( "2022preEE" "2022postEE" "2023preBPix" "2023postBPix" )
# eraList=( "2022postEE" )
massList=( 0p1 0p2 0p3 0p4 0p5 0p6 0p7 0p8 0p9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )
# massList=( 7 )

for era in "${eraList[@]}"; do
  for mA in "${massList[@]}"; do
    echo "Processing ERA: ${era}, Mass: ${mA}"

    LOG_FILE="/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/crab_${era}/HZaTo2l2g_AOD_M${mA}/crab_HZa_AOD_${era}_M${mA}/crab.log"

    if [ ! -f "${LOG_FILE}" ]; then
      echo "Log file not found: ${LOG_FILE}"
      continue
    fi

    # Extract the output dataset line
    OUTPUT_DATASET_LINE=$(grep "Output dataset:" "${LOG_FILE}")
    if [ -z "${OUTPUT_DATASET_LINE}" ]; then
      echo "No output dataset found in log file: ${LOG_FILE}"
      continue
    fi

    # Extract the dataset path
    DATASET_PATH=$(echo "${OUTPUT_DATASET_LINE}" | awk -F'[:\t]+' '{print $2}')
    echo "Found dataset: ${DATASET_PATH}"

    mkdir -p ./DAS_fileLists/AOD
    # Query DAS for files in the dataset
    dasgoclient -query="file dataset=${DATASET_PATH} instance=prod/phys03" > "./DAS_fileLists/AOD/AOD_files_${era}_M${mA}.txt"
    echo "File list saved to sim_files_${era}_M${mA}.txt"

  done
done