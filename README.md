# LecturePad

A zero-infrastructure, browser-based lecture annotation tool with sequential text revelation.

LecturePad is a single HTML file that runs in any modern browser. No installation, no account, no server. Open it and start annotating.

## Why LecturePad?

When presentation software displays a model answer as a complete sentence, students copy it wholesale. The word-by-word cognitive engagement that characterized blackboard instruction is lost.

LecturePad's **Type mode** recovers this: pre-prepared text is revealed one word at a time (one character for Japanese/CJK), letting the educator speak to each word as it appears. A separate **Present mode** window shows only the canvas to the projector, keeping the control interface and prepared answers hidden from students.

## Quick Start

1. Download `LecturePad.html`
2. Open it in Chrome, Firefox, Safari, or Edge
3. Click **Open PDF** or **+ BOARD**
4. Start annotating

Alternatively, use the hosted version: https://takeshi-sato-dev.github.io/lecturepad/

## Features

### Tools

| Tool | Button | Shortcut | Description |
|------|--------|----------|-------------|
| Select | ⇱ Select | V | Click to select. Shift+click for multi-select. Drag to move. Arrow keys for fine movement (Shift = 10px). Delete/Backspace to remove. |
| Pen | Pen | P | Freehand drawing. Configurable color, size, and opacity. |
| Pointer | Pointer | L | Laser pointer with fading trail. Configurable fade time (0.5-6.0s). |
| Text | Text | T | Click to place text. Click existing text to edit. Rich text: per-character color, bold, italic. |
| Type | Type | R | Sequential text revelation. Opens a separate control window. |
| Eraser | Eraser | E | Click or drag to remove annotations. |
| Line | ╱ | - | Straight lines. |
| Arrow | → | A | Arrows. |
| Circle | ○ | C | Circles. |
| Ellipse | ⬭ | - | Ellipses. |
| Rectangle | ▭ | - | Rectangles. |
| Rounded Rect | ▢ | - | Rounded rectangles. |
| Image | 🖼 | - | Import image. Auto-resize. Move and resize in Select mode. |

### Tool-Specific Colors

Each tool remembers its own color independently:

| Tool | Default |
|------|---------|
| Pen / Shapes | Red |
| Text | Black |
| Type | Black |
| Pointer | Red |

### Rich Text

Text annotations support per-character formatting within a single text box.

**During editing (contentEditable):**

- Select text within the box, then click a color in the palette to change just that selection
- Select text, then click **B** or **I** to toggle bold/italic on the selection
- If no text is selected, the setting applies to new text typed at the cursor
- Changes appear on the canvas in real time (visible in Present window)

**Data model:** Each text annotation stores an array of styled runs. Example: "hello" in red bold + "world" in blue italic within the same text box.

### Type Mode

Type mode opens a **separate control window** that can be moved to any monitor. The main canvas is unaffected.

**Setup:**

1. Press R to open the Type control window
2. Click **+ Add** to create text boxes (resizable)
3. Paste or type prepared answers
4. Each board/tab has its own independent text boxes and Prompt

**During class:**

1. Click a text box (blue border)
2. Click on the canvas to set position
3. **Spacebar** reveals the next word (works in any tool mode)
4. **Backspace** goes back one word
5. Drag the revealed text to reposition (in Reveal or Select mode)
6. On completion, auto-switches to Select with the text selected

**Auto mode:** Click **▶ Auto** for timed reveal. Adjust Speed (0.1-2.0s per word).

**Tokenization:** English = word-by-word. Japanese/CJK = character-by-character. Mixed text handled correctly.

### Prompt

Persistent question text overlay. Controls are in the Type control window.

- Enter text, click **📌 Prompt** to toggle
- Configure: BG/FG color, opacity (0 = no background), font size, line height, alignment (L/C/R)
- Drag in Select mode; other tools work on top of prompt
- OFF then ON resets position
- **📎 Bake** writes prompt to canvas as permanent annotation
- Per-tab settings

### Present Mode

1. Click **⛶ Present** to open a projector window
2. Drag to the projector display (extended desktop)
3. Shows the educator's visible canvas area
4. Cursor position visible as blue crosshair
5. **Esc** to close

**Asymmetric display:** Students see only the canvas. All controls, Type boxes, and prepared answers are hidden.

