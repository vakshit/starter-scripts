#!/bin/bash
# Exit the script immediately if any command fails
set -e

# Exit the script if any command in a pipeline fails
set -o pipefail

scripts_update() {
    sudo apt-get update
}

scripts_upgrade() {
    sudo apt-get -y upgrade
}

scripts_install() {
    sudo apt-get -y install "$@"
}

basic_start() {
    echo "Basic update upgrade and installing essential packages"
    scripts_update
    scripts_upgrade
    scripts_install gnome-tweaks tree dconf-editor curl git python3-pip lolcat figlet pulseaudio chrome-gnome-shell gnome-shell-extensions

    # setup git credentials
    git config --global user.email "akshitv18@gmail.com"
    git config --global user.name "vakshit"

    # Copy config files
    cp config_files/* $HOME
    cp -r custom_files/ $HOME

    # Restore dash to dock settings
    dconf load /org/gnome/shell/extensions/dash-to-dock/ < settings/dash_to_dock_settings.txt

}

install_wallpaper() {
    WALPAPER_DEST="/usr/share/backgrounds/Dynamic_Wallpapers"
    XML_DEST="/usr/share/gnome-background-properties/"
    GIT_URL="https://github.com/saint-13/Linux_Dynamic_Wallpapers.git/"

    # Display interactive list to user
    user_selection=cyberpunk-01

    # Create directories
    echo "-----------------"
    echo " ⚙️ Configuration"
    echo "-----------------"
    echo "- Walpapers destionation: $WALPAPER_DEST"
    echo "- XML slideshows destination: $XML_DEST"
    sudo mkdir -p "$WALPAPER_DEST"
    echo "✅ Created $WALPAPER_DEST"
    sudo mkdir -p "$XML_DEST"
    echo "✅ Created $XML_DEST"

    echo "-------------------------"
    echo " 🚀 Installing walpapers"
    echo "-------------------------"
    while IFS= read -r to_install; do
        # Delete quotes in name
        name=$(echo "$to_install" | tr -d '"')
        echo "- Installing $name"

        # List jpeg files to install
        list_to_install=$(git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name" | \
            tail -n +3)

        # Install jpeg files
        while IFS= read -r file; do
            echo " Downloading Dynamic_Wallpapers/$name/$file"
            sudo mkdir -p "$WALPAPER_DEST/$name"
            git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name/$file" | \
                sudo tee "$WALPAPER_DEST/$name/$file" >/dev/null
        done <<< "$list_to_install"

        # Install xml
        echo " Downloading Dynamic_Wallpapers/$name.xml"
        git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name.xml" | \
            sudo tee "$WALPAPER_DEST/$name.xml" >/dev/null

        # Install slideshow xml
        echo " Downloading xml/$name.xml"
        git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:xml/$name.xml" | \
            sudo tee "$XML_DEST/$name.xml" >/dev/null
    done <<< "$user_selection"

    echo
    echo "Success !"
    gsettings set org.gnome.desktop.background $WALPAPER_DEST/cyberpunk-01.xml
    echo "💜 Please support on https://github.com/saint-13/Linux_Dynamic_Wallpapers"
}

install_grub_theme() {
    chmod +x settings/Vimix/install.sh
    sudo ./settings/Vimix/istall.sh
}

install_microsoft_edge() {
    echo "Installing Microsoft Edge"
    curl --output /tmp/edge.deb -L https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_115.0.1901.188-1_amd64.deb?brand=M102
    scripts_install /tmp/edge.deb
    scripts_update
    scripts_upgrade
}

install_vscode() {
    echo "Installing Vscode"
    curl --output /tmp/vscode.deb -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 "
    scripts_install /tmp/vscode.deb
}

install_ulauncher() {
    echo "Installing ULauncher"
    sudo add-apt-repository ppa:agornostal/ulauncher
    scripts_update
    scripts_install ulauncher
    pip3 install fuzzywuzzy
    git clone --depth=1 https://github.com/plibither8/ulauncher-vscode-recent $HOME/.local/share/ulauncher/extensions/com.github.plibither8.ulauncher-vscode-recent

}

install_go() {
    echo "Installing golang"
    curl https://dl.google.com/go/go1.20.6.linux-amd64.tar.gz --output /tmp/go1.20.6.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.20.6.linux-amd64.tar.gz
    rm go1.20.6.linux-amd64.tar.gz
    cd $HOME
}

install_node() {
    echo "Installing Node"
    scripts_install curl
    curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
    scripts_install nodejs
}

install_ros() {
    echo "Installing ROS"
    
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
    # already in one file
    # echo "source /opt/ros/noetic/setup.$(basename $SHELL)" >> ~/.$(basename $SHELL)rc
    # source ~/.$(basename $SHELL)rc

    # 1.6 Install Build Dependencies
    scripts_install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin
    sudo rosdep init
    rosdep update
}

install_mailspring() {
    echo "Installing Mailspring"
    curl --output /tmp/mailspring.deb -L "https://updates.getmailspring.com/download?platform=linuxDeb" 
    scripts_install /tmp/mailspring.deb
}

install_discord() {
    echo "Installing Discord"
    curl --output /tmp/discord.deb -L "https://discord.com/api/download?platform=linux&format=deb"
    scripts_install /tmp/discord.deb
}

install_zsh() {
    echo "Installing ZSH Shell"

    # 1.1 Install zsh shell
    scripts_install zsh
    echo $HOME
    export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    # Change shell to zsh
    chsh -s $(which zsh)

    # Install OhMyZsh
    rm -rf $HOME/.oh-my-zsh 
    rm $HOME/.zshrc 2> /dev/null
    rm $HOME/.p10k.zsh 2> /dev/null
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    scripts_install fonts-powerline
    
    echo $HOME
    export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

    # Copy .zshrc and powerline10k conf
    cp .zshrc $HOME/.zshrc
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    cp .p10k.zsh $HOME/.p10k.zsh

    # Install Plugins

    # Autosuggestion
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    # Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
}

fresh_install () {
    basic_start
    install_wallpaper
    install_grub_theme
    install_microsoft_edge
    install_vscode
    install_ulauncher
    install_go
    install_node
    install_mailspring
    install_discord
    install_ros
    install_zsh
}

fresh_install
