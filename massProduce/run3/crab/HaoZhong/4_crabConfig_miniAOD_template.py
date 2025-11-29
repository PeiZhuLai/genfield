from WMCore.Configuration import Configuration
config = Configuration()


config.section_('General')
config.General.requestName = f'HZa_{step}_{era}_M{mass}'
config.General.workArea = f'/afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/massProduce/run3/{cmssw}/src/HZaTo2l2g_M{mass}/fraction1'
config.section_('JobType')
config.JobType.pluginName = 'Analysis'
config.JobType.psetName = '4_miniAOD_fragment_{era}_1.py'
config.JobType.numCores = 1


config.section_('Data')
config.Data.inputDataset = '/HZaTo2l2g_AOD/pelai-AOD-546d98d7d3219712f68f085782609601/USER'

config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 1 

config.Data.inputDBS = 'phys03'
config.Data.publication = True
config.Data.inputDBS = 'phys03'
config.Data.outputDatasetTag = 'miniAOD' 
config.General.transferOutputs = True 
config.General.transferLogs = True
config.Data.outLFNDirBase = '/store/user/pelai/'
config.JobType.maxMemoryMB = 3500

config.section_('Site')
config.Site.storageSite = 'T2_CN_Beijing'
