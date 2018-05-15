#!/bin/bash
cd $2 # gets into okl/app
REPO_NAME="https://github.com/okl/$1"
REVISION=$(bundle exec ruby -r ./config/initializers/ci_version.rb -e 'puts ENV["BBB_COMMIT_SHA"]')
BBB_CI_VERSION=$(bundle exec ruby -r ./config/initializers/ci_version.rb -e 'puts ENV["BBB_CI_VERSION"]')
bundle exec honeybadger deploy --repository=$REPO_NAME --revision=$REVISION --user="build:$BBB_CI_VERSION"
