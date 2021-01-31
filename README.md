# NERD Tree Harvest

This is a Vim plugin that adds several ways to “harvest” file paths from the
[NERD Tree directory browser](https://github.com/perservim/nerdtree).

🌴🥥 🌳🌰 🌲🌿 🎋💌

Harvest creates four mappings in the NERD Tree window: `y`, `Y`, `.`, and `!`.
Each mapping reads one or more additional characters to pick a path modifier
and then performs an operation with the modified path. For example, `yh` yanks
the path to the file's parent directory, much as `:cd %:h` changes the current
directory to the parent of the file in the current buffer. See
`:help filename-modifiers` for details on how these transform a file path.

NERD Tree only shows these four mappings in the help list; you can hit `?`
after starting a mapping to see a summary of available modifiers, or consult
the tables below.

Modifier | Name      | Path Modification
:------: | --------- | -----------------
`.`      | relative  | `:.` File path from current working directory
`~`      | home      | `:~` File path from home directory, or absolute
`p`      | absolute  | `:p` Absolute path from filesystem root
`h`      | head      | `:h` Path without the last component (parent directory)
`t`      | tail      | `:t` Final path component (file name)
`r`      | root      | `:t:r` Tail with last extension removed (`/a/b.c` → `b`)
`e`      | extension | `:e` Last extension of the file name (`/a/b.c` → `c`)
`:`      | modifier  | `:` Arbitrary modifier, type enter to end e.g. `:~:h<CR>`

## Yank Mappings

When NERD Tree is active, use one of this plugin's mappings to yank a modified
form of the selected path from the directory tree.

Key  | Name               | Path Modification
---- | ------------------ | -----------------
`y.` | yank relative      | File path from `$PWD`
`y~` | yank from homedir  | File path from `$HOME`
`yp` | yank absolute      | Absolute path from filestystem root
`yh` | yank head          | Parent directory path
`yt` | yank tail          | Final path component (file name)
`yr` | yank root          | File name with last extension removed
`ye` | yank extension     | Last extension of file name
`y:` | yank with modifier | Type arbitrary modifier, enter to end
     :                    : `y:s/foo/bar/:.<CR>` replaces foo→bar, then gets
     :                    : converted to a relative path

The yank register can be selected in the usual way, e.g. `"ryt` will yank the
file name into the `r` register. If no register is given, the yank mappings
harvest paths into the default register (`"`) and can thus be inserted into
another buffer with the `p` command with no specified register or `CTRL-R = "`.
Lowercase `y` yank mappings operate `characterwise` and overwrite the existing
register contents.

As with normal vim yanks, specifying an uppercase register name (`"Ryp`) will
append the path to the register rather than replacing it. However, this does not
include any delimiters or space, so the paths will all run together. To
accommodate harvesting several files from a directory tree, uppercase `Y`
mappings are provided which append to the existing register. The uppercase `Y`
mappings all operate `linewise` (even if the register starts empty), so `p`
putting the yanked text will do so on a new line rather than on the same line
as the cursor. Using `Y` makes it easy to collect several file paths from the
directory tree and later put them into a buffer.

Key  | Name                 | Path Modification
---- | -------------------- | -----------------
`Y.` | append relative      | File path from `$PWD`
`Y~` | append from homedir  | File path from `$HOME`
`Yp` | append absolute      | Absolute path from filestystem root
`Yh` | append head          | Parent directory path
`Yt` | append tail          | Final path component (file name)
`Yr` | append root          | File name with last extension removed
`Ye` | append extension     | Last extension of file name
`Y:` | append with modifier | Type arbitrary modifier, enter to end
     :                      : `Y:t:S<CR>` yanks shell-quoted file name

NERD Tree accepts a count for mappings, but just runs each mapping in sequence
for the next N directory nodes. If you use a count with `y` or `Y` you will be
need to enter that many modifiers (they can be different or all the same).
Since `y` overwrites the register, you will end up with the final path after a
counted mapping. A count with `Y` will append each referenced file. Mappings for
`.` and `!` currently print an error message N times if a count is given. A
future update to this plugin may improve the behavior with counts.

## Command Mappings

There are also mappings which harvest a tree path to the end of a command,
inspired by the [vinegar plugin](https://github.com/tpope/vim-vinegar). These
start a command with `:` (Ex) or `:!` (shell), append the path, then move the
cursor to the beginning of the command, making it easy to operate on the
selected file or directory. The `.` mapping starts an Ex command, `!` starts a
shell command.

### Ex

```
: path/to/file
 ↑ cursor is here
```

Key  | Name                     | Path Modification
---- | ------------------------ | -----------------
`..` | ex command relative      | File path from `$PWD`
`.~` | ex command from homedir  | File path from `$HOME`
`.p` | ex command absolute      | Absolute path from filestystem root
`.h` | ex command head          | Parent directory path
`.t` | ex command tail          | Final path component (file name)
`.r` | ex command root          | File name with last extension removed
`.e` | ex command extension     | Last extension of file name
`.:` | ex command with modifier | Type arbitrary modifier, enter to end
     :                          : `.:h:h<CR>` specifies parent’s parent dir

### Shell

```
:! path/to/file
  ↑ cursor is here
```

Key  | Name                | Path Modification
---- | ------------------- | -----------------
`!.` | shell relative      | File path from `$PWD`
`!~` | shell from homedir  | File path from `$HOME`
`!p` | shell absolute      | Absolute path from filestystem root
`!h` | shell head          | Parent directory path
`!t` | shell tail          | Final path component (file name)
`!r` | shell root          | File name with last extension removed
`!e` | shell extension     | Last extension of file name
`!:` | shell with modifier | Type arbitrary modifier, enter to end
     :                     : `.:gs/a/z/<CR>` replaces all `a` with `z` in path

## Installation

NERD Tree Harvest requires (naturally enough) the NERDTree plugin and Vim 7.3+.
I have only tested on Vim 7.4+ and have not tested on Windows; please file an
issue or send a pull request if you find compatibility issues.

Use your favorite plugin manager, e.g.

```vim
" vim-plug:
Plug 'perservim/nerdtree'
Plug 'flwyd/nerdtree-harvest'
" Vundle:
Plugin 'perservim/nerdtree'
Plugin 'flwyd/nerdtree-harvest'
" vim-addon-manager:
VAMActivate github:perservim/nerdtree
VAMActivate github:flwyd/nerdtree-harvest
```

or `git clone https://github.com/flwyd/nerdtree-harvest` and
`set runtimepath+=/path/to/nerdtree-harvest` in your `.vimrc`

or as a vim8 package:

```shell
dir="~/vim/pack/nerdtree-harvest/start"
mkdir -p "$dir"
git clone https://github.com/flwyd/nerdtree-harvest "$dir"
```

## License and Contributing

The code in this project is made available under an Apache 2.0 open source
license. Copyright 2021 Google LLC. This is not an official Google project.

Contributions are welcome, but please read the
[contributing document](CONTRIBUTING.md) first. Feel free to send a pull
request for bug fixes, but open an issue for feature requests. Features which
don’t “harvest” paths from NERD Tree in some way are probably more suited for
some other plugin.