### Select Mode

**Selection:** Click or Shift+click. Corner handles shown.

**Moving:** Drag, or arrow keys (Shift = 10px).

**Resizing:** Text: bottom-right corner changes wrap width. Images: bottom-right corner, aspect ratio maintained.

**Properties:** Font, size, B/I, alignment (L/C/R/J), line height. Changes apply immediately.

**Scaling:** Scale slider (25%-400%) with numeric input. Adjusts text, strokes, shapes, images.

**Lock (🔒):** Locked items cannot be moved, resized, erased, or deleted. Clear Page/All preserves locked items. Click 🔓 to unlock.

### Copy and Paste

- **Cmd+C / Ctrl+C:** Copy selected annotations
- **Cmd+V / Ctrl+V:** Paste (works across pages, offset 20px)
- Preserves rich text runs, strokes, shapes, images

### Image Import

Click **🖼** to import. Auto-resize to 50% canvas. Move/resize in Select mode (aspect ratio maintained). Included in PDF export and session save.

### Canvas and Board

**PDF:** Open via button or drag-and-drop. Navigate with ◀ ▶ or arrow keys.

**Whiteboard:** Click **+ BOARD**. Sizes: 4:3, 16:9, A4 (default), A4L, Letter, LetterL. Grid toggle. Add pages with **＋**.

**Tabs:** Click to switch. Double-click to rename. Drag to reorder. **×** to close. **⧉** to pop out. Each tab has independent annotations, Type boxes, and Prompt.

**Zoom:** +/- buttons or numeric input. CSS-based: coordinates stay stable. Pinch zoom on touch. Scroll to navigate.

### Color Palette

Red, orange, yellow, green, blue, purple, black, medium gray, light gray, white.

All numeric controls have both slider and number input, bidirectionally synced.

### Save and Export

| Button | Function |
|--------|----------|
| **Export PDF** | Current tab as PDF with annotations |
| **💾 Session** | All tabs + Type boxes + Prompt as JSON |
| **📂 Session** | Load JSON session |

**Auto-save:** IndexedDB, per tab. Restores on browser reopen. **Reset** clears all.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| V | Select |
| P | Pen |
| L | Pointer |
| T | Text |
| R | Type (opens control window) |
| E | Eraser |
| A | Arrow |
| C | Circle |
| Space | Reveal next word (any tool) |
| Backspace | Go back one word (Type) |
| Cmd/Ctrl+Z | Undo |
| Cmd/Ctrl+Shift+Z | Redo |
| Cmd/Ctrl+C | Copy |
| Cmd/Ctrl+V | Paste |
| ← → | Previous/next page |
| Arrows | Move selected (Select mode) |
| Shift+Arrows | Move 10px |
| Delete | Remove selected |
| Esc | Close Present window |

## PWA Installation

Works on any platform:

1. Open https://takeshi-sato-dev.github.io/lecturepad/
2. Share button (iOS) or menu (Android/Chrome)
3. "Add to Home Screen"
4. Works offline after first visit

### Self-hosting

Host these files on any static server:

```
LecturePad.html, sw.js, manifest.json, icon-192.png, icon-512.png, index.html
```

## iPad Native App (Optional)

For external display output via HDMI/AirPlay:

```bash
chmod +x make_ipad_app.sh
./make_ipad_app.sh
```

Open in Xcode, select iPad, click ▶. Free Apple ID requires re-signing every 7 days.

## Local Server

```bash
python3 -m http.server 8080
```

Or double-click `start_lecturepad.command` on Mac.

## Architecture

Single HTML file (~2300 lines), embedded CSS/JS. Dependencies: pdf.js (CDN, cached by service worker), jsPDF (CDN, cached). Two layered canvases (background + annotations). Present via window.opener. Type controls in separate popup window. Rich text via runs-based data model with contentEditable editing. Per-tab state persisted to IndexedDB.

## License

GPL-3.0. See [LICENSE](LICENSE).

## Citation

```bibtex
@article{sato2026lecturepad,
  title     = {LecturePad: A zero-infrastructure browser application for real-time lecture annotation with sequential text revelation},
  author    = {Sato, Takeshi},
  journal   = {Journal of Open Source Education},
  year      = {2026},
  doi       = {TBD}
}
```
