---
title: 'LecturePad: A zero-infrastructure browser application for real-time lecture annotation with sequential text revelation'
tags:
  - JavaScript
  - education
  - lecture annotation
  - presentation tool
  - PDF annotation
authors:
  - name: Takeshi Sato
    orcid: 0009-0006-9156-8655
    affiliation: 1
affiliations:
  - name: Kyoto Pharmaceutical University, Kyoto, Japan
    index: 1
date: 10 May 2026
bibliography: paper.bib
---

# Summary

LecturePad is an open-source, browser-based lecture annotation tool distributed as a single HTML file. It requires no installation, no user account, and no server infrastructure. Educators open the file in any modern browser to annotate PDF slides or write on a whiteboard canvas using pen, text, shape, and pointer tools. LecturePad runs entirely client-side using pdf.js [@pdfjs] for rendering and jsPDF [@jspdf] for export; all data remains on the local machine.

The distinguishing feature of LecturePad is its Type mode, which enables sequential text revelation: educators prepare answer text in advance and reveal it one token at a time during class by pressing the spacebar. English text is revealed word by word; Japanese (and other CJK) text is revealed character by character. This approach implements the segmenting principle of multimedia learning [@mayer2009; @mayer2001], which holds that learners achieve deeper understanding when information is presented in user-paced segments rather than as a continuous unit. A separate presenter window (Present mode) displays only the canvas to the projector, while the educator retains access to the full control interface, including the prepared answer text. Students therefore perceive the text as being typed in real time, while the educator can face the class and speak without interruption.

LecturePad also supports multi-tab workspaces, configurable board sizes, freehand drawing, geometric shapes, rich text annotations with per-character color and bold/italic formatting, image import, a fading laser pointer, annotation locking, copy/paste, undo/redo, zoom, PDF export, and session save/restore.

# Statement of Need

In language and science courses, educators frequently present model answers step by step. Research on active learning demonstrates that engagement improves with incremental information processing [@freeman2014; @prince2004]. Typing answers live introduces errors and forces the educator to face the screen. Presentation software displays pre-made text as a complete block, eliminating the pacing control that the segmenting principle identifies as beneficial [@mayer2009; @brame2016].

Existing tools such as MetaMoji Note [@metamoji], GoodNotes [@goodnotes], and Xournal++ [@xournalpp] provide freehand drawing and text placement but none offers incremental text revelation. They also require installation, platform-specific licenses, or cloud accounts.

LecturePad addresses these gaps with three combined capabilities not available together in any existing tool: (1) sequential text revelation via spacebar or auto-timer, (2) asymmetric display that hides the control interface from students, and (3) zero infrastructure as a single HTML file requiring no server, account, or installation.

# Key Features

| Feature | Description |
|---------|-------------|
| Type mode | Multiple independent text boxes per tab; spacebar or auto-timer revelation; word-by-word for English, character-by-character for CJK; separate popup control window |
| Present mode | Separate projector window mirroring the educator's visible canvas; cursor position visible to students |
| Rich text | Per-character color, bold, and italic within a single text box; contentEditable editing with real-time canvas preview |
| Prompt overlay | Persistent question text at canvas top; configurable colors, opacity, alignment, font size, line height; per-tab settings |
| Annotation tools | Pen, text, eraser, laser pointer, line, arrow, circle, ellipse, rectangle, rounded rectangle, image import |
| Select mode | Multi-select, drag, arrow keys, corner-handle resize, scale slider, lock/unlock, copy/paste across pages |
| PDF workflow | Open PDF, annotate, export annotated PDF; session save/restore as JSON with per-tab Type boxes and Prompt |
| Board sizes | 4:3, 16:9, A4, A4 Landscape, Letter, Letter Landscape; grid overlay; add pages |
| Tabs | Rename (double-click), reorder (drag), pop out to window; per-tab annotations, Type boxes, and Prompt |
| Cross-platform | PWA on any browser (Mac/Win/Linux/Chromebook/iPad/Android); optional iPad native app via WKWebView |

# State of the Field

PowerPoint and Keynote remain the dominant lecture tools but lack real-time annotation and incremental text display. MetaMoji Note [@metamoji] and GoodNotes [@goodnotes] provide tablet-based pen input and PDF annotation but require platform-specific installation and paid licenses; neither supports sequential text revelation. Xournal++ [@xournalpp] is an open-source desktop alternative for pen-based annotation but similarly lacks timed text display. None of these tools combines sequential text revelation with asymmetric display in a zero-infrastructure package.

# Software Design

LecturePad is a single HTML file (~2300 lines) with embedded CSS and JavaScript. Two external libraries are loaded from CDN: pdf.js [@pdfjs] for PDF rendering and jsPDF [@jspdf] for PDF export. A service worker caches all resources for offline PWA operation.

Two layered HTML5 `<canvas>` elements separate the static background (PDF or whiteboard) from annotations, allowing independent redraw. Present mode opens a second browser window that reads canvas content via `window.opener` at display refresh rate. Type mode opens a separate popup window for controls, keeping the main toolbar stable and preventing Present window jitter.

Text annotations use a runs-based data model where each annotation contains an array of styled segments, enabling per-character color and bold/italic formatting. A contentEditable div provides the editing interface with real-time canvas preview. Type mode maintains per-tab text boxes, each tokenized into words or CJK characters. All state is persisted to IndexedDB for automatic session recovery.

# Research Impact Statement

LecturePad has been used in English composition and pharmaceutical science courses at Kyoto Pharmaceutical University. Type mode enables word-by-word presentation of model answers synchronized with verbal explanation, a style of instruction previously possible only with a physical blackboard. This is relevant to any discipline where stepwise text presentation is pedagogically valuable, including language instruction, mathematics, and programming. By requiring no installation or accounts, LecturePad lowers adoption barriers for educators without institutional IT support.

# AI Usage Disclosure

An AI assistant (Claude, Anthropic) was used for code organization and English editing of the manuscript. The software concept, architectural design, feature specifications, and all pedagogical rationale originate entirely from the author based on over twenty years of teaching experience. The author takes full responsibility for the software and the manuscript.

# Software Availability and Use

LecturePad is available at [https://github.com/takeshi-sato-dev/lecturepad](https://github.com/takeshi-sato-dev/lecturepad) under the GPL-3.0 License. Download `LecturePad.html` and open it in a browser. No build step is required. Usage instructions are provided in the repository README.

# Author Contributions

T.S. conceived, designed, and developed the software, and wrote the manuscript.

# References
