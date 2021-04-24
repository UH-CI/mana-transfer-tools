#!/bin/bash


function helpout() {
    echo ""
    echo "-i --infile       The path to the input listing file. (required)"
    echo "-h --help         This message"
    echo ""
    echo "EXAMPLE: ${0} -i foo.txt"
    echo ""
};


PARAMS=""

while (( "$#" )); do
  case "$1" in
    -i|--infile)
	  infile=${2}
	  shift 2
      ;;
    -h|--help)
	  helpout $@
	  exit 0
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

if [[ -z ${infile} ]]
then
    echo "-i (--infile) required and must exist.  Exiting..."
    helpout $@
    exit 1
fi
 

lcnt=`wc -l ${infile} | head -n 1 | awk '{print $1}'`
if [[ $((lcnt % 2)) == 1 ]]
then
  lcnt=$((lcnt + 1))
fi
sline=`echo "${lcnt}/2" | bc`

split --verbose -l ${sline} ${infile}

 

exit 0
