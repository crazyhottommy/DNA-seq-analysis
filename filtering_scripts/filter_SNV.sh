#! /bin/bash

### This script is used to filter the SNV calls produced by speedseq
### it is a wrapper for the vawk https://github.com/cc2qe/vawk

set -e
set -u
set -o pipefail

function usage() {
    echo "
Program: filter_SNVs.sh
Version: 0.0.3
Author: Ming Tang (mtang1@mdanderson.org)
usage:  filter_SNVs.sh [options] <vcf.gz>
example: filter_SNVs.sh -S 20 -N 2 my.vcf.gz

This program filters SNV calls with maximal N (default 2) support reads for normal,
and a minimal somatic score of S (default 18)

options: -h       show this message
options: -S     minmal Somatic score (SSC) the variants  (default 18)
options: -N     maximal Pieces of evidences Support the variants for normal sample (default 2)
"
}

## set defaults
SSC_cutoff=18
Normal_SU=2

while getopts ":hT:N:R:"  OPTION
do
	case "$OPTION" in
	h)  usage
		exit 1
		;;
	S)	SSC_cutoff="${OPTARG}"
		;;
	N)	Normal_SU="${OPTARG}"
		;;
#	*)	usage
#		exit 1
#		;;
	esac
done

## now parsing the positional parameters
shift $[ $OPTIND -1 ]

## set vcf to $1, default to empty string if $1 is not supplied
## see here http://redsymbol.net/articles/unofficial-bash-strict-mode/
vcf="${1:-}"

# check if $vcf exists or not
if [ ! -f "$vcf" ]
then
	echo "error! please provide a gzipped vcf file!"
	usage
	exit 1
fi


## check if vawk is installed

## in strick mode, if vawk is not installed, the whole program will exit instantly, add || true
## to make the exit code to 0.
VAWK=$(which vawk || true)

if [[ ! -f "$VAWK" ]]
then
	echo -e "Error: vawk is not installed, please install it from https://github.com/cc2qe/vawk"
	usage
	exit 1
fi

##get the header for the vcf which contains the sample names in column 10 and 11
Normal=$(zless $vcf | grep "^#CHROM" | cut -f10)
Primary=$(zless $vcf | grep "^#CHROM" | cut -f11)


echo "Normal sample is $Normal"
echo "Primary sample is $Primary"

## one needs to escape the quotes and special character $
cmd1=$(printf "vawk --header 'S\$%s\$AO <= ${Normal_SU}  && I\$SSC >= ${SSC_cutoff}' " $Normal)

## add filtered_SNV as the suffix of the filtered vcf
echo "zless $vcf | $cmd1" | sh > "${vcf/vcf.gz/filtered_SNV.vcf}"
echo "filtering done for normal, tumor pair"
printf "###################################\n"
