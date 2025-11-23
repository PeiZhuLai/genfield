#!/bin/bash
# 這個腳本用 getfiles_ondisk.py 產生 2022 / 2023preBPix / 2023postBPix Premix PU 檔案清單，
# 提供給 3_prepareConfig.sh 的 --pileup_input 使用。

python3 getfiles_ondisk.py -o fileslist_Neutrino_E-10_gun_2022preEE.txt -u pelai -v -a T2_CH_CERN -- "/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX"

python3 getfiles_ondisk.py -o fileslist_Neutrino_E-10_gun_2022postEE.txt -u pelai -v -a T2_CH_CERN -- "/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX"

python3 getfiles_ondisk.py -o fileslist_Neutrino_E-10_gun_2023preBPix.txt -u pelai -v -a T2_CH_CERN -- "/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer23_130X_mcRun3_2023_realistic_v13-v1/PREMIX"

python3 getfiles_ondisk.py -o fileslist_Neutrino_E-10_gun_2023postBPix.txt -u pelai -v -a T2_CH_CERN -- "/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer23BPix_130X_mcRun3_2023_realistic_postBPix_v1-v1/PREMIX"