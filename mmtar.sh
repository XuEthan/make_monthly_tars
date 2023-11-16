#!/bin/bash

#TODO:
# running version
# take a path to some file set; 
# -> write stats of sorted tar contents to txt file
#   -> size in bytes  
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
    m_size=0
    if [ ${#marr[@]} == 0 ]; then
         return 
    fi
    echo -e "\n${m}" >> "$tyear"_stats.txt
    for f in "${marr[@]}"; do 
        fstat=$(du -b "$f")
        echo -e "$fstat" >> "$tyear"_stats.txt
        fstatss="${fstat%%/*}"
        fstatsi=$((fstatss))
        m_size=$((m_size + fstatsi))
    done    
    echo -e "Total size of ${m} tar: ${m_size}" >> "$tyear"_stats.txt
    return $m_size
}

# function to generate script contents for a given month 
function generate_month {
    local m="$1"
    local marr=("${@:2}")
    if [ ${#marr[@]} == 0 ]; then 
        return 
    fi
    tbp="tar -cvf ${sdir}/${tyear}_${m}.tar -C ${tyear} " 
    dq="\""
    for f in "${marr[@]}"; do 
        tbp="$tbp $dq$f$dq "    
    done
    echo -e "$tbp\n" >> "$tyear"_generate.sh
}

# function to preload generated script 
function pre_load {
    echo -e "#!/bin/bash" >> "$tyear"_generate.sh
}

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

# total size of all monthly tars 
tsize=0 

# create stat file and generate script in the local directory
create_metaf "$tyear"_stats.txt 
create_metaf "$tyear"_generate.sh

# preload the shell script 
pre_load

# loop through all months of the year and process 
for m in "${months[@]}"; do
    ss="$tyear"_"$m"
    ff=()
    while IFS= read -r -d $'\0' file; do
        ff+=("$file")
    done < <(find "$odir" -type f -name "*$ss*" -print0)
    stat_month "$m" "${ff[@]}"
    mts=$?
    tsize=$((tsize + mts))
    generate_month "$m" "${ff[@]}"    
done

echo -e "\nTotal size of all monthly tars: ${tsize}" >> "$tyear"_stats.txt
