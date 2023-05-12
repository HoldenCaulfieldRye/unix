# Why not make a bash script out of this? For now, run each of these one by one in terminal 

# Packages, libraries and configurations for your favorite programming activities, on Mac 

# Set bash as default shell 
chsh -s /bin/bash
# Create bash config file 
touch ~/.bashrc 

# Install Homebrew, the package manager for Mac (equivalent of apt-get on linux) 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install latest version of python 
brew install python
# Set python as alias for latest version of python (in this case python3) 
echo "alias python=python3" >> ~/.bashrc
# Install pip, the python package manager 
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

# open ~/.bashrc in text editor 
open ~/.bashrc 
# and now manually add the following to bashrc:
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin
# this will make sure python-pip stores executables for installed python packages in locations that are on PATH 

# Install git 
brew install git 
git config --global user.email "adalyac@gmail.com"

# install Git LFS (Large File Storage), which allows you to store large files (such as binary files eg NN weight files) separately from your Git repository, while still being able to version and track them with Git.
brew install git-lfs
git lfs install
git lfs install --system


# Install emacs 
brew tap d12frosted/emacs-plus
brew install emacs-plus


# Make only current directory display on terminal:
open ~/.bashrc
# and now manually add the following to .bashrc
replace:
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
with:
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi





