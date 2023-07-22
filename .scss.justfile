#!/usr/bin/env just --justfile

set -euxo pipefail

set shell := ["zsh", "-cu"] 
set dotenv-load := true
set positional-arguments := true

JUSTFILE_VERSION := "1.0.0"

FONTS_PATH := "./assets/fonts"

@_default: 
  just _selfupdate && echo "Update recipes file"
  just _init_recipes_as_shell_alias  && echo "Add shell aliases to recipes"
  just --list --unsorted

@_selfupdate:
  echo "TODO: add selfupdate function if gist version greather than version ${JUSTFILE_VERSION}"

@_init_recipes_as_shell_alias:
 for recipe in `just --justfile ~/.user.justfile --summary`; do
 alias $recipe="just --justfile ~/.user.justfile --working-directory . $recipe"
 done

@_remove_this_recipe_shell_aliases:
  for recipe in `just --justfile ~/.user.justfile --summary`; do
    unset -f $recipe
  done

add_scss_files_structure:
  mkdir scss \
    scss/abstracts \
    scss/plugins \
    scss/base \
    scss/base/elements \
    scss/base/components
  touch scss/main.scss \
    scss/abstracts/_variables.scss \
    scss/abstracts/_keyframes.scss \
    scss/abstracts/_mixins.scss \
    scss/base/elements/_typography.scss \
    scss/base/elements/_grid.scss \
    scss/base/_fonts.scss \
    scss/base/_colors.scss \
    scss/base/_base.scss 

add_font_insertion_fn:
  cat << EOF > scss/base/_fonts.scss
    $fonts-list:(
      lato-light: ("Lato", sans-serif) 300 normal,
      lato-regular: ("Lato", sans-serif) 400 normal,
      lato-bold: ("Lato", sans-serif) 700 normal,
      oswald-light: ("Oswald", sans-serif) 200 normal,
      oswald-regular: ("Oswald", sans-serif) 400 normal
    );
  "\n"
    @mixin fonts( $family, $weight, $style ) {
      font-family: $family;
      font-weight: $weight;
      font-style: $style;
    }
  "\n"
    @each $font, $attributes in $fonts-list {
      @font-face {
        font-family: nth($attributes, 1);
        src: url( $FONTS_PATH + $font + ".ttf") format("ttf");
        src: local( $font ),
             url( $FONTS_PATH + $font + ".eot?#iefix") format("embedded-opentype"),
             url( $FONTS_PATH + $font + ".woff") format("woff"),
             url( $FONTS_PATH + $font + ".ttf") format("truetype");
        font-weight: nth($attributes, 2);
        font-style: nth($attributes, 3);
      }
      "." + $font {
        @include fonts(nth($attributes, 1), nth($attributes, 2), nth($attributes, 3));
      }
    }
  "\n"
  EOF
