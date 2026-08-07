---
name: dotfiles
description: Manage dotfiles repository - add new tools, configure shell integrations, update installer. Use when the user wants to add a new tool to their dotfiles, configure shell setups (bash/zsh/nushell), or modify the Rust-based installer.
---

# Dotfiles Management Skill

This skill helps you work with buddhamagnet's dotfiles repository located at `/Users/buddhamagnet/Code/dotfiles`.

## ⚠️ Pending Tasks

**fzf optimization**: Consider configuring fzf to use ripgrep and fd for better performance:
- Add `FZF_DEFAULT_COMMAND` to use fd instead of find
- Add `FZF_CTRL_T_COMMAND` for file finder
- Add `FZF_ALT_C_COMMAND` for directory finder
- Benefits: faster, respects .gitignore, colored output
- Files to update: zshrc, bashrc, nushell/env.nu

## Repository Overview

**Location**: `/Users/buddhamagnet/Code/dotfiles`

**Installation method**: Rust-based CLI installer (`cargo run --release`)

**Architecture**: 
- Configuration files are version-controlled in the repo
- Files are symlinked from repo to home directory (e.g., `dotfiles/zshrc` → `~/.zshrc`)
- Tools that can't be symlinked are installed via functions in `src/main.rs`

## Key Files

- **`src/main.rs`** - Rust installer with symlink logic and tool installation functions
- **`bashrc`** - Bash shell configuration
- **`zshrc`** - Zsh shell configuration (primary shell)
- **`nushell/config.nu`** - Nushell configuration
- **`nushell/env.nu`** - Nushell environment setup
- **`README.rdoc`** - Installation and setup documentation

## Current Tools Managed

Tools installed via the Rust installer:
- **JetBrains Mono font** - Homebrew cask
- **Nushell** - Homebrew package
- **Starship** - Official curl installer
- **Carapace** - Homebrew package
- **Worktrunk** - Homebrew package
- **zoxide** - Homebrew package
- **fzf** - Homebrew package
- **ripgrep** - Homebrew package (used by telescope live_grep in neovim)
- **fd** - Homebrew package (used by telescope file finder in neovim)
- **tpm** - Git clone at pinned tag (tmux plugin manager)
- **tpm plugins** - Installed via tpm (catppuccin, tmux-cpu)

Neovim plugins (managed via lazy.nvim in nvim/lua/plugins/init.lua):
- **lazy.nvim** - Plugin manager (auto-bootstrapped)
- **catppuccin** - Color theme (mocha variant)
- **telescope** - Fuzzy finder with fzf-native extension
- **plenary** - Lua utility library (telescope dependency)

## Adding a New Tool

Follow this pattern to add a new tool to the dotfiles:

### 1. Install the tool binary (if needed)

Add an installation function in `src/main.rs` after the existing install functions:

```rust
/// Install <tool> via Homebrew if not already installed.
fn install_<tool>() {
    // Check if tool is already installed
    let check_status = Command::new("which").arg("<tool-binary>").status();

    if let Ok(s) = check_status {
        if s.success() {
            println!("<Tool> already installed");
            return;
        }
    }

    println!("Installing <Tool>...");
    let status = Command::new("brew")
        .args(["install", "<tool-package>"])
        .status();

    match status {
        Ok(s) if s.success() => println!("<Tool> installed successfully"),
        Ok(_) => eprintln!("Warning: brew install <tool-package> failed"),
        Err(e) => eprintln!("Warning: failed to run brew: {e}"),
    }
}
```

Then call it in `main()` within the `!dry_run` block:

```rust
if !dry_run {
    install_jetbrains_mono();
    install_nushell();
    install_starship();
    install_carapace();
    install_worktrunk();
    install_<tool>();  // Add here
    install_tmux_plugins();
}
```

### 2. Add shell integration (if needed)

**Bash** (`bashrc`):
```bash
# <Tool> configuration
eval "$(<tool> init bash)"
# or source specific files, set environment variables, etc.
```

**Zsh** (`zshrc`):
```bash
# <Tool> configuration
eval "$(<tool> init zsh)"
```

**Nushell** (`nushell/env.nu` or `nushell/config.nu`):
```nushell
# <Tool> configuration
# Note: Nushell often requires different setup patterns
```

### 3. Add configuration files (if needed)

If the tool needs config files managed by the dotfiles:

1. Create the config file(s) in the repo: `dotfiles/<tool>/config`
2. Add to the `MANIFEST` in `src/main.rs`:
   ```rust
   const MANIFEST: &[(&str, &str)] = &[
       // ... existing entries
       ("<tool>/config", ".config/<tool>/config"),
   ];
   ```

### 4. Update documentation

Update `README.rdoc` to mention the new tool in the "What it does" section.

## Common Patterns

### Pattern: Homebrew-installed CLI tool with shell integration

Example: Starship, Carapace, Worktrunk

1. Add `install_<tool>()` function with `which` check
2. Install via `brew install <package>`
3. Add `eval "$(<tool> init <shell>)"` to shell configs
4. Update README

### Pattern: Tool with config files

Example: Ghostty, Neovim, Starship

