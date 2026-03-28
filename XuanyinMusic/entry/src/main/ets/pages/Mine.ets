// 我的页
@Extend(Text)
function functionText(align: TextAlign) {
  .width(50)
  .height(30)
  .fontSize(14)
  .fontColor('#A3A4B5')
  .textAlign(align)
  .margin({
    bottom: 4,
    left: 12,
    right: 12
  })
}

@Entry
@Component
struct Mine {
  @State selectedIndex: number = 0;
  columnList: number[] = [0, 1, 2, 3, 4, 5, 6, 7];
  private controller: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .width(96)
        .height(36)
        .fontSize(16)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .fontColor(this.selectedIndex === index ? Color.White : Color.Black)
        .backgroundColor(this.selectedIndex === index ? '#0A59F7' : '#F3F3F3')
        .borderRadius('50%')
        .border({ width: 1 })
        .textAlign(TextAlign.Center)
    }
    .margin({ top: 10, left: 15 })
  }

  @Builder
  playlist(photo: Resource, name: string, detail: string, isList: boolean) {
    Row() {
      Stack() {
        Image(photo)
          .borderRadius(10)
          .height(48)
          .width(48)
          .margin({ right: 10 })
        if (isList) {
          Image($r('app.media.ic_like'))
            .height(16)
            .width(18)
            .margin({ right: 10 })
        }
      }

      Column() {
        Text(name)
          .fontSize(17)
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({ bottom: 5 })
        Text(detail)
          .fontSize(15)
          .fontColor('#7D7D7D')
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .width('70%')

      Image($r("app.media.ic_play_fill"))
        .width(20)
        .height(isList ? 20 : 0)
    }
    .height(64)
    .width('100%')
    .margin({ left: 4 })
  }

  @Builder
  songTabContent(isFirst: boolean, dataSource: number[]) {
    List() {
      if (isFirst) {
        ListItem() {
          this.playlist($r("app.media.ic_img_cover"), '我喜欢的音乐', '17 首·235 次播放', true);
        }
        .margin(8)
      }
      ForEach(dataSource, (item: number) => {
        ListItem() {
          this.playlist($r("app.media.ic_img_cover"), '歌单' + item, '17 首·235 次播放', false);
        }
        .margin(8)
      })

      ListItem() {
      }
      .height(260)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  personalInformation() {
    Column() {
      Image($r('app.media.ic_img_cover'))
        .height(80)
        .width(80)
        .borderRadius(40)
        .margin({ top: 60 })
      Row() {
        Text('我的音乐')
          .fontSize(20)
          .fontColor(Color.White)
        Image($r("app.media.ic_vip"))
          .width(20)
          .height(20)
          .margin({ left: 3 })
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text('00后')
          .functionText(TextAlign.End)
        Text('狮子座')
          .functionText(TextAlign.Center)
        Text('上海')
          .functionText(TextAlign.Start)
      }

      Row() {
        Text('1 关注')
          .functionText(TextAlign.End)
        Text('12粉丝')
          .functionText(TextAlign.Center)
        Text('13w 赞')
          .functionText(TextAlign.Start)
      }
      .margin({ bottom: 13 })
    }
  }

  @Builder
  songListShow() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.selectedIndex, controller: this.controller }) {
        TabContent() {
          this.songTabContent(true, this.columnList);
        }
        .tabBar(this.tabBuilder(0, '音乐'))

        TabContent() {
          List() {
            this.songTabContent(false, this.columnList);
          }
          .height('100%')
          .scrollBar(BarState.Off)
        }
        .tabBar(this.tabBuilder(1, '收藏'))

        TabContent() {
          List() {
            this.songTabContent(false, this.columnList);
          }
          .scrollBar(BarState.Off)
        }
        .tabBar(this.tabBuilder(2, '专辑'))
      }
      .onChange((index) => {
        this.selectedIndex = index;
      })
      .barMode(BarMode.Scrollable)
      .fadingEdge(false)
      .vertical(false)
      .barPosition(BarPosition.Start)
      .margin({ top: 12 })
    }
    .backgroundColor('rgb(241, 243, 245)')
    .borderRadius({
      topLeft: 12,
      topRight: 12
    })
  }

  build() {
    Column() {
      this.personalInformation();
      this.songListShow();
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      repeating: false,
      colors: [[0x22294F, 0.0], [0x616681, 1]]
    })
    .expandSafeArea([SafeAreaType.CUTOUT], [SafeAreaEdge.TOP])
  }
}

export default Mine;
