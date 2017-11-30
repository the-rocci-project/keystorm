#!/bin/bash

source $(dirname $0)/configuration.sh

configure_keystorm
bundle exec --keep-file-descriptors puma $@
