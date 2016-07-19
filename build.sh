#!/bin/bash

docker build --build-arg VERSION=$1 -t moodle .