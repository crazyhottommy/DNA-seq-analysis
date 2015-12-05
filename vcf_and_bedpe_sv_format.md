### VCF format structural variants

The standard format for variants is the vcf. Read the vcf4.2 [specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).


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

### Bedpe converted from vcf4.2 by [svtools](https://github.com/hall-lab/svtools/issues/5#issuecomment-161432757)

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
