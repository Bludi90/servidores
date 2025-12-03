#!/usr/bin/env bash
set -euo pipefail

echo "Buscando docker-compose.yml y compose.yaml relevantes..."
sudo find / -maxdepth 7 -type f \( -name 'docker-compose.yml' -o -name 'compose.yaml' \) 2>/dev/null \
  | grep -Ei 'nextcloud|jelly|collabora|firefly|pihole|unbound|caddy'
