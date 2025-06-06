#!/bin/bash
# /bin/hostname
# gcc -v
pwd
# export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH
source /cvmfs/cms.cern.ch/cmsset_default.sh

# cmssw-el8
# voms-proxy-init -voms cms
# cp /tmp/x509up_u23187 /publicfs/cms/user/laipeizhu/ALP/private_sample/genfield/x509up_u23187
export X509_USER_PROXY=/tmp/x509up_u175325

massList=( 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )
nMass=${#massList[@]}

export SCRAM_ARCH=el8_amd64_gcc10
source /cvmfs/cms.cern.ch/cmsset_default.sh
cmsrel CMSSW_12_4_14_patch3

export SCRAM_ARCH=el8_amd64_gcc11
cmsrel CMSSW_13_0_13

cfgpath=./Configuration/GenProduction/python

cp -r Configuration ./CMSSW_12_4_14_patch3/src/

for ((iBin=0; iBin<nMass; iBin++))
    do
    mass=${massList[$iBin]}
    mass=$(echo "$mass" | tr '.' 'p')

    cp -r ${cfgpath}/HIG-Run3Summer22wmLHEGS-00026-fragment.py ./CMSSW_12_4_14_patch3/src/${cfgpath}/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py
    sed -i "s/MASS/${mass}/g" ./CMSSW_12_4_14_patch3/src/${cfgpath}/HIG-Run3Summer22wmLHEGS-00026-fragment_M${mass}.py
    done

export SCRAM_ARCH=el8_amd64_gcc10
cd ./CMSSW_12_4_14_patch3/src/
cmsenv
scram b -j 8
cd -
