alias zrc="nvim ~/.zshrc && zrel"
alias zrel=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

alias gwr="git worktree remove"
alias gbd="git branch -D"
alias ghelp='alias | grep "^g"'
alias gg="lazygit"

alias nvim_domas='NVIM_APPNAME="nvim_domas" nvim'
alias nviml='NVIM_APPNAME="nvim_lazy" nvim'
alias nvima='NVIM_APPNAME="nvim_astro" nvim'
alias nvimc='NVIM_APPNAME="nvim_chad" nvim'

alias code2="code --disable-extensions --disable-gpu"

# Takes mode or apply. The script itself differs per machine — tmux repo, main
# branch on WSL, mac branch on macOS.
alias theme="$HOME/.config/tmux/scripts/theme.sh"
