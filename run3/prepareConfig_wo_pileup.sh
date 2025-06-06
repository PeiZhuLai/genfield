
# massList=( 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 25 30)
# massList=( 0.1 1 5 10 15 )
massList=( 0.1 )
# fractions=( 1 2 3 4 5 6 7 8 9 10 )
# NEvents=100
fractions=(1)
NEvents=10

nMass=${#massList[@]}
nFrac=${#fractions[@]}

for ((iBin=0; iBin<$nMass; iBin++))
    do
    mass=${massList[$iBin]}
    mass=$(echo "$mass" | tr '.' 'p')

    export SCRAM_ARCH=el8_amd64_gcc10
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_12_4_11_patch3/src/
    cmsenv
    scram b -j 9

    mkdir HZaTo2l2g_M${mass}
    cd HZaTo2l2g_M${mass}

    outpath=/eos/home-p/pelai/HZa/private_mc/signal/run3/HZaTo2l2g_M${mass}
    mkdir -p $outpath

    #cp ../../../HZaTo2l2g_M${mass}_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz .

    # Step 1: LHE->GEN-SIM
    # cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py \
    #     --python_filename HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py \
    #     --eventcontent RAWSIM,LHE \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier GEN-SIM,LHE \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22wmLHEGS-00026_FRACTIONS.root \
    #     --conditions 124X_mcRun3_2022_realistic_v12 \
    #     --beamspot Realistic25ns13p6TeVEarly2022Collision \
    #     --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(123456)"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    #     --step LHE,GEN,SIM \
    #     --geometry DB:Extended \
    #     --era Run3 \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py \
        --eventcontent RAWSIM,LHE \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier GEN-SIM,LHE \
        --conditions 124X_mcRun3_2022_realistic_v12 \
        --beamspot Realistic25ns13p6TeVEarly2022Collision \
        --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
        --step LHE,GEN,SIM \
        --geometry DB:Extended \
        --era Run3 \
        --python_filename HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22wmLHEGS-00026_FRACTIONS.root \
        --number ${NEvents} \
        --number_out ${NEvents} \
        --no_exec \
        --mc

    echo "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper" >> HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py
    echo "randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)" >> HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py
    echo "randSvc.populate()" >> HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py

    
    # Step 2: DIGI → L1 → DIGI2RAW → HLT
    # cmsDriver.py  \
    #     --python_filename HIG-Run3Summer22DRPremix-00013_1_cfg_FRACTIONS.py \
    #     --eventcontent PREMIXRAW \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier GEN-SIM-RAW \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
    #     --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" \
    #     --conditions 124X_mcRun3_2022_realistic_v12 \
    #     --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v12 \
	#     --procModifiers premix_stage2,siPixelQualityRawToDigi \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22wmLHEGS-00026_FRACTIONS.root \
	#     --datamix PreMix \
    #     --era Run3 \
    #     --runUnscheduled \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    # Without pile-up
    cmsDriver.py  \
        --python_filename HIG-Run3Summer22DRPremix-00013_1_cfg_FRACTIONS.py \
        --eventcontent RAWSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier GEN-SIM-DIGI \
        --conditions 124X_mcRun3_2022_realistic_v12 \
        --step DIGI,L1,DIGI2RAW \
        --geometry DB:Extended \
        --era Run3 \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
        --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22wmLHEGS-00026_FRACTIONS.root \
        --number ${NEvents} \
        --number_out ${NEvents} \
        --runUnscheduled \
        --no_exec \
        --mc

    # adding HLT
    cmsDriver.py \
        --python_filename HIG-Run3Summer22DRPremix-00013_2_cfg_FRACTIONS.py \
        --eventcontent RAWSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier GEN-SIM-RAW \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_1_FRACTIONS.root \
        --conditions 124X_mcRun3_2022_realistic_v12 \
        --customise_commands="process.source.bypassVersionCheck = cms.untracked.bool(True)" \
        --step HLT:2022v12 \
        --geometry DB:Extended \
        --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
        --era Run3 \
        --no_exec \
        --mc \
        -n ${NEvents}

    # AOD
    # cmsDriver.py  \
    #     --python_filename HIG-Run3Summer22DRPremix-00013_2_cfg_FRACTIONS.py \
    #     --eventcontent AODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier AODSIM --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
    #     --conditions 124X_mcRun3_2022_realistic_v12 \
    #     --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    #     --procModifiers siPixelQualityRawToDigi \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
    #     --era Run3 \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    cmsDriver.py  \
        --eventcontent AODSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier AODSIM \
        --conditions 124X_mcRun3_2022_realistic_v12 \
        --step RAW2DIGI,L1Reco,RECO,RECOSIM \
        --procModifiers siPixelQualityRawToDigi \
        --geometry DB:Extended \
        --era Run3 \
        --python_filename HIG-Run3Summer22DRPremix-00013_3_cfg_FRACTIONS.py \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
        --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_1_FRACTIONS.root \
        --number  ${NEvents} \
        --number_out  ${NEvents} \
        --no_exec \
        --mc 

    for ((jBin=0; jBin<$nFrac; jBin++))
        do
        fraction=${fractions[$jBin]}

        mkdir fraction${fraction}
        cd fraction${fraction}
        
        cp ../HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_FRACTIONS.py HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_${fraction}.py
        cp ../HIG-Run3Summer22DRPremix-00013_1_cfg_FRACTIONS.py HIG-Run3Summer22DRPremix-00013_1_cfg_${fraction}.py
        cp ../HIG-Run3Summer22DRPremix-00013_2_cfg_FRACTIONS.py HIG-Run3Summer22DRPremix-00013_2_cfg_${fraction}.py
        cp ../HIG-Run3Summer22DRPremix-00013_3_cfg_FRACTIONS.py HIG-Run3Summer22DRPremix-00013_3_cfg_${fraction}.py

        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_${fraction}.py
        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22DRPremix-00013_1_cfg_${fraction}.py
        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22DRPremix-00013_2_cfg_${fraction}.py
        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22DRPremix-00013_3_cfg_${fraction}.py
        cd ..
        
        done


    export SCRAM_ARCH=el8_amd64_gcc11
    cd ../../../CMSSW_13_0_13/src
    cmsenv
    scram b -j 9

    mkdir HZaTo2l2g_M${mass}
    cd HZaTo2l2g_M${mass}

    # MINIAOD
    # cmsDriver.py \
    #     --python_filename HIG-Run3Summer22MiniAODv4-00005_1_cfg_FRACTIONS.py \
    #     --eventcontent MINIAODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier MINIAODSIM \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root \
    #     --conditions 130X_mcRun3_2022_realistic_v5 \
    #     --step PAT \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
    #     --era Run3,run3_miniAOD_12X \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}
    
    cmsDriver.py  \
        --eventcontent MINIAODSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier MINIAODSIM \
        --conditions 130X_mcRun3_2022_realistic_v5 \
        --step PAT \
        --geometry DB:Extended \
        --era Run3,run3_miniAOD_12X \
        --python_filename HIG-Run3Summer22MiniAODv4-00005_1_cfg_FRACTIONS.py \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root \
        --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
        --number ${NEvents} \
        --number_out ${NEvents} \
        --no_exec \
        --mc

    # Nano
    # cmsDriver.py  \
    #    --python_filename  HIG-Run3Summer22NanoAODv12-00005_1_cfg_FRACTIONS.py \
    #    --eventcontent NANOEDMAODSIM \
    #    --customise Configuration/DataProcessing/Utils.addMonitoring \
    #    --datatier NANOAODSIM \
    #    --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22NanoAODv12-00005_FRACTIONS.root \
    #    --conditions 130X_mcRun3_2022_realistic_v5 \
    #    --step NANO \
    #    --scenario pp \
    #    --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root  \
    #    --era Run3 \
    #    --no_exec \
    #    --mc \
    #    -n ${NEvents}

    cmsDriver.py  \
        --eventcontent NANOEDMAODSIM \
        --customise Configuration/DataProcessing/Utils.addMonitoring \
        --datatier NANOAODSIM \
        --conditions 130X_mcRun3_2022_realistic_v5 \
        --step NANO \
        --scenario pp \
        --era Run3 \
        --python_filename HIG-Run3Summer22NanoAODv12-00005_1_cfg_FRACTIONS.py \
        --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22NanoAODv12-00005_FRACTIONS.root \
        --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root \
        --number ${NEvents} \
        --number_out ${NEvents} \
        --no_exec \
        --mc 
    
    for ((jBin=0; jBin<$nFrac; jBin++))
        do
        fraction=${fractions[$jBin]}

        mkdir fraction${fraction}
        cd fraction${fraction}
        
        cp ../HIG-Run3Summer22MiniAODv4-00005_1_cfg_FRACTIONS.py HIG-Run3Summer22MiniAODv4-00005_1_cfg_${fraction}.py
        cp ../HIG-Run3Summer22NanoAODv12-00005_1_cfg_FRACTIONS.py HIG-Run3Summer22NanoAODv12-00005_1_cfg_${fraction}.py

        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22MiniAODv4-00005_1_cfg_${fraction}.py
        sed -i "s/FRACTIONS/${fraction}/g" HIG-Run3Summer22NanoAODv12-00005_1_cfg_${fraction}.py

        cd ..
        
        done
    cd ../../../
done
