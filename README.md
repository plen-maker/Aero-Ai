# AERO

**Dynamic Island AI Assistant for Arch Linux + Hyprland**

> A macOS Dynamic Island–inspired AI assistant that lives at the top of your screen. Ask anything, open apps, browse the web, manage emails and tasks — all from a single keyboard shortcut.

---

## Features

| | |
|---|---|
| **AI Chat** | Groq llama-3.3-70b — fast, free |
| **Voice Dictation** | Super+Alt → record → auto-transcribe (Whisper) |
| **Memory** | Remembers the last 10 min by default; full history with API key |
| **App Launcher** | "open spotify", "launch firefox" |
| **Web** | "open youtube", any URL |
| **Gmail** | Read emails, send with confirmation (App Password) |
| **Tasks** | Add, list, complete tasks |
| **Terminal** | Run commands, get output inline |
| **Install commands** | Opens terminal for sudo (pacman, yay) |

---

## Install

```bash
git clone https://github.com/plen-maker/Aero-user-interface
cd Aero-user-interface && bash install.sh
```

Requires: Arch Linux + Hyprland + ml4w  
Get a free Groq API key at [console.groq.com](https://console.groq.com)

---

## Shortcuts

| Shortcut | Action |
|---|---|
| `Super + Space` | Open / close |
| `Super + Alt` | Voice dictation on/off |
| `Enter` | Send message |
| `Esc` | Close |
| Click response | Expand full text |
| `/load <word>` | Search conversation history |

---

## Customize

Edit `~/.local/bin/aero` — the top section has all visual settings:

```python
ISLAND_W_IDLE = 420      # notch width when closed
ISLAND_W_OPEN = 1000     # notch width when open
ISLAND_H      = 44       # notch height

BG            = "#000000" # background
ACCENT        = "#7c6ff7" # highlight color
TEXT_RESPONSE = "#c8beff" # response text color
```

Restart after changes: `pkill -f aero; aero &`

---

## Config

`~/.config/ai-assistant/config`

```ini
[main]
groq_api_key = gsk_...

[gmail]
email = you@gmail.com
app_password = yourapppassword
```

> Gmail requires an **App Password** (not your regular password).  
> Generate one at [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)

---

## How it works

Idc somehow it works

## License

Theres no license use it as u want.





For the scared ones: This ahh program uses ur app password and email to send mails theres no databases or anything everything is locally run.
