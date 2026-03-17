// 主页
import { TabClass } from '../models/Tab';
import { SONG_KEY, TABS_DATA } from '../constants/MusicConstants';
import Mine from './Mine';
import Community from './Community';
import FirstPage from './FirstPage';
import Favourite from './Favourite';
import { PlayerNav } from '../components/PlayerNav';
import { PlayStateType } from '../models/PlayState';
import AVPlayerManager from '../utils/AVPlayerManager';

@Entry
@Component
struct HomeIndex {
  @State currentName: string = 'firstPage';
  @StorageLink(SONG_KEY) playState: PlayStateType = new PlayStateType();
  @StorageLink('hasPlayed') hasPlayed: boolean = false;
  opacityNum: number = 1;

  async aboutToDisappear(): Promise<void> {
    AVPlayerManager.pause();
    await AVPlayerManager.player?.stop();
    await AVPlayerManager.player?.release();
    // 退出应用时清空播放列表，下次启动 PlayerNav 不显示
    AVPlayerManager.currentSong.playList = [];
    AVPlayerManager.currentSong.playIndex = 0;
    AppStorage.setOrCreate<PlayStateType>(SONG_KEY, AVPlayerManager.currentSong);
  }

  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Row() {
        Image(item.name === this.currentName ? item.iconLight : item.icon)
          .width(item.name === this.currentName ? 25 : 30)
          .aspectRatio(1)
      }
      .width(22)
      .aspectRatio(1)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)

      Text(item.title)
        .fontSize(10)
        .fontWeight(400)
        .margin({ top: 5 })
        .fontColor(item.name === this.currentName ? $r('app.color.primary_light') : $r('app.color.primary_dark'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ barPosition: BarPosition.End }) {
          ForEach(TABS_DATA, (item: TabClass) => {
            TabContent() {
              if (item.name === 'firstPage') {
                FirstPage();
              } else if (item.name === 'community') {
                Community();
              } else if (item.name === 'mine') {
                Mine({ playState: $playState });
              } else {
                Favourite();
              }
            }
            .tabBar(this.getTabBar(item))
            .backgroundColor($r('sys.color.white'))
          })
        }
        .barHeight(60)
        .onChange(index => {
          this.currentName = TABS_DATA[index].name;
        })

        // 底部迷你播放栏
        PlayerNav()
          .translate({ y: -60 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/Play'
            });
          })
          .visibility(this.hasPlayed ? Visibility.Visible : Visibility.Hidden)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .opacity(this.opacityNum)
    .padding({
      bottom: AppStorage.get<number>('bottomHeight')
    })
  }
}
