import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

# External lHE producer configuration
externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
        args = cms.vstring('/afs/cern.ch/work/p/pelai/HZa/gridpacks/genproductions_run3/bin/MadGraph5_aMCatNLO/13p6TeV/HZaTo2l2g_MMASS_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz'),
        nEvents = cms.untracked.uint32(5000),
        numberOfParameters = cms.uint32(1),
        outputFile = cms.string('cmsgrid_final.lhe'),
        generateConcurrently = cms.untracked.bool(True),
        scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
    comEnergy = cms.double(13600.),
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
    generateConcurrently = cms.untracked.bool(False),
)

ProductionFilterSequence = cms.Sequence(generator)