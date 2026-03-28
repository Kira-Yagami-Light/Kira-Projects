import AvSession from '@ohos.multimedia.avsession';
import { SongItemType } from '../models/Music';
import AVPlayerManager from './AVPlayerManager';
import { image } from '@kit.ImageKit';
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
    try {
      // 把 Resource 图片转成 PixelMap，AVSession 才能显示封面
      const ctx = AVPlayerManager.uiContext?.getHostContext();
      let pixelMap: image.PixelMap | undefined = undefined;
      if (ctx) {
        const resourceMgr = ctx.resourceManager;
        const rawData = resourceMgr.getMediaContentSync(song.img as Resource);
        const imageSource = image.createImageSource(rawData.buffer as ArrayBuffer);
        pixelMap = await imageSource.createPixelMap();
      }

      await AVSessionManager.session.setAVMetadata({
        assetId: song.id,
        title: song.name,
        artist: song.author,
        mediaImage: pixelMap ?? song.img.toString(),
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
