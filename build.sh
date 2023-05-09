unset LOS_REPO_INITIALIZED
unset LOS_UTILS_INSTALLED
unset LOS_BUILD_UTILS_INSTALLED
source $HOME/.bashrc
cd
#export LOS_B=lineage-18.1
#export LOS_D=a5y17lte
#export PATCHFILE="android_frameworks_base-R.patch"

if [[ -z "$LOS_BUILD_UTILS_INSTALLED" ]]; then
    #install needed packages
    sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python-is-python3

    echo "export LOS_BUILD_UTILS_INSTALLED=true" >> $HOME/.bashrc
    source $HOME/.bashrc
fi

if [[ -z "$LOS_UTILS_INSTALLED" ]]; then
    # make dirs for repo tool & source
    mkdir -p $HOME/bin
    mkdir -p $HOME/android/lineage

    # get repo tool
    curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
    chmod a+x $HOME/bin/repo
    echo "export PATH=$PATH:/home/$USER/bin" >> $HOME/.bashrc

    # enable ccache with 50GB
    echo "export USE_CCACHE=1" >> $HOME/.bashrc
    echo "export CCACHE_EXEC=/usr/bin/ccache" >> $HOME/.bashrc
    ccache -M 50G

    echo "export LOS_UTILS_INSTALLED=true" >> $HOME/.bashrc
    source $HOME/.bashrc
fi

if [[ -z "$LOS_REPO_INITIALIZED" ]]; then
    #configure git user
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    # initialize source repo
    cd $HOME/android/lineage
    # (press enter for default when asked if you want some color stuff)
    echo -ne '\n' | repo init -u https://github.com/LineageOS/android.git -b $LOS_B --git-lfs

    echo "export LOS_REPO_INITIALIZED=true" >> $HOME/.bashrc
    source $HOME/.bashrc
fi

cd $HOME/android/lineage

#repo checkout#####?

# sync src, might take a while
repo sync

#get setup script funcs
source build/envsetup.sh

# copy proprietary blobs into correct dir
cp -r $HOME/blobs/vendor/* vendor/

# apply microG signature spoofing patch # put your needed patch into $HOME/patch and specify with PATCHFILE
cd frameworks/base
sed 's/android:protectionLevel="dangerous"/android:protectionLevel="signature|privileged"/' "$HOME/patch/$PATCHFILE" | patch --quiet --force -p1

croot


# include apps of lineageos4microg
export WITH_GMS=true # dont know if needed
rm -rf .repo/local_manifests/manifest.xml
touch .repo/local_manifests/manifest.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> .repo/local_manifests/manifest.xml
echo "<manifest>" >> .repo/local_manifests/manifest.xml
echo "    <project path=\"vendor/partner_gms\" name=\"lineageos4microg/android_vendor_partner_gms\" remote=\"github\" revision=\"master\" />" >> .repo/local_manifests/manifest.xml
echo "</manifest>" >> .repo/local_manifests/manifest.xml


if [[ -z "$LOS_KEYS_EXIST" ]]; then
    # create sign keys if the dont exist (no password)
    subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'
    mkdir $HOME/.android-certs
    for cert in bluetooth cyngn-app media networkstack platform releasekey sdk_sandbox shared testcert testkey verity; do \
        echo -ne '\n' | ./development/tools/make_key $HOME/.android-certs/$cert "$subject"; \
    done

    echo "export LOS_KEYS_EXIST=true" >> $HOME/.bashrc
    source $HOME/.bashrc
fi

croot

# get device specific code
breakfast $LOS_D

# build packages
mka target-files-package otatools


# sign packages
sign_target_files_apks -o -d $HOME/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip

# create installer
ota_from_target_files -k $HOME/.android-certs/releasekey --block --backup=true signed-target_files.zip signed-ota_update.zip

# move out installer into home
mv signed-ota_update.zip $HOME/signed-ota_update.zip
rm -f signed-target_files.zip

#clean out dir
mka clean
mka clobber
