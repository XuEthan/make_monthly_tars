#!/bin/bash

as=23820406620160
if ((${as} <= 34)); then
    echo "not enough space on current system"
    echo "available space: ${as}"
    echo "combined size of all tars: 34"
    exit 1
fi

pid=${0%%sh}pid
if [ -f $pid ]; then
   echo "process already running: $pid"
   exit 1
else
   echo $$ > $pid
fi

panic=${0%%sh}_panic.txt
if [ -f $panic ]; then
   echo "panic file found, handle before rerunning"
   exit 1
fi

function check_ret {
   msg=$1; shift
   for ret in $*; do
       if  [ $ret -ne 0]; then
           echo $msg $* > $panic
           echo "error when creating tars, out -> $panic"
           exit 1
       fi
   done
}

tar -cvf /projects/ps-renlab/ecxu/mm_out_dir/2021_01.tar -C 2021 "/projects/ps-renlab/ecxu/mm_test_dir/01/2021_01_01_fish" "/projects/ps-renlab/ecxu/mm_test_dir/01/2021_01_01_taco" "/projects/ps-renlab/ecxu/mm_test_dir/01/2021_01_01_chip" "/projects/ps-renlab/ecxu/mm_test_dir/14/2021_01_14_taco" "/projects/ps-renlab/ecxu/mm_test_dir/14/2021_01_14_fish" "/projects/ps-renlab/ecxu/mm_test_dir/14/2021_01_14_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_14_taco" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_14_fish" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_01_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_28_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_14_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_01_fish" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_01_taco" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_28_taco" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_01_28_fish" "/projects/ps-renlab/ecxu/mm_test_dir/28/2021_01_28_chip" "/projects/ps-renlab/ecxu/mm_test_dir/28/2021_01_28_taco" "/projects/ps-renlab/ecxu/mm_test_dir/28/2021_01_28_fish"
check_ret /projects/ps-renlab/ecxu/mm_out_dir/2021_01.tar $*
tar -cvf /projects/ps-renlab/ecxu/mm_out_dir/2021_06.tar -C 2021 "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_06_14_fish" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_06_28_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_06_01_chip"
check_ret /projects/ps-renlab/ecxu/mm_out_dir/2021_06.tar $*
tar -cvf /projects/ps-renlab/ecxu/mm_out_dir/2021_12.tar -C 2021 "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_12_28_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_12_01_chip" "/projects/ps-renlab/ecxu/mm_test_dir/2021/2021_12_14_fish"
check_ret /projects/ps-renlab/ecxu/mm_out_dir/2021_12.tar $*
