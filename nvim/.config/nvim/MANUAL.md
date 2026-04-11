# Neovim Config Manual

> Leader key = `Space`
> When lost: press `Space` and wait — which-key shows everything.

---

## 1. Moving Between Files

This is where you spend most of your time. Learn this first.

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
| `Space fb` | Open buffers |
| `Space fp` | Switch project |

### File explorer
| Key | Action |
|-----|--------|
| `Space e` | Toggle neo-tree sidebar |
| `Space cd` | Toggle neo-tree sidebar |

Inside neo-tree: `a` create, `d` delete, `r` rename, `y` copy, `m` move, `?` all keys.

### Buffers
| Key | Action |
|-----|--------|
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |
| `Space w` | Save and close buffer |
| `Space q` | Close buffer without saving |

---

## 2. Editing

### Jumping anywhere — Flash
The fastest way to move your cursor to any visible text.

| Key | Action |
|-----|--------|
| `s` | Type 2 chars of your destination, jump there |
| `S` | Jump to a treesitter node (function, block, tag...) |

Example: you see `backgroundColor` on line 40. Press `s`, type `ba`, pick the label. Done.

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

### Undo
| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `Space u` | Open undotree — visual undo history, never lose a change |

---

## 3. Code Intelligence (LSP)

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
| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion manually |
| `Tab` / `Shift+Tab` | Navigate suggestions |
| `Enter` | Accept suggestion |
| `Ctrl+e` | Dismiss completion |
| `Ctrl+b` / `Ctrl+f` | Scroll through docs |

---

## 4. Copilot

Suggestions appear automatically while you type. Ghost text shows in gray.

| Key | Action |
|-----|--------|
| `Tab` | Accept full suggestion |
| Keep typing | Ignore suggestion |
| `Space tc` | Toggle Copilot on/off |

---

## 5. Git

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

## 6. Search & Replace

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

## 7. Windows & Layout

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move focus between windows |
| `Alt+h/j/k/l` | Resize current window |
| `Space \|` | Split vertically |
| `Space -` | Split horizontally |
| `Space wd` | Close window |

---

## 8. TODO Comments

Write `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `WARN:` anywhere in code — they get highlighted automatically.

| Key | Action |
|-----|--------|
| `]t` | Next TODO |
| `[t` | Previous TODO |
| `Space st` | Search all TODOs in project |

---

## 9. Diagnostics & Trouble

| Key | Action |
|-----|--------|
| `Space xl` | Open Trouble — all errors/warnings in a panel |
| `Space xX` | Workspace diagnostics |
| `Space xq` | Quickfix list |
| `]d` / `[d` | Jump between diagnostics inline |

---

## 10. Sudo & Misc

| Key / Command | Action |
|-----|--------|
| `:w suda://%` | Save current file as sudo |
| `Space u` | Undotree |
| `gx` | Open URL under cursor in browser |
| `Space ft` | Open floating terminal |
| `Space fT` | Open terminal in current dir |
| `Space,` | Switch buffer (fuzzy) |

---

## Cheat Sheet — Most Used Daily

```
NAVIGATE          Space ff  find file
                  Space fg  grep text
                  Space fp  switch project

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

WINDOWS           Ctrl+hjkl move window
                  Alt+hjkl  resize window
```
