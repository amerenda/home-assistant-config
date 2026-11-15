#!/bin/sh
# Builds a throwaway /config shaped like the HA pod after git-sync, then runs check_config.
# Usage (inside the HA image): sh ci/check.sh
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
CFG=$(mktemp -d)
mkdir -p "$CFG/git"
# media_dirs in configuration.yaml are absolute /config/www paths
mkdir -p /config/www/pets /config/www/intruders
ln -s "$REPO" "$CFG/git/current"
cp "$REPO/configuration.yaml" "$CFG/configuration.yaml"
ln -s "$REPO/python_scripts" "$CFG/python_scripts"
ln -s "$REPO/blueprints" "$CFG/blueprints"
echo '[]' > "$CFG/automations.yaml"
echo '[]' > "$CFG/scenes.yaml"
echo '{}' > "$CFG/scripts.yaml"
export HA_DB_URL="sqlite:///$CFG/ci.db" JELLYFIN_API_KEY=ci
python3 -m homeassistant --script check_config --config "$CFG"
