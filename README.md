# simple-session-manager

A minimalistic Neovim plugin for automatically loading and saving sessions.

## Installation
Install like any other Neovim plugin:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "shivanju/simple-session-manager",
  opts = {}
}
```

## Usage
The plugin will automatically check for a **.vim/sessions/session.vim** file in the current directory and load it if found. The session will also be saved automatically when you quit Neovim given it existed in the first place.

## Commands
**:SaveSession** - Save the current session manually.  
**:LoadSession** - Load the current session manually.  
**:CreateSession** - Create a new session manually.
