from WMCore.Configuration import Configuration
import os

config = Configuration()

# ========== Set from 8_sub_crab_nanoAOD.sh ==========
era       = os.getenv("ERA")
mass      = os.getenv("MASS")
step      = os.getenv("STEP", "nanoAOD")
cmsswBase = os.getenv("CMSSW")
DASFileBase = os.getenv("DASFILEBASE")
# ===== General =====
config.section_('General')
config.General.requestName = f'HZa_{step}_{era}_M{mass}'
config.General.workArea = f'crab_{era}/HZaTo2l2g_{step}_M{mass}'
config.section_('JobType')
config.JobType.pluginName = 'Analysis'
config.JobType.psetName = f'{cmsswBase}/HZaTo2l2g_M{mass}/5_nanoAOD_fragment_{era}_FRACTIONS.py'
config.JobType.numCores = 1


config.section_('Data')
# config.Data.inputDataset = '/HZaTo2l2g_miniAOD/pelai-miniAOD-546d98d7d3219712f68f085782609601/USER'
config.Data.userInputFiles = open(f"{DASFileBase}/miniAOD_files_{era}_M{mass}.txt").read().split()

config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 1 

config.Data.inputDBS = 'phys03'
config.Data.publication = True
config.Data.inputDBS = 'phys03'
config.Data.outputDatasetTag = 'nanoAOD' 
config.General.transferOutputs = True 
config.General.transferLogs = True
config.Data.outLFNDirBase = '/store/user/pelai/'
config.JobType.maxMemoryMB = 3000

config.section_('Site')
config.Site.storageSite = 'T2_CN_Beijing'
