# Pinky Adventure V2 — Audit

Date: 2026-11-17

## Existing application

- Flutter root: `D:\Dau_app`; Flutter 3.50.0 / Dart 3.14.0.
- Android SDK 36 and Java 21 are healthy; no Android device/emulator is connected.
- Application ID: `com.englishforkids.english_for_kids`.
- V1 version: `1.0.0+1`; release builds use the existing local Android debug key. This is suitable for personal installation and can update V1 only when the same local debug key is present.
- V1 content: 7 topics, 68 vocabulary items, 68 question WAV files, 68 learning PNGs.
- Architecture to preserve: JSON data loader, topic/vocabulary models, offline `audioplayers` service, Home/Quiz/Result navigation, asset generation and validation scripts.

## UX and technical findings

- Every activity is the same four-image selection layout.
- Long `questionText` and its audio are stored per item, so First Words and school sentence levels cannot be selected independently.
- `AudioPlayer.play()` returns after playback starts, while V1 transition timers start immediately afterward; therefore transition timing does not wait for speech completion.
- Wrong-answer feedback interrupts current audio but has no review scheduling.
- No local progress, sticker rewards, parent settings, scene interaction, drag/drop, coloring, counting, or adventure structure.
- Pinky and the V2 curriculum/game work started in the previous interrupted run are incomplete. Generated assets are retained; no user files were discarded.

## Source materials found and inspected

- 15 PDFs under `references/school/khóa 1/`, all pages extracted and reviewed.
- `references/school/week-5-electronics.jpg`, visually reviewed: 8 required Electronics words and two school sentence patterns.
- `references/extra-class/video-topics.PNG`, visually reviewed: Rules Homework plus 9 vocabulary topic titles.
- The archive mentioned by the brief is not present; the 15 PDF files are already extracted.

## Reuse and change strategy

- Keep application identity, signing behavior, V1 assets, legal notices, and data-driven loading.
- Normalize school vocabulary with per-source provenance; inferred extra-class words remain explicitly distinct from school-verified words.
- Replace the single quiz flow with a lesson/game registry and real interaction widgets.
- Add a CustomPainter Pinky to guarantee consistent lightweight expressions.
- Add coordinated audio, three language levels, local review metrics, stickers, worlds, parent settings, and a direct topic route.
- Package only optimized runtime assets; `references/` is not declared in `pubspec.yaml` and will not enter the APK.
