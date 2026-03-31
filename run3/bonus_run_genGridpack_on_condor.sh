#!/bin/bash

work_dir=$1
pack_name=$2
card_dir=$3

echo "work_dir = $1"
echo "pack_name = $2"
echo "card_dir = $3"
#echo "ls $1"
#echo "cd $1"

cd ${work_dir}

#./gridpack_generation.sh
./gridpack_generation.sh ${pack_name} ${card_dir} 

#echo 'good' > ${pack_name}.log
#no need to copy as they gen at the given local directory
##cp ${pack_name}.log ${work_dir}
##cp ${pack_name}.tar.xz ${work_dir}
