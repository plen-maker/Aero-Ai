#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  AERO — Dynamic Island AI Assistant                          ║
# ║  Installer for Arch Linux + Hyprland + ml4w                 ║
# ╚══════════════════════════════════════════════════════════════╝
#
# CONFIGURATION — edit these before running if you want defaults:
# ─────────────────────────────────────────────────────────────────
AERO_BIN="$HOME/.local/bin/aero"             # where aero gets installed
AERO_CFG="$HOME/.config/ai-assistant/config" # config file location
AERO_DATA="$HOME/.local/share/ai-assistant"  # data dir (history, tasks)
AERO_VENV="$AERO_DATA/venv"                  # Python venv location
HYPR_CUSTOM="$HOME/.config/hypr/custom.lua"  # Hyprland custom config
WAYBAR_CFG="$HOME/.config/waybar/themes/ml4w-transparent-centered/config"
GROQ_MODEL="llama-3.3-70b-versatile"         # Groq model to use
# ─────────────────────────────────────────────────────────────────

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC}  $1"; }
info() { echo -e "  ${CYAN}→${NC}  $1"; }
warn() { echo -e "  ${YELLOW}!${NC}  $1"; }
err()  { echo -e "  ${RED}✗  $1${NC}"; exit 1; }
ask()  { echo -ne "  ${BOLD}$1${NC} "; }
sep()  { echo -e "  ${DIM}────────────────────────────────────────${NC}"; }

clear
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}  ║                                          ║${NC}"
echo -e "${CYAN}  ║   ▄▄▄  ▄▄▄  ▄▄▄  ▄▄▄                   ║${NC}"
echo -e "${CYAN}  ║   █▀█  █▀   █▀▄  █▀█                   ║${NC}"
echo -e "${CYAN}  ║   ▀▀   ▀▀▀  ▀ ▀  ▀▀                    ║${NC}"
echo -e "${CYAN}  ║                                          ║${NC}"
echo -e "${CYAN}  ║   Dynamic Island AI for Arch + Hyprland  ║${NC}"
echo -e "${CYAN}  ║                                          ║${NC}"
echo -e "${CYAN}  ╚══════════════════════════════════════════╝${NC}"
echo ""

# ── 1. Check system ──────────────────────────────────────────────
sep
info "Checking system..."

[[ -f /etc/arch-release ]] || err "This installer requires Arch Linux."
command -v pacman &>/dev/null || err "pacman not found."
ok "Arch Linux detected"

# ── 2. System packages ───────────────────────────────────────────
sep
info "Installing system packages..."
echo -e "  ${DIM}python python-gobject gtk4 gtk4-layer-shell python-cairo${NC}"
echo ""
sudo pacman -S --needed --noconfirm \
    python python-gobject gtk4 gtk4-layer-shell python-cairo \
    2>/dev/null || err "pacman failed."
ok "System packages installed"

# ── 3. Python venv ───────────────────────────────────────────────
sep
info "Setting up Python environment..."
mkdir -p "$AERO_DATA"
python3 -m venv --system-site-packages "$AERO_VENV"
"$AERO_VENV/bin/pip" install --quiet --upgrade groq
ok "Python venv ready  ($AERO_VENV)"

# ── 4. Groq API key ──────────────────────────────────────────────
sep
echo -e "  ${BOLD}Groq API Key${NC}"
echo -e "  ${DIM}Free — no credit card required${NC}"
echo -e "  ${DIM}Get one at: console.groq.com → API Keys → Create${NC}"
echo ""
ask "Paste your key (gsk_...):"; read -r GROQ_KEY
echo ""
[[ "$GROQ_KEY" == gsk_* ]] || err "Invalid key — must start with gsk_"
ok "API key accepted"

# ── 5. Gmail (optional) ──────────────────────────────────────────
sep
echo -e "  ${BOLD}Gmail Integration${NC} ${DIM}(optional — press Enter to skip)${NC}"
echo ""
echo -e "  ${YELLOW}Important:${NC} If you have 2FA, you need an ${BOLD}App Password${NC}"
echo -e "  ${DIM}Generate at: myaccount.google.com/apppasswords${NC}"
echo -e "  ${DIM}It's 16 characters, NOT your Gmail password${NC}"
echo ""
ask "Gmail address (Enter to skip):"; read -r GMAIL_ADDR
GMAIL_PASS=""
if [[ -n "$GMAIL_ADDR" ]]; then
    ask "App password (16 chars, no spaces):"; read -rs GMAIL_PASS; echo ""
    GMAIL_PASS="${GMAIL_PASS// /}"
    ok "Gmail configured"
