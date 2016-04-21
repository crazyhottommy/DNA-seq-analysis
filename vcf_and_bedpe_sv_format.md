### VCF format structural variants

The standard format for variants is the vcf. Read the vcf4.2 [specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

### Lumpy outputs structural variants in VCF4.2 format.

some notes from [Colby Chiang](https://github.com/hall-lab/svtools/issues/104):

Hi, Thanks for making this useful tool. I am using vcfToBedpe to convert vcf from lumpy.
The resulting bedpe files in column 9 and 10 have strandness info "+" "-"
what does exactly those strandness tell us?
for translocations (BND), I found there are 4 different combinations of the strandness.
for deletions, it is always+ -
for inversions, it is always + +
for duplications, it is always - +

Thanks very much!
Ming

>BND is a catch-all for a generic breakpoint, so you can't assume all to be translocations

>When LUMPY reports a BND with both sides on the same chromsome, it is indicating misoriented reads (++ or --). When we see reciprocal evidence (both ++ and -- from the same event), LUMPY calls this an inversion. Howevere, when only one of these orientations are observed, it is designated a BND. Some of these "one-sided inversion" BNDs might be true inversions where we miss one of the sides, and others may be parts of complex variants or artifacts.

Thanks for clarifying this. So, a BND with both sides on the same chromosome can be an INV. Can it be a DUP or DEL?

>LUMPY never represents breakpoints with DEL or DUP orientations as BNDs. Only one sided inversions and interchromosomal events

### BEDPE format

Sometimes, BEDPE format is easier to use for processing.

[BEDPE](http://bedtools.readthedocs.org/en/latest/content/general-usage.html#bedpe-format) is defined in the bedtools documentation.  

See also [here](http://software.10xgenomics.com/docs/pipelines/output/bedpe)  
The BEDPE contains one SV per line with the following tab-delimited columns:

1. chrom1 - chromosome of the first breakpoint

2. start1 - start position of the first breakpoint

3. end1 - end position of the first breakpoint

4. chrom2 - chromosome of the second breakpoint

5. start2 - start position of the second breakpoint

6. end2 - end position of the second breakpoint

7. name - a unique string identifying the SV

8. quality - Phred-like quality score

9. strand1 - strand of the first breakpoint (not currently used; always '+')

10. strand2 - strand of the second breakpoint (not currently used; always '+')

11. filter - a semicolon-delimited list of filters that were applied to the SV, or single period (.) if the SV was not filtered out

12. info - extra information about the SV or a single period (.)



### Make sure you read this: [SV representations in BEDPE format](https://gist.github.com/ernfrid/e6af5c7a56758aaf3fbb)

I just copied from [Dave Larson](https://gist.github.com/ernfrid). credit goes to him!
There is a hot discussion on this at the [svtools issues](https://github.com/hall-lab/svtools/issues/49)


# Background
BEDPE coordinates refer to a genomic position, but it is unclear to me what position (relative to an SV) they are intended to convey. This is illustrated in the case where we know precisely where the breakpoints are.

# Potential Reporting Conventions
1. Affected Bases (AFF)
2. Left of the breakpoint (LOB)
3. Right of the breakpoint (ROB)
4. Exact breakpoint (BPT)
5. Last-aligned Base (LAB)

# Events to support
1. Simple Deletions
2. Simple Insertions
3. Range Math on coordinates
4. Balanced Translocations/Inversion
5. Telomeric Deletions
6. Unbalanced Translocations/Inversions
7. Telomeric Insertions

# Simple Deletions

## Alignment for fictional 5bp DEL
We will call the chromosome below 'chr'.

Plain alignment:
```
REF ACGTGCC
ALT A-----C
```

With 0-based coordinates (BED):
```
    0123456
REF ACGTGCC
ALT A-----C
```

With 1-based coordinates (VCF):
```
    1234567
REF ACGTGCC
ALT A-----C
```

## VCF Entry as a precise SV 
Assume chromosome name is 1
```
chr 1 . ACGTGC  A . PASS  SVTYPE=DEL;END=6
```

## VCF Entry as BND entries (again, precise)
```
chr 1 . A A[chr:7[  . PASS  SVTYPE=BND
chr 7 . C ]chr:1]C  . PASS  SVTYPE=BND
```

## BEDPE Entry options
### AFF
The coordinates label the first and last deleted bases.
```
chr 1 2 chr 5 6
```
* Note that for range arithmetic, the length would be end2 - start1

### LOB
The coordinates label the base to the left of the breakpoint(s).
```
chr 0 1 chr 5 6
```
* Note that for range arithmetic, the length would be start2 - start1 or end2 - end1 but that start2 - end1 and end2 - start1 would not give the length.

### ROB
The coordinates label the base to the right of the breakpoint(s).
```
chr 1 2 chr 6 7
```
* Note that for range arithmetic, the length would be start2 - start1 or end2 - end1 but that start2 - end1 and end2 - start1 would not give the length.

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr 1 1 chr 6 6
```
* Note that for range arithmetic, the length is the same no matter which coordinates you use between the two coordinate sets.

### LAB
Coordinates specify the "last-aligned base" as in VCF
```
chr 0 1 chr 6 7
```
* Note that for range arithmetic, the length would be start2 - end1 or end2 - end1 - 1 or start2 - start1 -1.

# Simple Insertions
## Alignment for fictional 5bp INS
We will call the chromosome below 'chr'.

Plain alignment:
```
REF A-----C
ALT ACGTGCC
```

With 0-based coordinates (BED):
```
    0123456
REF A-----C
ALT ACGTGCC
```

With 1-based coordinates (VCF):
```
    1234567
REF A-----C
ALT ACGTGCC
```
## VCF Entry as a precise SV 
Assume chromosome name is chr
```
chr 1 . A  ACGTGC . PASS  SVTYPE=INS;END=1
```

## VCF Entry as BND entries (again, precise)
```
chr 1 . A ACGTGC[chr:2[  . PASS  SVTYPE=BND
chr 2 . C ]chr:1]CGTGCC  . PASS  SVTYPE=BND
```

## BEDPE Entry options
Note that range arithmetic would not apply to these cases as insertion size has no effect on the coordinates of the reference.

### AFF
This seems to make no sense. What base is the affected-based? You would have to fall back to either leftmost or rightmost base in this case. See those below.
### LOB
```
chr 0   1 chr 0   1
```
### ROB
```
chr 1   2   chr 1   2
```
### BPT
```
chr 1   1   chr 1   1
```
### LAB
```
chr 0   1   chr 1   2
```

# Reciprocal Translocations/Inversions
Will only consider inversions as those actually have some range math applications that may prove illustrative.

## Alignment for fictional 5bp INV
We will call the chromosome below 'chr'

Plain alignment:
```
REF ATGTGCC
ALT AGCACAC
```

With 0-based coordinates (BED):
```
    0123456
REF ATGTGCC
ALT AGCACAC
```

With 1-based coordinates (VCF):
```
    1234567
REF ATGTGCC
ALT AGCACAC
```

## VCF Entry as a precise SV
```
chr 1   .   ATGTGC   AGCACA   .   PASS    SVTYPE=INV;END=6
```

## VCF Entries as a BND. Includes ALL breakends
```
chr 1   .   A   A]chr:6]    .   PASS    SVTYPE=BND
chr 2   .   T   [chr:7[T    .   PASS    SVTYPE=BND
chr 6   .   C   C]chr:1]    .   PASS    SVTYPE=BND
chr 7   .   C   [chr:2[C    .   PASS    SVTYPE=BND
```

## BEDPE Entry options

### AFF
```
chr 1   2   chr 5   6
```
* Note for range arithmetic, the length would be end2 - start1 

### LOB
```
chr 0   1   chr 5   6
```
* Note that for range operations, the length is end2 - end1. 

### ROB
```
chr 1   2   chr 6   7
```
* Note that for range operations, the length is end2 - end1.

### BPT
```
chr 1   1   chr 6   6
```
* Note that for the range arithmetic, the length is the same no matter which coordinates you use.

### LAB
```
chr 0   1   chr 6   7
```
* Note that for the range arithmetic, the length end2 - start2 - 1.

# Telomeric Deletion (Right)

## Alignment for fictional telomeric DEL
We will call the chromosome below 'chr'.

Plain alignment:
```
REF ACGTGCC
ALT A------
```

With 0-based coordinates (BED):
```
    0123456
REF ACGTGCC
ALT A------
```

With 1-based coordinates (VCF):
```
    1234567
REF ACGTGCC
ALT A------
```

## VCF Entry as a precise SV 
Assume chromosome name is 1
```
chr 1 . A  <DEL> . PASS  SVTYPE=DEL;END=7
```

## VCF Entry as BND entries (again, precise)
```
chr 1 . A .[chr:8[  . PASS  SVTYPE=BND
chr 8 . N ]chr:1].  . PASS  SVTYPE=BND
```

## BEDPE Entry options
### AFF
The coordinates label the first and last deleted bases.
```
chr 1 2 chr 6 7
```
* Note that for range arithmetic, the length would be end2 - start1

### LOB
The coordinates label the base to the left of the breakpoint(s).

```
chr 0 1 chr 6 7
```
* Note that for range arithmetic, the length would be end2 - end1

### ROB
The coordinates label the base to the right of the breakpoint(s). It would have to be allowed or hacked to go greater than the length of the reference for BED
```
chr 1 2 chr 7 8
```
* Note that for range arithmetic, the length would be start2 - start1 or end2 - end1 but that start2 - end1 and end2 - start1 would not give the length.

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr 1   1 chr 7   7
```
* Note that for range arithmetic, the length is the same no matter which coordinates you use between the two coordinate sets.

### LAB
Coordinates specify the "last-aligned base" as in VCF. This would also have to allow for virtual bases off the end of the reference
```
chr 0 1 chr 7 8
```
* Note that for range arithmetic, the length would be start2 - start1 - 1 or end2 - end1 -1.

# Telomeric Deletion (Left)

## Alignment for fictional telomeric DEL
We will call the chromosome below 'chr'.

Plain alignment:
```
REF ACGTGCC
ALT ------C
```

With 0-based coordinates (BED):
```
    0123456
REF ACGTGCC
ALT ------C
```

With 1-based coordinates (VCF):
```
    1234567
REF ACGTGCC
ALT ------C
```

## VCF Entry as a precise SV 
Assume chromosome name is 1
```
chr 0 . N  <DEL> . PASS  SVTYPE=DEL;END=6
```

## VCF Entry as BND entries (again, precise)
```
chr 0 . N .[chr:7[  . PASS  SVTYPE=BND
chr 7 . C ]chr:0]C  . PASS  SVTYPE=BND
```

## BEDPE Entry options
### AFF
The coordinates label the first and last deleted bases.
```
chr 0 1 chr 5 6
```
* Note that for range arithmetic, the length would be end2 - start1

### LOB
The coordinates label the base to the left of the breakpoint(s). This breaks for this variant type.

### ROB
The coordinates label the base to the right of the breakpoint(s).
```
chr 0 1 chr 6 7
```
* Note that for range arithmetic, the length would be start2 - start1 or end2 - end1 but that start2 - end1 and end2 - start1 would not give the length.

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr 0 0 chr 6 6
```
* Note that for range arithmetic, the length is the same no matter which coordinates you use between the two coordinate sets.

### LAB
Coordinates specify the "last-aligned base" as in VCF. This breaks for the same reason as left-most base.

# Unbalanced Translocation
In VCF, these have to be explicitly labeled as a pair.

## VCF Entry as BND entries (from VCF spec)
```
chr2 321681 bnd_W G G[chr13:123460[     .   PASS  SVTYPE=BND;PARID=bnd_V;MATEID=bnd_X
chr2 321682 bnd_V T ]chr13:123456]T     .   PASS  SVTYPE=BND;PARID=bnd_W;MATEID=bnd_U
chr13 123456 bnd_U C C[chr2:321682[     .   PASS  SVTYPE=BND;PARID=bnd_X;MATEID=bnd_V
chr13 123460 bnd_X A ]chr2:321681]A     .   PASS  SVTYPE=BND;PARID=bnd_U;MATEID=bnd_W
```

## BEDPE Entry options
### AFF
The coordinates label the first and last bases affected. Not clear what this means here. I contend it is invalid and you'd have to fallback to one of the other methodologies below.

### LOB
The coordinates label the base to the left of the breakpoint(s).
```
chr2 321680 321681  chr13   123458  123459
chr2    321680  321681  chr13   123455  123456
chr13 123455    123456  chr2    321680  321681
chr13 123458    123459  chr2    321680  321681
```

### ROB
The coordinates label the base to the right of the breakpoint(s).
```
chr2 321681 321682  chr13   123459  123460
chr2    321682  321683  chr13   123456  123457
chr13 123456    123457  chr2    321681  321682
chr13 123459    123460  chr2    321681  321682
```

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr2 321681 321681  chr13   123459  123459
chr2    321681  321681  chr13   123456  123456
```

### LAB
Coordinates specify the "last-aligned base" as in VCF.

```
chr2 321680 321681  chr13   123459  123460
chr2    321681  321682  chr13   123455  123456
chr13 123455    123456  chr2    321681  321682
chr13 123459    123460  chr2    321680  321681
```

# Telomeric Insertions (Left)

## Alignment for fictional telomeric INS (on left)
We will call the chromosome below 'chr'.

Plain alignment:
```
REF --ACGTGCC
ALT GCACGTGCC
```

With 0-based coordinates (BED):
```
      0123456
REF --ACGTGCC
ALT GCACGTGCC
```

With 1-based coordinates (VCF):
```
      1234567
REF --ACGTGCC
ALT GCACGTGCC
```

## VCF Entry as a precise SV 
Assume chromosome name is 1
```
chr 0 . N  <INS> . PASS  SVTYPE=INS;END=0
```

## VCF Entry as BND entries (again, precise)
```
chr 0 . N .[ctg1:1[  . PASS  SVTYPE=BND
chr 1 . A ]ctg1:1000]A  . PASS  SVTYPE=BND
```

## BEDPE Entry options
### AFF
The coordinates label the first and last affected bases. Would have to label the base before the insertion. Can't do this in BED.

### LOB
The coordinates label the base to the left of the breakpoint(s). This breaks for this variant type.

### ROB
The coordinates label the base to the right of the breakpoint(s).
```
chr 0 1 chr 0 1
```

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr 0 0 chr 0 0
```

### LAB
Coordinates specify the "last-aligned base" as in VCF. This breaks for the same reason as left-most base.


# Telomeric Insertions (Right)

## Alignment for fictional telomeric INS (on left)
We will call the chromosome below 'chr'.

Plain alignment:
```
REF ACGTGCC--
ALT ACGTGCCGC
```

With 0-based coordinates (BED):
```
    0123456  
REF ACGTGCC--
ALT ACGTGCCGC
```

With 1-based coordinates (VCF):
```
    1234567  
REF ACGTGCC--
ALT ACGTGCCGC
```

## VCF Entry as a precise SV 
Assume chromosome name is 1
```
chr 7 . C  CGC . PASS  SVTYPE=INS;END=7
```

## VCF Entry as BND entries (again, precise)
```
chr 7 . C C[ctg1:1[  . PASS  SVTYPE=BND
chr 8 . N ]ctg1:1000].  . PASS  SVTYPE=BND
```

## BEDPE Entry options
### AFF
The coordinates label the first and last affected bases. For insertions this could/should be the base to the left of the event.
```
chr 6 7 chr 6 7
```

### LOB
The coordinates label the base to the left of the breakpoint(s).
```
chr 6 7 chr 6 7
```

### ROB
The coordinates label the base to the right of the breakpoint(s).
```
chr 7 8 chr 7 8
```

### BPT
Coordinates are 0-length ranges specifying the position of the breakpoint.
```
chr 7 7 chr 7 7
```

### LAB
Coordinates specify the "last-aligned base" as in VCF.
```
chr 6 7 chr 6 7
```




### Strandness of Bedpe converted from vcf4.2 by [svtools](https://github.com/hall-lab/svtools/issues/5#issuecomment-161432757)

let me make it more clear:

when I look at the vcf ouput for one sv, check the `strands=-+`.
BND as in the [vcf4.2](http://samtools.github.io/hts-specs/VCFv4.2.pdf) specification. 

```
14      38454918        5956_2  N       ]8:9174263]N    25.35   .       SVTYPE=BND;STRANDS=-+:4;CIPOS=-9,8;CIEND=-9,8;CIPOS95=0,0;CIEND95=0,0
8       9174263 5956_1  N       N[14:38454918[  25.35   .       SVTYPE=BND;STRANDS=+-:4;CIPOS=-9,8;CIEND=-9,8;CIPOS95=0,0;CIEND95=0,0;MATEID=....
```
when it is converted to bedpe:
```
8	9174253	9174271	14	38454908	38454926	my_sv	25.35  +   -  BND  ....
```
I noticed that the strands is  `+ -` for this particular example when converted to bedpe.

Now, compare it to the vcf4.2 specification:
```
REF ALT Meaning
s t[p[ piece extending to the right of p is joined after t
s t]p] reverse comp piece extending left of p is joined after t
s ]p]t piece extending to the left of p is joined before t
s [p[t reverse comp piece extending right of p is joined before t


The example in Figure 1 shows a 3-break operation involving 6 breakends. It exemplifies all possible orientations
of breakends in adjacencies. Notice how the ALT field expresses the orientation of the breakends.
#CHROM POS ID REF ALT QUAL FILTER INFO
2 321681 bnd W G G]17:198982] 6 PASS SVTYPE=BND
2 321682 bnd V T ]13:123456]T 6 PASS SVTYPE=BND
13 123456 bnd U C C[2:321682[ 6 PASS SVTYPE=BND
13 123457 bnd X A [17:198983[A 6 PASS SVTYPE=BND
17 198982 bnd Y A A]2:321681] 6 PASS SVTYPE=BND
17 198983 bnd Z C [13:123457[C 6 PASS SVTYPE=BND
```
and  look at the figure in the specification:

<img width="470" alt="screenshot 2015-12-02 14 28 10" src="https://cloud.githubusercontent.com/assets/4106146/11543213/05a0cdb0-9901-11e5-8467-d78b301a3e54.png">

My particular example will be similar to breakpoint `U` ( with strand +) and `V` (with strand -)

By Colby Chiang
>The strands field is an internal convention, and you should probably ignore it. It is a vestige of BEDPE, where deletions are always +-, dups are -+ and inversions are ++ or --.

>note that the STRANDs field is wrong for the secondary side of BND variants (anything with a SECONDARY info tag and a variant ID ending in _2). STRANDs reports the orientation of the primary breakend variant only. (This is why you should ignore STRANDs, and also why we'll probably remove it to avoid confusion in the future)
>also, in general, those +/- orientations reflect the strands of inward facing reads

>


Thanks for your answer. That being said, how is it possible for one to figure out the translocation (fusion) direction of the breakpoints from a bedpe file converted from vcf? or I can only tell from the vcf file? I hate the `[` `]` notations..it is very hard for me to remember...

```
-------------A------|------B----------------  chr8
                 BND 5956_1
-------------C------------|-----D----------- chr14
                           BND 5956_2
```

How can I tell  it is A-C, A-D or B-C, B-D fusion?
Thanks!
Ming

>yeah, the +- in the BEDPE file means that it connects A to D

```
++ would be A to C
-- would be B to D
-+ would be B to C
```

>So, + means the region is at the 5' of the breakpoint and - means the region is at the 3' of the breakpoint.

### Please also check the figure from [Structural variation discovery in the cancer genome using next generation sequencing: Computational solutions and perspectives](http://www.impactjournals.com/oncotarget/index.php?journal=oncotarget&page=article&op=view&path%5B%5D=3491)

![screenshot 2016-01-08 16 17 35](https://cloud.githubusercontent.com/assets/4106146/12210993/a86a52ca-b623-11e5-8f27-d5fa3b215f6e.png)
