
### Visualize Structural variants

Read several biostars posts:  
[Best Genome Browser To Look At Structural Variation Calls](https://www.biostars.org/p/52014/)  
[Which Multiscale Genome Browser Is The Best At Visualizing Structural Variants?](https://www.biostars.org/p/19455/)


### Use [svviz](https://github.com/svviz/svviz)

For some background on ssh tunnelling:  
* [max planck computing](http://www.mpcdf.mpg.de/services/network/secure-shell/ssh-tunnelling-port-forwarding)  
* [Connecting to a database behind a firewall](http://blog.trackets.com/2014/05/17/ssh-tunnel-local-and-remote-port-forwarding-explained-with-examples.html)  
* [SSH Tunneling Explained](https://chamibuddhika.wordpress.com/2012/03/21/ssh-tunnelling-explained/)

In HPC nautilus:  

#### deletion
`svviz -p 7777 -t del -b my.bam Homo_sapiens_assembly19.fasta 1 29320981 29321462`

#### insertion
`svviz -p 7777 -t ins -b my.bam Homo_sapiens_assembly19.fasta 3 2516030 2516054`

####translocation

`svviz -p 7777 -t tra -b my.bam Homo_sapiens_assembly19.fasta 7  50996890  9  106346679 +`

**start an ssh tunnel to the server on my own computer:**  
`ssh -L 127.0.0.1:7777:127.0.0.1:7777 username@nautilus -N`

open `127.0.0.1:7777` on my local computer.

### Use [pybamview](http://melissagymrek.com/pybamview/)	

In HPC:  
`pybamview --port=7777 --bam my.bam --ref Homo_sapiens_assembly19.fasta`
 
on my own computer:  
`ssh -L 127.0.0.1:7777:127.0.0.1:7777 mtang1@nautilus -N`


####Another way to do it:

on HPC:  
`hostname -f`  
cnode338.mdanderson.edu


Use the option `"--ip 0.0.0.0"`, which will allow a remote user to view the results. Also set which port to serve the web application by setting `"--port $PORT"` where `$PORT`is some large number, between 1024-65535. This must be a port for which your server's security settings allow incoming http traffic. The default port for PyBamView is 5000. An example command is shown below:

`pybamview --ip 0.0.0.0 --port=7777 --bam my.bam --ref Homo_sapiens_assembly19.fasta`

`pybamview --ip 0.0.0.0 --port=7777 --bam mt.bam --ref Homo_sapiens_assembly19.fasta`

Navigate to `http://$HOSTNAME:$PORT` in a web broswer, where $HOSTNAME is the hostname mentioned above, and $PORT is the argument you used for the port. You can share this URL, or navigate to an interesting alignment view and copy the resulting URL from the browser, with another person that has access to the same server. Note that if you need VPN to access the server, the other user will probably also need VPN access to view the URL.

for example:  
`http://cnode338.mdanderson.edu:7777`

### or use X window forwarding
`ssh -Y hostname`


### Use `maze` from delly developer

see [github page](https://github.com/tobiasrausch/delly/tree/master/vis/maze/)
I will investigate a bit on it.
