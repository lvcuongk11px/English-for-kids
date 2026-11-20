#!/usr/bin/env python3
"""Create the complete V2 curriculum while preserving verified V1 assets."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from prepare_images import IMAGE_DIR, DATA_DIR, make_color, make_emoji, make_icon, make_shape, rounded_canvas, valid_png

ROOT = Path(__file__).resolve().parents[1]
NOTO_BASE = "https://raw.githubusercontent.com/googlefonts/noto-emoji/main/2D/png/512"

def t(topic_id, english, vietnamese, accent, kind, items):
    return {"id": topic_id, "english": english, "vietnamese": vietnamese, "accent": accent, "kind": kind, "items": items}

# item: id, English, Vietnamese, renderer value, optional plural flag
TOPICS = [
 t("animals","Animals","Động vật","FFF06B5B","emoji",[
  ("cat","cat","mèo","1f408"),("dog","dog","chó","1f415"),("pig","pig","lợn","1f416"),("cow","cow","bò","1f404"),("duck","duck","vịt","1f986"),("chicken","chicken","gà","1f414"),("sheep","sheep","cừu","1f411"),("horse","horse","ngựa","1f40e"),("fish","fish","cá","1f41f"),("bird","bird","chim","1f426"),("rabbit","rabbit","thỏ","1f407"),("elephant","elephant","voi","1f418"),("lion","lion","sư tử","1f981"),("tiger","tiger","hổ","1f405"),("monkey","monkey","khỉ","1f412"),("bear","bear","gấu","1f43b"),("panda","panda","gấu trúc","1f43c"),("frog","frog","ếch","1f438"),("turtle","turtle","rùa","1f422"),("butterfly","butterfly","bướm","1f98b"),("bee","bee","ong","1f41d"),("ladybug","ladybug","bọ rùa","1f41e"),("snail","snail","ốc sên","1f40c"),("whale","whale","cá voi","1f40b"),("dolphin","dolphin","cá heo","1f42c")]),
 t("colors","Colors","Màu sắc","FFFF9F43","color",[
  ("red","red","đỏ","E84141"),("blue","blue","xanh dương","3987E8"),("yellow","yellow","vàng","F7D838"),("green","green","xanh lá","43B96B"),("orange","orange","cam","F28C35"),("purple","purple","tím","8E5AD7"),("pink","pink","hồng","F17FA5"),("black","black","đen","2D3340"),("white","white","trắng","F8F8F5"),("brown","brown","nâu","925C36"),("gray","gray","xám","8A929C"),("gold","gold","vàng kim","D5A719")]),
 t("shapes","Shapes","Hình dạng","FF5CBAA8","shape",[
  ("circle","circle","hình tròn","circle"),("square","square","hình vuông","square"),("triangle","triangle","hình tam giác","triangle"),("rectangle","rectangle","hình chữ nhật","rectangle"),("star","star","ngôi sao","star"),("heart","heart","trái tim","heart"),("oval","oval","hình bầu dục","oval"),("diamond","diamond","hình thoi","diamond"),("pentagon","pentagon","hình ngũ giác","pentagon"),("hexagon","hexagon","hình lục giác","hexagon"),("semicircle","semicircle","nửa hình tròn","semicircle"),("cross","cross","hình chữ thập","cross")]),
 t("body_parts","Body Parts","Bộ phận cơ thể","FF9B6DDE","emoji",[
  ("head","head","đầu","1f9d1"),("hair","hair","tóc","1f9b1"),("face","face","mặt","1f600"),("eyes","eyes","mắt","1f440",True),("ears","ears","tai","1f442",True),("nose","nose","mũi","1f443"),("mouth","mouth","miệng","1f444"),("tongue","tongue","lưỡi","1f445"),("tooth","tooth","răng","1f9b7"),("hand","hand","bàn tay","270b"),("finger","finger","ngón tay","1f446"),("foot","foot","bàn chân","1f9b6"),("arm","arm","cánh tay","1f4aa"),("leg","leg","chân","1f9b5"),("heart","heart","tim","2764"),("brain","brain","não","1f9e0"),("bone","bone","xương","1f9b4"),("nails","nails","móng tay","1f485",True)]),
 t("vehicles","Vehicles","Phương tiện","FF438DDA","emoji",[
  ("car","car","ô tô","1f697"),("bus","bus","xe buýt","1f68c"),("bicycle","bicycle","xe đạp","1f6b2"),("train","train","tàu hỏa","1f686"),("airplane","airplane","máy bay","2708"),("boat","boat","thuyền","26f5"),("truck","truck","xe tải","1f69a"),("motorcycle","motorcycle","xe máy","1f3cd"),("helicopter","helicopter","trực thăng","1f681"),("scooter","scooter","xe trượt","1f6f4"),("taxi","taxi","taxi","1f695"),("ambulance","ambulance","xe cứu thương","1f691"),("fire_engine","fire engine","xe cứu hỏa","1f692"),("police_car","police car","xe cảnh sát","1f693"),("tractor","tractor","máy kéo","1f69c"),("rocket","rocket","tên lửa","1f680"),("ship","ship","tàu thủy","1f6a2"),("tram","tram","tàu điện","1f68a"),("van","van","xe van","1f690"),("canoe","canoe","xuồng","1f6f6")]),
 t("household","Household Items","Đồ dùng trong nhà","FFE66A9D","emoji",[
  ("clock","clock","đồng hồ","23f0"),("lamp","lamp","đèn","1fa94"),("phone","phone","điện thoại","1f4f1"),("television","television","tivi","1f4fa"),("key","key","chìa khóa","1f511"),("cup","cup","cốc","2615"),("plate","plate","đĩa","1f37d"),("spoon","spoon","thìa","1f944"),("toothbrush","toothbrush","bàn chải","1faa5"),("soap","soap","xà phòng","1f9fc"),("broom","broom","chổi","1f9f9"),("bucket","bucket","xô","1faa3"),("basket","basket","giỏ","1f9fa"),("sponge","sponge","miếng bọt biển","1f9fd"),("toilet_paper","toilet paper","giấy vệ sinh","1f9fb"),("trash_can","trash can","thùng rác","1f5d1"),("toilet","toilet","bồn cầu","1f6bd"),("bathtub","bathtub","bồn tắm","1f6c1"),("shower","shower","vòi sen","1f6bf"),("door","door","cửa","1f6aa"),("lock","lock","ổ khóa","1f512"),("fan","fan","quạt","1faad")]),
 t("rooms","Rooms","Các phòng trong nhà","FF5DB9D1","emoji",[
  ("kitchen","kitchen","bếp","1f373"),("bedroom","bedroom","phòng ngủ","1f6cf"),("bathroom","bathroom","phòng tắm","1f6c1"),("living_room","living room","phòng khách","1f6cb"),("dining_room","dining room","phòng ăn","1f37d"),("study","study","phòng học","1f4da"),("laundry_room","laundry room","phòng giặt","1f9fa"),("garage","garage","ga-ra","1f3e0")]),
 t("fruits","Fruits","Trái cây","FFFF6B81","emoji",[
  ("apple","apple","táo","1f34e"),("banana","banana","chuối","1f34c"),("orange","orange","cam","1f34a"),("mango","mango","xoài","1f96d"),("grapes","grapes","nho","1f347",True),("watermelon","watermelon","dưa hấu","1f349"),("strawberry","strawberry","dâu tây","1f353"),("pineapple","pineapple","dứa","1f34d"),("pear","pear","lê","1f350"),("peach","peach","đào","1f351"),("cherries","cherries","anh đào","1f352",True),("lemon","lemon","chanh","1f34b"),("coconut","coconut","dừa","1f965"),("kiwi","kiwi","kiwi","1f95d"),("melon","melon","dưa","1f348"),("blueberries","blueberries","việt quất","1fad0",True),("avocado","avocado","bơ","1f951"),("tomato","tomato","cà chua","1f345")]),
 t("vegetables","Vegetables","Rau củ","FF73C66A","emoji",[
  ("carrot","carrot","cà rốt","1f955"),("corn","corn","ngô","1f33d"),("broccoli","broccoli","bông cải xanh","1f966"),("cucumber","cucumber","dưa chuột","1f952"),("pepper","pepper","ớt chuông","1fad1"),("mushroom","mushroom","nấm","1f344"),("potato","potato","khoai tây","1f954"),("onion","onion","hành tây","1f9c5"),("garlic","garlic","tỏi","1f9c4"),("lettuce","lettuce","rau xanh","1f96c"),("eggplant","eggplant","cà tím","1f346"),("beans","beans","đậu","1fad8",True)]),
 t("furniture","Furniture","Đồ nội thất","FFB47B57","emoji",[
  ("chair","chair","ghế","1fa91"),("bed","bed","giường","1f6cf"),("sofa","sofa","ghế sofa","1f6cb"),("door","door","cửa","1f6aa"),("mirror","mirror","gương","1fa9e"),("window","window","cửa sổ","1fa9f"),("bookshelf","bookshelf","giá sách","1f4da"),("table","table","bàn","1f37d"),("cabinet","cabinet","tủ","1f5c4"),("desk","desk","bàn học","1f4bb"),("picture","picture","tranh","1f5bc"),("plant","plant","cây cảnh","1fab4")]),
 t("clothes","Clothes","Quần áo","FFE680B3","emoji",[
  ("shirt","shirt","áo sơ mi","1f455"),("pants","pants","quần dài","1f456"),("dress","dress","váy","1f457"),("coat","coat","áo khoác","1f9e5"),("socks","socks","tất","1f9e6",True),("shoes","shoes","giày","1f45f",True),("boot","boot","ủng","1f462"),("hat","hat","mũ","1f3a9"),("cap","cap","mũ lưỡi trai","1f9e2"),("scarf","scarf","khăn quàng","1f9e3"),("gloves","gloves","găng tay","1f9e4",True),("shorts","shorts","quần soóc","1fa73",True),("sandal","sandal","dép","1fa74"),("handbag","handbag","túi xách","1f45c"),("backpack","backpack","ba lô","1f392"),("glasses","glasses","kính","1f453",True),("crown","crown","vương miện","1f451"),("umbrella","umbrella","ô","1f302")]),
 t("school","School Things","Đồ dùng học tập","FF6F9DE8","emoji",[
  ("book","book","sách","1f4d5"),("notebook","notebook","vở","1f4d3"),("pencil","pencil","bút chì","270f"),("pen","pen","bút mực","1f58a"),("crayon","crayon","bút màu","1f58d"),("ruler","ruler","thước","1f4cf"),("scissors","scissors","kéo","2702",True),("backpack","backpack","ba lô","1f392"),("globe","globe","quả địa cầu","1f30e"),("abacus","abacus","bàn tính","1f9ee"),("paint","paint","màu vẽ","1f3a8"),("school","school","trường học","1f3eb")]),
 t("toys","Toys","Đồ chơi","FFFFB74D","emoji",[
  ("ball","ball","quả bóng","26bd"),("doll","doll","búp bê","1fa86"),("teddy_bear","teddy bear","gấu bông","1f9f8"),("blocks","blocks","khối xếp hình","1f9f1",True),("puzzle","puzzle","xếp hình","1f9e9"),("kite","kite","diều","1fa81"),("yo_yo","yo-yo","con quay yo-yo","1fa80"),("video_game","video game","trò chơi điện tử","1f3ae"),("drum","drum","trống","1f941"),("toy_train","toy train","tàu đồ chơi","1f682"),("toy_car","toy car","ô tô đồ chơi","1f697"),("balloon","balloon","bóng bay","1f388")]),
 t("numbers","Numbers","Số đếm","FF7E6BD7","number",[(str(i),str(i),str(i),str(i)) for i in range(1,21)]),
 t("family","Family","Gia đình","FFF18D6D","emoji",[
  ("baby","baby","em bé","1f476"),("girl","girl","bé gái","1f467"),("boy","boy","bé trai","1f466"),("mother","mother","mẹ","1f469"),("father","father","bố","1f468"),("grandmother","grandmother","bà","1f475"),("grandfather","grandfather","ông","1f474"),("sister","sister","chị em gái","1f9d2"),("brother","brother","anh em trai","1f9d1"),("family","family","gia đình","1f46a")]),
 t("food","Food","Đồ ăn","FFFF8A65","emoji",[
  ("bread","bread","bánh mì","1f35e"),("rice","rice","cơm","1f35a"),("egg","egg","trứng","1f95a"),("cheese","cheese","phô mai","1f9c0"),("pizza","pizza","pizza","1f355"),("sandwich","sandwich","bánh kẹp","1f96a"),("noodles","noodles","mì","1f35c",True),("soup","soup","súp","1f372"),("chicken","chicken","thịt gà","1f357"),("fish","fish","cá","1f363"),("hamburger","hamburger","bánh hamburger","1f354"),("fries","fries","khoai tây chiên","1f35f",True),("cake","cake","bánh kem","1f370"),("cookie","cookie","bánh quy","1f36a"),("ice_cream","ice cream","kem","1f366")]),
 t("drinks","Drinks","Đồ uống","FF55B8C5","emoji",[
  ("water","water","nước","1f4a7"),("milk","milk","sữa","1f95b"),("juice","juice","nước ép","1f9c3"),("tea","tea","trà","1f375"),("cocoa","cocoa","ca cao","2615"),("lemonade","lemonade","nước chanh","1f379"),("smoothie","smoothie","sinh tố","1f964"),("coconut_water","coconut water","nước dừa","1f965")]),
 t("weather","Weather","Thời tiết","FF64B5F6","emoji",[
  ("sunny","sunny","nắng","2600"),("cloudy","cloudy","nhiều mây","2601"),("rainy","rainy","mưa","1f327"),("stormy","stormy","bão","26c8"),("snowy","snowy","tuyết","1f328"),("windy","windy","gió","1f32c"),("hot","hot","nóng","1f975"),("cold","cold","lạnh","1f976")]),
 t("jobs","Jobs","Nghề nghiệp","FF9575CD","emoji",[
  ("doctor","doctor","bác sĩ","1fa7a"),("nurse","nurse","y tá","1f3e5"),("teacher","teacher","giáo viên","1f3eb"),("police_officer","police officer","cảnh sát","1f46e"),("firefighter","firefighter","lính cứu hỏa","1f692"),("cook","cook","đầu bếp","1f373"),("farmer","farmer","nông dân","1f69c"),("builder","builder","thợ xây","1f477"),("driver","driver","tài xế","1f695"),("pilot","pilot","phi công","2708"),("singer","singer","ca sĩ","1f3a4"),("artist","artist","họa sĩ","1f3a8")]),
 t("actions","Actions","Hành động","FF4DB6AC","emoji",[
  ("run","run","chạy","1f3c3"),("walk","walk","đi bộ","1f6b6"),("jump","jump","nhảy","1f938"),("sit","sit","ngồi","1fa91"),("sleep","sleep","ngủ","1f634"),("eat","eat","ăn","1f37d"),("drink","drink","uống","1f964"),("clap","clap","vỗ tay","1f44f"),("dance","dance","nhảy múa","1f483"),("swim","swim","bơi","1f3ca"),("read","read","đọc","1f4d6"),("write","write","viết","270d"),("play","play","chơi","26bd"),("sing","sing","hát","1f3a4"),("wash","wash","rửa","1f9fc")]),
]

def make_number(path: Path, value: str, index: int) -> None:
    if valid_png(path): return
    image, draw = rounded_canvas(index)
    font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 180 if len(value) == 1 else 145)
    box = draw.textbbox((0, 0), value, font=font)
    x = (384 - (box[2] - box[0])) / 2; y = (384 - (box[3] - box[1])) / 2 - box[1]
    colors = ["#EF5D60","#3A8DE2","#E6B72F","#4DBB78","#9B62DB"]
    draw.text((x, y), value, font=font, fill=colors[index % len(colors)], stroke_width=4, stroke_fill="white")
    image.save(path, "PNG", optimize=True)

def prompts(word: str, topic_id: str, plural: bool) -> dict:
    display = word[0].upper() + word[1:]
    level2 = f"Find {word}!" if topic_id in {"colors","shapes","numbers","weather","actions"} else f"Find the {word}!"
    if topic_id == "colors": level3 = f"Which one is {word}?"
    elif topic_id == "jobs": level3 = f"Who is the {word}?"
    elif plural: level3 = f"Where are the {word}?"
    else: level3 = f"Where is the {word}?"
    return {"level1": {"text": f"{display}!"}, "level2": {"text": level2}, "level3": {"text": level3}}

def main() -> None:
    IMAGE_DIR.mkdir(parents=True, exist_ok=True); DATA_DIR.mkdir(parents=True, exist_ok=True)
    output_topics=[]; credits=[]; counter=0
    for topic in TOPICS:
        output_items=[]
        for raw in topic["items"]:
            item_id, word, vi, value, *extra = raw; plural = bool(extra[0]) if extra else False
            path=IMAGE_DIR / f"{topic['id']}_{item_id}.png"
            if topic["kind"] == "emoji":
                make_emoji(path,value,counter)
                credits.append({"file":path.name,"source":f"{NOTO_BASE}/emoji_u{value}.png","sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
            elif topic["kind"] == "color": make_color(path,value,counter)
            elif topic["kind"] == "shape": make_shape(path,value,counter)
            else: make_number(path,value,counter)
            item_prompts=prompts(word,topic["id"],plural)
            for level in item_prompts:
                item_prompts[level]["audioPath"] = f"assets/audio/prompts/{level}/{topic['id']}_{item_id}.wav"
            output_items.append({"id":f"{topic['id']}_{item_id}","word":word,"vietnamese":vi,"imagePath":f"assets/images/{path.name}","wordAudioPath":f"assets/audio/words/{topic['id']}_{item_id}.wav","prompts":item_prompts,"plural":plural,"tags":[topic["id"]],"minimumLevel":1})
            counter += 1
        output_topics.append({"id":topic["id"],"englishName":topic["english"],"vietnameseName":topic["vietnamese"],"coverImagePath":output_items[0]["imagePath"],"accentColor":topic["accent"],"items":output_items})
    (DATA_DIR/"topics.json").write_text(json.dumps({"schemaVersion":2,"topics":output_topics},ensure_ascii=False,indent=2),encoding="utf-8")
    (DATA_DIR/"image_manifest.json").write_text(json.dumps({"notoEmoji":credits},indent=2),encoding="utf-8")
    make_icon(); print(f"Prepared V2: {len(output_topics)} topics and {counter} vocabulary items.")

if __name__ == "__main__": main()
