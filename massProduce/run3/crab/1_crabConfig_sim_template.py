from WMCore.Configuration import Configuration
import os

config = Configuration()

# ========== Set from 4_sub_crab_sim.sh ==========
era       = os.getenv("ERA")
mass      = os.getenv("MASS")
step      = os.getenv("STEP", "sim")
cmsswBase = os.getenv("CMSSW")  # 新增：由 4_sub_crab_sim.sh 傳入
# ===== General =====
config.section_('General')
config.General.requestName = f'HZa_{step}_{era}_M{mass}'
config.General.workArea = f'crab_{era}/HZaTo2l2g_{step}_M{mass}'
config.General.transferOutputs = True
config.General.transferLogs = True 

config.section_('JobType')
config.JobType.pluginName = 'PrivateMC'
config.JobType.disableAutomaticOutputCollection = True
config.JobType.psetName = f'{cmsswBase}/HZaTo2l2g_M{mass}/1_sim_fragment_{era}_FRACTIONS.py'
config.JobType.outputFiles = [f'HZaTo2l2g_M{mass}_{era}_sim_FRACTIONS.root'] 

# --fileout file:HZaTo2l2g_M${mass}_2022preEE_sim_FRACTIONS.root \

config.JobType.inputFiles = [f'/afs/cern.ch/work/p/pelai/HZa/gridpacks/genproductions_run3/bin/MadGraph5_aMCatNLO/13p6TeV/HZaTo2l2g_M{mass}_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz']

config.section_('Data')
config.Data.splitting = 'EventBased'

# Test Produce
# config.Data.unitsPerJob = 100
# NJOBS = 10  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.

# Massive Procedure
config.Data.unitsPerJob = 1000
NJOBS = 260  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.

config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.outLFNDirBase = '/store/user/pelai/' 
config.Data.publication = True
config.Data.outputPrimaryDataset = f"HZaTo2l2g_M{mass}"
config.Data.outputDatasetTag = f"sim_{era}"

config.section_('Site')
config.Site.storageSite = 'T2_CN_Beijing'