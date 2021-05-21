# pdb.vim
Simple pdb wrapper for Neovim.
![example](https://user-images.githubusercontent.com/9946301/119111454-c10ac280-ba2b-11eb-88a7-c8885c03555b.gif)
## installation

Using vim-plug:

`Plug 'ruslan-savina/pdb'`

`:PlugInstall`

## breakpoints management

`:PdbBreakpointAdd` Add breakpoint in a current line

`:PdbBreakpointAddConditional` Add conditional breakpoint

`:PdbBreakpointList` Show breakpoints list

`:PdbBreakpointDelete` Delete breakpoint in a current line

`:PdbBreakpointDeleteInFile` Delete all breakpoints in a current buffer

`:PdbBreakpointDeleteAll` Delete all breakpoints

`:PdbBreakpointCopy` Copy breakpint string

## commands
`:PdbDebugScript` Debug current script

`:PdbDebugDjangoScript` Debug current script using Django shell

`:PdbDebugDjangoServer` Debug Django server

`:PdbDebugDockerScript` Debug current script in Docker container

`:PdbDebugDockerDjangoScript` Debug current script using Django shell in Docker container

`:PdbDebugDockerDjangoServer` Debug Django server in Docker container
