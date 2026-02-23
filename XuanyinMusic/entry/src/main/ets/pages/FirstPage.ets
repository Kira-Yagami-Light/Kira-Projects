// 首页
import { DAILY_RECOMMEND, RECOMMEND_LIST, RANK_LIST } from '../constants/MusicConstants';
import { RecommendDailyType, RecommendListType, RankListType, RankSongItem } from '../models/Music';

@Entry
@Component
struct FirstPage {
  @State changeValue: string = '';
  @State submitValue: string = '';

  @Builder
  stickyHeader() {
    Column() {
      Row() {
        Text($r('app.string.first_page'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
      }
      .width('92%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ top: 12, bottom: 12 })

      Search({ value: this.changeValue, placeholder: $r('app.string.search') })
        .searchIcon({ src: $r('sys.media.ohos_ic_public_search_filled') })
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: { src: $r('sys.media.ohos_ic_public_cancel_filled') }
        })
        .width('92%')
        .height(44)
        .maxLength(20)
        .backgroundColor($r('sys.color.gray_02'))
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 16, weight: 400 })
        .textFont({ size: 16, weight: 400 })
        .borderRadius(22)
        .onSubmit((value: string) => {
          this.submitValue = value;
        })
        .onChange((value: string) => {
          this.changeValue = value;
        })
        .margin({ bottom: 10 })
    }
    .padding({ top: AppStorage.get<number>('topHeight') })
    .width('100%')
    .backgroundColor('rgb(241, 243, 245)')
    .border({ width: { bottom: 1 }, color: '#e8e8e8' })
  }

  // 推荐歌单卡片
  @Builder
  recommend(item: RecommendListType) {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Row() {
            Image($r('app.media.ic_back_left'))
              .width('50%')
              .aspectRatio(1)
            Image($r('app.media.ic_back_right'))
              .width('50%')
              .aspectRatio(1)
          }
          .width('100%')
          .margin({ top: '50px' })
          .alignItems(VerticalAlign.Center)

          Image(item.img)
            .width('63%')
            .borderRadius(10)
            .aspectRatio(1)
        }
        .padding({ top: 18, bottom: 4 })
        .alignContent(Alignment.Center)

        Row() {
          Image($r('app.media.icon_play_album'))
            .width(24)
            .height(24)
          Text(item.count + '人听过')
            .width('100%')
            .fontSize(11)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .padding(8)
        }
        .padding({ left: 8 })
        .margin({ bottom: '20px' })
        .alignItems(VerticalAlign.Center)
      }
      .aspectRatio(1)
      .borderRadius(10)
      .backgroundImage(item.img)
      .backgroundImageSize(ImageSize.Cover)
      .backdropBlur(66)

      Row() {
        Text(item.title)
          .textAlign(TextAlign.Start)
          .fontSize(15)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.black'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
    .width('38%')
  }

  @Builder
  songList() {
    Column() {
      Row() {
        Text($r('app.string.song_list_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('95%')
      .padding(8)
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Scroll() {
        Row({ space: 10 }) {
          ForEach(RECOMMEND_LIST, (item: RecommendListType) => {
            this.recommend(item);
          })
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 16 })
    }
  }

  // 音乐电台卡片
  @Builder
  album(item: RecommendDailyType) {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.icon_song'))
            .width(16)
            .height(16)
            .fillColor($r('sys.color.black'))
            .margin({ left: 4 })
          Text(item.title)
            .width('100%')
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .fontSize(13)
            .padding(8)
        }
        .padding({ left: 8, top: 6 })

        Stack({ alignContent: Alignment.Center }) {
          Row() {
            Image($r('app.media.ic_back_left'))
              .width('50%')
              .aspectRatio(1)
            Image($r('app.media.ic_back_right'))
              .width('50%')
              .aspectRatio(1)
          }
          .width('100%')
          .margin({ top: '50px' })
          .alignItems(VerticalAlign.Center)

          Image(item.img)
            .width('63%')
            .borderRadius(8)
            .aspectRatio(1)
        }
        .width('100%')
        .margin({ top: '50px' })
        .alignContent(Alignment.Center)
      }
      .height('33%')
      .backgroundImage(item.img)
      .backgroundImageSize(ImageSize.Cover)
      .backdropBlur(50)
      .flexGrow(3)

      Row() {
        Column() {
          Text(item.type)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.white'))
            .margin({ left: '20px' })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(item.song)
            .fontSize(13)
            .fontColor('#f8f8ff')
            .margin({ left: '20px' })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ top: 5 })
        }
        .width('80%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: '30px', bottom: '30px' })

        Image($r('app.media.icon_play_album'))
          .width(32)
          .height(32)
      }
      .flexGrow(1)
      .width('100%')
      .height('11%')
      .padding({ left: 10, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(item.bottom)
    }
    .backgroundImage(item.img)
    .backgroundImageSize(ImageSize.Cover)
    .backdropBlur(70)
    .width('63%')
    .height(280)
    .borderRadius(16)
    .clip(true)
  }

  @Builder
  displayWindow() {
    Row() {
      Text($r('app.string.music_radio'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
    }
    .width('95%')
    .padding(8)
    .justifyContent(FlexAlign.Start)
    .margin({ top: 12, bottom: 8 })

    Scroll() {
      Row({ space: 10 }) {
        ForEach(DAILY_RECOMMEND, (item: RecommendDailyType) => {
          this.album(item);
        })
      }
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBarWidth(0)
    .padding({ left: 16 })
  }

  // 排行榜
  @Builder
  songRow(index: number, item: RankSongItem, isFirst: boolean) {
    Row() {
      Text(`${index} `)
        .fontSize(15)
        .fontColor(Color.Gray)
      Text(`${item.song} `)
        .fontSize(15)
        .fontColor(Color.Black)
      Text(item.author)
        .fontSize(13)
        .fontColor(Color.Gray)
    }
    .width('90%')
    .margin({ left: '16px' })
    .padding({ top: isFirst ? 0 : 10 })
  }

  @Builder
  rankList(list: RankListType[]) {
    Column() {
      Row() {
        Text($r('app.string.month_rank_list'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ top: 12, bottom: 12 })

      List({ space: 10 }) {
        ForEach(list, (item: RankListType) => {
          ListItem() {
            Row() {
              Stack() {
                Image(item.img)
                  .height('100%')
                  .aspectRatio(1)
                  .zIndex(1)
                  .borderRadius({ topLeft: 12, bottomLeft: 12 })
                  .alignSelf(ItemAlign.Start)
                Column() {
                  Text($r('app.string.update_daily'))
                    .fontSize(11)
                    .fontColor($r('sys.color.white'))
                    .textAlign(TextAlign.Start)
                    .margin({ top: '10px', left: '20px' })
                  Text(item.title1)
                    .fontSize(22)
                    .fontColor($r('sys.color.white'))
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .alignSelf(ItemAlign.Center)
                    .margin({ top: '40px' })
                  Text(item.title2)
                    .fontSize(17)
                    .fontColor($r('sys.color.white'))
                    .alignSelf(ItemAlign.Center)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                  Row() {
                    Image($r('app.media.ic_play_wb'))
                      .width('60px')
                      .height('60px')
                      .fillColor($r('sys.color.black'))
                      .alignSelf(ItemAlign.Start)
                    Text(item.count)
                      .fontSize(11)
                      .fontColor($r('sys.color.white'))
                      .textAlign(TextAlign.Start)
                  }
                  .margin({ top: '30px', left: '20px' })
                  .padding({ bottom: 5 })
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)
                .zIndex(10)
                .width('100%')
                .height('100%')
              }
              .height('100%')
              .width('30%')
              .borderRadius(10)

              Column() {
                ForEach(item.songs, (songItem: RankSongItem, idx: number) => {
                  this.songRow(idx + 1, songItem, idx === 0);
                })
              }
              .height('100%')
              .width('70%')
              .borderRadius({ topRight: 12, bottomRight: 12 })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.White)
            }
            .width('100%')
            .height('20%')
            .alignItems(VerticalAlign.Top)
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

      Row() {
        Text($r('app.string.touch_the_end'))
          .fontSize(13)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .height(10)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
    }
    .width('92%')
    .margin({ top: 16 })
  }

  build() {
    Column() {
      this.stickyHeader()

      Scroll() {
        Column() {
          this.songList()
          this.displayWindow()
          this.rankList(RANK_LIST)
        }
        .width('100%')
        .backgroundColor('rgb(241, 243, 245)')
        .justifyContent(FlexAlign.Start)
        .padding({
          bottom: (AppStorage.get<number>('bottomHeight') ?? 0) + 40
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('rgb(241, 243, 245)')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgb(241, 243, 245)')
  }
}

export default FirstPage;
