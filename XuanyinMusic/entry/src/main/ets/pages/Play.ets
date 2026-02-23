// 详细播放页
import { AnimatorResult } from '@ohos.animator';
import { SongItemType, LyricLine } from '../models/Music';
import { PlayStateType } from '../models/PlayState';
import { SONG_KEY } from '../constants/MusicConstants';
import AVPlayerManager from '../utils/AVPlayerManager';
import { util } from '@kit.ArkTS';

// LRC 解析函数：[mm:ss.xx]歌词行 → LyricLine[]
function parseLrc(lrc: string): LyricLine[] {
  const result: LyricLine[] = [];
  const metaKeywords =
    ['作词', '作曲', '编曲', '人声', '录音', '混音', '母带', '设计', '统筹', '发行', '营销', '监制', '出品', 'OP'];
  const lines = lrc.split('\n');
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    const match = line.match(/^\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)$/);
    if (!match) {
      continue;
    }
    const minutes = parseInt(match[1]);
    const seconds = parseInt(match[2]);
    const ms = match[3].length === 2 ? parseInt(match[3]) * 10 : parseInt(match[3]);
    const text = match[4].trim();
    // 过滤空行
    if (!text) {
      continue;
    }
    // 过滤元数据行
    let isMeta = false;
    for (let k = 0; k < metaKeywords.length; k++) {
      if (text.indexOf(metaKeywords[k]) !== -1) {
        isMeta = true;
        break;
      }
    }
    if (isMeta) {
      continue;
    }
    const time = (minutes * 60 + seconds) * 1000 + ms;
    const lyricLine: LyricLine = { time, text };
    result.push(lyricLine);
  }
  return result;
}

// 唱针收起角度
const NEEDLE_REST_ANGLE: number = -30;
// 唱针落下角度
const NEEDLE_PLAY_ANGLE: number = 0;

@Entry
@Component
struct Play {
  @State opacityNum: number = 1;
  @State panelHeight: string = '0%';
  @State rotateAngle: number = 0;
  @State needleAngle: number = NEEDLE_REST_ANGLE;
  @State glowOpacity: number = 0;
  @State translateY: number = 0;
  // 歌词相关状态
  @State lyrics: LyricLine[] = [];
  @State currentLyricIndex: number = 0;
  // 是否显示歌词页（true=歌词，false=唱盘）
  @State showLyrics: boolean = false;
  private lyricListScroller: Scroller = new Scroller();
  animatorResult: AnimatorResult = this.getUIContext().createAnimator({
    duration: 1000 * 18,
    easing: 'linear',
    delay: 0,
    fill: 'forwards',
    direction: 'normal',
    iterations: -1,
    begin: 0,
    end: 360
  });
  @StorageLink(SONG_KEY) @Watch('onPlayStateChange') playState: PlayStateType = new PlayStateType();
  @State currentName: string = '';
  @State currentAuthor: string = '';
  @State currentImg: ResourceStr = '';
  // 记录上一次的歌曲 src，用于检测歌曲是否切换
  private lastSongSrc: string = '';

  onPlayStateChange() {
    const item = this.playState.playList[this.playState.playIndex];
    if (item) {
      this.currentName = item.name;
      this.currentAuthor = item.author;
      this.currentImg = item.img;
      // 歌曲切换时重新加载歌词
      if (item.src !== this.lastSongSrc) {
        this.lastSongSrc = item.src;
        this.loadLyrics();
      }
    }
    this.syncAnimations();
    this.syncLyric();
  }

