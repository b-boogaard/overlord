#!/usr/bin/env bash

RESET='\e[0m'           # Reset
RED='\e[0;31m'          # Red
GREEN='\e[0;32m'        # Green
YELLOW='\e[0;33m'       # Yellow
BLUE='\e[0;34m'         # Blue
PURPLE='\e[0;35m'       # Magenta
CYAN='\e[0;36m'         # Cyan
WHITE='\e[0;37m'        # White
BRED='\e[1;31m'         # Bold Red
BGREEN='\e[1;32m'       # Bold Green
BYELLOW='\e[1;33m'      # Bold Yellow
BBLUE='\e[1;34m'        # Bold Blue
BPURPLE='\e[1;35m'      # Bold Magenta
BCYAN='\e[1;36m'        # Bold Cyan
BWHITE='\e[1;37m'       # Bold White

check_dependency () {
  printf "$CYAN Checking for $1 installation. . . $RESET\n"
  which $1 > /dev/null

  result="$?"

  if [ "$result" -eq 0 ]
  then
    printf "$YELLOW $1 installation detected.$RESET\n"
  else
    printf "$RED $1 not detected.$RESET\n"
  fi

  return "$result"
}

check_install () {
  if [ $1 -eq 0 ]
  then
    shift 1
    printf "$GREEN $1 installed successfully.$RESET\n";
  else
    printf "$RED $1 installation failed. Aborting.$RESET\n";
    exit 1
  fi
}

# Install Ruby
if ! check_dependency "ruby"
then
  printf "$BRED Need ruby version to continue. Aborting installation.$RESET\n"
  exit 1
fi

# Install Homebrew
if ! check_dependency "brew"
then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  check_install $? "homebrew"
fi

# Install zsh
printf "$CYAN Checking for zsh installation. . . $RESET\n"
case $SHELL in
  *zsh)
    printf "$YELLOW zsh installation detected.$RESET\n"
    ;;
  *)
    printf "$CYAN Attempting to install zsh. . . $RESET\n"
    brew install zsh
    check_install $? 'zsh'
    ;;
esac

# Install oh-my-zsh
if [ "$ZSH" ]
then
  printf "$YELLOW oh-my-zsh installation detected.$RESET\n"
else
  printf "$CYAN Attempting to install oh-my-zsh.$RESET\n"
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  check_install $? 'oh-my-zsh'
fi

# Install zsh-syntax-highlighting
if [ -e $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]
then
  printf "$YELLOW zsh-syntax-highlighting plugin detected.$RESET\n"
else
  mkdir $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone git://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

  check_install $? 'zsh-syntax-highlighting'
fi

# Install python
if ! check_dependency "python"
then
  brew install python
  check_install $? "python"
fi

# Install vim
if ! check_dependency "vim"
then
  brew install macvim --env-std --override-system-vim
  check_install $? "vim"
  brew linkapps macvim
fi

# Install powerline
printf "$CYAN Checking for Powerline. . .$RESET\n"

if ! ls /Library/Python/2.7/site-packages/ | grep -i "*powerline*"
then
  printf "$YELLOW Powerline installation detected.$RESET\n"
else
  pip install https://github.com/Lokaltog/powerline/tarball/develop
  check_install $? "powerline"
fi

# Installing fonts for powerline
printf "$CYAN Checking for powerline fonts. . .$RESET\n"

if ! ls $HOME/Library/Fonts/ | grep -i powerline
then
  printf "$YELLOW Powerline fonts detected.$RESET\n"
else
  printf "$CYAN Installing fonts for powerline.$RESET\n"
  curl -L https://raw.githubusercontent.com/powerline/fonts/master/install.sh | sh
  wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
  mv PowerlineSymbols.otf $HOME/Library/Fonts

  check_install $? 'fonts'
  printf "$PURPLE Powerline fonts and symbols installed at $HOME/Library/Fonts$RESET\n"
  printf "$PURPLE Make sure to set them as your terminal default fonts.$RESET\n"
  printf "$PURPLE Documentation on the fonts: https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation$RESET\n"
fi

# Install tmux
if ! check_dependency "tmux"
then
  brew install tmux
  check_install $? 'tmux'
fi

# Install emacs
if ! check_dependency "emacs"
then
  brew install emacs --with-cocoa
  check_install $? 'emacs'
  brew linkapps emacs
fi

# Install Prelude
if [ -f "$HOME/.emacs.d/core/prelude-core.el" ]
then
  printf "$YELLOW Prelude installation detected.$RESET\n"
else
  curl -L http://git.io/epre | sh
  check_install $? 'prelude'
fi

# Install dotfiles
curl -L https://raw.githubusercontent.com/b-boogaard/dotfiles/master/utils/installer.sh | sh
check_install $? 'dotfiles'

printf "$GREEN Finished with install. Restart terminal and make sure to set the powerline fonts.$RESET\n"
exit 0
