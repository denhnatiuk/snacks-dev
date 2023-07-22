#!/usr/bin/env just --justfile

set shell := ["zsh", "-cu"] 
set dotenv-load
set export
set positional-arguments

# set -euxo pipefail

JUSTFILE_VERSION := "1.0.0"
IS_PROD := env_var_or_default("PROD", "")
IS_CI := env_var_or_default("CI", "")

TIMESTAMP := `date +"%y%m%d.%H%M%S"`

Project_Name := trim_start_match( trim_start_match( absolute_path(justfile_directory()), parent_directory( justfile_directory() ) ), "/" )
PROJECT_NAME := env_var_or_default("Project_Name", "")
Project_Type := env_var_or_default("WP", "")

# ssh:
#   ssh $SSH_User@$SSH_Server -p $SSH_Port 

@_default: 
  just --list --unsorted
  echo "Credentials:"
  echo "Justfile https://gist.github.com/DenysHnatiuk/a651e786d42c6bff32e5e41a15f53012"
  echo "Gist token is $GITHUB_GIST_TOKEN"

@_selfupdate_justfile:
  echo $GITHUB_GIST_TOKEN
  echo "Getting latest release"
  sudo curl -o "new.justfile" -L \
  --oauth2-bearer $GITHUB_GIST_TOKEN \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  $JUSTFILE_GIST
# sudo wget -O ".justfile" -H "Cache-Control: no-cache"  ${JUSTFILE_GIST}
# sudo curl -o "new.justfile" -L \
# -H "Accept: application/vnd.github+json" \
# -H "Authorization: Bearer {{GITHUB_GIST_TOKEN}}"\
# -H "X-GitHub-Api-Version: 2022-11-28" \
# {{JUSTFILE_GIST}}


# Concat 2 text files with new line
@_concat-envrc-files +FILES:
  cp .envrc .envrc.prev
  for f in {{FILES}}; do (cat "${f}"; echo) >> .envrc; done
  direnv allow .
  awk -F= '{print $1"="}' .envrc > .envrc-example
# sed -i 's/START.*STOP/NEW TEXT/g' input.txt
# sed 's/=.*//' .envrc > .envrc-example
# source .envrc && env -i bash -c 'for v in "${!BASH_*}" "${!GIT_*}" "${!SSH_*}" "${!GPG_*}" "${GITHUB_GIST_TOKEN}"; do unset "$v"; done; env -0 > .envrc-example.txt'
#  cat File1.txt <(echo) File2.txt > finalfile.txt

@tar-bz2-project:
  rm -f ".temporary/{{Project_Name}}.tar.bz2"
  tar -C {{justfile_directory()}} --exclude=".temporary" --exclude-vcs-ignores -cjvf .temporary/{{Project_Name}}.tar.bz2 $( ls -a {{justfile_directory()}} | grep -v '\(^\.$\)\|\(^\.\.$\)' )

@untar-bz2-project:
  if [ ! -d {{Project_Name}} ]; then \
    mkdir {{Project_Name}} \
  else \
    tar -C {{Project_Name}} -cjvf .temporary/{{Project_Name}}.tar.bz2 $( ls -a {{justfile_directory()}} | grep -v '\(^\.$\)\|\(^\.\.$\)' )
  fi \
    && tar -xjvf {{Project_Name}}.tar.bz2 -C ~/projects/{{Project_Name}} \
    && rm -f ~/projects/{{Project_Name}}.tar.bz2


#backup files to NAS
@backup2nas +FILES:
  echo $NAS/$Project_Type/{{Project_Name}}/
  sudo scp -rf -P $NAS_Port {{FILES}} $NAS/$Project_Type/{{Project_Name}}/{{FILES}}

#backup project to NAS
@backup2nas-all:
  rm -f ".temporary/{{Project_Name}}.tar.bz2"
  tar -C {{justfile_directory()}} --exclude=".temporary" --exclude="{{Project_Name}}.tar.bz2" -cjvf .temporary/{{Project_Name}}.tar.bz2 $( ls -a {{justfile_directory()}} | grep -v '\(^\.$\)\|\(^\.\.$\)' )
  sudo scp -P $NAS_Port .temporary/{{Project_Name}}.tar.bz2 $NAS_User@$NAS_Server:~/projects
  ssh -p $NAS_Port $NAS_User@$NAS_Server 'cd ~/projects \
    && if [ ! -d "$DIRECTORY" ]; then mkdir {{Project_Name}} fi \
    && tar -xjvf {{Project_Name}}.tar.bz2 -C ~/projects/{{Project_Name}} \
    && rm -f ~/projects/{{Project_Name}}.tar.bz2'
