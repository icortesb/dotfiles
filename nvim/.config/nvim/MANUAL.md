# Neovim Config Manual

> Leader key = `Space`
> When lost: press `Space` and wait — which-key shows everything.

---

## Modes — the basics

Neovim is modal. You are always in one of these:

| Mode | How to enter | What it does |
|------|-------------|--------------|
| **Normal** | `Escape` or `jk` | Navigate, run commands. Default mode. |
| **Insert** | `i` (before cursor), `a` (after), `o` (new line below) | Type text |
| **Visual** | `v` (char), `V` (line), `Ctrl+v` (block) | Select text |
| **Command** | `:` | Run vim commands (`:w`, `:q`, etc.) |

**Rule:** always go back to Normal with `Escape` or `jk`. Everything else starts from Normal.

---

## 1. Buffers and Tabs

This is the most important mental model to get right.

**What looks like tabs at the top are buffers.** Every file you open becomes a buffer. Bufferline shows them as a tab bar, but they are not tabs — they are all open in memory at the same time.

```
 index.ts   styles.css   api.ts      ← these are buffers, shown as tabs
```

You can have as many open as you want. Closing a buffer removes it from the bar.

### Switching buffers
| Key | Action |
|-----|--------|
| `Shift+h` | Go to previous buffer (left in the bar) |
| `Shift+l` | Go to next buffer (right in the bar) |
| `Space,` | Fuzzy search all open buffers by name |
| `Space fb` | Same, in a picker |

### Closing buffers
| Key | Action |
|-----|--------|
| `Space w` | Save and close current buffer |
| `Space q` | Close without saving |

Closing a buffer does **not** close the window. Your layout stays intact.

### Opening files into buffers
Any time you open a file — from neo-tree, `Space ff`, `gd`, anywhere — it opens as a new buffer and appears in the tab bar automatically.

---

## 2. Windows and Splits

A window is a panel on screen. You can have multiple windows showing different buffers side by side.

### Splits — two files at once
| Key | Action |
|-----|--------|
| `Space \|` | Split current window vertically |
| `Space -` | Split current window horizontally |
| `Space wd` | Close current window (buffer stays open) |

**Workflow to open two files side by side:**
1. Open first file normally
2. Press `Space |` to split
3. Press `Space ff` in the new panel to find your second file
4. Use `Ctrl+h/l` to switch focus between them

### Moving between windows
| Key | Action |
|-----|--------|
| `Ctrl+h` | Focus window to the left |
| `Ctrl+j` | Focus window below |
| `Ctrl+k` | Focus window above |
| `Ctrl+l` | Focus window to the right |

### Resizing windows
| Key | Action |
|-----|--------|
| `Alt+h` | Shrink window left |
| `Alt+l` | Grow window right |
| `Alt+j` | Shrink window down |
| `Alt+k` | Grow window up |

---

## 3. Moving Between Files

### Harpoon — your active file set
Mark the 3-4 files you're actively working on. Jump between them instantly.

| Key | Action |
|-----|--------|
| `Space a` | Mark current file |
| `Ctrl+e` | Open mark list |
| `Ctrl+n` | Next marked file |
| `Ctrl+p` | Previous marked file |
| `Space fl` | See marks in fuzzy picker |

**Workflow:** open your component, its styles, and its test. Mark each with `Space a`. Now `Ctrl+n/p` cycles them instantly — no searching, no thinking.

### Finding files
| Key | Action |
|-----|--------|
| `Space ff` | Find file by name |
| `Space fg` | Search text across all files |
| `Space fr` | Recent files |
| `Space fp` | Switch project |

### File explorer — neo-tree
| Key | Action |
|-----|--------|
| `Space e` | Toggle neo-tree sidebar |

**Focusing neo-tree when it's open:** press `Space e` again or `Ctrl+h` to move focus into it.

Inside neo-tree:

