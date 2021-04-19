#!/bin/bash

#----------------------------------------------------------------------------------------------

# Auxiliary function of mainSummarizeSyms
# Env: $dumptmp must point to the stripped objdump file
function stripSyms() {
  if [ "$dumptmp" == "" ] || [ ! -e $dumptmp ]; then echo "ERROR! File '$dumptmp' not found"; exit 1; fi 
  cnt=0
  for sym in "$@"; do
    # Use cut -f3- to print only the assembly code after two leading fields separated by tabs
    (( cnt += $(cat $dumptmp | egrep "$sym" | wc -l) ))
    cat $dumptmp | egrep -v "$sym" > ${dumptmp}.new
    \mv ${dumptmp}.new $dumptmp
  done; echo $cnt
}

#----------------------------------------------------------------------------------------------

function mainSummarizeSyms() {

  # Command line arguments: HelAmps functions only?
  helamps=0
  if [ "$1" == "-helamps" ]; then
    helamps=1
    shift
  fi

  # Command line arguments: select file
  if [ "$1" == "" ] || [ "$2" != "" ]; then
    echo "Usage:   $0 [-helamps] <filename>"
    echo "Example: $0 ./check.exe"
    exit 1
  fi
  file=$1

  # Disassemble selected file
  # Use cut -f3- to print only the assembly code after two leading fields separated by tabs
  dumptmp=${file}.objdump.tmp
  if [ "$helamps" == "0" ]; then
    objdump -d -C $file | awk '/^ +[[:xdigit:]]+:\t/' | cut -f3- > ${dumptmp}
  else
    objdump -d -C $file | awk -v RS= '/^[[:xdigit:]]+ <MG5_sm::.*/' | awk '/^ +[[:xdigit:]]+:\t/' | cut -f3- > ${dumptmp}
  fi
  ###ls -l $dumptmp

  # Count and strip AVX512 zmm symbols
  cnt512z=$(stripSyms '^v.*zmm')
  ###echo $cnt512z; ls -l $dumptmp

  # Count and strip AVX512 ymm/xmm symbols
  # [NB: these are AVX512VL symbols, i.e. implementing AVX512 on xmm/ymm registers]
  cnt512y=$(stripSyms '^v.*dqa(32|64).*(x|y)mm' '^v.*(32|64)x2.*(x|y)mm' '^vpcmpneqq.*(x|y)mm')
  ###echo $cnt512y; ls -l $dumptmp

  # Count and strip AVX2 symbols
  cntavx2=$(stripSyms '^v.*(x|y)mm')
  ###echo $cntavx2; ls -l $dumptmp

  # Count and strip ~SSE4 symbols
  ###cntsse4=$(stripSyms '^[^v].*xmm') # 'too many'(*): includes many symbols from "none" build
  cntsse4=$(stripSyms '^[^v].*p(d|s).*xmm') # okish, representative enough of what sse4/nehalem adds
  ###cntsse4=$(stripSyms '^(mul|add|sub)p(d|s).*xmm') # too few: should also include moves
  ###echo $cntsse4; ls -l $dumptmp

  # Is there anything else?...
  ###cntelse=$(stripSyms '.*(x|y|z)mm') # only makes sense when counting 'too many'(*) as sse4
  ###echo $cntelse; ls -l $dumptmp
  ###if [ "$cntelse" != "0" ]; then echo "ERROR! cntelse='$cntelse'"; exit 1; fi 

  # Final report
  printf "=== Symbols in $file === (~sse4:%5d) (avx2:%5d) (512y:%5d) (512z:%5d)\n" $cntsse4 $cntavx2 $cnt512y $cnt512z

}

mainSummarizeSyms $*

#----------------------------------------------------------------------------------------------
