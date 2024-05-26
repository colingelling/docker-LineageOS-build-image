#!/bin/bash

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Fill in both email and username to configure your git identity

# Due to their size, some repos are configured for lfs or Large File Storage. This is to make sure the distribution is prepared for that
git lfs install

git config --global trailer.changeid.key "Change-Id"