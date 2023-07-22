this is test of Wprdpress dev environment to create production-ready wordpress theme and separate development theme environment from production files. 

Theme dev version keeps sibling to same directory with its prod version like a child-theme on production for end user.
Benefits of this hook is clear and minified css and js

project structure
```

$THEME_dev
  /docs/
    CODE_OF_CONDUCT
    DEV_LICENSE
    /issues/
  /scss/
    /abstracts/
      _variables.scss
      _keyframes.scss
      _mixins.scss
    /plugins/
    /base/
      /elements/
        _typography.scss
      /components/
      _fonts.scss
      _colors.scss
      _base.scss
    main.scss
  /config/
      rollup.config.js // in package.json use rollup --config /config/rollup.config.js
  /vendor/
  /node_modules/

  readme.md

  .justfile
  .envrc

  .gitignore
  .gitattributes

  .editorconfig

  package.json


  composer.json
  phpstan.neon
  phpcs.xml

(parent dir)

../ $THEME
  /docs/
  |- LICENSE
  |- GPL2+
  |- Purchase_PRO.html
  |- index.html
  - theme_wiki.html
  /templates/
  |  404
  |  index
  |  single

  /patterns/
  /parts/
  /assets/
  |-/fonts/
  |-/vendor/
  |-/img/
    |-/svg/
  |-/js/
    |-main.js
  |-/css/
    |- main.css
    |- editor-style.css
  /languages/
  style.css
  functions.php
  screenshot.png

- $CHILD_THEME

```

just license
```

    cd ${PROD_DIR}
    https://gist.github.com/DenysHnatiuk/48b680b29474ae8f0a8d8245924b7095#file-license

```