  private syncAnimations() {
    if (this.playState.isPlay) {
      this.animatorResult.play();
      this.getUIContext()?.animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.needleAngle = NEEDLE_PLAY_ANGLE;
        this.glowOpacity = 1;
      });
    } else {
      this.animatorResult.pause();
      this.getUIContext()?.animateTo({ duration: 400, curve: Curve.EaseIn }, () => {
        this.needleAngle = NEEDLE_REST_ANGLE;
        this.glowOpacity = 0;
      });
    }
  }

  // 歌词实时滚动
  private syncLyric() {
    if (this.lyrics.length === 0) {
      return;
    }
    const currentTime = this.playState.time;
    let idx = 0;
    for (let i = 0; i < this.lyrics.length; i++) {
      if (this.lyrics[i].time <= currentTime) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx !== this.currentLyricIndex) {
      this.currentLyricIndex = idx;
      // 高亮行滚到中央，偏移3行
      const scrollTarget = idx > 3 ? idx - 3 : 0;
      this.lyricListScroller.scrollToIndex(scrollTarget, true, ScrollAlign.START);
    }
  }

  private async loadLyrics() {
    const currentItem = this.playState.playList[this.playState.playIndex];
    if (!currentItem) {
      this.lyrics = [];
      return;
    }
    try {
      const ctx = AVPlayerManager.uiContext?.getHostContext();
      if (!ctx) {
        this.lyrics = [];
        return;
      }
      const fileName = currentItem.id + '.lrc';
      // getRawFileContent 返回 Uint8Array，用 TextDecoder 转为字符串
      const rawData = ctx.resourceManager.getRawFileContentSync(fileName);
      const lrcText = new util.TextDecoder('utf-8').decodeToString(rawData);
      this.lyrics = parseLrc(lrcText);
    } catch (e) {
      // 文件不存在或读取失败时显示暂无歌词
      this.lyrics = [];
    }
    this.currentLyricIndex = 0;
    this.lyricListScroller.scrollToIndex(0, false, ScrollAlign.START);
  }

  async aboutToAppear() {
    this.animatorResult.onFrame = (val: number) => {
      this.rotateAngle = val;
    };
    // 初始化显示字段
    const item = this.playState.playList[this.playState.playIndex];
    if (item) {
      this.currentName = item.name;
      this.currentAuthor = item.author;
      this.currentImg = item.img;
    }
    this.syncAnimations();
    this.loadLyrics();
  }

  aboutToDisappear() {
    this.animatorResult.cancel();
  }

  number2time(number: number): string {
    const totalSeconds = Math.floor(number / 1000);
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return m.toString().padStart(2, '0') + ':' + s.toString().padStart(2, '0');
  }

  @Builder
  deleteButton(index: number) {
    Button($r('app.string.delete'))
      .backgroundColor($r('app.color.primary_light'))
      .fontColor('#fff')
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(() => {
        AVPlayerManager.remove(index);
      })
  }

  // 顶部导航
  @Builder
  headBuilder() {
    Row() {
      Image($r('app.media.chevron_down'))
        .width(24).height(24)
        .fillColor(Color.White)
        .onClick(() => {
          this.getUIContext()?.animateTo({
            duration: 350, curve: Curve.EaseIn, onFinish: () => {
              this.getUIContext().getRouter().back();
            }
          }, () => {
            this.translateY = 800;
            this.opacityNum = 0;
          });
        })

      Text(this.currentName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 12, right: 12 })

      Image($r('app.media.people_wifi'))
        .width(26)
        .height(22)
        .fillColor(Color.White)
    }
    .height(48)
    .margin({ top: AppStorage.get<number>('topHeight') })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 黑胶唱盘
  @Builder
  vinylPlayer() {
    Stack({ alignContent: Alignment.Center }) {
      // 外发光圆环
      Circle()
        .width(264)
        .height(264)
        .fill('none')
        .stroke('#ffffff')
        .strokeWidth(14)
        .opacity(this.glowOpacity * 0.15)

      // 黑胶底盘
      Circle()
        .width(244)
        .height(244)
        .fill('#1a1a2e')
        .shadow({
          radius: this.playState.isPlay ? 32 : 12,
          color: 'rgba(0,0,0,0.6)',
          offsetX: 0,
          offsetY: 6
        })

      // 圆形封面（Stack + clip 裁剪）
      Stack() {
        Image(this.currentImg)
          .width(200)
          .height(200)
          .objectFit(ImageFit.Cover)
      }
      .width(200)
      .height(200)
      .borderRadius(100)
      .clip(true)
      .backgroundColor(Color.Transparent)
      .rotate({ angle: this.rotateAngle })

      // 同心纹路
      Circle()
        .width(212)
        .height(212)
        .fill('none')
        .stroke('rgba(255,255,255,0.07)')
        .strokeWidth(1)
      Circle()
        .width(224)
        .height(224)
        .fill('none')
        .stroke('rgba(255,255,255,0.04)')
        .strokeWidth(1)

      // 轴心
      Circle().width(18).height(18).fill('#9aa0b0')
      Circle().width(8).height(8).fill('#2a2a3c')

      // 唱针
      Column() {
        Stack() {
          Circle().width(22).height(22).fill('#c0c8d8')
          Circle().width(10).height(10).fill('#7a8090')
        }
        .width(22).height(22)

        Column()
          .width(5)
          .height(108)
          .backgroundColor('#b8c0d0')
          .borderRadius(3)
          .shadow({
            radius: 4,
            color: 'rgba(0,0,0,0.35)',
            offsetX: 2,
            offsetY: 0
          })
          .margin({ top: 3 })

        Column()
          .width(3)
          .height(20)
          .backgroundColor('#a0a8b8')
          .borderRadius(2)
          .rotate({ angle: 18, centerX: '50%', centerY: 0 })
          .margin({ top: 2 })

        Circle().width(7).height(7).fill('#dde0e8').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width(28)
      .rotate({ angle: this.needleAngle, centerX: '50%', centerY: 0 })
      .position({ x: '63%', y: 0 })
      .zIndex(10)
    }
    .width('100%')
    .height(310)
    .margin({ top: 12, bottom: 4 })
    .backgroundColor(Color.Transparent)
  }

  // 歌词视图
  // 根据与当前行的距离计算透明度
  private lyricAlpha(idx: number): number {
    const dist = Math.abs(idx - this.currentLyricIndex);
    if (dist <= 1) {
      return 0.55;
    }
    if (dist <= 3) {
      return 0.35;
    }
    return 0.2;
  }

  @Builder
  lyricView() {
    Column() {
      if (this.lyrics.length === 0) {
        // 无歌词占位
        Column() {
          Text('暂无歌词')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.4)')
        }
        .width('100%')
        .height(310)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 12, bottom: 4 })
      } else {
        List({ scroller: this.lyricListScroller }) {
          // 顶部留白
          ListItem() {
            Column().height(80)
          }

          ForEach(this.lyrics, (line: LyricLine, idx: number) => {
            ListItem() {
              if (idx === this.currentLyricIndex) {
                // 当前行：白色加粗 + 发光阴影 + 放大
                Text(line.text)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .fontSize(19)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .textShadow({
                    radius: 14,
                    color: 'rgba(255,255,255,0.5)',
                    offsetX: 0,
                    offsetY: 0
                  })
                  .padding({
                    top: 14,
                    bottom: 14,
                    left: 20,
                    right: 20
                  })
                  .scale({ x: 1.06, y: 1.06 })
                  .animation({ duration: 350, curve: Curve.EaseOut })
              } else {
                // 非当前行：白色半透明，距离越远越淡
                Text(line.text)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .fontSize(15)
                  .fontWeight(FontWeight.Normal)
                  .fontColor(`rgba(255,255,255,${this.lyricAlpha(idx)})`)
                  .padding({
                    top: 14,
                    bottom: 14,
                    left: 20,
                    right: 20
                  })
                  .scale({ x: 1.0, y: 1.0 })
                  .animation({ duration: 350, curve: Curve.EaseOut })
              }
            }
          })
          // 底部留白
          ListItem() {
            Column().height(80)
          }
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height(340)
        .margin({ top: 8, bottom: 4 })
      }
    }
  }

  // 歌曲信息行
  @Builder
  songInformation() {
    Row() {
      Column({ space: 4 }) {
        Text(this.currentName)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E1E2E7')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.currentAuthor)
          .fontSize(15)
          .fontColor('#989EAD')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Stack() {
        Image($r('app.media.ic_like'))
          .width(24)
          .fillColor(Color.White)
        Text('1w+')
          .fontColor(Color.White)
          .fontSize(10)
          .padding({ bottom: 20, left: 20 })
          .fontWeight(600)
          .width(40)
          .height(40)
      }
      .width(40)
      .height(40)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ top: 8, bottom: 16 })
  }

  // 操作按钮行
  @Builder
  songOperation() {
    Row() {
      Image($r('app.media.ic_song_list'))
        .fillColor(Color.White)
        .width(28)
        .onClick(() => {
          this.panelHeight = '100%';
        })
      Image($r('app.media.ic_download_o'))
        .fillColor(Color.White)
        .width(30)
      Image($r('app.media.ic_sing'))
        .fillColor(Color.White)
        .width(30)
      Image($r('app.media.ic_other'))
        .fillColor(Color.White)
        .width(30)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 12 })
  }

  // 进度条与播放控制
  @Builder
  playerControls() {
    Column() {
      Slider({
        value: this.playState.time,
        min: 0,
        max: this.playState.duration,
        style: SliderStyle.InSet,
      })
        .blockBorderWidth(0)
        .blockSize({ width: 0.2, height: 0.2 })
        .trackThickness(4)
        .blockColor(Color.White)
        .blockBorderColor(Color.White)
        .selectedColor(Color.White)
        .trackColor('rgba(255,255,255,0.25)')
        .onChange((val) => {
          AVPlayerManager.player!.seek(val);
        })
        .margin({ bottom: -8, left: -7, right: -7 })

      Row() {
        Text(this.number2time(this.playState.time))
          .fontSize(12).fontColor('#A5B4B1')
        Text(this.number2time(this.playState.duration))
          .fontSize(12).fontColor('#A5B4B1')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        Image($r('app.media.ic_prev'))
          .fillColor(Color.White)
          .width(36)
          .onClick(() => {
            AVPlayerManager.prevPlay();
          })

        Stack() {
          Circle()
            .width(64)
            .aspectRatio(1)
            .fill('rgba(255,255,255,0.15)')
          Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
            .fillColor(Color.White)
            .width(36)
            .objectFit(ImageFit.Contain)
        }
        .width(64)
        .aspectRatio(1)
        .onClick(() => {
          if (!this.playState.isPlay) {
            AVPlayerManager.singlePlay(this.playState.playList[this.playState.playIndex]);
          } else {
            AVPlayerManager.pause();
          }
        })

        Image($r('app.media.ic_next'))
          .fillColor(Color.White)
          .width(36)
          .onClick(() => {
            AVPlayerManager.nextPlay();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ bottom: 24 })
    }
    .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack() {
        Image(this.currentImg)
          .width('100%')
          .height('100%')
          .blur(1000)
          .opacity(0.85)
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(10,10,20,0.45)')
      }
      .width('100%')
      .height('100%')

      Column() {
        this.headBuilder()
        // 唱盘/歌词 左右滑动切换（Swiper）
        // 左页：唱盘，右页：歌词
        Swiper() {
          Column() {
            this.vinylPlayer()
          }
          .width('100%')

          Column() {
            this.lyricView()
          }
          .width('100%')
        }
        .width('100%')
        .loop(false)
        .indicator(
          new DotIndicator()
            .color('rgba(255,255,255,0.3)')
            .selectedColor(Color.White)
        )
        .onChange((index: number) => {
          this.showLyrics = index === 1;
        })

        // 歌曲信息、操作、进度控制
        Column() {
          this.songInformation()
          this.songOperation()
          this.playerControls()
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 8, right: 8 })

      // 播放列表面板
      Column() {
        Column()
          .width('100%').layoutWeight(1)
          .onClick(() => {
            this.panelHeight = '0%';
          })

        Column() {
          Row() {
            Row() {
              Image($r('app.media.ic_play'))
                .width(20)
                .fillColor('#ff5186')
            }
            .width(50)
            .aspectRatio(1)
            .justifyContent(FlexAlign.Center)

            Row({ space: 8 }) {
              Text(`播放列表 (${this.playState.playList?.length})`)
                .fontColor(Color.White)
                .fontSize(14)
            }.layoutWeight(1)

            Image($r('app.media.ic_close'))
              .fillColor('#ffa49a9a')
              .width(24)
              .height(24)
              .margin({ right: 16 })
              .onClick(() => {
                this.panelHeight = '0%';
              })
          }
          .width('100%')
          .backgroundColor('#ff353333')
          .padding(8)
          .border({ width: { bottom: 1 }, color: '#12ec5c87' })
          .borderRadius({ topLeft: 4, topRight: 4 })

          List() {
            ForEach(this.playState.playList, (item: SongItemType, index: number) => {
              ListItem() {
                Row() {
                  Row() {
                    Text((index + 1)
                      .toString())
                      .fontColor('#ffa49a9a')
                  }
                  .width(50)
                  .aspectRatio(1)
                  .justifyContent(FlexAlign.Center)

                  Column() {
                    Text(item.name).fontSize(14)
                      .fontColor(this.playState.playIndex === index
                        ? $r('app.color.primary_light') : '#ffa49a9a')
                    Text(item.author).fontSize(12)
                      .fontColor(this.playState.playIndex === index
                        ? $r('app.color.primary_light') : Color.Gray)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Center)

                  Image($r('app.media.ic_more'))
                    .width(24)
                    .height(24)
                    .margin({ right: 16 })
                    .fillColor(Color.Gray)
                }
                .alignItems(VerticalAlign.Center)
              }
              .onClick(() => {
                AVPlayerManager.singlePlay(item);
                this.loadLyrics();
              })
              .swipeAction({ end: this.deleteButton(index) })
              .border({ width: { bottom: 1 }, color: '#12ec5c87' })
            })
          }
          .layoutWeight(1)
          .backgroundColor('#ff353333')
        }
        .height(400)
      }
      .height(this.panelHeight)
      .animation({ duration: 300 })
    }
    .width('100%')
    .height('100%')
    .opacity(this.opacityNum)
    .translate({ y: this.translateY })
  }

  pageTransition() {
    PageTransitionEnter({ duration: 380, curve: Curve.EaseOut })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ duration: 10 })
  }
}
