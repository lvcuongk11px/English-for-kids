#!/usr/bin/env python3
"""Build provenance-aware Pinky Adventure vocabulary and lesson catalogs."""
from __future__ import annotations
import json, re
from collections import Counter, defaultdict
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'assets'/'data'
IMAGE_OVERRIDES={
    'computer':'assets/images/school_computer.png',
    'camera':'assets/images/school_camera.png',
    'tablet':'assets/images/original_tablet.png',
    'aircon':'assets/images/original_aircon.png',
}

def words(text): return [part.strip() for part in text.split('|') if part.strip()]
def lesson(file,week,level,topic,vi,terms,patterns):
    return {"file":file,"week":week,"schoolLevel":level,"topic":topic,"vietnameseTopic":vi,"terms":terms,"sentencePatterns":patterns}

VERIFIED=[
 lesson('WEEK 1 - PRE 2C- ANIMALS( C41).pdf',1,'Pre-Starters 2','animals','Động vật',words('horse|mouse|sheep|goat|buffalo|rabbit|snake|frog'),['What animal is it?','What colour animal is it?']),
 lesson('WEEK 1 - PRE1B - UNIT 1 - C40.pdf',1,'Pre-Starters 1','shapes','Hình dạng',words('circle|square|triangle|star|heart|diamond|oval|rectangle'),['What shape is it?']),
 lesson('WEEK 11 - PRE 1B - FOOD (C40).pdf',11,'Pre-Starters 1','food','Đồ ăn',words('rice|soup|chicken|milk|onion|water|beef|noodles|carrot'),['What is this?','What do you like?','What don’t you like?']),
 lesson('WEEK 12 - PRE 1B - NATURE (C40) (1).pdf',12,'Pre-Starters 1','nature','Thiên nhiên',words('river|mountain|grass|leaf|tree|flower|rainbow'),['What is it?']),
 lesson('WEEK 13 - PRE 1B - ACTIVITIES (C40) (1).pdf',13,'Pre-Starters 1','activities','Hoạt động',words('playing football|swimming|running|karate|skipping|walking|playing'),['What is it?','What do you like to do?','Do you like …?']),
 lesson('WEEK 14 - PRE 1C - ZOO ANIMALS (C40) (1).pdf',14,'Pre-Starters 1','zoo_animals','Động vật sở thú',words('elephant|hippo|rhino|monkey|panda|tiger|lion|zebra|giraffe'),['What animal is it?','What colour is the animal?']),
 lesson('WEEK 2-PRE 2C (1).pdf',2,'Pre-Starters 2','big_numbers','Số đếm lớn',words('ten|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|one hundred'),['What number is it?']),
 lesson('WEEK 3  - PRE 1B -  ANIMALS (C40) .docx (1).pdf',3,'Pre-Starters 1','animals','Động vật',words('bird|cat|chicken|cow|dog|duck|pig|rabbit'),['What animal is this?','Do you like animals?']),
 lesson('Week 3- Pre 2C- Face and body parts.pdf',3,'Pre-Starters 2','face_body','Khuôn mặt và cơ thể',words('chin|lips|neck|back|beard|mustache|teeth|tooth|elbow'),['What is this?','What are these?']),
 lesson('WEEK 4  - PRE 1B -  NUMBERS (C40) (1).pdf',4,'Pre-Starters 1','numbers','Số đếm',[str(i) for i in range(1,21)],['What number is it?','How many … are there?','How old are you?']),
 lesson('WEEK 4- PRE 2C- CLOTHES(C41).pdf',4,'Pre-Starters 2','clothes','Quần áo',words('jacket|trousers|suit|tie|pocket|underwear|raincoat|scarf|shoes'),['What is it?','What are these?']),
 lesson('WEEK 5 - PRE 1B - FACE (C40) (1).pdf',5,'Pre-Starters 1','face','Khuôn mặt',words('eyes|nose|mouth|ears|teeth|tongue|hair'),['What is it?','What are they?','How many … are there?']),
 lesson('WEEK 6- PRE 2C- FAMILY( C41).docx.pdf',6,'Pre-Starters 2','family','Gia đình',words('mum|dad|brother|sister|grandpa|grandma|mother|mom|father'),['Who is it?']),
 lesson('WEEK 7 - PRE 1A - CLOTHES (C40) (1).pdf',7,'Pre-Starters 1','clothes','Quần áo',words('hat|shirt|shoes|dress|t-shirt|socks|shorts|jeans|skirt'),['What colour clothing is it?']),
 lesson('WEEK 9 - PRE 1B - TOYS (C40).pdf',9,'Pre-Starters 1','toys','Đồ chơi',words('ball|doll|teddy bear|kite|blocks|robot'),['What toy is it?','What are they?']),
 lesson('week-5-electronics.jpg',5,'Pre-Starters 2','electronics','Đồ điện tử',words('phone|computer|camera|clock|TV|tablet|aircon|fan'),['What is it?','How many … are there?']),
]

