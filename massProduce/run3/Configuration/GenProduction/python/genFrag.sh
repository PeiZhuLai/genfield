#!/bin/bash

default=$(basename $(pwd))
massList=( 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 15 20 25 30 )

for m in "${massList[@]}"; do
    # format m file name (Replace . with P)
    m_formatted=$(echo "$m" | tr '.' 'p')

    echo "Copying mass M$m"
    cp 0_fragment.py 0_fragment_M"$m_formatted".py
    # Modify mass parameter
    sed -i 's/@@AMASS@@/'$m_formatted'/g' 0_fragment_M"$m_formatted".py
done