@Builder
export function appPageBuilder() {
  AppInformation();
}

@Component
struct AppInformation {
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  titleBuilder(title: ResourceStr) {
    Row() {
      Image($r('app.media.ic_back'))
        .width(32)
        .height(32)
        .onClick(() => {
          this.pageInfos.pop();
        })
      Text(title)
        .fontSize(24)
        .fontWeight(700)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({ left: 24 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12, left: 16 })
    .margin({ top: 12, bottom: 12 })
  }

  @Builder
  versionBuilder(version: string) {
    Row() {
      Text('当前版本号: ' + version)
        .fontSize(20)
        .fontColor($r('sys.color.black'))
        .padding({ top: 320 })
    }
    .width('100%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundImage($r('app.media.img_information_bg'))
    .backgroundImageSize({ width: '100%', height: '100%' })

  }

  @Builder
  versionInformation() {
    Row() {
      Text($r('app.string.description'))
        .fontSize(14)
        .fontColor($r('sys.color.black'))
    }
    .width('94%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(20)
    .margin({ top: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBuilder($r('app.string.app_information'));
        this.versionBuilder('Demo V1.0');
        this.versionInformation();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgb(241, 243, 245)')
      .padding({
        top: this.getUIContext().px2vp(AppStorage.get<number>('topHeight')),
        bottom: this.getUIContext().px2vp(AppStorage.get<number>('bottomHeight'))
      })
    }
    .hideTitleBar(true)
  }
}