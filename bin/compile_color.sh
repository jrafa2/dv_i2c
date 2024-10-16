#
# source compile_color.sh
# compile.sh test_i2c_read $color_suffix
#
color_suffix=' | awk '"'"'{ if($0 ~ /UVM_INFO/) print "\033[32m" $0 "\033[0m";   else if($0 ~ /*I/) print "\033[32m" $0 "\033[0m";    else if($0 ~ /*W/) print "\033[33m" $0 "\033[0m";    else if($0 ~ /UVM_WARNING/) print "\033[33m" $0 "\033[0m";    else if($0 ~ /UVM_ERROR/) print "\033[31m" $0 "\033[0m"; 	else if($0 ~ /UVM_FATAL/) print "\033[31m" $0 "\033[0m";        else if($0 ~ /*E/) print "\033[31m" $0 "\033[0m";    else print $0 }'"'"' '
