#!/bin/bash
# Show the used space in /nobackup per folders.
# 
# Parameters:
#      -a : all folders in /nobackup/$USER. Useful when you didn't execute "pinit"
#           if no indicated, examine only /nobackup/$USER/$PRJ_NAME
#           It can take a while.
#      -n : number of lines when -a (10 by default)
#      -p : % of use of /nobackup/$USER
#      -h : help
#
# Syntaxis:
#   space
#   space -a 
#   space -a -n 10
#   space -p
# 
# Example:
#   space.sh
#   set num=`space.sh -p | rev | cut -c2- | rev`  #save % into a variable
#   watch -n 60 "space.sh -p"                     #monitor % of use each 60 seconds

# Set variables
all_folders="N"
n_lines=10
percentage="N"

while [ $# -gt 0 ]
do
 arg=$1; shift
 val=$1; shift
 case $arg in
   "-a")all_folders="Y"
   ;;
   "-n")n_lines=$val
   ;;
   "-p")percentage="Y"
   ;;
   "-h")
        echo "space. Show disk space used by folders in /nobackup"
        echo "  space -a -n 10"
        exit 0
   ;;
 esac
done

if [[ "$percentage" == "Y" ]];
then
    df >& /tmp/space2_tmp.txt
    #echo "Percentage of use: "
    cat /tmp/space2_tmp.txt | grep ~ | tail -n 1 | awk '{ print $ 5}'
    rm -rf /tmp/space2_tmp.txt
    exit 0
    
fi

if [[ "$all_folders" == "Y" ]];
then
    # du: show size of folder and subfolders
    #   -d: directory depth
    #   -t: exclude files smaller than... (for performance)
    #   --exclude="pattern": exclude files with name that matches. In this case begining with "." (hidden, typically system files, .snapshot, etc)
    # sort: sort
    #   -h: compare numbers in 'human-format'
    #   -r: reverse
    # tail: take only a few lines at the end
    #   -n: number of lines
    du -d 3 -h -t 1000 --exclude=".*" ~ | sort -h -r | tail -n $n_lines 
    
    echo "du"
else
    # if project
    du -h -t 1000 --exclude=".*" -sh ~/dv*/* | sort -h -r | head -n $n_lines 
    echo "ls"
fi