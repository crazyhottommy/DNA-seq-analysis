`Segment_Mean` is the log2 ratio of the sample (tumor and matched normal) intensity to the reference pool intensity. 
0 means the CN is 2N. To convert to an absolute cn, use:  (2^seg_mean)*2  [see here](https://www.biostars.org/p/112310/#146946)

>In general a zero value corresponding to CN2. You have to define a threshold for a deletion and duplication. This group used -0.2 and 0.2, respectively. http://mcr.aacrjournals.org/content/12/4/485.long
