#!/bin/bash
# export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH

step=1

massList=( 0.1 )
# fractions=( 1 2 3 4 5 6 7 8 9 10 )
fractions=( 1 )
# NEvents=5000
NEvents=10

nMass=${#massList[@]}
nFrac=${#fractions[@]}

for ((iBin=0; iBin<$nMass; iBin++))
    do
    mass=${massList[$iBin]}
    mass=$(echo "$mass" | tr '.' 'p')

    for ((jBin=0; jBin<$nFrac; jBin++))
        do
        fraction=${fractions[$jBin]}

        hep_sub 4_private_product_condor.sh -wt mid -g cms -mem 4000 -o ./job_out/job${step}_${fraction}_M${mass}.out -e ./job_out/job${step}_${fraction}_M${mass}.err -argu ${step} ${mass} ${fraction} ${NEvents}
    done
done