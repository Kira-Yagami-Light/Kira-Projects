import { Context } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { PlayStateType } from '../models/PlayState';
import Logger from './Logger';

const SONG_CACHE_STORE = 'song_cache';
const SONG_CACHE_KEY = 'song_cache_key';

export default class SongManager {
  static context: Context;

  static getStore() {
    const ctx = SongManager.context || getContext();
    if (!ctx) {
      throw new Error('[SongManager] context 未初始化，请先调用 SongManager.context = context');
    }
    return preferences.getPreferencesSync(ctx, {
      name: SONG_CACHE_STORE
    });
  }

  // 持久化保存当前播放状态
  static async updateSong(song: string) {
    try {
      let store = SongManager.getStore();
      store.putSync(SONG_CACHE_KEY, song);
      await store.flush();
    } catch (e) {
      Logger.error('[SongManager] updateSong failed:', e?.message);
    }
  }

  // 读取上次保存的播放状态
  static async getSong(): Promise<PlayStateType> {
    try {
      let store = SongManager.getStore();
      const raw = store.getSync(SONG_CACHE_KEY, JSON.stringify(new PlayStateType())) as string;
      return JSON.parse(raw) as PlayStateType;
    } catch (e) {
      Logger.error('[SongManager] getSong failed:', e?.message);
      return new PlayStateType();
    }
  }
}
