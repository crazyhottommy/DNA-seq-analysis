Let me demonstrate it with an example. Use the `ToothGrowth` data set in the `ggplot2` library  

```r
library(ggplot2)

ggplot(ToothGrowth, aes(x=as.factor(dose), y=len, color=supp)) + 
        geom_boxplot(position=position_dodge(0.9))+
        geom_jitter(position=position_dodge(0.9)) +
        xlab("dose")


```
![](https://github.com/crazyhottommy/DNA-seq-analysis/files/28465/Rplot.pdf)
