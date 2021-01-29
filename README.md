# NERD Tree Harvest

This is a Vim plugin that adds several ways to "harvest" file paths from the
[NERD Tree directory browser](https://github.com/perservim/nerdtree).

🌴🥥 🌳🌰 🌲🌿 🎋💌

## Yank Mappings

When NERD Tree is active, use one of this plugin's mappings to yank a modified
form of the selected path from the directory tree. The key bindings are based on
the characters used in `:help file name-modifiers`. For example, `yh` yanks the
path to the file's parent directory, much as `:cd %:h` changes the current
directory to the parent of the file in the current buffer.

Key  | Name              | Path Modification
---- | ----------------- | --------------------------------------------
`y.` | yank relative     | `:.` File path from `$PWD`
`y~` | yank from homedir | `:~` File path from `$HOME`
`yp` | yank absolute     | `:p` Absolute path from root
`yh` | yank head         | `:h` Parent directory path
`yt` | yank tail         | `:t` Final path component (file name)
`yr` | yank root         | `:t:r` File name with last extension removed
`ye` | yank extension    | `:e` Last extension of file name

The yank mappings currently harvest paths into the default register (`"`) and
can thus be inserted into another buffer with the `p` command or `CTRL-R = "`.
TODO: add support for designating a named register.

## Command Mappings

There are also mappings which harvest a tree path to the end of a command,
inspired by the [vinegar plugin](https://github.com/tpope/vim-vinegar). These
start a command with `:` (Ex) or `:!` (shell), append the path, then move the
cursor to the beginning of the command, making it easy to operate on the
selected file or directory.

### Ex

```
: path/to/file
 ↑ cursor is here
```

Key  | Name                    | Path Modification
---- | ----------------------- | --------------------------------------------
`..` | ex command relative     | `:.` File path from `$PWD`
`.~` | ex command from homedir | `:~` File path from `$HOME`
`.p` | ex command absolute     | `:p` Absolute path from root
`.h` | ex command head         | `:h` Parent directory path
`.t` | ex command tail         | `:t` Final path component (file name)
`.r` | ex command root         | `:t:r` File name with last extension removed
`.e` | ex command extension    | `:e` Last extension of file name

### Shell

```
:! path/to/file
  ↑ cursor is here
```

Key  | Name               | Path Modification
---- | ------------------ | --------------------------------------------
`!.` | shell relative     | `:.` File path from `$PWD`
`!~` | shell from homedir | `:~` File path from `$HOME`
`!p` | shell absolute     | `:p` Absolute path from root
`!h` | shell head         | `:h` Parent directory path
`!t` | shell tail         | `:t` Final path component (file name)
`!r` | shell root         | `:t:r` File name with last extension removed
`!e` | shell extension    | `:e` Last extension of file name

## License and Contributing

The code in this project is made available under an Apache 2.0 open source
license. Copyright 2021 Google LLC. This is not an official Google project.

Pull requests are welcome, but please read the
[contributing document](CONTRIBUTING.md) first. Features which don't "harvest"
paths from NERD Tree in some way are probably more suited for some other plugin.
