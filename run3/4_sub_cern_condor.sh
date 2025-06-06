#!/bin/bash

# Ensure CVMFS is available for CMS environment
source /cvmfs/cms.cern.ch/cmsset_default.sh

# Create output directory for logs if it doesn't exist
mkdir -p ./job_out
mkdir -p ./job_sub

step=5
# massList=( 5 15 30 )
massList=( 0.9 )
fractions=({1..100})
NEvents=1000

nMass=${#massList[@]}
nFrac=${#fractions[@]}

# Update this path to your CERN AFS or EOS storage
PROXY_PATH="/tmp/x509up_u175325"

# Verify proxy certificate
if [ ! -f "$PROXY_PATH" ]; then
    echo "Error: Proxy certificate not found at $PROXY_PATH"
    exit 1
fi
voms-proxy-info -file "$PROXY_PATH" --all || { echo "Error: Invalid proxy certificate"; exit 1; }

for ((iBin=0; iBin<$nMass; iBin++))
do
    mass=${massList[$iBin]}
    mass=$(echo "$mass" | tr '.' 'p')

    for ((jBin=0; jBin<$nFrac; jBin++))
    do
        fraction=${fractions[$jBin]}

        # Create a Condor submission file for each job
        cat > ./job_sub/job_${step}_${fraction}_M${mass}.sub <<EOF
# Condor submission file for step ${step}, mass ${mass}, fraction ${fraction}
Universe = vanilla
Executable = /afs/cern.ch/work/p/pelai/HZa/gridpacks/genfield/run3/private_product_condor.sh
MY.WantOS   = "el8"
Arguments = ${step} ${mass} ${fraction} ${NEvents}
Output = ./job_out/job${step}_${fraction}_M${mass}.out
Error = ./job_out/job${step}_${fraction}_M${mass}.err
Log = ./job_out/job${step}_${fraction}_M${mass}.log
RequestMemory = 6000MB
request_cpus            = 1      
request_disk            = 500MB  
+MaxRuntime             = 86400  
priority                = 10     
requirements            = (OpSys == "LINUX") && (Arch == "X86_64")  
Queue
EOF
        # Submit the job to HTCondor
        condor_submit ./job_sub/job_${step}_${fraction}_M${mass}.sub
    done
done