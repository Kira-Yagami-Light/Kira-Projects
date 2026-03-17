import { media } from '@kit.MediaKit';
import { wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { SONG_KEY } from '../constants/MusicConstants';
import { SongItemType } from '../models/Music';
import { PlayStateType } from '../models/PlayState';
import AVSessionManager from './AVSessionManager';
import Logger from './Logger';
import { audio } from '@kit.AudioKit';

// 应用包名常量，避免硬编码
const BUNDLE_NAME = 'com.example.xuanyinmusic';
const ABILITY_NAME = 'com.example.xuanyinmusic.EntryAbility';

class AVPlayerManager {
  static player: media.AVPlayer | null = null;
  static currentSong: PlayStateType = new PlayStateType();
  static uiContext: UIContext | undefined = undefined;
  private static isInitialized: boolean = false;
  private static listenerPlayer: media.AVPlayer | null = null;

  static async init() {
    if (!AVPlayerManager.player) {
      AVPlayerManager.player = await media.createAVPlayer();
    }
    // 防止重复注册：用实例引用比较，热重载后实例变了也能重新注册
    if (AVPlayerManager.listenerPlayer === AVPlayerManager.player) {
      return;
    }
    AVPlayerManager.listenerPlayer = AVPlayerManager.player;
    AVPlayerManager.isInitialized = true;

    // 启动时清空播放列表和播放状态，PlayerNav 从隐藏开始
    AVPlayerManager.currentSong.playList = [];
    AVPlayerManager.currentSong.playIndex = 0;
    AVPlayerManager.currentSong.isPlay = false;
    AppStorage.setOrCreate<boolean>('hasPlayed', false);
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);

    // 监听状态
    
    AVPlayerManager.player.on('stateChange', (state) => {
      switch (state) {
        case 'initialized':
          AVPlayerManager.player!.prepare();
          break;
        case 'prepared':
          AVPlayerManager.player!.play();
          AVPlayerManager.currentSong.isPlay = true;
          break;
        case 'completed':
          AVPlayerManager.nextPlay(AVPlayerManager.currentSong.playMode === 'repeat');
          break;
      }
    });

    // 监听歌曲时长，切换歌曲时触发
    AVPlayerManager.player.on('durationUpdate', (duration) => {
      AVPlayerManager.currentSong.duration = duration;
      AVSessionManager.setAVMetaData(AVPlayerManager.currentSong.playList[AVPlayerManager.currentSong.playIndex]);
    });

    // 监听播放进度，更新全局状态
    AVPlayerManager.player.on('timeUpdate', async (time) => {
      AVPlayerManager.currentSong.time = time;
      AVSessionManager.setAVPlaybackState();
      AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
    });

    // 监听音频焦点打断（来电、闹钟等）
    AVPlayerManager.player.on('audioInterrupt', (event: audio.InterruptEvent) => {
      switch (event.hintType) {
        case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
          if (AVPlayerManager.currentSong.isPlay) {
            AVPlayerManager.player?.pause();
            AVPlayerManager.currentSong.isPlay = false;
            AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
          }
          break;
        case audio.InterruptHint.INTERRUPT_HINT_RESUME:
          AVPlayerManager.player?.play();
          AVPlayerManager.currentSong.isPlay = true;
          AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
          break;
        case audio.InterruptHint.INTERRUPT_HINT_STOP:
          AVPlayerManager.player?.pause();
          AVPlayerManager.currentSong.isPlay = false;
          AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
          break;
        default:
          break;
      }
    });
  }

  // 单曲播放
  static async singlePlay(song: SongItemType) {
    if (!AVPlayerManager.player) {
      await AVPlayerManager.init();
    }
    if (!song) {
      return;
    }
    AVPlayerManager.startBackgroundTask();

    // 用 src 去重，避免社区重复加载产生重复列表项
    const existIndex = AVPlayerManager.currentSong.playList.findIndex(
      (item: SongItemType) => item.src === song.src
    );

    if (existIndex !== -1) {
      const currentSrc =
        AVPlayerManager.currentSong.playList[AVPlayerManager.currentSong.playIndex]?.src;

      if (currentSrc === song.src) {
        // 当前歌曲，恢复播放
        AVPlayerManager.player?.play();
        AVPlayerManager.currentSong.isPlay = true;
      } else {
        // 切换到列表中已有的这首歌
        AVPlayerManager.currentSong.playIndex = existIndex;
        await AVPlayerManager.changePlay();
      }
    } else {
      // 新歌曲，追加到列表末尾
      AVPlayerManager.currentSong.playList.push(song);
      AVPlayerManager.currentSong.playIndex = AVPlayerManager.currentSong.playList.length - 1;
      await AVPlayerManager.changePlay();
    }

    // 任何成功播放都显示 PlayerNav
    AppStorage.set<boolean>('hasPlayed', true);
    AVSessionManager.setAVPlaybackState();
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
  }

  static async startBackgroundTask() {
    // 当前存在会话则不重复开启后台任务
    if (AVSessionManager.session?.sessionId) {
      return;
    }
    try {
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: BUNDLE_NAME,
            abilityName: ABILITY_NAME
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      let want = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(
        AVPlayerManager.uiContext?.getHostContext(),
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        want
      );
    } catch (e) {
      AVPlayerManager.uiContext?.showAlertDialog({ message: e.message });
    }
  }

  // 暂停播放
  static pause() {
    AVPlayerManager.player!.pause();
    AVPlayerManager.currentSong.isPlay = false;
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
    AVSessionManager.setAVPlaybackState();
  }

  // 上一首
  static prevPlay() {
    const list = AVPlayerManager.currentSong.playList;
    if (!list.length) {
      return;
    }
    if (AVPlayerManager.currentSong.playMode === 'random') {
      AVPlayerManager.currentSong.playIndex = AVPlayerManager.getRandomIndex();
    } else {
      AVPlayerManager.currentSong.playIndex =
        (AVPlayerManager.currentSong.playIndex - 1 + list.length) % list.length;
    }
    AVPlayerManager.changePlay();
  }

  // 下一首
  static nextPlay(repeat?: boolean) {
    const list = AVPlayerManager.currentSong.playList;
    if (!list.length) {
      return;
    }
    if (!repeat) {
      if (AVPlayerManager.currentSong.playMode === 'random') {
        AVPlayerManager.currentSong.playIndex = AVPlayerManager.getRandomIndex();
      } else {
        AVPlayerManager.currentSong.playIndex =
          (AVPlayerManager.currentSong.playIndex + 1) % list.length;
      }
    }
    AVPlayerManager.changePlay();
  }

  // 切换歌曲（重置播放器并加载本地 rawfile）
  static async changePlay() {
    if (AVPlayerManager.player!.state !== 'idle') {
      await AVPlayerManager.player!.reset();
    }
    AVPlayerManager.currentSong.duration = 0;
    AVPlayerManager.currentSong.time = 0;

    const currentItem = AVPlayerManager.currentSong.playList[AVPlayerManager.currentSong.playIndex];

    // 先同步元数据到 currentSong 并推送 AppStorage
    // 确保 Play 页封面/标题在音频加载前就已更新
    AVPlayerManager.currentSong.img = currentItem.img.toString();
    AVPlayerManager.currentSong.name = currentItem.name;
    AVPlayerManager.currentSong.author = currentItem.author;
    AVPlayerManager.currentSong.src = currentItem.src;
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);

    const ctx = AVPlayerManager.uiContext?.getHostContext();
    if (!ctx) {
      Logger.warn('AVPlayerManager: uiContext not ready');
      return;
    }

    try {
      const fileName = currentItem.src;
      const fd = ctx.resourceManager.getRawFdSync(fileName);
      AVPlayerManager.player!.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
    } catch (e) {
      Logger.error('AVPlayerManager: failed to load rawfile:', e.message);
    }
  }

  // 从播放列表中移除指定歌曲
  static async remove(index: number) {
    if (AVPlayerManager.currentSong.playIndex === index) {
      if (AVPlayerManager.currentSong.playList.length > 1) {
        AVPlayerManager.currentSong.playList.splice(index, 1);
        AVPlayerManager.currentSong.playIndex =
          AVPlayerManager.currentSong.playIndex %
          AVPlayerManager.currentSong.playList.length;
        await AVPlayerManager.changePlay();
      } else {
        // 列表仅剩一首，重置播放器并返回上一页
        await AVPlayerManager.player?.reset();
        AVPlayerManager.currentSong = new PlayStateType();
        AVPlayerManager.uiContext?.getRouter().back();
      }
    } else {
      if (AVPlayerManager.currentSong.playIndex > index) {
        AVPlayerManager.currentSong.playIndex--;
      }
      AVPlayerManager.currentSong.playList.splice(index, 1);
    }
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
  }

  private static getRandomIndex(): number {
    const len = AVPlayerManager.currentSong.playList.length;
    if (len <= 1) {
      return 0;
    }
    let index: number;
    do {
      index = Math.floor(Math.random() * len);
    } while (index === AVPlayerManager.currentSong.playIndex);
    return index;
  }
}

export default AVPlayerManager;
