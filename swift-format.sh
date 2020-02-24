#!/bin/bash

# Formats all source files
swift run swiftformat ${BASH_SOURCE%/*}/Sources
