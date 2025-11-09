#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
WG="$ROOT/docs/WIREGUARD.md"
H="$ROOT/scripts/help.d"

stamp() { date +%F' '%H:%M; }
indent() { sed 's/^/    /'; }

# Tabla: saca una línea de resumen razonable de un .help
summarize_help() {
  local title="$1" file="$2" line
  line="$(grep -m1 '—' "$file" || true)"
  if [[ -z "${line// }" ]]; then
    line="$(awk 'NF && $0 !~ /^(USO|Uso|USAGE|Usage)/{print; exit}' "$file")"
  fi
  line="${line//|/\\|}"
  printf '| `%s` | %s |\n' "$title" "${line:-Ver ayuda}"
}

# Tabla: parsea WIREGUARD.md y convierte cada "## Subcmd" en fila
summarize_wg_from_md() {
  local md="$WG"
  awk -v prefix="wg " '
    BEGIN{insec=0; name=""; got=0; desc=""}
    /^##[[:space:]]+/ {
      if (insec && name!="") {
        gsub(/\|/,"\\|",desc)
        printf("| `%s%s` | %s |\n", prefix, name, (got?desc:"Ver ayuda"))
      }
      name=$0
      sub(/^##[[:space:]]+/, "", name)
      insec=1; got=0; desc=""
      next
    }
    insec {
      if (!got) {
        if ($0 ~ /^[_`]/) next
        if ($0 ~ /^[[:space:]]*$/) next
        if ($0 ~ /^[[:space:]]{4}/) next
        if ($0 ~ /^Disponible/) next
        desc=$0; got=1
      }
    }
    END{
      if (insec && name!="") {
        gsub(/\|/,"\\|",desc)
        printf("| `%s%s` | %s |\n", prefix, name, (got?desc:"Ver ayuda"))
      }
    }
  ' "$md"
}

mkdir -p "$ROOT/docs"
shopt -s nullglob

# -------------------------------
# COMANDOS.md (único fichero que generamos)
# -------------------------------
{
  echo "# Comandos personalizados"
  echo
  echo "_Generado: $(stamp)_"
  echo

  echo "## Guías y hojas rápidas"
  [[ -r "$WG" ]] && echo "- **Cheatsheet WireGuard:** [WIREGUARD.md](WIREGUARD.md)"
  [[ -r "$ROOT/docs/LANSCAN.md" ]] && echo "- **Guía LAN Scan:** [LANSCAN.md](LANSCAN.md)"
  [[ -r "$ROOT/docs/WOL.md" ]] && echo "- **Guía Wake-on-LAN:** [WOL.md](WOL.md)"
  echo

  # Bloque agrupado: wg — importa WIREGUARD.md si existe
  if [[ -r "$WG" ]]; then
    echo "## wg"
    echo
    awk '
      NR==1 && $0 ~ /^# / {next}
      NR==2 && $0 ~ /^_Generado:/ {next}
      {print}
    ' "$WG"
    echo
  elif compgen -G "$H/wireguard/*.help" > /dev/null; then
    echo "## wg"
    echo
    [ -r "$H/wireguard/_index.help" ] && indent < "$H/wireguard/_index.help" && echo
    for hf in "$H/wireguard/"*.help; do
      bn="$(basename "$hf")"
      [[ "$bn" == "_index.help" ]] && continue
      sub="${bn%.help}"
      echo "### wg $sub"
      echo
      indent < "$hf"
      echo
    done
  fi

  # Comandos sueltos (help.d/*.help)
  for f in "$H"/*.help; do
    name="$(basename "$f" .help)"
    echo "## $name"
    echo
    indent < "$f"
    echo
  done

  # Resumen rápido
  echo "## Resumen rápido"
  echo
  echo "| Comando | Para qué sirve |"
  echo "|---|---|"

  if [[ -r "$WG" ]]; then
    summarize_wg_from_md
  elif compgen -G "$H/wireguard/*.help" > /dev/null; then
    for hf in "$H/wireguard/"*.help; do
      bn="$(basename "$hf")"
      [[ "$bn" == "_index.help" ]] && continue
      sub="${bn%.help}"
      summarize_help "wg $sub" "$hf"
    done
  fi

  for f in "$H"/*.help; do
    name="$(basename "$f" .help)"
    summarize_help "$name" "$f"
  done

  # Snapshot final con el contenido íntegro de WIREGUARD.md y todos los *.help
  echo
  echo "## Listado final — contenidos de ayuda (snapshot)"
  echo
  if [[ -r "$WG" ]] || compgen -G "$H/*.help" > /dev/null || compgen -G "$H/wireguard/*.help" > /dev/null; then
    echo '```text'
    if [[ -r "$WG" ]]; then
      echo "--- docs/WIREGUARD.md ---"
      cat "$WG"
      echo
    fi
    if compgen -G "$H/wireguard/*.help" > /dev/null; then
      for hf in "$H/wireguard/"*.help; do
        bn="$(basename "$hf")"
        echo "--- scripts/help.d/wireguard/$bn ---"
        cat "$hf"
        echo
      done
    fi
    if compgen -G "$H/*.help" > /dev/null; then
      for f in "$H"/*.help; do
        bn="$(basename "$f")"
        echo "--- scripts/help.d/$bn ---"
        cat "$f"
        echo
      done
    fi
    echo '```'
  else
    echo "_No se han encontrado archivos de ayuda._"
  fi
} > "$OUT"

echo "OK: regenerado $(basename "$OUT") importando WIREGUARD.md si existe"