INFERRED={
 'class_things': words('book|notebook|pencil|pen|ruler|eraser|bag|desk|chair|board|crayon|paper|glue|scissors|marker'),
 'mid_autumn': words('moon|star|lantern|mooncake|rabbit|lion|drum|light|night|sky|cake|dance|red|yellow|round'),
 'places_school': words('school|classroom|library|playground|bathroom|canteen|garden|hall|office|gym|music room|art room|computer room|schoolyard|school gate'),
 'face_extra': words('face|eyes|ears|nose|mouth|hair|teeth|tongue|lips|cheeks|chin|eyebrows|forehead|eyelashes|head'),
 'body_extra': words('body|head|shoulders|arms|hands|fingers|legs|feet|toes|knees|elbows|tummy|back|neck|chest'),
 'feelings': words('happy|sad|angry|scared|tired|sleepy|excited|surprised|shy|hungry|thirsty|bored|worried|calm|okay'),
 'halloween': words('pumpkin|ghost|witch|bat|spider|cat|hat|candy|mask|costume|skeleton|monster|broom|moon|bag'),
 'family_extra': words('mum|dad|brother|sister|grandma|grandpa|baby|uncle|aunt|cousin|mother|father|parents|grandparents|family'),
 'rooms_extra': words('bedroom|bathroom|kitchen|living room|dining room|playroom|study|toilet|hallway|garage|balcony|garden|door|window|stairs'),
}

VI={
 'horse':'ngựa','mouse':'chuột','sheep':'cừu','goat':'dê','buffalo':'trâu','rabbit':'thỏ','snake':'rắn','frog':'ếch','circle':'hình tròn','square':'hình vuông','triangle':'hình tam giác','star':'ngôi sao','heart':'trái tim','diamond':'hình thoi','oval':'hình bầu dục','rectangle':'hình chữ nhật','rice':'cơm','soup':'súp','chicken':'gà','milk':'sữa','onion':'hành tây','water':'nước','beef':'thịt bò','noodles':'mì','carrot':'cà rốt','river':'sông','mountain':'núi','grass':'cỏ','leaf':'lá','tree':'cây','flower':'hoa','rainbow':'cầu vồng','playing football':'chơi bóng đá','swimming':'bơi','running':'chạy','karate':'võ karate','skipping':'nhảy dây','walking':'đi bộ','playing':'chơi','elephant':'voi','hippo':'hà mã','rhino':'tê giác','monkey':'khỉ','panda':'gấu trúc','tiger':'hổ','lion':'sư tử','zebra':'ngựa vằn','giraffe':'hươu cao cổ','bird':'chim','cat':'mèo','cow':'bò','dog':'chó','duck':'vịt','pig':'lợn','chin':'cằm','lips':'môi','neck':'cổ','back':'lưng','beard':'râu','mustache':'ria mép','teeth':'răng','tooth':'răng','elbow':'khuỷu tay','jacket':'áo khoác','trousers':'quần dài','suit':'com-lê','tie':'cà vạt','pocket':'túi áo','underwear':'đồ lót','raincoat':'áo mưa','scarf':'khăn quàng','shoes':'giày','eyes':'mắt','nose':'mũi','mouth':'miệng','ears':'tai','tongue':'lưỡi','hair':'tóc','mum':'mẹ','mother':'mẹ','mom':'mẹ','dad':'bố','father':'bố','brother':'anh/em trai','sister':'chị/em gái','grandpa':'ông','grandma':'bà','hat':'mũ','shirt':'áo sơ mi','dress':'váy','t-shirt':'áo phông','socks':'tất','shorts':'quần soóc','jeans':'quần bò','skirt':'chân váy','ball':'bóng','doll':'búp bê','teddy bear':'gấu bông','kite':'diều','blocks':'khối xếp hình','robot':'rô-bốt','phone':'điện thoại','computer':'máy tính','camera':'máy ảnh','clock':'đồng hồ','tv':'tivi','tablet':'máy tính bảng','aircon':'máy điều hòa','fan':'quạt'
}
NUMBERS={1:'one',2:'two',3:'three',4:'four',5:'five',6:'six',7:'seven',8:'eight',9:'nine',10:'ten',11:'eleven',12:'twelve',13:'thirteen',14:'fourteen',15:'fifteen',16:'sixteen',17:'seventeen',18:'eighteen',19:'nineteen',20:'twenty',30:'thirty',40:'forty',50:'fifty',60:'sixty',70:'seventy',80:'eighty',90:'ninety',100:'one hundred'}
for n,name in NUMBERS.items(): VI[str(n)]=f'số {n}'; VI[name]=f'số {n}'

