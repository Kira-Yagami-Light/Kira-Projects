import { TaskListData } from '../common/TaskListData';

@Component
export struct Settings {
  @Link tasks: TaskListData[];
  @Consume('pageInfos') pageInfos: NavPathStack;
  private now: Date = new Date();
  private hour: number = this.now.getHours();

  @Builder
  titleBuilder(title: ResourceStr) {
    Column() {
      Text(title)
        .fontSize(30)
        .fontWeight(700)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height(160)
    .backgroundImage($r('app.media.img_settings_bg'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .padding({
      top: this.getUIContext().px2vp(AppStorage.get<number>('topHeight')),
      left: 16
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  settingsListItem(name: ResourceStr) {
    Row() {
      Text(name)
        .fontSize(18)
        .fontColor($r('sys.color.black'))
      Image($r('app.media.ic_right'))
        .width(12)
        .height(12)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(60)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  personalization() {
    // todo:multi-languages-support/status-change/font-change
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBuilder(getGreeting(this.hour));
        List() {
          ListItem() {
            this.settingsListItem($r('app.string.app_information'))
          }
          .onClick(() => {
            this.pageInfos.pushPathByName('AppInformation', null);
          })

          ListItem() {
            this.settingsListItem($r('app.string.operation_guide'))
          }
          .onClick(() => {
            this.pageInfos.pushPathByName('Guide', null);
          })
        }
        .padding(12)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('rgb(241, 243, 245)')
        .zIndex(10)
        .position({ y: 148 })
        .borderRadius({ topLeft: 12, topRight: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgb(241, 243, 245)')
    }
    .hideTitleBar(true)
  }
}

function getGreeting(hour: number): ResourceStr {
  if (hour < 11) {
    return $r('app.string.good_morning');
  } else if (hour < 13) {
    return $r('app.string.good_midday');
  } else if (hour < 18) {
    return $r('app.string.good_afternoon');
  } else {
    return $r('app.string.good_evening');
  }
}