1. Create config directory: `mkdir -p dotfiles/<tool>`
2. Add config file(s) to the directory
3. Add to `MANIFEST` for symlinking
4. Optionally add installation function if the binary needs to be installed
5. Update README

### Pattern: Tool that modifies PATH

Example: Homebrew curl, local bins

Add to shell configs (zshrc/bashrc):
```bash
export PATH="/path/to/tool/bin:$PATH"
```

### Pattern: Git-cloned plugin at pinned version

Example: Catppuccin tmux plugin

1. Define constants for repo URL and tag
2. Create installation function that:
   - Checks if already installed
   - Creates parent directories
   - Git clones with `--depth 1 --branch <tag>`
3. Document how to update the pinned version in README

## Shell-Specific Notes

### Bash (`bashrc`)
- Currently minimal (9 lines)
- Has Carapace completion
- Has Worktrunk integration
- PATH set to `$HOME/bin:/usr/local/bin:$PATH`

### Zsh (`zshrc`)
- Primary shell with extensive configuration
- Uses Oh-My-Zsh framework
- Plugins: git, z, colored-man-pages
- Has Starship prompt
- Has NVM, Carapace, Worktrunk integration
- Custom functions: `claude()`, `claude-work()`
- Vi mode enabled
- PATH extended in multiple places

### Nushell (`nushell/env.nu` and `config.nu`)
- Minimal configuration
- Uses Carapace for completions (generates cache on startup)
- Some tools require different integration patterns (e.g., worktrunk uses static file)

## Testing Workflow

After making changes:

```bash
# 1. Dry-run to preview changes
cd ~/Code/dotfiles
cargo run --release -- --dry-run

# 2. Check for compilation errors
cargo check

# 3. Run the installer
cargo run --release

# 4. Test in each shell
bash -c "source ~/.bashrc && <test-command>"
zsh -c "source ~/.zshrc && <test-command>"
nu -c "source ~/.config/nushell/config.nu; <test-command>"
```

## Common Tasks

### Add a new Homebrew tool
1. Add `install_<tool>()` function
2. Call it in `main()`
3. Update README
4. Test with dry-run

### Add shell completion
1. Add to appropriate shell config file
2. Follow existing Carapace pattern if possible
3. Test in each shell

### Update a pinned version
1. Change the version constant (e.g., `TMUX_PLUGIN_TAG`)
2. Document in README how to update
3. Remove old installation and re-run installer

### Add PATH modification
1. Add `export PATH="...":$PATH` to shell configs
2. Consider consolidating PATH modifications to reduce duplication
3. Use absolute paths or `$HOME` rather than hardcoded user paths

## Important Conventions

1. **Idempotency**: All install functions check if tool is already installed
2. **Error handling**: Print warnings but don't fail the entire installation
3. **Backup**: Existing files are backed up to `~/.dotfiles-backup/` before symlinking
4. **Comments**: Add descriptive comments before each tool's configuration section
5. **Ordering**: Install tools before tmux plugins (tmux is often last)
6. **Version control**: All configs should be in the repo, not generated files

## Troubleshooting

### Symlink already exists
The installer will prompt to overwrite. Existing files are backed up to `~/.dotfiles-backup/`.

### Tool not in PATH
Check that:
1. The tool's installation succeeded
2. Shell integration is after PATH modifications
3. A new shell session is started (or config sourced)

### Nushell integration differs
Nushell often requires:
- Setting environment variables in `env.nu`
- Sourcing completions in `config.nu`
- Sometimes manual tool-specific setup commands
- Static files instead of `eval` patterns

### Homebrew not found
The installer will print a warning but continue. Install Homebrew first.

## Reference: Complete Tool Addition Example

Adding `zoxide` (a smarter cd command):

```rust
// In src/main.rs, add after install_worktrunk():
/// Install zoxide via Homebrew if not already installed.
fn install_zoxide() {
    let check_status = Command::new("which").arg("zoxide").status();

    if let Ok(s) = check_status {
        if s.success() {
            println!("Zoxide already installed");
            return;
        }
    }

    println!("Installing Zoxide...");
    let status = Command::new("brew")
        .args(["install", "zoxide"])
        .status();

    match status {
        Ok(s) if s.success() => println!("Zoxide installed successfully"),
        Ok(_) => eprintln!("Warning: brew install zoxide failed"),
        Err(e) => eprintln!("Warning: failed to run brew: {e}"),
    }
}

// In main(), add:
install_zoxide();
```

```bash
# In bashrc, add:
# Zoxide initialization
eval "$(zoxide init bash)"

# In zshrc, add:
# Zoxide initialization
eval "$(zoxide init zsh)"
```

```nushell
# In nushell/env.nu, add:
# Zoxide initialization
zoxide init nushell | save -f ~/.zoxide.nu

# In nushell/config.nu, add:
source ~/.zoxide.nu
```

Update README.rdoc to mention Zoxide in the tools list.

## Getting Help

- Check existing tool integrations in the repo for patterns
- Read tool documentation for shell integration requirements
- Test thoroughly in all three shells before committing
- Use `--dry-run` to preview changes
