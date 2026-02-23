// 底部迷你播放栏组件
import { SONG_KEY, SONGS } from '../constants/MusicConstants';
import { PlayStateType } from '../models/PlayState';
import AVPlayerManager from '../utils/AVPlayerManager';

const PRIMARY_COLOR: string = '#FE1A47';

@Component
export struct PlayerNav {
  @StorageLink(SONG_KEY) @Watch('onPlayStateChange') playState: PlayStateType = new PlayStateType();
  // @StorageLink 对象内部字段变化不触发 UI 刷新，手动同步
  @State currentImg: ResourceStr = '';
  @State currentName: string = '';
  @State currentAuthor: string = '';
  @State isPlaying: boolean = false;

  onPlayStateChange() {
    const item = this.playState.playList[this.playState.playIndex];
    if (item) {
      this.currentImg = item.img;
      this.currentName = item.name;
      this.currentAuthor = item.author;
    }
    this.isPlaying = this.playState.isPlay;
  }

  private togglePlay() {
    if (!this.isPlaying) {
      const current = AVPlayerManager.currentSong;
      const song = current.playList.length > 0
        ? current.playList[current.playIndex]
        : SONGS[0];
      if (song) {
        AVPlayerManager.singlePlay(song);
      }
    } else {
      AVPlayerManager.pause();
    }
  }

  build() {
    Row() {
      // 左侧：封面 + 歌曲信息
      Row({ space: 10 }) {
        Image(this.currentImg)
          .width(40)
          .borderRadius(5)
          .aspectRatio(1)
          .margin({ left: 8 })
        Column() {
          Text(this.currentName)
            .fontColor($r('sys.color.black'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.currentAuthor)
            .fontSize(12)
            .fontColor($r('sys.color.black'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .height('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      // 右侧：控制按钮区
      Row({ space: 4 }) {
        Image($r('app.media.ic_prev'))
          .height(24)
          .width(24)
          .fillColor(PRIMARY_COLOR)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            AVPlayerManager.prevPlay();
          })

        Image(this.isPlaying ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
          .height(24)
          .width(24)
          .fillColor(PRIMARY_COLOR)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.togglePlay();
          })

        Image($r('app.media.ic_next'))
          .height(24)
          .width(24)
          .fillColor(PRIMARY_COLOR)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            AVPlayerManager.nextPlay();
          })
      }
      .height('100%')
      .margin({ right: 8 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(52)
    .backgroundColor($r('sys.color.white'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
