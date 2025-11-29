#from CRABClient.UserUtilities import config, getUsernameFromSiteDB
from WMCore.Configuration import Configuration

config = Configuration()

config.section_('General')
config.General.requestName = f'HZa_{step}_{era}_M{mass}'
config.General.workArea = f'/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/{cmssw}/src/HZaTo2l2g_M{mass}/fraction1'
config.General.transferOutputs = True
config.General.transferLogs = True 

config.section_('JobType')
config.JobType.pluginName = 'PrivateMC'
config.JobType.disableAutomaticOutputCollection = True
config.JobType.psetName = f'1_sim_fragment_{era}_1.py'
config.JobType.outputFiles = [f'HZaTo2l2g_M{mass}_{era}_sim_FRACTIONS.root'] 

config.JobType.inputFiles = [f'/afs/cern.ch/work/p/pelai/HZa/gridpacks/genproductions_run3/bin/MadGraph5_aMCatNLO/13p6TeV/HZaTo2l2g_M{mass}_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz']

config.section_('Data')
config.Data.outputPrimaryDataset = 'HZaTo2l2g_sim'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = 100
NJOBS = 10  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.outLFNDirBase = '/store/user/pelai/' 
config.Data.publication = True
config.Data.outputDatasetTag = 'sim'

config.section_('Site')
config.Site.storageSite = 'T2_CN_Beijing'
# config.Debug.extraJDL = ['+RequiresTools = "xrootd"']