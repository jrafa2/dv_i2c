#!/bin/bash
# XRUN wrapper
# It runs the compilation, elaboration and simulation for a preconfigured environment. It includes a DUT and testbench with support for UVM.
# Folder structure must be meet: rtl/, dv/, dv/tests, dv/models, etc.
# Main file names must be meet: testbench.sv, digital_top.sv, dut.f
#
# It supports regressions. Regression file: regr.list
#
# Parameters:
#    -h: help
#    -d: delete temporal files. Clean
#    -s: seed number or "random". It is random by default
#    -c: coverage
#    -r: regression
#    others: testcase name
#
# Examples:
#     clear; compile.sh -r
#     clear; compile.sh -s 1232 test_i2c_read
#     clear; compile.sh -c test_i2c_read

debug=0

#https://community.cadence.com/cadence_technology_forums/f/functional-verification/35702/how-to-run-a-regression-for-multiple-testcases-with-only-a-single-compile-using-ncsim
function regression () {
  ###TODO for, read testcase names from file?
  echo "  ** Testcases run phase **"
  res=()
  while read -r regr_file_line 
  do
    command_regr=$command_regr_ini
    # Read the regression file line by line and run a simulation
    echo "  -- $regr_file_line --"
    [ $coverage -eq 1 ] && command_regr+="-covtest $regr_file_line "
    command_regr+="-R +UVM_TESTNAME=$regr_file_line "
    eval $command_regr

    #build the results array with testcase name and result
    status=$?
    res_code=""
    [ $status -eq 0 ] && res_code='PASS' || res_code="FAIL"
    res+=("$regr_file_line  $res_code")  
    echo "-----"
  done < "$regr_file"

  echo " ** Regression result **"
  printf '%s\n' "${res[@]}"   #show regression result

  #Merge coverage results. https://community.cadence.com/cadence_technology_forums/f/functional-verification/20269/how-to-merge-the-coverage-report-using-imc
  command_merge='imc -execcmd "merge cov_work/scope/* -out all"'
  [ $coverage -eq 1 ] && eval $command_merge   #TODO check if this works
}

function banner () {
    if [ $status -eq 0 ]
    then
    cat <<-END
 ____       _      ____    ____     
U|  _"\ uU  /"\  u / __"| u/ __"| u  
\| |_) |/ \/ _ \/ <\___ \/<\___ \/   
 |  __/   / ___ \  u___) | u___) |   
 |_|     /_/   \_\ |____/>>|____/>>  
 ||>>_    \\    >>  )(  (__))(  (__) 
(__)__)  (__)  (__)(__)    (__)      
END
    else
    cat <<-END
 (              (    (     
 )\ )    (      )\ ) )\ )  
(()/(    )\    (()/((()/(  
 /(_))((((_)(   /(_))/(_)) 
(_))_| )\ _ )\ (_)) (_))   
| |_   (_)_\(_)|_ _|| |    
| __|   / _ \   | | | |__  
|_|    /_/ \_\ |___||____|      
END
    fi
}

#build the compilation command
command="xrun  "
command+="dv/testbench/testbench.sv rtl/digital_top.sv -f rtl/dut.f -sv -sysv "
command+="-64bit -dynamic -turbo  "
command+="-incdir . -incdir ./dv/testbench/ -incdir ./dv/testbench/tests/ -incdir ./dv/testbench/agents/i2c_agent/ -incdir ./dv/testbench/agents/clock_agent/ -incdir ./dv/testbench/models/ -incdir ./rtl/ "
command+="+overwrite -access +rw  "
command+="-run  "
command+="-stats -status  -licqueue "
command+="-uvm -uvmhome CDNS-1.2 +UVM_NO_RELNOTES "
command_regr_ini=$command
regr_file=./regr.list

show_result=1
provided_seed=0
coverage=0
seed=" random "
while getopts dcrs:h option; do
    [ $debug -eq 1 ] && echo "$option err $OPTERR"
    case $option in
        d) # delete/clean
            [ $debug -eq 1 ] && echo "option d"
            echo "** Deleting temporal files **"
            command="rm -rf xcelium.d waves.shm xrun.* dump.vcd cov_work .simvision imc* mdv*"
            eval $command
            show_result=0
            exit;;
        c) # coverage
            [ $debug -eq 1 ] && echo "option c"
            coverage=1
            command+=" -coverage all -cov_cgsample -covoverwrite "
            ommand_regr_ini+=" -coverage all -cov_cgsample -covoverwrite "
            ;;
        r) # regression
            #compile only (for regressions)
            show_result=0
            #regr_file=${OPTARG}
            command+=" -elaborate "  
            ;;
        s) # seed
            [ $debug -eq 1 ] && echo "option s"
            provided_seed=1
            seed=${OPTARG}
            echo "seed $seed"
            ;;
        h) # help
            [ $debug -eq 1 ] && echo "option h"
            command="head -n 20 compile.sh"
            eval $command
            show_result=0
            exit
            ;;
        *) # Invalid option
            [ $debug -eq 1 ] && echo "option unknown"
            echo "Error: Invalid option $option"
            exit;;
    esac
done
command+=" -seed $seed "
command_regr_ini+=" -seed $seed "

#other params
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift
[ $debug -eq 1 ] && echo "test $@"

#if single testcase (not regression), add the testcase name
[ $show_result -eq 1 ] && command+="+UVM_TESTNAME=$@ "   #name from param
#command+="+tcl+dump.tcl"

#execute command!!!
echo "-----"
echo $command
echo "-----"

eval $command
status=$?
echo "-----"

#Show results
[ $show_result -eq 0 ] && echo "Compilation phase"
[ $show_result -eq 1 ] && banner
[ $status -eq 0 ] && echo -e '\033[0;32mPASS \033[0m' || echo -e "\033[0;31mFAIL \033[0m"
[ $status -eq 1 ] && exit

#If regression, run simulations only
[ $show_result -eq 0 ] && regression; exit