ALIASES={'mum':'mother','mom':'mother','dad':'father','grandma':'grandmother','grandpa':'grandfather','tv':'television','eye':'eyes','ear':'ears','lip':'lips','t-shirt':'tshirt'}
HARD={'eyelashes','worried','underwear','beard','mustache','forehead','chest','hall','office','gym','computer room','schoolyard','school gate','grandparents','parents'}
MEDIUM={'eyebrows','cheeks','chin','elbows','knees','toes','tummy','neck','back','calm','bored','shy','surprised','hallway','balcony','canteen'}

def slug(text): return re.sub(r'[^a-z0-9]+','_',text.lower()).strip('_')
def canonical(term):
    low=term.lower(); return ALIASES.get(low,low)

def main():
    existing=json.loads((DATA/'topics.json').read_text(encoding='utf-8'))['topics']
    by_word=defaultdict(list)
    for topic in existing:
        for item in topic['items']: by_word[item['word'].lower()].append((topic['id'],item))
    catalog={}; lessons=[]
    def add(term,topic,source):
        canon=canonical(term); vid=slug(canon); aliases=sorted({term.lower(),canon})
        entry=catalog.setdefault(vid,{"id":vid,"english":canon,"vietnamese":VI.get(term.lower(),VI.get(canon,canon)),"aliases":[],"topicIds":[],"sourceTypes":[],"difficulty":"hard" if canon in HARD else "medium" if canon in MEDIUM else "easy","imagePath":None,"audioPath":f"assets/audio/words/{vid}.wav","provenance":[]})
        entry['aliases']=sorted(set(entry['aliases']+aliases)); entry['topicIds']=sorted(set(entry['topicIds']+[topic])); entry['sourceTypes']=sorted(set(entry['sourceTypes']+[source['sourceType']])); entry['provenance'].append(source)
        candidates=by_word.get(term.lower()) or by_word.get(canon)
        override=IMAGE_OVERRIDES.get(canon)
        if override and (ROOT/override).exists():
            entry['imagePath']=override
        elif candidates and not entry['imagePath']:
            entry['imagePath']=candidates[0][1]['imagePath']
        return vid
    for source in VERIFIED:
        ids=[]
        for term in source['terms']:
            lookup=term
            if term in NUMBERS.values(): lookup=str(next(n for n,v in NUMBERS.items() if v==term))
            provenance={"sourceType":"school_verified","file":source['file'],"page":1,"week":source['week'],"schoolLevel":source['schoolLevel'],"topic":source['topic'],"sentencePatterns":source['sentencePatterns']}
            ids.append(add(lookup,source['topic'],provenance))
        lessons.append({"id":f"school_{slug(source['schoolLevel'])}_week_{source['week']}_{source['topic']}","title":source['topic'].replace('_',' ').title(),"vietnameseTitle":source['vietnameseTopic'],"worldId":"school_review","sourceType":"school_verified","week":source['week'],"schoolLevel":source['schoolLevel'],"vocabularyIds":list(dict.fromkeys(ids)),"sentencePatterns":source['sentencePatterns'],"gameTypes":["explore","hiddenObjects","matchingPairs","dragDrop"]})
    for topic,terms in INFERRED.items():
        ids=[]
        for term in terms:
            provenance={"sourceType":"extra_class_inferred","file":"video-topics.PNG","page":1,"week":None,"schoolLevel":"Extra class","topic":topic,"sentencePatterns":[]}
            ids.append(add(term,topic,provenance))
        lessons.append({"id":f"extra_{topic}","title":topic.replace('_',' ').title(),"vietnameseTitle":topic.replace('_',' ').title(),"worldId":"extra_class","sourceType":"extra_class_inferred","week":None,"schoolLevel":"Extra class","candidateTerms":terms,"vocabularyIds":list(dict.fromkeys(ids)),"sentencePatterns":[],"gameTypes":["explore","hiddenObjects","matchingPairs"]})
    items=sorted(catalog.values(),key=lambda x:x['id'])
    (DATA/'vocabulary_catalog.json').write_text(json.dumps({"schemaVersion":1,"items":items},ensure_ascii=False,indent=2),encoding='utf-8')
    (DATA/'lesson_catalog.json').write_text(json.dumps({"schemaVersion":1,"lessons":lessons},ensure_ascii=False,indent=2),encoding='utf-8')
    verified_ids={i['id'] for i in items if 'school_verified' in i['sourceTypes']}; inferred_ids={i['id'] for i in items if 'extra_class_inferred' in i['sourceTypes']}; overlap=verified_ids & inferred_ids
    files='\n'.join(f"- `{l['file']}` — {l['schoolLevel']}, tuần {l['week']}, {len(l['terms'])} mục, trang từ vựng: 1." for l in VERIFIED)
    inferred='\n'.join(f"- `{k}`: {len(v)} ứng viên — {', '.join(v)}." for k,v in INFERRED.items())
    hard=', '.join(sorted(i['english'] for i in items if i['difficulty']=='hard'))
    report=f'''# Vocabulary source mapping\n\n## School sources reviewed\n\nAll pages of the 15 PDFs were extracted and reviewed. Week 5 Electronics was reviewed visually.\n\n{files}\n\n## Extra-class title inference\n\n`Rules homework vid` is excluded because it is an instruction video. The other nine titles produce explicitly inferred candidates only:\n\n{inferred}\n\n## Normalization summary\n\n- Unique normalized vocabulary IDs: **{len(items)}**.\n- IDs with at least one `school_verified` record: **{len(verified_ids)}**.\n- IDs with at least one `extra_class_inferred` record: **{len(inferred_ids)}**.\n- IDs occurring in both source groups: **{len(overlap)}** (`{', '.join(sorted(overlap))}`).\n- Synonym links: mum/mom → mother; dad → father; grandma/grandpa → grandmother/grandfather; TV → television. Original terms remain in aliases and provenance.\n- Hard/deferred terms: {hard}. They remain in the catalog but are not forced into opening lessons.\n- No PDF was unreadable; all vocabulary lists were available as embedded text. Parent-only explanations (phonetics, countability details, web links and general advice) were not promoted to required child vocabulary.\n\n## Runtime completeness rule\n\nOnly catalog entries with a verified `imagePath` and generated `audioPath` may be selected by the lesson repository. Source records may remain non-playable until a clear asset is prepared.\n'''
    (ROOT/'docs'/'VOCABULARY_SOURCE_MAPPING.md').write_text(report,encoding='utf-8')
    print(json.dumps({"unique":len(items),"verified":len(verified_ids),"inferred":len(inferred_ids),"overlap":len(overlap),"lessons":len(lessons),"playableImages":sum(bool(i['imagePath']) for i in items)},indent=2))

if __name__=='__main__': main()