| Key | Action |
|-----|--------|
| `j` / `k` | Move up/down |
| `Enter` | Open file |
| `l` | Expand folder / open file |
| `h` | Collapse folder |
| `s` | Open file in vertical split |
| `a` | Create file or folder (end name with `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy |
| `m` | Move |
| `q` | Close neo-tree |
| `?` | Show all keybinds |

---

## 4. Editing

### Jumping anywhere — Flash
The fastest way to move your cursor to any visible text.

| Key | Action |
|-----|--------|
| `s` | Type 2 chars of your destination, jump there |
| `S` | Jump to a treesitter node (function, block, tag...) |

Example: you see `backgroundColor` on line 40. Press `s`, type `ba`, pick the label. Done.

### The `]` / `[` pattern
Throughout the config, `]x` means "next x" and `[x` means "previous x". Works consistently for:

| Key | Jumps to |
|-----|----------|
| `]d` / `[d` | Next / previous diagnostic (error, warning) |
| `]h` / `[h` | Next / previous git hunk |
| `]t` / `[t` | Next / previous TODO comment |
| `]b` / `[b` | Next / previous buffer |

### Text objects — what you select, delete, change
Works with `v` (visual), `d` (delete), `c` (change), `y` (yank):

| Key | Selects |
|-----|---------|
| `if` / `af` | inside / around **function** |
| `ic` / `ac` | inside / around **class** |
| `ia` / `aa` | inside / around **argument** |
| `it` / `at` | inside / around **HTML tag** |
| `iq` / `aq` | inside / around **any quote** |
| `ib` / `ab` | inside / around **any bracket** `()[]{}` |

Examples:
- `daf` — delete entire function including signature
- `ciq` — change text inside quotes (any quote type)
- `vat` — select HTML tag and its content
- `cia` — change a function argument

### Commenting
| Key | Action |
|-----|--------|
| `gcc` | Toggle comment on line |
| `gc` + motion | Comment a block (`gcip` = comment paragraph) |
| `gc` in visual | Comment selection |

### Auto-pairs
Brackets, quotes, and tags close automatically. Press the closing char to skip over it instead of typing it twice.

`nvim-ts-autotag` closes HTML/JSX tags automatically on `>`.

### Emmet — HTML/CSS abbreviations
Type your abbreviation then `Ctrl+y ,` to expand.

| Abbreviation | Expands to |
|---|---|
| `div.container` | `<div class="container"></div>` |
| `ul>li*3` | `<ul>` with 3 `<li>` items |
| `a[href=#]` | `<a href="#"></a>` |
| `p.title+span` | `<p class="title">` followed by `<span>` |

### Yank history — Yanky
Every time you copy (`y`) something it goes into a history. You can cycle through it after pasting.

| Key | Action |
|-----|--------|
| `p` | Paste (as usual) |
| `]p` | Cycle to next item in yank history (after pasting) |
| `[p` | Cycle to previous item in yank history |
| `Space p` | Browse full yank history in a picker |

### Undo
| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `Space u` | Open undotree — full visual undo history, never lose a change |

---

## 5. Code Intelligence (LSP)

Works automatically for: TypeScript, JavaScript, Astro, Vue, PHP, Go, Bash, Lua.

### Navigation
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find all references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Show docs / hover info |
| `Ctrl+k` | Signature help (in insert mode) |

### Actions
| Key | Action |
|-----|--------|
| `Space ca` | Code actions (imports, refactors, fixes) |
| `Space cr` | Rename symbol across the project |
| `Space cf` | Format file manually |
| `Space cd` | Show diagnostic for current line |
| `]d` / `[d` | Next / previous diagnostic |
| `Space cq` | All diagnostics in quickfix list |

### Format on save
Runs automatically. Formatters by file type:
- **JS/TS/Astro/Vue/CSS/HTML/JSON** → Prettier
- **PHP** → PHP-CS-Fixer
- **Lua** → Stylua
- **Go** → gofmt

### Completion
Completion and Copilot both use `Tab`. Here is how they interact:

- If a **Copilot** ghost suggestion is visible → `Tab` accepts the Copilot suggestion
- If a **completion menu** is open → `Tab` / `Shift+Tab` navigate the menu, `Enter` accepts
- If neither is showing → `Tab` inserts a tab character

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion manually |
| `Tab` / `Shift+Tab` | Navigate completion menu |
| `Enter` | Accept selected completion item |
| `Ctrl+e` | Dismiss completion menu |
| `Ctrl+b` / `Ctrl+f` | Scroll docs up/down |

---

## 6. Copilot

Suggestions appear automatically while you type. Ghost text shows in gray.

| Key | Action |
|-----|--------|
| `Tab` | Accept full Copilot suggestion |
| Keep typing | Ignore suggestion |
| `Space tc` | Toggle Copilot on/off |

---

## 7. Git

### Gitsigns — work with hunks without leaving the file
A hunk is a block of changed lines.

| Key | Action |
|-----|--------|
| `]h` | Next changed hunk |
| `[h` | Previous changed hunk |
| `Space ghs` | Stage hunk under cursor |
| `Space ghr` | Undo hunk (reset to HEAD) |
| `Space ghp` | Preview hunk diff inline |
| `Space ghb` | Blame current line (who wrote this, when) |
| `Space ghd` | Diff current file |
| `Space ghS` | Stage entire file |
| `Space ghR` | Reset entire file |
| `ih` in visual | Select the hunk as text object |

### Lazygit — full git UI
| Key | Action |
|-----|--------|
| `Space gg` | Open lazygit |

Inside lazygit:

| Key | Action |
|-----|--------|
| `Space` | Stage / unstage file |
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `b` | Branches |
| `l` | Log / commit history |
| `Enter` | View file diff |
| `?` | All keybinds |
| `q` | Close lazygit |

---

## 8. Search & Replace

| Key | Action |
|-----|--------|
| `Space fg` | Live grep — search text in all project files |
| `Space sg` | Grep from project root |
| `/` | Search in current buffer |
| `*` | Search word under cursor (forward) |
| `#` | Search word under cursor (backward) |
| `n` / `N` | Next / previous match |
| `Space sr` | Search and replace across project (grug-far) |
| `Space ss` | Go to symbol in current file |
| `Space sS` | Go to symbol in workspace |

---

## 9. TODO Comments

Write `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `WARN:` anywhere in code — they get highlighted automatically.

| Key | Action |
|-----|--------|
| `]t` | Next TODO |
| `[t` | Previous TODO |
| `Space st` | Search all TODOs in project |

---

## 10. Diagnostics & Trouble

| Key | Action |
|-----|--------|
| `Space xl` | Open Trouble — all errors/warnings in a panel |
| `Space xX` | Workspace diagnostics |
| `Space xq` | Quickfix list |
| `]d` / `[d` | Jump between diagnostics inline |

---

## 11. Terminal

| Key | Action |
|-----|--------|
| `Space ft` | Open floating terminal |
| `Space fT` | Open terminal in current directory |

To exit the terminal and return to nvim: type `exit` to close it, or press `Ctrl+\` then `Ctrl+n` to go back to normal mode without closing it.

---

## 12. Maintenance

These are commands you run occasionally to keep things working.

| Command | What it does |
|---------|-------------|
| `:Lazy` | Open plugin manager — update, install, check status |
| `:Lazy sync` | Install missing plugins + update all |
| `:Mason` | Open LSP/formatter manager — install new language servers |
| `:TSUpdate` | Update treesitter parsers (syntax highlighting) |
| `:checkhealth` | Diagnose any setup issues |
| `:w suda://%` | Save current file as sudo |

---

## 13. Misc

| Key | Action |
|-----|--------|
| `Space u` | Undotree |
| `gx` | Open URL under cursor in browser |
| `Space,` | Switch buffer by name |

---

## Cheat Sheet — Most Used Daily

```
MODES             i         insert mode
                  Escape    back to normal
                  jk        back to normal (faster)

BUFFERS           Shift+h/l prev/next buffer (tab)
                  Space w   save and close
                  Space,    switch buffer by name

NAVIGATE          Space ff  find file
                  Space fg  grep text
                  Space fp  switch project
                  Space e   file explorer

HARPOON           Space a   mark file
                  Ctrl+e    mark list
                  Ctrl+n/p  jump marks

JUMP              s         flash jump (2 chars)
                  gd        go to definition
                  gr        references
                  K         hover docs

EDIT              Space ca  code action
                  Space cr  rename
                  Space cf  format
                  gcc       comment line
                  daf       delete function
                  ciq       change in quotes

GIT               Space gg  lazygit
                  ]h / [h   next/prev hunk
                  Space ghs stage hunk
                  Space ghb blame line

SPLITS            Space |   split vertical
                  Ctrl+h/l  move between panels
```
