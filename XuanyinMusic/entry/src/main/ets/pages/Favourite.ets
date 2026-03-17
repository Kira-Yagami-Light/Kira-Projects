// 最爱音乐列表页
import { FAVORITE_LIST } from '../constants/MusicConstants';
import { SongItemType } from '../models/Music';
import AVPlayerManager from '../utils/AVPlayerManager';

@Entry
@Component
struct Favourite {
  @Builder
  button(icon: ResourceStr, name: ResourceStr) {
    Button() {
      Row({ space: 8 }) {
        Image(icon)
          .width(24)
        Text(name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
      }
      .width('40%')
      .height('20%')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#dcdcdc')
    }
    .clip(true)
    .onClick(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.display_only') });
    })
  }

  @Builder
  introduction() {
    Column() {
      Row({ space: 12 }) {
        Image($r('app.media.img_like'))
          .width('35%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
        Column({ space: 8 }) {
          Text($r('app.string.my_favourite'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text($r('app.string.favourite_description'))
            .fontSize(16)
            .fontColor($r('sys.color.white'))
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .width('92%')
      .height('80%')

      Row() {
        this.button($r('app.media.icon_plus'), $r('app.string.add'));
        this.button($r('app.media.icon_share'), $r('app.string.share'));
      }
      .width('92%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('32%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 12, bottom: 20 })
  }

  @Builder
  listTopBuilder() {
    Row({ space: 8 }) {
      Row({ space: 8 }) {
        Image($r('app.media.icon_list_play'))
          .width(32)
          .height(32)
        Text(`播放全部 ${FAVORITE_LIST.songs.length}`)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
      }
    }
    .width('100%')
    .padding(16)
    .border({
      width: { bottom: 1 },
      color: '#cccccc'
    })
  }

  @Builder
  songList(songs: SongItemType[]) {
    Column() {
      List() {
        ForEach(songs, (item: SongItemType) => {
          ListItem() {
            Row() {
              Row({ space: 10 }) {
                Column() {
                  Text(item.name)
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.black'))
                  Row() {
                    Image($r('app.media.ic_sq'))
                      .width(16)
                    Text(item.author)
                      .fontSize(14)
                      .fontColor(Color.Gray)
                      .margin({ left: 4 })
                  }
                  .margin({ top: 8 })
                }
                .margin({ left: 12 })
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

                Image($r('app.media.ic_path'))
                  .width(7)
                  .height(14)
                  .margin({ right: 16 })
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: 8 })
            }
            .height('15.7%')
            .alignItems(VerticalAlign.Center)
          }
          .border({
            width: { bottom: 1 },
            color: '#cccccc'
          })
          .onClick(() => {
            AVPlayerManager.singlePlay(item);
          })
        })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }

  @Builder
  favouriteList() {
    Column() {
      this.listTopBuilder();
      this.songList(FAVORITE_LIST.songs);
    }
    .backgroundColor('rgb(241, 243, 245)')
    .layoutWeight(1)
    .width('100%')
    .borderRadius({ topLeft: 25, topRight: 25 })
  }

  build() {
    Column() {
      Column() {
        this.introduction();
        this.favouriteList();
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backdropBlur(71)
    .backgroundImage($r('app.media.img_like'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .padding({
      top: AppStorage.get<number>('topHeight')
    })
  }
}

export default Favourite;
