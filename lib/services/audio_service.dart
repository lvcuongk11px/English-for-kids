import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

abstract class AppAudioService {
  Future<void> playAsset(String path);
  Future<void> playAssetAndWait(String path) => playAsset(path);
  Future<void> stop();
  Future<void> dispose();
}

class AudioService implements AppAudioService {
  AudioService({this.playbackRate = 1.0});

  final double playbackRate;
  final AudioPlayer _player = AudioPlayer();
  Completer<void>? _cancelPlayback;

  @override
  Future<void> playAsset(String path) => _play(path, waitUntilComplete: false);

  @override
  Future<void> playAssetAndWait(String path) =>
      _play(path, waitUntilComplete: true);

  Future<void> _play(String path, {required bool waitUntilComplete}) async {
    try {
      _cancelPlayback?.complete();
      final cancellation = Completer<void>();
      _cancelPlayback = cancellation;
      final completed = _player.onPlayerComplete.first;
      await _player.stop();
      await _player.setPlaybackRate(playbackRate);
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
      if (waitUntilComplete) {
        await Future.any<void>([
          completed,
          cancellation.future,
          Future<void>.delayed(const Duration(seconds: 20)),
        ]);
      }
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      _cancelPlayback?.complete();
      _cancelPlayback = null;
      await _player.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() => _player.dispose();
}
