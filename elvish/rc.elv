# set E:PATH = ~/bin:$E:PATH
# set paths = (conj $paths ~/bin)
# set E:PATH = /home/commondev/.local/bin:$E:PATH
# set paths = (conj $paths /home/commondev/.local/bin)
# set E:PATH = /home/commondev/.local/usr/bin:$E:PATH
# set paths = (conj $paths /home/commondev/.local/usr/bin)

use naroslife/utilities/log

fn ls {|@a| e:ls -h --color $@a }
fn ll {|@a| ls -alhF $@a }
fn la {|@a| ls -hA $@a }
fn l {|@a| ls -hCF $@a }
# fn gcc {|@a| e:gcc -fdiagnostics-color $@a }

fn grep {|@a| e:grep --color $@a}
fn egrep {|@a| e:egrep --color $@a}
fn fgrep {|@a| e:fgrep --color $@a}
set E:GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"

set edit:prompt = {
     tilde-abbr $pwd
     styled '❱ ' bright-red
   }

# var asdf_data_dir = ~'/.asdf'
# var asdf_dir = ~'/.asdf'
# if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
#   set asdf_data_dir = $E:ASDF_DATA_DIR
# }
# 
# if (not (has-value $paths $asdf_data_dir'/shims')) {
#   set paths = (conj $paths $asdf_data_dir/shims)
# }
# use naroslife/utilities/asdf _asdf
# var asdf~ = $_asdf:asdf~
# set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~

eval (zoxide init --cmd cd elvish | slurp)

use github.com/iwoloschin/elvish-packages/python
# use github.com/zzamboni/elvish-completions/git
# use github.com/zzamboni/elvish-completions/builtins
# use github.com/zzamboni/elvish-completions/ssh
use github.com/zzamboni/elvish-modules/alias
# use github.com/zzamboni/elvish-modules/long-running-notifications
use github.com/zzamboni/elvish-modules/util
use github.com/zzamboni/elvish-modules/dir
use github.com/zzamboni/elvish-modules/terminal-title
use github.com/muesli/elvish-libs/git
use github.com/iandol/elvish-modules/cmds
# use github.com/zzamboni/elvish-modules/spinners


# use github.com/aca/elvish-bash-completion/bash-completer
# set edit:completion:arg-completer[ssh] = (bash-completer:new "ssh")
# set edit:completion:arg-completer[scp] = (bash-completer:new "scp")
# set edit:completion:arg-completer[curl] = (bash-completer:new "curl")
# set edit:completion:arg-completer[man] = (bash-completer:new "man")
# set edit:completion:arg-completer[killall] = (bash-completer:new "killall")
# set edit:completion:arg-completer[aria2c] = (bash-completer:new "aria2c")
# set edit:completion:arg-completer[ip] = (bash-completer:new "ip")
# set edit:completion:arg-completer[journalctl] = (bash-completer:new "journalctl")
# set edit:completion:arg-completer[tcpdump] = (bash-completer:new "tcpdump")
# set edit:completion:arg-completer[iptables] = (bash-completer:new "iptables")
# set edit:completion:arg-completer[tmux] = (bash-completer:new "tmux")
# set edit:completion:arg-completer[fd] = (bash-completer:new "fd")
# set edit:completion:arg-completer[rg] = (bash-completer:new "rg")
# set edit:completion:arg-completer[pueue] = (bash-completer:new "pueue")
# # for some commands, we need to pass bash_function
# set edit:completion:arg-completer[gh] = (bash-completer:new "gh" &bash_function="__start_gh")
# set edit:completion:arg-completer[pkill] = (bash-completer:new "pkill" &bash_function="pgrep")
# set edit:completion:arg-completer[umount] = (bash-completer:new "umount" &bash_function="_umount_module")
# set edit:completion:arg-completer[systemctl] = (bash-completer:new "systemctl" &bash_function="_systemctl systemctl")
# set edit:completion:arg-completer[virsh] = (bash-completer:new "virsh" &bash_function="_virsh_complete virsh")
# # builtin completions
# set edit:completion:arg-completer[which] = (bash-completer:new "which"  &bash_function="_complete type" &completion_filename="complete")

# # alias
# set edit:completion:arg-completer[kubectl] = (bash-completer:new "kubectl" &bash_function="__start_kubectl")
# set edit:completion:arg-completer[k] = $edit:completion:arg-completer[kubectl]

set-env CARAPACE_BRIDGES 'fish' # optional
eval (carapace _carapace|slurp)
eval (starship init elvish)

set edit:insert:binding[C-a] = $edit:move-dot-sol~
set edit:insert:binding[C-e] = $edit:move-dot-eol~
set edit:insert:binding[Alt-b] = $dir:left-word-or-prev-dir~
set edit:insert:binding[Alt-f] = $dir:right-word-or-next-dir~
set edit:insert:binding[Alt-i] = $dir:history-chooser~


var detail_printKeybinds = {
log:print-stuff '@INFO:' '@Useful keybinds:'
log:print-keybind '@Ctrl - R:' '@Command history'
log:print-keybind '@Alt - ,:' '@Last command'
log:print-keybind '@Ctrl - L:' '@Directory history'
log:print-keybind '@Ctrl - N:' '@Navigation mode'
log:print-keybind '@Ctrl - a:' '@Move to the beginning of the line'
log:print-keybind '@END:' '@Move to the end of the line'
log:print-keybind '@Ctrl - u:' '@Delete from the cursor to the beginning of the line'
log:print-keybind '@Ctrl - k:' '@Delete from the cursor to the end of the line'
log:print-keybind '@Alt - b:' '@Left word or next dir'
log:print-keybind '@Alt - f:' '@Right word or next dir'
log:print-keybind '@Alt - i:' '@History chooser'
log:print-keybind '@Ctrl - Alt - Arrow:' '@Multiple cursor'
}
var detail_printTmux = {
log:print-stuff '@INFO:' '@Tmux Cheatsheet:'
log:print-keybind '@Ctrl+B D' '@Detach from the current session'
log:print-keybind '@Ctrl+B C' '@Create a new window'
log:print-keybind '@Ctrl+B N' '@Move to the next window'
log:print-keybind '@Ctrl+B %' '@Split the window vertically'
log:print-keybind '@Ctrl+B "' '@Split the window horizontally'
log:print-keybind '@Ctrl+B Arrow' '@Move to the pane in the direction of the arrow'
log:print-keybind '@Ctrl+B Space' '@Cycle through the pane layouts'
log:print-keybind '@Ctrl+B Z' '@Zoom in/out the current pane'
log:print-keybind '@Ctrl+B X' '@Close the current pane'
log:print-keybind '@Ctrl+B :' '@Enter the tmux command prompt'
log:print-keybind '@Ctrl+B ?' '@View all keybindings. Press Q to exit.'
log:print-keybind '@Ctrl+B W' '@Hierarchy. Use to kill session/windows.'
}

fn printTmux { 
  call $detail_printTmux [] [&] | ~/column_ansi/src/column_ansi.sh -t -s "@" -R 1,2
 } 

fn printKeybinds { 
  call $detail_printKeybinds [] [&] | ~/column_ansi/src/column_ansi.sh -t -s "@" -R 1,2
 }

fn help {

  each {|f| log:print-stuff '@INFO:' '@For help in the future just type help / printKeybinds / printTmux'; call $detail_printTmux [] [&]; call $detail_printKeybinds [] [&]} [detail_printTmux] | ~/column_ansi/src/column_ansi.sh -t -s "@" -R 1,2
}
help
