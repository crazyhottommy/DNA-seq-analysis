### Make a box-plot with jittered points 

Let me demonstrate it with an example. Use the `ToothGrowth` data set in the `ggplot2` library  

```r
library(ggplot2)

ggplot(ToothGrowth, aes(x=as.factor(dose), y=len, color=supp)) + 
        geom_boxplot(position=position_dodge(0.9))+
        geom_jitter(position=position_dodge(0.9)) +
        xlab("dose")
```
![](https://cloud.githubusercontent.com/assets/4106146/10983407/f4804756-83d7-11e5-8013-f34622f8860d.png)


I want to make the points seperate from each other rather than on the same vertical line.

```r
ggplot(ToothGrowth, aes(x= as.factor(dose), y=len, color= supp,fill= supp)) + 
        geom_point(position=position_jitterdodge(dodge.width=0.9)) +
        geom_boxplot(fill="white", alpha=0.1, outlier.colour = NA, 
                     position = position_dodge(width=0.9)) +
        xlab("dose")
```
![](https://cloud.githubusercontent.com/assets/4106146/10983409/f6d6ae28-83d7-11e5-9540-62585d42d08c.png)
