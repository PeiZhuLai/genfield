from WMCore.Configuration import Configuration
import os

config = Configuration()

# ========== Set from 7_sub_crab_miniAOD.sh ==========
era       = os.getenv("ERA")
mass      = os.getenv("MASS")
step      = os.getenv("STEP", "miniAOD")
cmsswBase = os.getenv("CMSSW")
DASFileBase = os.getenv("DASFILEBASE")
# ===== General =====
config.section_('General')
config.General.requestName = f'HZa_{step}_{era}_M{mass}'
config.General.workArea = f'crab_{era}/HZaTo2l2g_{step}_M{mass}'
config.section_('JobType')
config.JobType.pluginName = 'Analysis'
config.JobType.psetName = f'{cmsswBase}/HZaTo2l2g_M{mass}/4_miniAOD_fragment_{era}_FRACTIONS.py'
config.JobType.numCores = 1


config.section_('Data')

dataset_file = f"{DASFileBase}/DAS_Names_{era}_M{mass}.txt"
with open(dataset_file) as f:
    for line in f:
        ds = line.strip()
        if ds:          # first non-empty line
            config.Data.inputDataset = ds
            break

config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 1 

config.Data.inputDBS = 'phys03'
config.Data.publication = True
config.Data.outputDatasetTag = 'miniAOD' 
config.General.transferOutputs = True 
config.General.transferLogs = True
config.Data.outLFNDirBase = '/store/user/pelai/'
config.JobType.maxMemoryMB = 3000

config.section_('Site')
config.Site.storageSite = 'T2_CN_Beijing'
