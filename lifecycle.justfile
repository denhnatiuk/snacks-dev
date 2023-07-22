#!/usr/bin/env just --justfile

set shell := ["zsh", "-cu"] 
set dotenv-load
set export
set positional-arguments

JUSTFILE := trim_start_match(justfile(), justfile_directory());


@_default: 
  just _selfupdate && echo "Update recipes file"
  just _init_recipes_as_shell_alias  && echo "Add shell aliases to recipes"
  just --list --unsorted

# Update justfile from the repo
@_selfupdate:
  echo "TODO: add selfupdate function if gist version greather than version ${JUSTFILE_VERSION}"


# Add receipes to shell aliases
@_init_recipes_as_shell_alias:
 for recipe in `just --justfile ~/.user.justfile --summary`; do
 alias $recipe="just --justfile ~/.user.justfile --working-directory . $recipe"
 done

# Remove receipes from shell aliases
@_remove_this_recipe_shell_aliases:
  for recipe in `just --justfile ~/.user.justfile --summary`; do
    unset -f $recipe
  done