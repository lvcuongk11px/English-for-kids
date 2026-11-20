# Asset credits

## Noto Emoji pictograms

- Source: [Google Noto Emoji](https://github.com/googlefonts/noto-emoji), official `2D/png/512` assets.
- Copyright: Google and the Noto Emoji contributors.
- License: Apache License 2.0. A distribution copy is included at `licenses/NotoEmoji-LICENSE.txt`.
- Changes: each source pictogram is resized, centered, and composited onto an original pastel background at 384×384 pixels. No text or watermark is added.
- Exact source URL and SHA-256 for each packaged derivative are recorded in `assets/data/image_manifest.json`.

## Original assets

Color cards, geometric shape cards, decorative backgrounds, launcher icon, and synthesized correct/wrong tones were created specifically for this project and have no external asset dependency.

## Speech audio

Question and encouragement clips were generated locally through the Windows `System.Speech` offline synthesizer. They contain only project-authored phrases and are distributed as generated PCM WAV output; no voice model or synthesizer is packaged in the application.

V2 word clips are generated locally with Piper 1.8.0 using the `en_GB-alba-medium` voice at `length_scale=1.22` (about 0.82× natural speed). The voice dataset is licensed CC BY 4.0; its model card is included at `licenses/Piper-en_GB-alba-MODEL_CARD.md`. Piper and the 63 MB model are build tools only and are not packaged in the APK.

## Private learning references

The PDFs and photographed school sheets under `references/` are user-provided source material. They are used only to create provenance metadata and are not declared as Flutter assets, redistributed, or packaged in the APK.
