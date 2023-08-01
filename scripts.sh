# Exit the script immediately if any command fails
set -e

# Exit the script if any command in a pipeline fails
set -o pipefail

essential_packages="gnome-tweaks tree dconf-editor curl git python3-pip lolcat figlet pulseaudio"

alias scripts_update="sudo apt-get update"
alias scripts_upgrade="sudo apt-get -y upgrade"
alias scripts_install="sudo apt-get -y install"

basic_start() {
    scripts_update
    scripts_upgrade
    scripts_install $essential_packages
}

install_ros() {
    # 1.1 Update source list
    scripts_update

    # 1.2 Setup Sources
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

    # 1.3 Setup Keys
    scripts_install curl
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    # 1.4 Installation
    scripts_update
    scripts_install ros-noetic-desktop-full

    # 1.5 Environment Setup
    echo "source /opt/ros/noetic/setup.bash" >> ~/.$(basename $SHELL)rc
    source ~/.$(basename $SHELL)rc

    # 1.6 Install Build Dependencies
    scripts_install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin
    sudo rosdep init
    rosdep scripts_update
}

install_go() {
    curl https://dl.google.com/go/go1.20.6.linux-amd64.tar.gz --output /tmp/go1.20.6.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go1.20.6.linux-amd64.tar.gz
    rm go1.20.6.linux-amd64.tar.gz
    cd
}

install_zsh() {
    # 1.1 Install zsh shell
    scripts_install zsh

    # Change shell to zsh
    chsh -s $(which zsh)

    # Install OhMyZsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/scripts_install.sh)"
    scripts_install fonts-powerline

    # Copy .zshrc and powerline10k conf
    cp .zshrc ~/.zshrc
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    cp .p10k.zsh ~/.p10k.zsh

    # Install Plugins

    # Autosuggestion
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    # Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlightingm
}

install_vscode() {
    curl https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 --output /tmp/vscode.deb
    scripts_install /tmp/vscode.deb
}

install_ulauncher() {
    sudo add-apt-repository ppa:agornostal/ulauncher
    scripts_update
    scripts_install ulauncher
}

install_node() {
    scripts_install curl
    curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
    scripts_install nodejs
}

install_mailspring() {
    curl https://updates.getmailspring.com/download?platform=linuxDeb --output /tmp/mailspring.deb
    scripts_install /tmp/mailspring.deb
}

install_discord() {
    curl https://discord.com/api/download?platform=linux&format=deb --output /tmp/discord.deb
    scripts_install /tmp/discord.deb
}

fresh_install() {
    basic_start
    install_zsh
    install_vscode
    install_ulauncher
    install_ros
    install_go
    install_node
    install_mailspring
    install_discord
}