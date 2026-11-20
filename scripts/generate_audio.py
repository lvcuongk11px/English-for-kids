#!/usr/bin/env python3
"""Generate offline English speech and simple feedback effects as PCM WAV."""

from __future__ import annotations
import json
import math
import os
import struct
import subprocess
import tempfile
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data" / "topics.json"


def valid_wav(path: Path) -> bool:
    try:
        with wave.open(str(path), "rb") as audio:
            return audio.getnframes() > 100 and audio.getframerate() >= 16000
    except (FileNotFoundError, wave.Error, EOFError):
        return False


def speak(text: str, target: Path) -> None:
    if valid_wav(target):
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    safe_text = text.replace("'", "''")
    safe_target = str(target.resolve()).replace("'", "''")
    script = (
        "Add-Type -AssemblyName System.Speech; "
        "$s=New-Object System.Speech.Synthesis.SpeechSynthesizer; "
        "$s.Rate=-2; $s.Volume=100; "
        "try {$s.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female,[System.Speech.Synthesis.VoiceAge]::Adult,0,[cultureinfo]'en-US')} catch {}; "
        f"$s.SetOutputToWaveFile('{safe_target}'); $s.Speak('{safe_text}'); $s.Dispose()"
    )
    result = subprocess.run(["powershell", "-NoProfile", "-Command", script], capture_output=True, text=True, timeout=45)
    if result.returncode != 0 or not valid_wav(target):
        raise RuntimeError(f"TTS failed for {text!r}: {result.stderr}")


def effect(path: Path, notes: list[tuple[float, float]], volume: float = 0.28) -> None:
    if valid_wav(path): return
    path.parent.mkdir(parents=True, exist_ok=True)
    rate = 22050
    samples: list[int] = []
    for frequency, duration in notes:
        count = int(rate * duration)
        for i in range(count):
            envelope = min(1.0, i / (rate * 0.015)) * max(0.0, 1 - i / count)
            samples.append(int(32767 * volume * envelope * math.sin(2 * math.pi * frequency * i / rate)))
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1); output.setsampwidth(2); output.setframerate(rate)
        output.writeframes(struct.pack(f"<{len(samples)}h", *samples))


def main() -> None:
    data = json.loads(DATA.read_text(encoding="utf-8"))
    count = 0
    for topic in data["topics"]:
        for item in topic["items"]:
            speak(item["questionText"], ROOT / item["questionAudioPath"])
            count += 1
    feedback = {"great_job": "Great job!", "excellent": "Excellent!", "try_again": "Try again!", "well_done": "Well done!", "you_did_it": "You did it!"}
    for filename, text in feedback.items(): speak(text, ROOT / "assets" / "audio" / "feedback" / f"{filename}.wav")
    effect(ROOT / "assets" / "audio" / "effects" / "correct.wav", [(523.25, .13), (659.25, .13), (783.99, .23)])
    effect(ROOT / "assets" / "audio" / "effects" / "wrong.wav", [(330, .16), (260, .23)], .18)
    print(f"Generated {count} questions, {len(feedback)} feedback clips, and 2 effects.")


if __name__ == "__main__": main()
