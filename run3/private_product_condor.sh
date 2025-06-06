#!/bin/bash
# cmssw-el8 bash << 'EOF'
# requirements = TARGET.OpSysAndVer =?= "AlmaLinux9"                                                                                                                                           
# MY.WantOS = "el8"

/bin/hostname
gcc -v
pwd
# export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH
source /cvmfs/cms.cern.ch/cmsset_default.sh
d
# cmssw-el8

export X509_USER_PROXY=/tmp/x509up_u175325

step=$1
mass=$2
fraction=$3
NEvents=$4


if [ $step == 1 ] 
then
    # Step 1: LHE->GEN-SIM
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_12_4_14_patch3/src/
    cmsenv
    cd HZaTo2l2g_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/tmp/x509up_u175325
    
    # cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py \
    #     --python_filename HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_${fraction}.py \
    #     --eventcontent RAWSIM,LHE \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier GEN-SIM,LHE \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22wmLHEGS-00026_FRACTIONS.root \
    #     --conditions 124X_mcRun3_2022_realistic_postEE_v1 \
    #     --beamspot Realistic25ns13p6TeVEarly2022Collision \
    #     --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(123456)"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    #     --step LHE,GEN,SIM \
    #     --geometry DB:Extended \
    #     --era Run3 \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    cmsRun HIG-Run3Summer22wmLHEGS-00026_1_fragment_cfg_${fraction}.py

elif [ $step == 2 ] 
then
    # Step 2: DIGI → L1 → DIGI2RAW → HLT
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_12_4_14_patch3/src/
    cmsenv
    cd HZaTo2l2g_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/tmp/x509up_u175325
    
    #export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
    #cp /publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163 /tmp
    
    #proxy

    # cmsDriver.py  \
    #     --python_filename HIG-Run3Summer22DRPremix-00013_1_cfg_${fraction}.py \
    #     --eventcontent PREMIXRAW \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier GEN-SIM-RAW \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
    #     --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" \
    #     --conditions 124X_mcRun3_2022_realistic_postEE_v1 \
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

    cmsRun HIG-Run3Summer22DRPremix-00013_1_cfg_${fraction}.py


elif [ $step == 3 ] 
then
    # AOD
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_12_4_14_patch3/src/
    cmsenv
    cd HZaTo2l2g_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/tmp/x509up_u175325

    # cmsDriver.py  \
    #     --python_filename HIG-Run3Summer22DRPremix-00013_2_cfg_FRACTIONS.py \
    #     --eventcontent AODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier AODSIM --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
    #     --conditions 124X_mcRun3_2022_realistic_postEE_v1 \
    #     --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    #     --procModifiers siPixelQualityRawToDigi \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_0_FRACTIONS.root \
    #     --era Run3 \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    cmsRun HIG-Run3Summer22DRPremix-00013_2_cfg_${fraction}.py



elif [ $step == 4 ] 
then
    # MINIAOD
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_13_0_13/src/
    cmsenv
    cd HZaTo2l2g_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/tmp/x509up_u175325

    # cmsDriver.py \
    #     --python_filename HIG-Run3Summer22MiniAODv4-00005_1_cfg_${fraction}.py \
    #     --eventcontent MINIAODSIM \
    #     --customise Configuration/DataProcessing/Utils.addMonitoring \
    #     --datatier MINIAODSIM \
    #     --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root \
    #     --conditions 130X_mcRun3_2022_realistic_postEE_v6 \
    #     --step PAT \
    #     --geometry DB:Extended \
    #     --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22DRPremix-00013_FRACTIONS.root \
    #     --era Run3,run3_miniAOD_12X \
    #     --no_exec \
    #     --mc \
    #     -n ${NEvents}

    cmsRun HIG-Run3Summer22MiniAODv4-00005_1_cfg_${fraction}.py


elif [ $step == 5 ] 
then
    # MINIAODSIM
    cd /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/CMSSW_13_0_13/src/
    cmsenv
    cd HZaTo2l2g_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/tmp/x509up_u175325

    # cmsDriver.py  \
    #    --python_filename  HIG-Run3Summer22NanoAODv12-00005_1_cfg_${fraction}.py \
    #    --eventcontent NANOEDMAODSIM \
    #    --customise Configuration/DataProcessing/Utils.addMonitoring \
    #    --datatier NANOAODSIM \
    #    --fileout file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22NanoAODv12-00005_FRACTIONS.root \
    #    --conditions 130X_mcRun3_2022_realistic_postEE_v6 \
    #    --step NANO \
    #    --scenario pp \
    #    --filein file:$outpath/HZaTo2l2g_M${mass}-Run3Summer22MiniAODv4-00005_FRACTIONS.root  \
    #    --era Run3 \
    #    --no_exec \
    #    --mc \
    #    -n ${NEvents}

    cmsRun HIG-Run3Summer22NanoAODv12-00005_1_cfg_${fraction}.py


fi

# EOF
