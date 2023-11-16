#!/bin/bash

#TODO:
# running version
# take a path to some file set; 
# -> write stats of sorted tar contents to txt file 
# -> write script to actually produce sorted tars to seperate .sh file   

# function to handle creation of meta files 
function create_metaf {
    local f=$1
    if test -e "$f"; then 
        echo "File ${f} already exists. Overwrite? (yes/no)"
        read confirmation 
        if [ "$confirmation" != "yes" ] && [ "$confirmation" != "no" ]; then 
            echo "Unknown input, exiting"
            exit 1
        elif [ "$confirmation" == "yes" ]; then 
            echo "Overwriting ${f}"
            rm "$f"
            touch "$f"
        else 
            echo "Handle pre-existing meta files, exiting" 
            exit 1
        fi      
    else
        touch "$f" 
    fi 
}

# function to stat tars for a given month 
function stat_month {
    local m="$1" 
    local marr=("${@:2}")
    if [ ${#marr[@]} == 0 ]; then
         return 
    fi
    echo -e "\n${m}" >> "$tyear"_stats.txt
    for f in "${marr[@]}"; do 
        du -b "$f" >> "$tyear"_stats.txt
    done    
}

# function to generate script for a given month 
#function generate_month {
#
#}

# months in the year 
months=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12")
readonly months

# original directory where files should be searched for 
odir="/projects/ps-renlab/ecxu/mm_test_dir" 

# save directory to save monthly tars to 
sdir="/projects/ps-renlab/ecxu/mm_out_dir"

# specified year for fileset 
tyear=2021

# array to store paths for found files in a month 
ff=()

# create stat file and generate script in the local directory
create_metaf "$tyear"_stats.txt 
create_metaf "$tyear"_generate.sh
 
# loop through all months of the year 
for m in "${months[@]}"; do
    ss="$tyear"_"$m"
    ff=()
    while IFS= read -r -d $'\0' file; do
        ff+=("$file")
    done < <(find "$odir" -type f -name "*$ss*" -print0)
    stat_month "$m" "${ff[@]}"
done

# for testing 
#for file in "${ff[@]}"; do
#    echo "$file"
#done
