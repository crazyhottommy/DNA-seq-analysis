
In my pervious blog post, I wrote [How to get the cooridnates of the cytobands](http://crazyhottommy.blogspot.com/2015/10/cytogenetic-band-explained.html)  

Now, how about I want to get coordinates of the bigger band merging all the sub-bands.  
ex. chr1 p36.33 p36.32, p36.31, p36.23, p36.22, p36.13, p36.12, p36.11....p31.1  to `p3 chr1 0  84900000`  
This is a task that requires some efforts for text processing.
First look at what the data look like:

```
head -30 cytoBand.txt  
chr1	0	2300000	p36.33	gneg
chr1	2300000	5400000	p36.32	gpos25
chr1	5400000	7200000	p36.31	gneg
chr1	7200000	9200000	p36.23	gpos25
chr1	9200000	12700000	p36.22	gneg
chr1	12700000	16200000	p36.21	gpos50
chr1	16200000	20400000	p36.13	gneg
chr1	20400000	23900000	p36.12	gpos25
chr1	23900000	28000000	p36.11	gneg
chr1	28000000	30200000	p35.3	gpos25
chr1	30200000	32400000	p35.2	gneg
chr1	32400000	34600000	p35.1	gpos25
chr1	34600000	40100000	p34.3	gneg
chr1	40100000	44100000	p34.2	gpos25
chr1	44100000	46800000	p34.1	gneg
chr1	46800000	50700000	p33	gpos75
chr1	50700000	56100000	p32.3	gneg
chr1	56100000	59000000	p32.2	gpos50
chr1	59000000	61300000	p32.1	gneg
chr1	61300000	68900000	p31.3	gpos50
chr1	68900000	69700000	p31.2	gneg
chr1	69700000	84900000	p31.1	gpos100
chr1	84900000	88400000	p22.3	gneg
chr1	88400000	92000000	p22.2	gpos75
chr1	92000000	94700000	p22.1	gneg
chr1	94700000	99700000	p21.3	gpos75
chr1	99700000	102200000	p21.2	gneg
chr1	102200000	107200000	p21.1	gpos100
chr1	107200000	111800000	p13.3	gneg
chr1	111800000	116100000	p13.2	gpos50

```

The coordinates are sorted in a way that larger cytoband is also sorted: p3, p2, p1, q1, q2...
so we only need to keep the major chromosome band, and keep expanding the end coordinates until it hits a new band.
At the same time, tracking which chromosome is processed and which major band is processed.

A python script using a list of lists data structure can serve this purpose:

```python

import re
with open("/Users/Tammy/annotations/human/hg19_UCSC_genome/cytoBand.txt", "r") as f:
    # A list of lists
    # { ['chr1', 'p1','107200000', '125000000'], ['chr1',  'p2','84900000', '107200000'] ... ['chr2', 'p1' , '47800000', '93300000'],...} }
    genome_list = []
    # a set of chromosomes seen so far
    chrSet = set()
    # a set of chromosome arms seen so far
    armSet = set()
    # loop over each line
    for line in f:
        # split each line to a list
        lineSplit = line.strip().split()
        chr = lineSplit[0]
        start = lineSplit[1]
        end = lineSplit[2]
        band = lineSplit[3]
        ## this regex capture the p1 of p11, p11.1 or p12...
        arm = re.search('([pq]\d).+', band).group(1)

        # if this is the first time see this chr,
        # empty the armSet
        if chr not in chrSet:
            chrSet.add(chr)
            armSet = set()
            armSet.add(arm)
            arm_list = [chr, start, end, arm]
            genome_list.append(arm_list)
        else:
            if arm not in armSet:
                armSet.add(arm)
                arm_list = [chr, start, end, arm]
                ## append this to the genome_list
                genome_list.append(arm_list)
            else:
                ## keep the start of the arm as previous 
                new_start = genome_list[-1][1]
                ## change the previous end of the arm to current end
                new_end = end
                arm_list = [chr, new_start, new_end, arm]
                # mutate the last entry of arm_list
                genome_list[-1] = arm_list

ofile = open("/Users/Tammy/annotations/human/hg19_UCSC_genome/chrom_arm_list.txt", "w")
for arm_list in genome_list:
    ofile.write(arm_list[0] +"\t" + arm_list[1] + "\t" + arm_list[2] + "\t" + arm_list[3] + "\n")
    ## always remember to close the file!
ofile.close()

```

```bash
$ head chrom_arm_list.txt 
chr1	0	84900000	p3
chr1	84900000	107200000	p2
chr1	107200000	125000000	p1
chr1	125000000	142600000	q1
chr1	142600000	185800000	q2
chr1	185800000	214500000	q3
chr1	214500000	249250621	q4
chr10	0	40200000	p1
chr10	40200000	52900000	q1
chr10	52900000	135534747	q2

```

There are many ways to achieve the same purpose.
Just for some advanture, I used dictionary of dictionaries to record the data

```python

import re
with open("/Users/Tammy/annotations/human/hg19_UCSC_genome/cytoBand.txt", "r") as f:
    # A dictionary of dictionaries
    # { chr1: {'p1': ['107200000', '125000000'], 'p2': ['84900000', '107200000'] ...}, chr2:{ 'p1': ['47800000', '93300000'],...} }
    genome_dict = {}
    # a set of chromosomes seen so far
    chrSet = set()
    for line in f:
        lineSplit = line.strip().split()
        chr = lineSplit[0]
        start = lineSplit[1]
        end = lineSplit[2]
        band = lineSplit[3]
        ## this regex capture the p1 of p11, p11.1 or p12
        arm = re.search('([pq]\d).+', band).group(1)

        ## if it is the first time see this chromosome
        if chr not in chrSet:
            chrSet.add(chr)
            # initiate an empty dictionary
            arm_dict = dict()
            arm_dict[arm] = [start, end]
            genome_dict[chr] = arm_dict
        else:
            # if this chromosome arm seen the first time
            if not arm_dict.get(arm):
                arm_dict[arm] = [start, end]
            else:
                new_start = arm_dict[arm][0]
                new_end = end
                arm_dict[arm] = [new_start, new_end]
            genome_dict[chr] = arm_dict

ofile = open("/Users/Tammy/annotations/human/hg19_UCSC_genome/chrom_arm_dict.txt", "w")
for key in genome_dict.keys():
    for key2 in genome_dict[key].keys():
        ofile.write(key + "\t" + genome_dict[key][key2][0] + "\t" + genome_dict[key][key2][1] + "\t" + key2 +"\n")
ofile.close()

```
**Note that, There is no order of dictionary, so the output may not be sorted** 
You can sort by chr and start:  
` cat chrom_arm_dict.txt | sort -k1,1V -k2,2n`

`V` is only for GNU sort which will [sort chromsome in alpha-numeric order](http://crazyhottommy.blogspot.com/2013/09/amazing-gnu-sort.html)


