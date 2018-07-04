#!/bin/bash

pwd
REV_NUMBER=$(git rev-list --count HEAD)

revision_number=$(git rev-list --count HEAD)

git log | head -n 2 | tail -n 1
git log | head -n 3 | tail -n 1
echo "G-${REV_NUMBER}"
HASH=$(git log | head -n 1 | awk '{print $2}')
echo "HASH: ${HASH}"

