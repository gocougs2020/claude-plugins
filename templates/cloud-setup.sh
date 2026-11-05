#!/bin/bash
# Setup script for a Claude Code cloud environment (claude.ai/code →
# environment selector → settings icon on the environment → Setup script).
#
# Cloud sessions ignore the marketplaces a repository's .claude/settings.json
# declares, so the plugins never load there. This script runs before Claude
# Code starts and installs them at user scope, so they load in every
# repository opened in this environment. It needs a network level that allows
# github.com (the default "Trusted" level does).
set -uo pipefail

claude plugin marketplace add anthropics/claude-plugins-official || true
claude plugin marketplace add gocougs2020/claude-plugins || true

for p in \
  review-loop@gocougs \
  web-design@gocougs \
  security-guidance@claude-plugins-official \
  frontend-design@claude-plugins-official
do
  claude plugin install "$p" --scope user || echo "Could not install $p"
done
