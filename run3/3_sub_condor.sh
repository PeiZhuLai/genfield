#!/bin/bash
export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH

step=5

massList=( 0P05 0P5 )
fractions=( 1 2 3 4 5 6 7 8 9 10 )
NEvents=5000

nMass=${#massList[@]}
nFrac=${#fractions[@]}

for ((iBin=0; iBin<$nMass; iBin++))
    do
    mass=${massList[$iBin]}

    for ((jBin=0; jBin<$nFrac; jBin++))
        do
        fraction=${fractions[$jBin]}

        hep_sub private_product_condor.sh -wt mid -g cms -mem 4000 -o ./job_out/job${step}_${fraction}_M${mass}.out -e ./job_out/job${step}_${fraction}_M${mass}.err -argu ${step} ${mass} ${fraction} ${NEvents}
    done
done