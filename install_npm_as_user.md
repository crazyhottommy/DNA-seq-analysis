In order to visalize the supporting reads for a structural variant from a bam file. I need to use [pybamview](http://melissagymrek.com/pybamview/index.html).  

It requires installing [npm](https://nodejs.org/en/) to make [snapshots of bam](http://melissagymrek.com/pybamview/snapshots.html) files.

Following this [link](http://tnovelli.net/blog/blog.2011-08-27.node-npm-user-install.html)(Thanks!), I installed npm as a local user:  


1. Add this to your $HOME/.npmrc (create the file if it doesn't exist already):

```
root =    /scratch/genomic_medicine/mtang1/.local/lib/node_modules
binroot = /scratch/genomic_medicine/mtang1/.local/bin
manroot = /scratch/genomic_medicine/mtang1/.local/share/man
```

2. Download the Nodejs source code from nodejs.org and install it under your $HOME/.local tree:
(You could try using a binary installer instead, but that hasn't worked for me since ~ 0.8.x)

```bash
wget https://nodejs.org/dist/v4.2.2/node-v4.2.2.tar.gz
tar xvzf node-v4.2.2.tar.gz
cd node-v4.2.2
./configure --prefix=$HOME/.local
make
make install
```

3. Create $HOME/.node_modules symlink. (This directory will be automatically searched when you load modules using require "module" in scripts. I'm not sure why Node doesn't search $HOME/.local/lib/node_modules by default.)

```bash
cd
ln -s .local/lib/node_modules .node_modules
```

4. Is $HOME/.local/bin in your path? Type

`which npm`

If it says $HOME/.local/bin/npm, you're done.

Otherwise, do this...

`export PATH=$HOME/.local/bin:$PATH`
...and add that line to your `$HOME/.profile` file, so it'll run every time you log in.

(Note: Unixes are adopting on $HOME/.local as the standard per-user program/library location, but they're not all there yet.)

Install pybamview:  

```bash
pip install --user pybamview
```

```bash
npm install npm --global
npm install d3 --global
npm install jsdom --global
```
