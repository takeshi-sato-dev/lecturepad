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

LecturePad supports multi-tab workspaces (multiple PDFs and whiteboards simultaneously), configurable board sizes (4:3, 16:9, A4, Letter), freehand drawing, geometric shapes (line, arrow, circle, ellipse, rectangle, rounded rectangle), text annotations with font/size/alignment/line-height controls, a fading laser pointer, annotation locking, undo/redo, zoom with scroll synchronization to the presenter window, PDF export with baked-in annotations, and session save/restore. An iPad-native wrapper is also provided.

# Statement of Need

In language and science courses, educators frequently need to present model answers step by step, allowing students time to think before each word appears. Research on active learning consistently demonstrates that student engagement improves when learners are given time to process information incrementally rather than passively receiving complete blocks of content [@freeman2014; @prince2004]. The conventional approach is to type answers live during class, which introduces typing errors, forces the educator to face the screen rather than the students, and consumes class time. Presentation software such as PowerPoint or Keynote can display pre-made text, but only as a complete block, eliminating the pedagogically valuable pacing control that the segmenting principle identifies as beneficial for learning [@mayer2009; @brame2016].

Existing annotation tools such as MetaMoji Note [@metamoji], GoodNotes [@goodnotes], and Xournal++ [@xournalpp] provide freehand drawing and text placement, but none offers a mechanism for pre-loaded text to be revealed incrementally during a lecture. Furthermore, these tools require installation, platform-specific licenses, or cloud accounts.

LecturePad addresses these gaps with three combined capabilities that, to the authors' knowledge, are not available together in any existing tool:

1. **Sequential text revelation (Type mode):** Pre-prepared text is displayed token by token via spacebar or auto-timer, with independent text boxes that can be individually reset and repositioned.
2. **Asymmetric display (Present mode):** A separate window shows only the annotated canvas. The educator's control panel, including all prepared text, remains hidden from students.
3. **Zero infrastructure:** The entire application is a single HTML file (~1500 lines) with no server, no account, and no installation requirement. It runs on Mac, Windows, Chromebook, and iPad.

# Key Features

| Feature | Description |
|---------|-------------|
| Type mode | Multiple independent text boxes; spacebar or auto-timer revelation; English word-by-word, CJK character-by-character |
| Present mode | Separate projector window mirroring the educator's viewport (zoom and scroll synchronized) |
| Prompt overlay | Persistent question text displayed at the canvas top; configurable color, opacity, alignment, font size; movable in Select mode |
| Annotation tools | Pen, text (with justify/align, line height, word wrap), eraser, laser pointer, geometric shapes |
| Select mode | Click or Shift+click multi-select; drag to move; arrow keys for fine positioning; right-bottom handle for text box resize; Delete to remove |
| Lock | Selected annotations can be locked to prevent accidental modification or deletion |
| PDF workflow | Open PDF, annotate, export as annotated PDF; session save/restore as JSON |
| Board sizes | 4:3, 16:9, A4, A4 Landscape, Letter, Letter Landscape; grid overlay toggle |
| Cross-platform | Browser (Mac/Win/Linux/Chromebook); iPad native app via WKWebView wrapper; PWA for offline use |

# Software Availability and Use

LecturePad is available at [https://github.com/takeshi-sato-dev/lecturepad](https://github.com/takeshi-sato-dev/lecturepad) under the MIT License. To use it, download `LecturePad.html` and open it in a browser. No build step or dependency installation is required; pdf.js and jsPDF are loaded from a CDN on first use and cached by the service worker for subsequent offline use.

For iPad deployment, a shell script (`make_ipad_app.sh`) generates a complete Xcode project that bundles all dependencies locally. A free Apple ID is sufficient for installation on personal devices.

Detailed usage instructions and keyboard shortcuts are provided in the repository README.

# Author Contributions

T.S. conceived, designed, and developed the software, and wrote the manuscript.

# References
