#!/bin/bash
# 這個腳本現在的角色：只負責準備各 mass / fraction 的 cmsRun cfg 檔案（LHEGS/DRPremix/AOD/MiniAOD/NanoAOD）
# 實際執行不再在這裡用 cmsRun 跑，而是透過 CRAB（見 5_sub_crab.sh）。
# 如需支援 2022postEE, 2023preBPix, 2023postBPix，請在此增加各 era 對應的 cmsDriver 區塊（調整 --conditions / --pileup_input / --beamspot）.

massList=( 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )
# massList=( 8 9 10 15 20 25 30 )
# massList=( 30 )
fractions=({1..100})
NEvents=100

nMass=${#massList[@]}
nFrac=${#fractions[@]}

for ((iBin=0; iBin<$nMass; iBin++))
    do
    mass=${massList[$iBin]}
    mass=$(echo "$mass" | tr '.' 'p')

    export SCRAM_ARCH=el8_amd64_gcc10
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/CMSSW_13_0_23/src/
    cmsenv
    scram b -j 9

    mkdir -p HZaTo2l2g_M${mass}
    cd HZaTo2l2g_M${mass}

    outpath=/eos/home-p/pelai/HZa/private_mc/signal/run3/HZaTo2l2g_M${mass}_2023preBPix
    mkdir -p $outpath

    # Step 1: LHE->GEN-SIM  (2023preBPix)
    cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py \
        --eventcontent RAWSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier GEN-SIM \
        --conditions 130X_mcRun3_2023_realistic_v15 \
        --beamspot Realistic25ns13p6TeVEarly2023Collision \
        --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(123456)"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
        --step LHE,GEN,SIM \
        --geometry DB:Extended \
        --era Run3 \
        --python_filename 1_sim_fragment_2023preBPix_FRACTIONS.py \
        --fileout file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_sim_FRACTIONS.root \
        --number ${NEvents} \
        --number_out ${NEvents} \
        --no_exec \
        --mc

    echo "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper" >> 1_sim_fragment_2023preBPix_FRACTIONS.py
    echo "randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)" >> 1_sim_fragment_2023preBPix_FRACTIONS.py
    echo "randSvc.populate()" >> 1_sim_fragment_2023preBPix_FRACTIONS.py

    
    # # Step 2: DIGI → L1 → DIGI2RAW → HLT (Premix)
    # cmsDriver.py  \
    #     --python_filename 2_digi_fragment_2023preBPix_FRACTIONS.py \
    #     --eventcontent PREMIXRAW \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier GEN-SIM-RAW \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_digi_FRACTIONS.root \
    #     --pileup_input "filelist:/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/fileslist_Neutrino_E-10_gun_2023preBPix.txt" \
    #     --conditions 130X_mcRun3_2023_realistic_v15 \
    #     --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2023v12 \
	#     --procModifiers premix_stage2,siPixelQualityRawToDigi \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_sim_FRACTIONS.root \
	#     --datamix PreMix \
    #     --era Run3 \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    # # AOD
    # cmsDriver.py  \
    #     --eventcontent AODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier AODSIM \
    #     --conditions 130X_mcRun3_2023_realistic_v15 \
    #     --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    #     --procModifiers siPixelQualityRawToDigi \
    #     --geometry DB:Extended \
    #     --era Run3 \
    #     --python_filename 3_AOD_fragment_2023preBPix_FRACTIONS.py \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_AOD_FRACTIONS.root \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_digi_FRACTIONS.root \
    #     --number  ${NEvents} \
    #     --number_out  ${NEvents} \
    #     --no_exec \
    #     --mc 

    for ((jBin=0; jBin<$nFrac; jBin++))
        do
        fraction=${fractions[$jBin]}

        mkdir -p fraction${fraction}
        cd fraction${fraction}
        
        cp ../1_sim_fragment_2023preBPix_FRACTIONS.py 1_sim_fragment_2023preBPix_${fraction}.py
        # cp ../2_digi_fragment_2023preBPix_FRACTIONS.py 2_digi_fragment_2023preBPix_${fraction}.py
        # cp ../3_AOD_fragment_2023preBPix_FRACTIONS.py 3_AOD_fragment_2023preBPix_${fraction}.py

        sed -i "s/FRACTIONS/${fraction}/g" 1_sim_fragment_2023preBPix_${fraction}.py
        # sed -i "s/FRACTIONS/${fraction}/g" 2_digi_fragment_2023preBPix_${fraction}.py
        # sed -i "s/FRACTIONS/${fraction}/g" 3_AOD_fragment_2023preBPix_${fraction}.py
        cd ..
        
        done


    # export SCRAM_ARCH=el8_amd64_gcc11
    # cd ../../../CMSSW_13_0_13/src
    # cmsenv
    # scram b -j 9

    # mkdir -p HZaTo2l2g_M${mass}
    # cd HZaTo2l2g_M${mass}

    # # MINIAOD
    # cmsDriver.py  \
    #     --eventcontent MINIAODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier MINIAODSIM \
    #     --conditions 130X_mcRun3_2023_preBPix_realistic_v6 \
    #     --step PAT \
    #     --geometry DB:Extended \
    #     --era Run3,run3_miniAOD_12X \
    #     --python_filename 4_miniAOD_fragment_2023preBPix_FRACTIONS.py \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_MiniAODv4_FRACTIONS.root \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_AOD_FRACTIONS.root \
    #     --number ${NEvents} \
    #     --number_out ${NEvents} \
    #     --no_exec \
    #     --mc

    # # Nano
    # cmsDriver.py  \
    #     --eventcontent NANOAOD \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier NANOAOD \
    #     --conditions 130X_mcRun3_2023_preBPix_realistic_v6 \
    #     --step NANO \
    #     --scenario pp \
    #     --era Run3 \
    #     --python_filename 5_nanoAOD_fragment_2023preBPix_FRACTIONS.py \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}_2023preBPix-Run3Summer22NanoAODv12-00005_FRACTIONS.root \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}_2023preBPix_MiniAODv4_FRACTIONS.root \
    #     --number ${NEvents} \
    #     --number_out ${NEvents} \
    #     --no_exec \
    #     --mc 
    
    # for ((jBin=0; jBin<$nFrac; jBin++))
    #     do
    #     fraction=${fractions[$jBin]}

    #     mkdir -p fraction${fraction}
    #     cd fraction${fraction}
        
    #     cp ../4_miniAOD_fragment_2023preBPix_FRACTIONS.py 4_miniAOD_fragment_2023preBPix_${fraction}.py
    #     cp ../5_nanoAOD_fragment_2023preBPix_FRACTIONS.py 5_nanoAOD_fragment_2023preBPix_${fraction}.py

    #     sed -i "s/FRACTIONS/${fraction}/g" 4_miniAOD_fragment_2023preBPix_${fraction}.py
    #     sed -i "s/FRACTIONS/${fraction}/g" 5_nanoAOD_fragment_2023preBPix_${fraction}.py

    #     cd ..
        
    #     done
    cd ../../../
done
