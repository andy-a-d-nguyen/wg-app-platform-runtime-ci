#!/bin/bash

# @AI-Generated
# Generated in whole or in part by Cursor with a mix of different LLM models (Auto select mode)
# Description:
# 2026-05-08: Create bump-dependencies-gemfile shared task (TNZ-100412)

set -eEu
set -o pipefail

THIS_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export TASK_NAME="$(basename $THIS_FILE_DIR)"
source "$THIS_FILE_DIR/../../../shared/helpers/helpers.bash"
source "$THIS_FILE_DIR/../../../shared/helpers/git-helpers.bash"
unset THIS_FILE_DIR

export CURRENT_DIR="$PWD"

function run() {
  local task_tmp_dir="${1:?provide temp dir for task}"
  shift 1
  git_configure_author
  git_configure_safe_directory

  local env_file="$(mktemp -p ${task_tmp_dir} -t 'XXXXX-env.bash')"
  expand_envs "${env_file}"
  . "${env_file}"

  pushd repo > /dev/null

  for entry in ${GEMFILES:-}
  do
    dir_name=$(dirname "$entry")
    gemfile=$(basename "$entry")

    echo "---Updating Gemfile dependencies for ${dir_name}"

    pushd "$dir_name" > /dev/null

    bundle update

    if [[ $(git status --porcelain) ]]; then
      git add -A .
      git commit -m "Bump Gemfile dependencies"
    fi

    popd > /dev/null
  done

  rsync -av $PWD/ "$CURRENT_DIR/bumped-repo"
  popd > /dev/null
}

function cleanup() {
    rm -rf $task_tmp_dir
}

task_tmp_dir="$(mktemp -d -t 'XXXX-task-tmp-dir')"
trap cleanup EXIT
trap 'err_reporter $LINENO' ERR
run $task_tmp_dir "$@"
