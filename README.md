This is supposed to be a script for my specific use case to build Lineage OS for my device.

It's designed to run inside a (fresh) Ubuntu 22.04 LXC Container which only serves this one purpose and expects you to provide the proprietray blobs at ~/blobs/ needed to build.

For me it looks like this:

`~/blobs/vendor/samsung/universal7880-common/`

The branch is specified with LOS_B=lineage-18.1 e.g.

Device with LOS_D=a5y17lte e.g.

Vendor LOS_V=samsung

MicroG Patch (from [here](https://github.com/lineageos4microg/docker-lineage-cicd/tree/master/src/signature_spoofing_patches)) PATCHFILE="android_frameworks_base-R.patch"

-> put in ~/patch

~~I plan on adding the option to include MicroG, but first I will have to finish the base script.~~

The current script works fine for me to build (up to LOS 18.1, check [this](https://wiki.lineageos.org/signing_builds) out for more details), however the microG part, even though it should be added, is not included in the resulting build for some reason. I will have to dig deeper.

To run the current script which should build a signed build:

`export LOS_B=lineage-18.1; export LOS_D=a5y17lte; export LOS_V=samsung; export PATCHFILE="android_frameworks_base-R.patch"; source build.sh`

Or just uncomment the env vars on the top and set your correct values

//source to make it run in the current shell instead of its own, prevents issues with cd