# gpg --encrypt -r denys.hnatiuk@gmail.com 
# ssh -P $aliNAS_Port $aliNAS_User@$aliNAS_Server 'cat > ~/projects/$Project_Type.tar.gz.gpg'

_gitattributes:
  sudo wget -O "/etc/.gitattributes" -H "Cache-Control: no-cache" https://gist.githubusercontent.com/DenysHnatiuk/40b1f11db14baffd7c01b2b05fd35075/raw/1a24b050b053a087b52751b95923c84acc7131f5/gitattributes.txt | tee > .gitattributes

_init_receipes-as-shell-alias:
  for recipe in `just --justfile ~/.user.justfile --summary`; do
  alias $recipe="just --justfile ~/.user.justfile --working-directory . $recipe"
  done

_npm-audit-fix:
  npm audit fix

# yarn audit fix 
_yarn-audit-fix:
  #!/usr/bin/env bash
  npm i --package-lock-only
  npm audit fix --force
  rm yarn.lock
  yarn import
  rm package-lock.json

# Setup pre-commit as a Git hook
precommit:
  #!/usr/bin/env bash
  set -euxo pipefail
  if [ -z "$SKIP_PRE_COMMIT" ] && [ ! -f ./pre-commit.pyz ]; then
    echo "Getting latest release"
    curl \
      ${GITHUB_TOKEN:+ --header "Authorization: Bearer ${GITHUB_TOKEN}"} \
      --output latest.json \
      https://api.github.com/repos/pre-commit/pre-commit/releases/latest
    cat latest.json
    URL=$(grep -o 'https://.*\.pyz' -m 1 latest.json)
    rm latest.json
    echo "Downloading pre-commit from $URL"
    curl \
      --fail \
      --location `# follow redirects, else cURL outputs a blank file` \
      --output pre-commit.pyz \
      ${GITHUB_TOKEN:+ --header "Authorization: Bearer ${GITHUB_TOKEN}"} \
      "$URL"
    echo "Installing pre-commit"
    python3 pre-commit.pyz install -t pre-push -t pre-commit
    echo "Done"
  else
    echo "Skipping pre-commit installation"
  fi



## Docker receipes

DOCKER_FILE := "-f " + (
    if IS_PROD == "true" { "prod/docker-compose.yml" }
    else { "docker-compose.yml" }
)


## PHP Toolkit

# PHPBrew
# PHP stdlib : PhpDotEnv, AutoLoader, ObjectBox, 
# XDebug
# Composer
# CodeSniffer
# Mess Detector
# CS Fixer
# PHP Stan
# Psalm
# Unit Tests
# PHP Frameworks : 
# PHP CMS :


# SASS Toolkit
_create-sassrc:
  touch .sassrc 
  echo '{ "includePaths": [ "node_modules" ] }' | tee -a .sassrc >/dev/null


# Wordpress
_init-wp-dev:

# WordPress prod theme
_init-wp-prod:
  mkdir {{PROJECT_NAME}}
  for i in {docs, assets, parts, patterns, templates}
  do
  mkdir {{PROJECT_NAME}}/$i
  done
  touch style.css theme.json functions.php LICENSE
  touch docs/LICENSE.TXT

_create-theme-style-css:
  touch style.css
  cat << EOF >>```
  @charset "UTF-8";
  /*!
  Theme Name: {{PROJECT_NAME}} 
  Theme URI: https://github.com/DenysHnatiuk/{{PROJECT_NAME}} 
  Author: Den Hnatiuk  
  Author URI: https://denyshnatiuk.github.io/{{PROJECT_NAME}} 
  Description: {{PROJECT_NAME}} Wordpress Theme
  Version: 0.0.1 
  Requires PHP: 5.6 
  Tested up to: 5.4 
  License: GNU General Public License v2 or later 
  License URI: LICENSE 
  Text Domain: {{PROJECT_NAME}} 
  Tags:  
  
  This theme, like WordPress, is licensed under the GPL. 
  */ ```EOF

# _git_check_remote_branch *:
#   git fetch --prune
#   git ls-remote --heads ${REPO} ${BRANCH} | grep ${BRANCH} >/dev/null
#   if [ "$?" == "1" ] ; then echo "Branch doesn't exist"; exit; fi
