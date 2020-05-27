# fish-autoenv

An autoenv plugin for fish shell allowing excuting scripts when entering and leaving a directory

This is a fork of `https://github.com/eknkc/fish-autoenv`. With following changes being made:

1. Adaption to most recent `fish`
2. Bug fixes
3. Tests added

## Installation

via `fisher`:

```shell console
fisher add pwwang/fish-autoenv
```

## Excution on login

Due to the event loading issue before first load ([#845](https://github.com/fish-shell/fish-shell/issues/845)), `autoenv` is not able to execute on the initial PWD when logging in until you jump to some other directory after the PS shows. To solve this problem, you need to add following to your `~/.config/fish/config.fish`:

```fish
set -g __autoenv_init_pwd "" && __autoenv
```

to manually trigger it.

## Usage

### Entry and exit points

`fish-autoenv` sources `./.in.fish` (~~`./.env.fish`~~) while entering a directory and `./.out.fish` while leaving it.

### Use cases

- If you are in the directory `/home/user/dir1` and execute `cd /var/www/myproject` this plugin will source following files if they exist
    ```
    /home/user/dir1/.out.fish
    /home/user/.out.fish
    /home/.out.fish
    /var/.in.fish
    /var/www/.in.fish
    /var/www/myproject/.in.fish
    ```

- If you are in the directory `/` and execute `cd /home/user/dir1` this plugin will source following files if they exist
    ```
    /home/.in.fish
    /home/user/.in.fish
    /home/user/dir1/.in.fish
    ```

- If you are in the directory `/home/user/dir1` and execute `cd /` this plugin will source following files if they exist
    ```
    /home/user/dir1/.out.fish
    /home/user/.out.fish
    /home/.out.fish
    ```

### Examples

If you have an NLP project in `/home/user/nlp`, and you have installed all the tools needed via `conda` environment `nlp`. You probably want to automatically activate `nlp` while entering the directory and deactivate it while leaving the directory.

So you `.in.fish` would simply be:

```fish
conda activate nlp
```

And you `.out.fish`:

```fish
# resume whatever previous environment is
conda deactivate
```
