#!/bin/bash

# Formats all source files
swift run --package-path ${BASH_SOURCE%/*}/Tools swiftformat ${BASH_SOURCE%/*}/Sources
