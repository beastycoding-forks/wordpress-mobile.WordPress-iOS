#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- 📦 Downloading Build Artifacts"
download_artifact build-products-wordpress.tar
tar -v -xf build-products-wordpress.tar
ls -la

echo "--- Running Danger: PR Check"
bundle exec danger --fail-on-errors=true --dangerfile=.buildkite/danger/Dangerfile-post-build --danger_id=post-build
