#!/usr/bin/env python3
"""Validate Pinky V2 source provenance, runtime catalogs, images and audio."""
from __future__ import annotations
import json,sys,wave
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]; DATA=ROOT/'assets'/'data'
def main()->int:
    errors=[]
    try:
        vocabulary=json.loads((DATA/'vocabulary_catalog.json').read_text(encoding='utf-8'))['items']
        lessons=json.loads((DATA/'lesson_catalog.json').read_text(encoding='utf-8'))['lessons']
    except (OSError,json.JSONDecodeError,KeyError) as error:
        print(f'CATALOG INVALID: {error}');return 1
    ids=[item['id'] for item in vocabulary]
    if len(ids)!=len(set(ids)):errors.append('Duplicate vocabulary IDs')
    pdfs=list((ROOT/'references').rglob('*.pdf'))
    if len(pdfs)!=15:errors.append(f'Expected 15 PDFs, found {len(pdfs)}')
    if not (ROOT/'references'/'school'/'week-5-electronics.jpg').exists():errors.append('Missing Week 5 Electronics image')
    if not (ROOT/'references'/'extra-class'/'video-topics.PNG').exists():errors.append('Missing extra-class video title image')
    verified={item['id'] for item in vocabulary if 'school_verified' in item['sourceTypes']}
    inferred={item['id'] for item in vocabulary if 'extra_class_inferred' in item['sourceTypes']}
    if not verified:errors.append('No school_verified vocabulary')
    if not inferred:errors.append('No extra_class_inferred vocabulary')
    for item in vocabulary:
        for source in item['provenance']:
            if source['sourceType'] not in {'school_verified','extra_class_inferred'}:errors.append(f"Unknown source type: {item['id']}")
            if source['sourceType']=='extra_class_inferred' and source.get('file')!='video-topics.PNG':errors.append(f"Inferred term has invalid source: {item['id']}")
        image=item.get('imagePath')
        if image:
            try:
                with Image.open(ROOT/image) as opened:opened.verify()
            except (OSError,FileNotFoundError) as error:errors.append(f'Bad image {image}: {error}')
            audio=ROOT/item['audioPath']
            try:
                with wave.open(str(audio),'rb') as opened:
                    if opened.getnframes()<100:errors.append(f'Empty audio: {audio}')
            except (OSError,wave.Error,EOFError) as error:errors.append(f'Bad audio {audio}: {error}')
    inferred_lessons=[lesson for lesson in lessons if lesson['sourceType']=='extra_class_inferred']
    if len(inferred_lessons)!=9:errors.append(f'Expected 9 inferred topics, found {len(inferred_lessons)}')
    for lesson in inferred_lessons:
        if len(lesson.get('candidateTerms',[]))<15:errors.append(f"Inferred topic below 15 candidates: {lesson['id']}")
    known=set(ids)
    playable=0
    by_id={item['id']:item for item in vocabulary}
    for lesson in lessons:
        missing=set(lesson['vocabularyIds'])-known
        if missing:errors.append(f"Unknown vocabulary in {lesson['id']}: {sorted(missing)}")
        complete=[by_id[item_id] for item_id in lesson['vocabularyIds'] if by_id[item_id].get('imagePath')]
        if len(complete)>=4:playable+=1
    if playable<10:errors.append(f'Too few complete playable lessons: {playable}')
    packaged_images={Path(item['imagePath']).name for item in vocabulary if item.get('imagePath')}
    try:
        credited={entry['file'] for entry in json.loads((DATA/'image_manifest.json').read_text(encoding='utf-8'))['notoEmoji']}
        original={name for name in packaged_images if name.startswith(('colors_','shapes_','numbers_','original_'))}
        uncredited=packaged_images-credited-original
        if uncredited:errors.append(f'Images missing external credits: {sorted(uncredited)[:10]}')
    except (OSError,json.JSONDecodeError,KeyError) as error:errors.append(f'Invalid image manifest: {error}')
    if errors:
        print('PINKY V2 VALIDATION FAILED')
        for error in errors:print('-',error)
        return 1
    audio_count=sum(bool(item.get('imagePath')) for item in vocabulary)
    print(f'PINKY V2 VALIDATION PASSED: 15 PDFs, {len(vocabulary)} unique terms, {len(verified)} school verified, {len(inferred)} inferred, {playable} playable lessons, {len(packaged_images)} images, {audio_count} word audio files')
    return 0
if __name__=='__main__':sys.exit(main())
