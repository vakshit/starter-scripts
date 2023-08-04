#!/bin/bash
# Exit the script immediately if any command fails
set -e

# Exit the script if any command in a pipeline fails
set -o pipefail

#COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;          # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;          # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;          # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;          # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

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
    prompt -i "Basic update upgrade and installing essential packages"
    scripts_update
    scripts_upgrade
    scripts_install gnome-tweaks tree dconf-editor curl git python3-pip lolcat figlet pulseaudio chrome-gnome-shell gnome-shell-extensions copyq

    # setup git credentials
    git config --global user.email "akshitv18@gmail.com"
    git config --global user.name "vakshit"

    # Copy config files
    cp $(pwd)/config_files/.zshrc $HOME
    cp $(pwd)/config_files/.p10k.zsh $HOME
    cp -r $(pwd)/custom_files/ $HOME

    # Restore dash to dock settings
    dconf load /org/gnome/shell/extensions/dash-to-dock/ < settings/dash_to_dock_settings.dconf

    # Restore terminal settings
    dconf load /org/gnome/terminal/legacy/profiles:/ < settings/terminal-profile.dconf.dconf

    # Restore Extensions
    cat settings/extensions.dconf | while read line; do gnome-extensions enable "$line"; done

    # Restore Gnome Settings
    dconf load / < settings/gnome-settings.dconf
}

install_wallpaper() {
    prompt -i "Installing Dynamic Wallpapers"

    WALPAPER_DEST="/usr/share/backgrounds/Dynamic_Wallpapers"
    XML_DEST="/usr/share/gnome-background-properties/"
    GIT_URL="https://github.com/saint-13/Linux_Dynamic_Wallpapers.git/"
    rm -rf Linux_Dynamic_Wallpapers
    # Clone .git folder -> Lightweigh checkout
    git clone --filter=blob:none --no-checkout "$GIT_URL"

    # List files in repo and create array of available walpapers
    walpaper_list="$(git --git-dir Linux_Dynamic_Wallpapers/.git ls-tree --full-name --name-only -r HEAD | \
	grep xml/ | \
	sed -e 's/^xml\///' | \
	sed -e 's/.xml//' | \
	sed -e 's/$/,,OFF/' | \
	tr "\n" "," \
    )"
    
    user_selection=cyberpunk-01

    # Create directories
    echo "-----------------"
    echo " ⚙️ Configuration"
    echo "-----------------"
    echo "- Walpapers destionation: $WALPAPER_DEST"
    echo "- XML slideshows destination: $XML_DEST"
    rm -rf $WALLPEPER_DEST
    sudo mkdir -p "$WALPAPER_DEST"
    echo "✅ Created $WALPAPER_DEST"
    rm -rf $WALLPEPER_DEST
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
    gsettings set org.gnome.desktop.background picture-uri $WALPAPER_DEST/cyberpunk-01.xml
    echo "💜 Please support on https://github.com/saint-13/Linux_Dynamic_Wallpapers"
    rm -rf Linux_Dynamic_Wallpapers

    prompt -i "Wallpaper installed"
}

install_grub_theme() {
    prompt -i "Installing Grub Theme"

    chmod +x $(pwd)/settings/Vimix/install.sh
    sudo $(pwd)/settings/Vimix/install.sh

    prompt -i "Grub Theme installed"
}

install_microsoft_edge() {
    prpmpt -i "Installing Microsoft Edge"

    curl --output /tmp/edge.deb -L https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_115.0.1901.188-1_amd64.deb?brand=M102
    scripts_install /tmp/edge.deb
    scripts_update
    scripts_upgrade

    prompt -i "Microsoft Edge installed"
}

install_vscode() {
    prpmpt -i "Installing VSCode"

    curl --output /tmp/vscode.deb -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    scripts_install /tmp/vscode.deb

    prompt -i "Installed VSCode"
}

install_ulauncher() {
    prompt -i "Installing ULauncher"

    sudo add-apt-repository ppa:agornostal/ulauncher
    scripts_update
    scripts_install ulauncher
    pip3 install fuzzywuzzy
    git clone --depth=1 https://github.com/plibither8/ulauncher-vscode-recent $HOME/.local/share/ulauncher/extensions/com.github.plibither8.ulauncher-vscode-recent

    prompt -i "Installed ULauncher with code extension"
}

install_go() {
    prompt -i "Installing golang"

    curl https://dl.google.com/go/go1.20.6.linux-amd64.tar.gz --output /tmp/go1.20.6.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.20.6.linux-amd64.tar.gz

    prompt -i "Installed golang"
}

install_node() {
    prompt -i "Installing Node"

    scripts_install curl
    curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
    scripts_install nodejs
    scripts_install yarn

    prompt -i "Installed Node"
}

install_ros() {
    prompt -i "Installing ROS"
    
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
    prompt -i "Installing Mailspring"

    curl --output /tmp/mailspring.deb -L "https://updates.getmailspring.com/download?platform=linuxDeb" 
    scripts_install /tmp/mailspring.deb

    prompt -i "Installed Mailspring"
}

install_discord() {
    prompt -i "Installing Discord"

    curl --output /tmp/discord.deb -L "https://discord.com/api/download?platform=linux&format=deb"
    scripts_install /tmp/discord.deb

    prompt -i "Installed Discord"
}

install_zsh() {
    prompt -i "Installing ZSH Shell"

    # 1.1 Install zsh shell
    scripts_install zsh
    export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

    # Install OhMyZsh
    rm -rf $HOME/.oh-my-zsh 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    scripts_install fonts-powerline
    
    echo $HOME
    export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Install Font
    sudo cp $(pwd)/settings/MLGSNF.ttf /usr/share/fonts/truetype/
    sudo fc-cache -f

    # Install Plugins

    # Autosuggestion
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    # Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

    prompt -i "Installed ZSH Shell. Please restart your machine"
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
