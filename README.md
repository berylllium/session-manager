# session-manager

A very simple session manager for NeoVim.

## About

session-manager is a very simple session manager for NeoVim. I've created this plugin because other "simple" session managers weren't really simple enough for my needs. This session manager also only saves sessions if a directory already contains a session file, still allowing you to use vim for its intended purpose, editing small files, without creating session files everywhere.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```lua
vim.call("plug#begin")

local Plug = vim.fn["plug#"]

Plug ("berylllium/session-manager", {['tag'] = 'v1.0.1'})

vim.call("plug#end")
```

## Configuration

The default configuration is as follows:

|             Entry             |    Default Value    |                                          Description                                          |
|:-----------------------------:|:-------------------:|:---------------------------------------------------------------------------------------------:|
| session\_path                 | ".nvim/Session.vim" | The path to the generated session file. Relative to the current working directory.            |
| save\_session\_if\_not\_exist | false               | Automatically save the current session on exit even when there is no currently saved session. |
| load\_session\_if\_exist      | true                | Automatically load the currently saved session on entry if it exists.                         |

An example of a modified configuration looks as follows:

```lua
require("session-manager").setup({
    session_path = ".mydir/myses.vim",
    save_session_if_exist = false
})
```

## Usage

In order to use session-manager, you have to explicitly call the setup function, passing in any configurations you'd like to change.

```lua
require("session-manager").setup({})
```

By default, session-manager will not save a session if there isn't an already saved session for that directory. In order to save a session for the first time, run the `:SessionManagerSave` command. This command can also be ran at any time to make a manual save. In order to disable this functionality, set the save\_session\_if\_not\_exist config to true.

