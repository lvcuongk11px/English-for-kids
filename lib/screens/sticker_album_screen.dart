import 'package:material_ui/material_ui.dart';

import '../models/catalog_models.dart';
import '../services/audio_service.dart';
import '../widgets/cloud_background.dart';
import '../widgets/pinky_mascot.dart';

class StickerAlbumScreen extends StatefulWidget {
  const StickerAlbumScreen({
    super.key,
    required this.stickerIds,
    required this.vocabulary,
  });
  final Set<String> stickerIds;
  final Map<String, VocabularyEntry> vocabulary;
  @override
  State<StickerAlbumScreen> createState() => _StickerAlbumScreenState();
}

class _StickerAlbumScreenState extends State<StickerAlbumScreen> {
  final AppAudioService _audio = AudioService();
  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stickers = widget.stickerIds
        .map((id) => widget.vocabulary[id])
        .whereType<VocabularyEntry>()
        .where((item) => item.isPlayable)
        .toList();
    return Scaffold(
      body: CloudBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'My Sticker Album',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const PinkyMascot(mood: PinkyMood.happy, size: 68),
                ],
              ),
            ),
            if (stickers.isEmpty)
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Finish an adventure to earn your first sticker!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: stickers.length,
                  itemBuilder: (context, index) {
                    final item = stickers[index];
                    return Material(
                      color: const Color(0xFFFFF4BF),
                      borderRadius: BorderRadius.circular(28),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: ValueKey('sticker-${item.id}'),
                        onTap: () => _audio.playAsset(item.audioPath),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Expanded(child: Image.asset(item.imagePath!)),
                              Text(
                                item.english,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Icon(
                                Icons.volume_up_rounded,
                                size: 20,
                                color: Color(0xFF6657D9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
