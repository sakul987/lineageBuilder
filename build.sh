unset LOS_REPO_INITIALIZED
unset LOS_UTILS_INSTALLED
source ~/.bashrc
cd
#export LOS_B=lineage-18.1
#export LOS_D=a5y17lte

if [[ -z "$LOS_UTILS_INSTALLED" ]]; then
    # make dirs for repo tool & source
    mkdir -p ~/bin
    mkdir -p ~/android/lineage

    # get repo tool
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    echo "export PATH=$PATH:/home/$USER/bin" >> ~/.bashrc

    # enable ccache with 50GB
    echo "export USE_CCACHE=1" >> ~/.bashrc
    echo "export CCACHE_EXEC=/usr/bin/ccache" >> ~/.bashrc
    ccache -M 50G

    echo "export LOS_UTILS_INSTALLED=true" >> ~/.bashrc
    source ~/.bashrc
fi

if [[ -z "$LOS_REPO_INITIALIZED" ]]; then
    #configure git user
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    # initialize source repo
    cd ~/android/lineage
    # (press enter for default when asked if you want some color stuff)
    echo -ne '\n' | repo init -u https://github.com/LineageOS/android.git -b $LOS_B --git-lfs

    echo "export LOS_REPO_INITIALIZED=true" >> ~/.bashrc
    source ~/.bashrc
fi

cd ~/android/lineage

#get setup script funcs
source build/envsetup.sh

#repo checkout#####?

# sync src, might take a while
repo sync

# copy proprietary blobs into correct dir
cp -r ~/blobs/vendor/* vendor/

# get device specific code
breakfast $LOS_D

if [[ -z "$LOS_KEYS_EXIST" ]]; then
    # create sign keys if the dont exist (no password)
    subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'
    mkdir ~/.android-certs
    for cert in bluetooth cyngn-app media networkstack platform releasekey sdk_sandbox shared testcert testkey verity; do \
        echo -ne '\n' | ./development/tools/make_key ~/.android-certs/$cert "$subject"; \
    done

    echo "export LOS_KEYS_EXIST=true" >> ~/.bashrc
    source ~/.bashrc
fi

# build packages
mka target-files-package otatools

croot

# sign packages
sign_target_files_apks -o -d ~/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip

# create installer
ota_from_target_files -k ~/.android-certs/releasekey --block --backup=true signed-target_files.zip signed-ota_update.zip

#make clean#?
