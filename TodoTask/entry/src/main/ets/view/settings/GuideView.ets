class guideRes {
  id: ResourceStr = '';
  imgPath: string = '';

  constructor(id: string, path: string) {
    this.id = id;
    this.imgPath = path;
  }
}

class dataSource implements IDataSource {
  resource: guideRes[] = [];
  private listener: DataChangeListener | null = null;

  constructor(list: guideRes[]) {
    this.resource = list;
  }

  unregisterDataChangeListener(): void {
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listener = listener;
  }

  getData(index: number) {
    return this.resource[index];
  }

  totalCount(): number {
    return this.resource.length;
  }
}

interface GuideStep {
  id: ResourceStr;
  imgPath: string;
}

@Builder
export function guidePageBuilder() {
  Guide();
}

@Component
struct Guide {
  private guideSteps: dataSource = new dataSource([
    { id: $r('app.string.guide1'), imgPath: 'guide/guide1.png' },
    { id: $r('app.string.guide2'), imgPath: 'guide/guide2.png' },
    { id: $r('app.string.guide3'), imgPath: 'guide/guide3.png' },
    { id: $r('app.string.guide4'), imgPath: 'guide/guide4.png' },
    { id: $r('app.string.guide5'), imgPath: 'guide/guide5.png' }
  ] as GuideStep[]);
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  LongText(value: ResourceStr) {
    Text(value)
      .fontSize(24)
      .margin({ bottom: 20 })
      .textAlign(TextAlign.Center)
  }

  @Builder
  guidePage(guideItem: guideRes, index: number) {
    Column() {
      Column() {
        this.LongText(guideItem.id);
        Image($rawfile(guideItem.imgPath))
          .height((index === 0 ? '30%' : '70%'))
          .borderRadius((index === 0  ? 16 : 0))
      }
      if (index === 4) {
        Button($r('app.string.start'))
          .width('70%')
          .margin({ top: 16 })
          .onClick(() => {
            this.pageInfos.pop();
          })
      }
    }
    .justifyContent(FlexAlign.Start)
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Swiper() {
            LazyForEach(this.guideSteps, (guideItem: guideRes, id) => {
              this.guidePage(guideItem, id);
            })
          }
          .width('100%')
          .height('90%')
          .cachedCount(2)
          .index(0)
          .loop(false)
          .indicator(
            new DotIndicator()
              .bottom(24)
          )
        }
        .width('100%')
      }
      .height('100%')
      .backgroundColor('#f1f2f3')
      .padding({
        top: this.getUIContext().px2vp(AppStorage.get<number>('topHeight')),
        bottom: this.getUIContext().px2vp(AppStorage.get<number>('bottomHeight'))
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return true;
    })
  }
}