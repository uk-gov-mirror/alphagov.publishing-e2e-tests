require "webdrivers"

import "lib/tasks/docker.rake"
import "lib/tasks/govuk.rake"
load "webdrivers/Rakefile"

Webdrivers.install_dir = File.expand_path('/webdrivers/install/dir' + ENV['TEST_ENV_NUMBER'].to_s)
