#!/bin/bash
/bin/hostname
gcc -v
pwd
export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH
source /cvmfs/cms.cern.ch/cmsset_default.sh

#cmssw-el7

export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
#cp /afs/cern.ch/work/z/zewang/private/ALP/gen/private_product/x509up_u117617 /tmp/x509up_u117617

step=$1
mass=$2
fraction=$3
NEvents=$4

if [ $step == 0 ]
then

    export SCRAM_ARCH=slc7_amd64_gcc700
    cmsrel CMSSW_10_6_19
    cmsrel CMSSW_10_2_16_UL
    cmsrel CMSSW_10_6_27


    cp -r Configuration ./CMSSW_10_6_19/src/
    cd ./CMSSW_10_6_19/src/
    cmsenv
    
    sed -i "s/MASS/${mass}/g" Configuration/GenProduction/python/HIG-RunIISummer20UL18wmLHEGEN-01820_fragment.py
    scram b -j 8



elif [ $step == 1 ] 
then
    # Step 1: LHE->GEN-SIM
    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_19/src/
    cmsenv
    #scram b
    cd mass_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
    

    #cmsDriver.py Configuration/GenProduction/python/HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_M${mass}.py \
    #    --python_filename HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_GS_cfg_${fraction}.py \
    #    --eventcontent RAWSIM \
    #    --customise Configuration/DataProcessing/Utils.addMonitoring \
    #    --datatier GEN-SIM \
    #    --fileout file:HZATollg_M${mass}-RunIISummer20UL18GS_${fraction}.root \
    #    --conditions 106X_upgrade2018_realistic_v4 \
    #    --beamspot Realistic25ns13TeVEarly2018Collision \
    #    --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(250)" \
    #    --step LHE,GEN,SIM \
    #    --geometry DB:Extended \
    #    --era Run2_2018 \
    #    --no_exec \
    #    --mc \
    #    -n ${NEvents}

    cmsRun HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_GS_cfg_${fraction}.py

elif [ $step == 2 ] 
then
    # Step 2: DIGI2RAW-HLT (DR)
    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_19/src/
    cmsenv
    #scram b
    cd mass_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
    
    #export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
    #cp /publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163 /tmp
    
    #proxy

    #cmsDriver.py  \
    #    --python_filename HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_DR_cfg_${fraction}.py \
    #    --eventcontent RAWSIM \
    #    --pileup 2018_25ns_UltraLegacy_PoissonOOTPU \
    #    --customise Configuration/DataProcessing/Utils.addMonitoring \
    #    --datatier GEN-SIM-DIGI \
    #    --fileout file:HZATollg_M${mass}-RunIISummer20UL18DR_${fraction}.root \
    #    --pileup_input "dbs:/MinBias_TuneCP5_13TeV-pythia8/RunIISummer20UL18SIM-106X_upgrade2018_realistic_v11_L1v1-v2/GEN-SIM" \
    #    --conditions 106X_upgrade2018_realistic_v11_L1v1 \
    #    --step DIGI,L1,DIGI2RAW \
    #    --geometry DB:Extended \
    #    --filein file:HZATollg_M${mass}-RunIISummer20UL18GS_${fraction}.root \
    #    --era Run2_2018 \
    #    --runUnscheduled \
    #    --no_exec \
    #    --mc \
    #    -n ${NEvents}

    cmsRun HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_DR_cfg_${fraction}.py

elif [ $step == 3 ] 
then
    # Adding the HLT objects /information.

    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_2_16_UL/src/
    cmsenv

    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_19/src/
    export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163
    #scram b
    cd mass_M${mass}/fraction${fraction}

    #cmsDriver.py \
    #--python_filename HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_HLT_cfg_${fraction}.py \
    #--eventcontent RAWSIM \
    #--customise Configuration/DataProcessing/Utils.addMonitoring \
    #--datatier GEN-SIM-RAW \
    #--fileout file:HZATollg_M${mass}-RunIISummer20UL18HLT_${fraction}.root \
    #--conditions 102X_upgrade2018_realistic_v15 \
    #--customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' \
    #--step HLT:2018v32 \
    #--geometry DB:Extended \
    #--filein file:HZATollg_M${mass}-RunIISummer20UL18DR_${fraction}.root \
    #--era Run2_2018 \
    #--no_exec \
    #--mc \
    #-n ${NEvents}

    cmsRun HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_HLT_cfg_${fraction}.py

elif [ $step == 4 ] 
then
    # MINIAOD
    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_19/src/
    cmsenv
    #scram b
    cd mass_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163

    #cmsDriver.py \
    #--python_filename HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_RECO_cfg_${fraction}.py \
    #--eventcontent AODSIM \
    #--customise Configuration/DataProcessing/Utils.addMonitoring \
    #--datatier AODSIM \
    #--fileout file:HZATollg_M${mass}-RunIISummer20UL18AOD_${fraction}.root \
    #--conditions 106X_upgrade2018_realistic_v11_L1v1 \
    #--step RAW2DIGI,L1Reco,RECO,RECOSIM,EI \
    #--geometry DB:Extended \
    #--filein file:HZATollg_M${mass}-RunIISummer20UL18HLT_${fraction}.root \
    #--era Run2_2018 \
    #--runUnscheduled \
    #--no_exec \
    #--mc \
    #-n ${NEvents}

    cmsRun HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_RECO_cfg_${fraction}.py

elif [ $step == 5 ] 
then
    # MINIAODSIM
    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_27/src/
    cmsenv

    cd /publicfs/cms/user/wangzebing/ALP/genproduct/CMSSW_10_6_19/src/
    cd mass_M${mass}/fraction${fraction}
    export X509_USER_PROXY=/publicfs/cms/user/wangzebing/ALP/genproduct/x509up_u12163

    #cmsDriver.py \
    #--python_filename HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_MINIAODSIM_cfg_${fraction}.py \
    #--eventcontent MINIAODSIM \
    #--customise Configuration/DataProcessing/Utils.addMonitoring \
    #--datatier MINIAODSIM \
    #--fileout file:HZATollg_M${mass}-RunIISummer20UL18MINIAODSIM_${fraction}.root \
    #--conditions 106X_upgrade2018_realistic_v16_L1v1 \
    #--step PAT \
    #--procModifiers run2_miniAOD_UL \
    #--geometry DB:Extended \
    #--filein file:HZATollg_M${mass}-RunIISummer20UL18AOD_${fraction}.root \
    #--era Run2_2018 \
    #--runUnscheduled \
    #--no_exec \
    #--mc \
    #-n ${NEvents}

    cmsRun HIG-RunIISummer20UL18wmLHEGEN-01820_fragment_MINIAODSIM_cfg_${fraction}.py

fi