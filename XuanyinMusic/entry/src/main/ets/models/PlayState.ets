import { SongItemType } from './Music';

export class PlayStateType {
  img: string = '';           // 音乐封面
  name: string = '';          // 音乐名称
  author: string = '';        // 作者
  src: string = '';           // 当前播放链接
  playIndex: number = 0;      // 当前在播放列表中的播放索引
  time: number = 0;           // 已播放时间（单位：ms）
  duration: number = 0;       // 音乐总时长（单位：ms）
  isPlay: boolean = false;    // 是否正在播放
  playMode: 'auto' | 'repeat' | 'random' = 'auto'; // 播放模式
  playList: SongItemType[] = []; // 当前播放列表
}
