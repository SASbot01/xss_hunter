# xss_hunter

🇪🇸 XSS-Fuzz — Escáner automático de XSS (Reflected)

XSS-Fuzz es un script en Bash para detectar de forma rápida posibles vulnerabilidades XSS reflejado. Inyecta payloads comunes como parámetro en una URL y comprueba si aparecen reflejados en la respuesta. Si el contenido se refleja sin sanear, podría existir una vulnerabilidad XSS.

✨ Características

Inyección automática de múltiples payloads XSS.

Detección de:

Posible XSS (payload crudo reflejado).

Reflexión (texto marcador reflejado).

Soporta una URL (-u) o lista de URLs (-f).

Control básico de User-Agent y timeout.

Colores y banner estilo cyberpunk.

📦 Requisitos

Bash (Linux/macOS o WSL).

curl, grep, sed.

🧪 Uso rápido

# URL única

./xss_fuzz.sh -u "https://ejemplo.com/buscar?q=hola"

# Archivo con varias URLs (una por línea)

./xss_fuzz.sh -f urls.txt

⚙️ Opciones
-u, --url URL objetivo
-f, --file Archivo con URLs (una por línea)
-p, --param Nombre del parámetro a inyectar (por defecto: xss_test)
-A, --agent User-Agent personalizado
-T, --timeout Timeout por petición en segundos (por defecto: 15)
--no-colors Desactiva colores en la salida
-h, --help Muestra la ayuda

🧩 Ejemplos

# Cambiar nombre del parámetro e indicar User-Agent

./xss_fuzz.sh -u "https://site.com/search" -p query -A "Mozilla/5.0"

# Escanear muchas URLs con timeout más laxo

./xss_fuzz.sh -f urls.txt -T 30

🧠 Interpretación de resultados

[!] Posible XSS encontrado → El payload aparece crudo en la respuesta. Señal fuerte de XSS reflejado.

[!] Reflexión encontrada → El texto marcador aparece. Hay reflexión; puede requerir payloads/contexto específicos para explotar.

Nota: Esta herramienta no ejecuta JavaScript; solo verifica reflexión. Úsala como pre-chequeo y confirma manualmente en navegador si es necesario.

🛡️ Ética y legalidad

Usa esta herramienta solo con permiso explícito del propietario del sistema. Respeta la ley y las políticas de uso responsable. El autor no se hace responsable del uso indebido.

XSS-Fuzz — Automatic XSS (Reflected) Scanner

XSS-Fuzz is a Bash script to quickly spot reflected XSS leads. It injects common XSS payloads as a URL parameter and checks whether the response reflects them. If unsanitized content is reflected, the target might be vulnerable.

✨ Features

Automated injection of multiple XSS payloads.

Detects:

Possible XSS (raw payload reflected).

Reflection (marker text reflected).

Accepts single URL (-u) or URL list (-f).

Basic User-Agent and timeout control.

Cyberpunk-styled banner and colored output.

📦 Requirements

Bash (Linux/macOS or WSL).

curl, grep, sed.

🧪 Quick start

# Single URL

./xss_fuzz.sh -u "https://example.com/search?q=hello"

# Multiple URLs (one per line)

./xss_fuzz.sh -f urls.txt

⚙️ Options
-u, --url Target URL
-f, --file File with URLs (one per line)
-p, --param Parameter name to inject (default: xss_test)
-A, --agent Custom User-Agent
-T, --timeout Per-request timeout in seconds (default: 15)
--no-colors Disable colored output
-h, --help Show help

🧩 Examples

# Change parameter name and set a User-Agent

./xss_fuzz.sh -u "https://site.com/search" -p query -A "Mozilla/5.0"

# Scan many URLs with a longer timeout

./xss_fuzz.sh -f urls.txt -T 30

🧠 Reading the results

[!] Possible XSS found → Raw payload reflected. Strong sign of reflected XSS.

[!] Reflection found → Marker text appears. Reflection exists; may need context-aware payloads to exploit.

Note: This tool does not execute JavaScript; it only checks for reflection. Use it as a pre-check and verify in a browser if needed.

🛡️ Ethics & legality

Use only with explicit permission of the system owner. Respect the law and responsible use policies. The author is not responsible for misuse.
