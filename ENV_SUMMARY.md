## System Context: Master's Fortress (CachyOS)
- **OS**: CachyOS (Arch Linux based)
- **Shell**: fish with Fisher & fzf.fish
- **Editor**: Neovim (config managed via GitHub)
- **Terminal**: WezTerm
- **GUI File Manager**: Dolphin (invoked via `gui` function)

## Active Aliases & Functions (config.fish)
| Command | Action | Purpose |
| :--- | :--- | :--- |
| `conf` | `nvim ~/.config/fish/config.fish` | Edit fish config |
| `nconf` | `nvim ~/.config/nvim/init.lua` | Edit Neovim config |
| `reload` | `source ~/.config/fish/config.fish` | Reflect changes instantly |
| `maintain` | `git push` & system update script | Backup & Update |
| `gui` | `function gui` (with `pwd` display) | Open Dolphin in background |

## Known Issues & Notes
- Use `fg` to resume if suspended via `Ctrl + z`.
- Swapfile warnings handled by `L` (Load file).
