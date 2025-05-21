import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

# External lHE producer configuration
externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
        args = cms.vstring('/publicfs/cms/user/laipeizhu/ALP/private_sample/HZaTo2l2g/gridpack/13p6TeV/HZaTo2l2g_MMASS_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz'),
        nEvents = cms.untracked.uint32(5000),
        numberOfParameters = cms.uint32(1),
        outputFile = cms.string('cmsgrid_final.lhe'),
        scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

generator = cms.EDFilter("Pythia8HadronizerFilter",
    comEnergy = cms.double(13600.0),
    filterEfficiency = cms.untracked.double(1.0),
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        parameterSets = cms.vstring(
                'pythia8CommonSettings', 
                'pythia8CP5Settings',
                'pythia8PSweightsSettings',
            ),
    ),
)

ProductionFilterSequence = cms.Sequence(generator)