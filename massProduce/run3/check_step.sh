
# step 1
# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22EEwmLHEGS-00019-fragment.py \
    --eventcontent RAWSIM,LHE \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM,LHE \
    --conditions 124X_mcRun3_2022_realistic_postEE_v1 \
    --beamspot Realistic25ns13p6TeVEarly2022Collision \
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    --step LHE,GEN,SIM \
    --geometry DB:Extended \
    --era Run3 \
    --python_filename HIG-Run3Summer22EEwmLHEGS-00019_1_cfg.py \
    --fileout file:HIG-Run3Summer22EEwmLHEGS-00019.root \
    --number 100 \
    --number_out 100 \
    --no_exec \
    --mc 
    || exit $? ;