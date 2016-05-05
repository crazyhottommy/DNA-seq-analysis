#! /bin/bash

### This script is used to filter the structural variation vcf file produced by lumpy/speedseq

set -e
set -u
set -o pipefail

function usage() {
    echo "
Program: filter_vcf.sh
Version: 0.0.2
Author: Ming Tang (mtang1@mdanderson.org)
usage:  filter_vcf.sh [options] <vcf.gz>
example: filter_vcf.sh -T 2 -N 2 -R 3 my.vcf.gz

This program filters with normal genotype of 0/0, primary genotype of 0/1 or 1/1, and 
recurrent genotype of 0/1 or 1/1 if there is any with maximal N (default 0) support reads for normal,
minimal T (default 3) support reads for primary and minimal R (default 3) support reads for recurrent.
   
options: -h       show this message
options: -T     minmal Pieces of evidences Support the variants for tumor sample (default 3)
options: -R     minmal Pieces of evidences Support the variants for recurrent tumor sample (default 3)
options: -N     maximal Pieces of evidences Support the variants for normal sample (default 0)
"
}


## set defaults
Tumor_SU=3
Normal_SU=0
Recurrent_SU=3


while getopts ":hT:N:R:"  OPTION
do 
	case "$OPTION" in
	h)  usage
		exit 1
		;;
	T)	Tumor_SU="${OPTARG}"
		;;
	N)	Normal_SU="${OPTARG}"
		;;
	R)	Recurrent_SU="${OPTARG}"
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
## if there is no recurrent sample, Recurrent will be evaluated to empty string
Recurrent=$(zless $vcf | grep "^#CHROM" | cut -f12)

echo "Normal sample is $Normal"
echo "Primary sample is $Primary"
echo "Recurrent sample is ${Recurrent:-None}"

## one needs to escape the quotes and special character $ 

# can be further filtered  with SU <= 0  in normal and SU >= 3 in primary tumor
cmd1=$(printf "vawk --header '(S\$%s\$GT==\"0/1\" || S\$%s\$GT==\"1/1\") && S\$%s\$GT==\"0/0\" && \
S\$%s\$SU <= "${Normal_SU}"  && S\$%s\$SU >= "${Tumor_SU}" ' " "$Primary" "$Primary" "$Normal" "$Normal" "$Primary")



## filter Recurrent against normal 
cmd2=$(printf "vawk --header '(S\$%s\$GT==\"0/1\" || S\$%s\$GT==\"1/1\") && S\$%s\$GT==\"0/0\" && \
S\$%s\$SU <= "${Normal_SU}"  && S\$%s\$SU >= "${Recurrent_SU}" ' " "$Recurrent" "$Recurrent" "$Normal" "$Normal" "$Recurrent")


if [ -z $Recurrent ]
then
	echo "zless $vcf | $cmd1" | sh > "${vcf/vcf.gz/filtered_primary.vcf}"
	echo "filtering done for normal, tumor pair"
	printf "###################################\n"
else
	echo "zless $vcf | $cmd1" | sh > "${vcf/vcf.gz/filtered_primary.vcf}"
	echo "zless $vcf | $cmd2" | sh > "${vcf/vcf.gz/filtered_recurrent.vcf}"
	echo "filtering done for triplets"
	printf "###################################\n"
fi
	
