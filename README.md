This is supposed to be a script for my specific use case to build Lineage OS for my device.

It's designed to run inside an Ubuntu 22.04 LXC Container which only serves this one purpose and expects you to provide the proprietray blobs at ~/blobs/ needed to build.

The branch is specified with LOS_B=lineage-18.1 e.g.

Device with LOS_D=a5y17lte e.g.

I plan on adding the option to include MicroG, but first I will have to finish the base script.

To run the current script which should build a signed build:

`LOS_B=lineage-18.1 LOS_D=a5y17lte source build.sh`

//source to make it run in the current shell instead of its own, prevents issues with cd
