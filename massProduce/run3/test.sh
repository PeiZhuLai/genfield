#!/bin/bash
# export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH

step=1

massList=( 1 )
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

        sh test_private_product.sh ${step} ${mass} ${fraction} ${NEvents}
    done
done

# sh test_private_product.sh 1 0p1 1 10