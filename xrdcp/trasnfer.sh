#!/bin/bash


function helpout() {
    echo ""
    echo "-i --infile          The path to the input listing file. (required)"
    echo "-r --remote         The path on the remote server that the file exist at. (required)"
    echo "-o --outdir          The path on the local host where to save the files.  Default is '.'"
    echo "-c --connections     The number of parallel connections to make (default is 32)"
    echo "-s --streams         The number of streams used by xrdcp (default is 15)"
    echo "-h --help            This message"
    echo "EXAMPLE: ${0} -i xaa -r \"root://eosuser.cern.ch//eos/user/7/total\" -o \".\""
    echo ""
    echo "EXAMPLE: ${0} -i xaa -r \"root://eosuser.cern.ch/\" -o \".\""
    echo ""
};

CONNECTIONS=32
STREAMS=15
PARAMS=""
REMOTE=""
OUTDIR=""
FILELIST=""


while (( "$#" )); do
  case "$1" in
    -i|--infile)
	  FILELIST=${2}
	  shift 2
      ;;
    -r|--remote)
	  REMOTE=${2}
	  shift 2
      ;;
    -o|--outdir)
	  OUTDIR=${2}
	  shift 2
      ;;
    -c|--connections)
	  CONNECTIONS=${2}
	  shift 2
      ;;
    -s|--streams)
	  STREAMS=${2}
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


if [[ ${FILELIST} == '' ]]
then
    echo " -i or --infile is required with listing file path.. Exiting."
    helpout $@
    exit 1
fi


if [[ ${OUTDIR} == '' ]]
then
    echo "-o or --outdir not specified.  Setting output directory to the current directory."
    OUTDIR="."
fi

if [[ ${REMOTE} == '' ]]
then
    echo "-r or --remote not specified.  Exiting."
    helpout $@
    exit 1
fi


which xrdcp 2> /dev/null > /dev/null
if [[ $? != 0 ]]
then
echo "This script requires xrootd/xrdcp.  Please install xrootd client. (yum install xrootd-client ).  Exiting."
exit 1
fi


which parallel 2> /dev/null > /dev/null
if [[ $? != 0 ]]
then
echo "This script requires GNU parallel.  Please install parallel. (yum install parallel ).  Exiting."
exit 1
fi


echo -e "\n\n----------------------------------------"
echo "Total transfers to perform: `wc -l ${FILELIST}` "
echo -e "----------------------------------------\n\n"

time cat ${FILELIST} | parallel --progress  -j ${CONNECTIONS} xrdcp -s --streams ${STREAMS} ${REMOTE%/}/{} ${OUTDIR%/}/


exit 0
