#!/bin/bash
# ═══════════════════════════════════════
# LecturePad Server
# ═══════════════════════════════════════

DIR="$(cd "$(dirname "$0")" && pwd)"
PORT=8080

IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║           LecturePad Server                  ║"
echo "  ╠══════════════════════════════════════════════╣"
echo "  ║                                              ║"
echo "  ║  Mac:    http://localhost:$PORT/LecturePad.html"
echo "  ║  iPad:   http://$IP:$PORT/LecturePad.html"
echo "  ║                                              ║"
echo "  ║  iPad setup (one time only):                 ║"
echo "  ║    1. Open URL above in Safari               ║"
echo "  ║    2. Tap Share button (box with arrow)       ║"
echo "  ║    3. Add to Home Screen                     ║"
echo "  ║    4. Done! Opens like a native app.         ║"
echo "  ║       Works offline after first load.        ║"
echo "  ║                                              ║"
echo "  ║  Stop:   Ctrl+C                              ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

open "http://localhost:$PORT/LecturePad.html" 2>/dev/null

cd "$DIR"
python3 -m http.server $PORT