else
    ok "Gmail skipped"
fi

# ── 6. Write config ──────────────────────────────────────────────
sep
info "Writing config..."
mkdir -p "$(dirname "$AERO_CFG")"
cat > "$AERO_CFG" <<EOF
[main]
groq_api_key = $GROQ_KEY

[gmail]
email = $GMAIL_ADDR
app_password = $GMAIL_PASS
EOF
chmod 600 "$AERO_CFG"
ok "Config saved  ($AERO_CFG)"

# ── 7. Install aero ──────────────────────────────────────────────
sep
info "Installing aero..."
mkdir -p "$(dirname "$AERO_BIN")"
cp "$SCRIPT_DIR/aero" "$AERO_BIN"
chmod +x "$AERO_BIN"

# patch venv path to match this system
sed -i "s|sys.path.insert(0, \".*venv.*\")|sys.path.insert(0, \"$AERO_VENV/lib/$(python3 --version | awk '{print tolower($2)}' | cut -d. -f1-2 | sed 's/python/python/')/site-packages\")|" "$AERO_BIN" 2>/dev/null || true

ok "Installed  ($AERO_BIN)"

# ── 8. Hyprland keybindings ──────────────────────────────────────
sep
info "Configuring Hyprland..."
if [[ -f "$HYPR_CUSTOM" ]]; then
    if ! grep -q "aero" "$HYPR_CUSTOM"; then
        cat >> "$HYPR_CUSTOM" <<'LUA'

-- AERO Dynamic Island
local HOME = os.getenv("HOME")
hl.config({ input = { kb_options = "" } })
hl.bind("SUPER + SPACE",  hl.dsp.exec_cmd(HOME .. "/.local/bin/aero"))
hl.bind("SUPER + ALT_L",  hl.dsp.exec_cmd("pkill -USR1 -f 'python3.*aero'"))
hl.on("hyprland.start", function()
    hl.exec_cmd(HOME .. "/.local/bin/aero")
end)
LUA
        ok "Hyprland keybindings added"
        ok "  Super+Space  → open/close"
        ok "  Super+Alt    → voice dictation"
    else
        ok "Hyprland keybindings already present"
    fi
else
    warn "~/.config/hypr/custom.lua not found — add manually:"
    echo -e "  ${DIM}hl.bind(\"SUPER + SPACE\", hl.dsp.exec_cmd(os.getenv(\"HOME\") .. \"/.local/bin/aero\"))${NC}"
fi

# ── 9. Hide waybar workspace switcher ────────────────────────────
sep
info "Configuring waybar..."
if [[ -f "$WAYBAR_CFG" ]] && grep -q '"hyprland/workspaces"' "$WAYBAR_CFG"; then
    sed -i 's/"hyprland\/workspaces"[^,]*,//' "$WAYBAR_CFG"
    ok "Waybar workspace switcher hidden"
else
    ok "Waybar already configured (or file not found)"
fi

# ── 10. PATH check ───────────────────────────────────────────────
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    sep
    warn "~/.local/bin is not in your PATH"
    echo -e "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "  ${DIM}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

# ── Done ─────────────────────────────────────────────────────────
sep
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}  ║          Installation complete!          ║${NC}"
echo -e "${GREEN}  ╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Quick start:${NC}"
echo -e "  ${DIM}1.${NC}  hyprctl reload"
echo -e "  ${DIM}2.${NC}  Super+Space to open AERO"
echo -e "  ${DIM}3.${NC}  Super+Alt for voice dictation"
echo ""
echo -e "  ${BOLD}Config:${NC}     $AERO_CFG"
echo -e "  ${BOLD}Customize:${NC}  $AERO_BIN  (top ~50 lines)"
echo -e "  ${BOLD}History:${NC}    $AERO_DATA/history.json"
echo ""

read -rp "  Reload Hyprland and start AERO now? [Y/n] " yn
if [[ "${yn,,}" != "n" ]]; then
    hyprctl reload 2>/dev/null || true
    pkill -f "python3.*aero" 2>/dev/null || true
    nohup "$AERO_BIN" > /dev/null 2>&1 &
    echo ""
    ok "AERO is running!"
fi
echo ""
