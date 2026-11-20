# English for Kids: Pinky Adventure

Ứng dụng Flutter học tiếng Anh offline cho bé 3 tuổi với mascot Pinky, sáu mini-game, học liệu có provenance, audio en-GB, sticker và tiến độ local.

## Kiểm tra project

```powershell
python scripts/validate_assets.py
flutter analyze
flutter test
```

## APK Android arm64

File phát hành: `dist/EnglishForKids-PinkyAdventure-V2-arm64.apk`

```powershell
adb install -r dist/EnglishForKids-PinkyAdventure-V2-arm64.apk
```

Nếu máy tính chưa có `adb`, chép APK sang điện thoại, mở file và cho phép trình quản lý tệp cài ứng dụng không rõ nguồn gốc.

Xem `PINKY_ADVENTURE_RELEASE_REPORT.md`, `PARENT_GUIDE_VI.md`, `docs/VOCABULARY_SOURCE_MAPPING.md` và `ASSET_CREDITS.md`.
