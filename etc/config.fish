# configure bobthefish theme
set -g theme_powerline_fonts no
set -g theme_nerd_fonts yes
set -g theme_display_date no

# direnv hook
direnv hook fish | source

if type -f $PWD/".envrc"
  direnv allow .
end
