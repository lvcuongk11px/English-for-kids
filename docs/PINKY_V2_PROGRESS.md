# Pinky Adventure V2 — Tiến độ

## Trạng thái hiện tại

Phase 7 — QA & APK: hoàn thành ngày 17/11/2026.

## Kết quả theo phase

- Phase 1: kiểm tra V1, source, assets, Android identity/signing và môi trường; ghi tại `PINKY_V2_AUDIT.md`.
- Phase 2: đọc đủ 15 PDF và hai ảnh tham chiếu; tạo catalog có provenance và `VOCABULARY_SOURCE_MAPPING.md`.
- Phase 3: tạo Pinky, Home mới, lesson engine, audio coordinator và ba mức ngôn ngữ.
- Phase 4: triển khai Explore Scene, Drag & Drop, Hidden Objects, Coloring, Matching Pairs và Counting.
- Phase 5: phát hành 16 lesson đủ tài nguyên; Electronics có đủ chính xác 8/8 từ.
- Phase 6: lưu tiến độ từng từ, ưu tiên từ cần ôn, sticker album và cài đặt phụ huynh.
- Phase 7: validator đạt, analyze sạch, 15 test đạt, APK arm64 build và xác minh thành công.

## Số liệu

- 25 lesson trong catalog; 16 lesson đủ điều kiện phát hành.
- 240 vocabulary ID duy nhất; 134 ID có nguồn `school_verified`; 128 ID có nguồn `extra_class_inferred`; 22 ID giao nhau.
- 114 hình và 114 audio từ dùng trong lesson phát hành.
- 15/15 PDF đã đọc; Week 5 Electronics và danh sách video đã xử lý.

## Kiểm thử đã chạy

- `python scripts/validate_assets.py`: PASS.
- `flutter analyze`: PASS, 0 issue.
- `flutter test`: PASS, 15/15 test.
- Widget test ở 390×844 và 320×568.
- `flutter build apk --release --split-per-abi --target-platform android-arm64`: PASS.
- `aapt`: đúng package, version, label và chỉ có native code arm64-v8a.
- `apksigner`: chữ ký v2 hợp lệ, chứng thư trùng V1.
- Không có thiết bị/emulator kết nối, vì vậy chưa tuyên bố đã smoke-test trên Android thật.

## Blocker và phần hoãn

- Không có blocker đối với APK arm64.
- 9 lesson catalog chưa đủ tối thiểu 4 hình rõ nghĩa nên được ẩn khỏi trẻ thay vì phát hành thiếu tài nguyên.
- Thuật toán ôn tập là heuristic local đơn giản, chưa phải spaced repetition theo lịch dài hạn.

## Bàn giao

- APK: `dist/EnglishForKids-PinkyAdventure-V2-arm64.apk`
- Hướng dẫn: `PARENT_GUIDE_VI.md`
- Báo cáo: `PINKY_ADVENTURE_RELEASE_REPORT.md`
