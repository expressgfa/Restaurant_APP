import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class AudioFeedback {
  static final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  static playSuccessSound() async {
    // final path = await rootBundle.load("assets/audio/success.wav");
    // audioPlayer.setSource(AssetSource("assets/audio/success.wav"));
    //audioPlayer.setSourceUrl(url);
    audioPlayer.setReleaseMode(ReleaseMode.release);
    FlutterVolumeController.showSystemUI = false;

    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
    // errorLog(ringerStatus.name);

    try {
      await SoundMode.setSoundMode(RingerModeStatus.normal);
    } on PlatformException {
      errorLog('Please enable permissions required');
    }


    await FlutterVolumeController.setVolume(1);
    audioPlayer.play(
      AssetSource("audio/success.wav"),
      // BytesSource(path.buffer.asUint8List()),
      volume: 1,
      ctx: const AudioContext(
        android: AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            isSpeakerphoneOn: true,
            stayAwake: false,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [
            // AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () async {
      await audioPlayer.stop();
    });
  }

  static playBackgroundSound() async {
    audioPlayer.setReleaseMode(ReleaseMode.release);
    FlutterVolumeController.showSystemUI = false;

    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
    errorLog(ringerStatus.name);

    try {
      await SoundMode.setSoundMode(RingerModeStatus.normal);
    } on PlatformException {
      errorLog('Please enable permissions required');
    }


    await FlutterVolumeController.setVolume(1);

    audioPlayer.play(
      // AssetSource("audio/open-app.mp3"),
      AssetSource("audio/open-app-loud.mp3"),
      volume: 1,
      ctx: const AudioContext(
        android: AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            isSpeakerphoneOn: true,
            stayAwake: false,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [
            // AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 4), () async {
      await audioPlayer.stop();
    });
  }

  //  static playFailureSound() async {
  //   // final path = await rootBundle.load("assets/audio/failure.wav");
  //   //
  //   // audioPlayer.setSourceBytes(path.buffer.asUint8List());
  //   audioPlayer.setReleaseMode(ReleaseMode.release);
  //   //audioPlayer.setSourceUrl(url);
  //   audioPlayer.play(
  //     AssetSource("audio/failure.wav"),
  //     // BytesSource(path.buffer.asUint8List()),
  //     volume: 0.1,
  //     ctx: const AudioContext(
  //       android: AudioContextAndroid(
  //           contentType: AndroidContentType.music,
  //           isSpeakerphoneOn: true,
  //           stayAwake: true,
  //           usageType: AndroidUsageType.alarm,
  //           audioFocus: AndroidAudioFocus.gainTransient),
  //       iOS: AudioContextIOS(
  //         category: AVAudioSessionCategory.playback,
  //         options: [
  //           // AVAudioSessionOptions.mixWithOthers,
  //           AVAudioSessionOptions.defaultToSpeaker,
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // static playButtonSound() async {
  //   audioPlayer.setReleaseMode(ReleaseMode.release);
  //   audioPlayer.play(
  //     AssetSource("audio/button-16.wav"),
  //     volume: 15,
  //     ctx: const AudioContext(
  //       android: AudioContextAndroid(
  //         contentType: AndroidContentType.music,
  //         isSpeakerphoneOn: true,
  //         stayAwake: true,
  //         usageType: AndroidUsageType.alarm,
  //         audioFocus: AndroidAudioFocus.gainTransient,
  //       ),
  //       iOS: AudioContextIOS(
  //         category: AVAudioSessionCategory.playback,
  //         options: [
  //           AVAudioSessionOptions.defaultToSpeaker,
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
