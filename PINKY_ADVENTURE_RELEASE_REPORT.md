# Pinky Adventure V2 — Báo cáo phát hành

## 1. Tổng quan

V2 nâng cấp trực tiếp project Flutter V1 thành trải nghiệm học offline “English for Kids: Pinky Adventure”. Bài học nay là chuỗi 7 hoạt động có Pinky đồng hành, gameplay đa dạng, phần thưởng và tiến độ local thay cho việc chỉ lặp quiz 4 hình.

## 2. Thành phần V1 được giữ lại

Giữ nguyên `applicationId` `com.englishforkids.english_for_kids`, cấu hình ký hiện có, các asset V1 hợp lệ, quiz engine/màn hình cũ để không phá hồi quy, nền mây và luồng Flutter/Android đang hoạt động.

## 3. Mini-game đã triển khai

1. Explore Scene với hotspot độc lập.
2. Drag & Drop bằng `Draggable`/`DragTarget`, kèm cách chạm thay thế.
3. Hidden Objects trong khung cảnh.
4. Coloring thực sự đổi màu hình.
5. Matching Pairs lật và ghép cặp.
6. Counting chạm đếm rồi chọn số.

## 4. World và lesson phát hành

Hai khu hành trình là **School Adventure** và **Extra-Class Worlds**. Có 16 lesson đủ hình và audio:

- School: Animals (2 lesson), Shapes, Food, Zoo Animals, Numbers, Face, Family, Clothes, Toys, Electronics.
- Extra class: Class Things, Mid Autumn, Face Extra, Family Extra, Rooms Extra.

Mỗi lesson sinh tối đa 7 hoạt động từ registry, tránh lặp cùng kiểu game liên tiếp. Lesson thiếu tài nguyên không xuất hiện trong app.

## 5–9. Số liệu học liệu

- Catalog: 25 lesson; 16 lesson phát hành.
- Vocabulary ID duy nhất: **240**.
- Có nguồn `school_verified`: **134**.
- Có nguồn `extra_class_inferred`: **128**.
- Giao hai nguồn: **22**; mỗi từ giữ nhiều provenance record.
- Asset dùng trong lesson: **114 hình + 114 audio từ**.
- Electronics: đủ 8/8 từ `phone`, `computer`, `camera`, `clock`, `television` (alias TV), `tablet`, `aircon`, `fan`.

## 10. Giọng đọc

Audio được tạo sẵn offline bằng Piper `en_GB-alba-medium`, tốc độ tạo khoảng 0,82×, không đóng model TTS vào APK. Cài đặt phụ huynh cho phép điều chỉnh 0,72–0,95× bằng playback rate. Audio coordinator dừng clip cũ, chờ hiệu ứng và từ đọc xong rồi mới tính khoảng phản hồi 2,7 giây.

## 11. Pinky

Pinky là CustomPainter vector nguyên bản, nhất quán ở Home, lesson và Result. Có bảy mood: Idle, Hello, Listening, Happy, Encourage, Celebrate và Sleep/Rest.

## 12. Kiểm tra học liệu

`python scripts/validate_assets.py`: **PASS** — đủ 15 PDF, 240 từ chuẩn hóa, 134 verified, 128 inferred, 16 lesson chơi được, 114 hình và 114 audio. Đã kiểm tra đủ Week 5 và ảnh video titles; 9 topic suy luận đều có ít nhất 15 ứng viên. Không có PDF, ảnh chụp nguồn hay model ONNX trong APK.

## 13. Flutter analyze

`flutter analyze`: **PASS — No issues found**.

## 14. Flutter test

`flutter test`: **PASS — 15/15 test**. Phạm vi gồm provenance, registry/engine, ưu tiên từ cần ôn, sáu game, thời gian/audio không chồng, lưu progress/sticker, luồng Home/lesson, hồi quy quiz V1 và bố cục 390×844 + 320×568.

## 15. Build và xác minh

- Lệnh: `flutter build apk --release --split-per-abi --target-platform android-arm64`.
- Kết quả: **PASS**.
- Package: `com.englishforkids.english_for_kids`.
- Version: `2.0.0`, versionCode Android `2002`.
- ABI: chỉ `arm64-v8a`.
- APK Signature Scheme v2: hợp lệ.
- SHA-256 APK: `51CAC02B608C567EA7D47506FD8BE47C10C1E5F436E7772E4F7FA2CC8CFD3740`.
- Chứng thư ký SHA-256 trùng V1: `93ecf89a89cded073a93886446a5db08b4d5507185ebc7f17c48b7a9d8ed0498`.
- Quyền duy nhất được aapt liệt kê là quyền receiver nội bộ do Android/Flutter tạo; không xin Internet, camera, microphone hoặc vị trí.

## 16–17. APK

- File: `dist/EnglishForKids-PinkyAdventure-V2-arm64.apk`.
- Kích thước thực: **37.495.954 byte** (khoảng **35,8 MiB**).

## 18. Cài lên Android

Cách dễ nhất: chép APK vào điện thoại arm64, mở ứng dụng Files, chạm APK, cho phép “Cài ứng dụng không rõ nguồn gốc” đối với Files nếu Android hỏi, rồi chọn **Cài đặt**. Vì package và chứng thư trùng V1 nên có thể cài đè bản V1 bằng file này.

Nếu dùng máy tính và đã có Android Platform Tools:

```powershell
adb install -r D:\Dau_app\dist\EnglishForKids-PinkyAdventure-V2-arm64.apk
```

## 19. Hướng dẫn phụ huynh

Xem `PARENT_GUIDE_VI.md`. Khuyến nghị học 3–5 phút/lần, dùng Level 1 trước, cùng bé nghe lại và nhắc từ, sau đó bật Review Mode.

## 20. Hạng mục chưa hoàn thành và giới hạn

- Không có điện thoại/emulator kết nối (`adb devices` trống), nên chưa chạy smoke test trên Android thật; các kết quả Android ở trên là build, kiểm tra APK và widget test.
- 9/25 lesson catalog chưa đủ 4 hình rõ nghĩa và audio tương ứng nên được ẩn an toàn; dữ liệu/provenance vẫn được giữ để mở rộng sau.
- Review Mode dùng heuristic local (ưu tiên từ có số sai cao hoặc chưa đúng đủ hai lần), chưa có lịch spaced-repetition dài hạn.
- Level 3 hiển thị đúng mẫu câu của nguồn trường; audio trong lượt chơi vẫn ưu tiên đọc từ đích ngắn, rõ cho bé 3 tuổi thay vì phát trọn mọi mẫu câu.
- APK release hiện dùng lại chứng thư debug Android của V1 theo cấu hình project để cài đè cá nhân; không phải khóa upload dành cho Google Play.
