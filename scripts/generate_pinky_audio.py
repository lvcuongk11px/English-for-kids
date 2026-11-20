#!/usr/bin/env python3
"""Generate slow en-GB offline word audio for every playable catalog entry."""
from __future__ import annotations
import json, wave
from pathlib import Path
from piper import PiperVoice, SynthesisConfig

ROOT=Path(__file__).resolve().parents[1]
MODEL=Path(r'D:\dev-tools\piper-voices\en_GB-alba-medium.onnx')
CATALOG=ROOT/'assets'/'data'/'vocabulary_catalog.json'

def valid(path:Path)->bool:
    try:
        with wave.open(str(path),'rb') as audio: return audio.getnframes()>100 and audio.getframerate()>=16000
    except (OSError,wave.Error,EOFError): return False

def main():
    if not MODEL.exists(): raise SystemExit(f'Missing Piper model: {MODEL}')
    items=json.loads(CATALOG.read_text(encoding='utf-8'))['items']
    playable=[item for item in items if item.get('imagePath')]
    voice=PiperVoice.load(MODEL)
    config=SynthesisConfig(length_scale=1.22,noise_scale=0.62,noise_w_scale=0.78,normalize_audio=True,volume=0.92)
    made=0
    for item in playable:
        target=ROOT/item['audioPath']; target.parent.mkdir(parents=True,exist_ok=True)
        if valid(target): continue
        with wave.open(str(target),'wb') as output: voice.synthesize_wav(item['english'].title()+'!',output,syn_config=config)
        made+=1
    print(f'Piper en-GB audio ready: {len(playable)} playable words ({made} generated).')

if __name__=='__main__': main()
