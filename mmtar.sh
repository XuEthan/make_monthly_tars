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
    tbp="tar -cvf ${sdir}/${tyear}_${m}.tar -C ${tyear}" 
    dq="\""
    for f in "${marr[@]}"; do 
        tbp="$tbp $dq$f$dq"    
    done
    echo -e "$tbp" >> "$tyear"_generate.sh
    echo -e "check_ret ${sdir}/${tyear}_${m}.tar ${sw_literal}" >> "$tyear"_generate.sh
}

# function to preload generated script 
function pre_load {
    local ts="$1"
    outf="$tyear"_generate.sh

    # check space on system before running
    as_literal='${as}'
    echo -e "#!/bin/bash\n" >> "$tyear"_generate.sh
    echo -e "as=$(df --output=avail -B 1 . | awk 'NR==2 {print $1}')" >> "$outf"
    echo -e "if ((${as_literal} <= ${ts})); then" >> "$outf" 
    echo -e "    echo \"not enough space on current system\"" >> "$outf"
    echo -e "    echo \"available space: ${as_literal}\"" >> "$outf" 
    echo -e "    echo \"combined size of all tars: ${ts}\"" >> "$outf"
    echo -e "    exit 1" >> "$outf"
    echo -e "fi\n" >> "$outf"   
    
    # check if the process is already running 
    pid_literal='${0%%sh}'
    p_literal='$pid'
    process_literal='$$'
    echo -e "pid=${pid_literal}pid" >> "$outf"
    echo -e "if [ -f ${p_literal} ]; then" >> "$outf" 
    echo -e "   echo \"process already running: ${p_literal}\"" >> "$outf"
    echo -e "   exit 1" >> "$outf"
    echo -e "else" >> "$outf"
    echo -e "   echo ${process_literal} > ${p_literal}" >> "$outf"
    echo -e "fi\n" >> "$outf"
        
    # check for panic file in local directory 
    panic_literal='${0%%sh}'
    p_literal='$panic'
    echo -e "panic=${panic_literal}_panic.txt" >> "$outf"
    echo -e "if [ -f ${p_literal} ]; then" >> "$outf"
    echo -e "   echo \"panic file found, handle before rerunning\"" >> "$outf" 
    echo -e "   exit 1" >> "$outf" 
    echo -e "fi\n" >> "$outf"     
    
    # function to handle potential errors produced by tar commands 
    one_literal='$1'
    sw_literal='$*' 
    r_literal='$ret'
    m_literal='$msg'
    echo -e "function check_ret {" >> "$outf"
    echo -e "   msg=${one_literal}; shift" >> "$outf"
    echo -e "   for ret in ${sw_literal}; do" >> "$outf"
    echo -e "       if  [ ${r_literal} -ne 0]; then" >> "$outf"
    echo -e "           echo ${m_literal} ${sw_literal} > ${p_literal}" >> "$outf"
    echo -e "           echo \"error when creating tars, out -> ${p_literal}\"" >> "$outf"
    echo -e "           exit 1" >> "$outf"
    echo -e "       fi" >> "$outf"
    echo -e "   done" >> "$outf"
    echo -e "}\n" >> "$outf"              
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

# boolean to check if generated script has already been preloaded
preloaded=false

# create stat file and generate script in the local directory
create_metaf "$tyear"_stats.txt 
create_metaf "$tyear"_generate.sh

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
    # preload the file once 
    if [ "$preloaded" = false ]; then 
        pre_load "$tsize"
        preloaded=true
    fi
    generate_month "$m" "${ff[@]}"    
done

echo -e "\nTotal size of all monthly tars: ${tsize}" >> "$tyear"_stats.txt
