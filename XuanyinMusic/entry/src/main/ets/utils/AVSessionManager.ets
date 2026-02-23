import AvSession from '@ohos.multimedia.avsession';
import { SongItemType } from '../models/Music';
import AVPlayerManager from './AVPlayerManager';
import Logger from './Logger';

export default class AVSessionManager {
  static session: AvSession.AVSession;
  static controller: AvSession.AVSessionController;

  // 初始化媒体会话
  static async init(context: Context) {
    AVSessionManager.session = await AvSession.createAVSession(context, 'bgPlay', 'audio');
    AVSessionManager.controller = await AVSessionManager.session.getController();
    AVSessionManager.registerEvent();
  }

  static async setAVMetaData(song: SongItemType) {
    // 防止 session 失效时静默崩溃
    try {
      await AVSessionManager.session.setAVMetadata({
        assetId: song.id,
        title: song.name,
        artist: song.author,
        mediaImage: song.img.toString(),
        duration: AVPlayerManager.currentSong.duration
      });
    } catch (e) {
      Logger.error('[AVSessionManager] setAVMetaData failed:', e?.message);
    }
  }

  static async setAVPlaybackState() {
    try {
      await AVSessionManager.session.setAVPlaybackState({
        state: AVPlayerManager.currentSong.isPlay ?
        AvSession.PlaybackState.PLAYBACK_STATE_PLAY :
        AvSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: AVPlayerManager.currentSong.time,
          updateTime: (new Date()).getTime(),
        },
        speed: 1.0,
        duration: AVPlayerManager.currentSong.duration
      });
    } catch (e) {
      Logger.error('[AVSessionManager] setAVPlaybackState failed:', e?.message);
    }
  }

  static async registerEvent() {
    AVSessionManager.session.on('play', () => {
      AVPlayerManager.singlePlay(AVPlayerManager.currentSong.playList[AVPlayerManager.currentSong.playIndex]);
    });
    AVSessionManager.session.on('pause', () => {
      AVPlayerManager.pause();
    });
    // stop 停止播放并重置状态
    AVSessionManager.session.on('stop', () => {
      AVPlayerManager.pause();
      AVPlayerManager.player?.reset();
      AVPlayerManager.currentSong.isPlay = false;
    });
    AVSessionManager.session.on('playNext', () => {
      AVPlayerManager.nextPlay();
    });
    AVSessionManager.session.on('playPrevious', () => {
      AVPlayerManager.prevPlay();
    });
    AVSessionManager.session.on('seek', (time) => {
      AVPlayerManager.player!.seek(time);
    });
    AVSessionManager.session.activate();
  }
}
