// 社区页
import { MOMENT_LIST } from '../constants/MusicConstants';
import { MomentListType } from '../models/Music';
import AVPlayerManager from '../utils/AVPlayerManager';

// 下拉刷新状态枚举
enum PullRefreshState {
  IDLE, // 静止
  PULLING, // 下拉中（未达到触发阈值）
  READY, // 已达到触发阈值，可松手
  REFRESHING, // 刷新中
  SUCCESS // 刷新成功
}

// 上拉加载状态枚举
enum LoadMoreState {
  IDLE, // 静止
  LOADING, // 加载中
  NO_MORE // 没有更多数据
}

// 下拉触发阈值
const PULL_THRESHOLD: number = 70;
// 下拉最大拉伸距离
const PULL_MAX_DISTANCE: number = 110;
// 顶部刷新指示区最大高度
const REFRESH_BAR_HEIGHT: number = 60;
// 上拉加载条数
const PAGE_SIZE: number = 3;

@Entry
@Component
struct Community {
  @State displayList: MomentListType[] = MOMENT_LIST.slice();
  @State refreshState: PullRefreshState = PullRefreshState.IDLE;
  @State loadMoreState: LoadMoreState = LoadMoreState.IDLE;
  @State refreshBarHeight: number = 0;
  @State pullOffset: number = 0;
  @State spinAngle: number = 0;
  private spinTimer: number = -1;
  private touchStartY: number = 0;
  private isAtTop: boolean = true;
  private isLoadingMore: boolean = false;
  // 模拟数据池
  private dataPool: MomentListType[] = [...MOMENT_LIST, ...MOMENT_LIST, ...MOMENT_LIST];
  private loadedIndex: number = MOMENT_LIST.length;

  // 旋转动画控制
  private startSpinAnimation() {
    if (this.spinTimer !== -1) {
      return;
    }
    this.spinTimer = setInterval(() => {
      this.spinAngle = (this.spinAngle + 6) % 360;
    }, 16);
  }

  private stopSpinAnimation() {
    if (this.spinTimer !== -1) {
      clearInterval(this.spinTimer);
      this.spinTimer = -1;
    }
    this.spinAngle = 0;
  }

  // 下拉刷新
  private async doRefresh() {
    this.refreshState = PullRefreshState.REFRESHING;
    this.refreshBarHeight = REFRESH_BAR_HEIGHT;
    this.pullOffset = 0;
    this.startSpinAnimation();

    // 模拟网络请求
    await new Promise<void>((resolve) => setTimeout(resolve, 1500));

    // 打乱顺序模拟刷新内容
    this.displayList = MOMENT_LIST.slice().sort(() => Math.random() - 0.5);
    this.loadedIndex = MOMENT_LIST.length;
    this.loadMoreState = LoadMoreState.IDLE;
    this.stopSpinAnimation();
    this.refreshState = PullRefreshState.SUCCESS;

    // 成功提示停留 800ms 后收起
    await new Promise<void>((resolve) => setTimeout(resolve, 800));
    this.getUIContext()?.animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
      this.refreshBarHeight = 0;
    });
    this.refreshState = PullRefreshState.IDLE;
  }

  // 上拉加载
  private async doLoadMore() {
    if (this.isLoadingMore || this.loadMoreState === LoadMoreState.NO_MORE) {
      return;
    }
    this.isLoadingMore = true;
    this.loadMoreState = LoadMoreState.LOADING;
    this.startSpinAnimation();

    // 模拟网络请求
    await new Promise<void>((resolve) => setTimeout(resolve, 1200));

    const end = this.loadedIndex + PAGE_SIZE;
    const newItems = this.dataPool.slice(this.loadedIndex, end);

    if (newItems.length === 0) {
      this.loadMoreState = LoadMoreState.NO_MORE;
    } else {
      this.displayList = [...this.displayList, ...newItems];
      this.loadedIndex = end;
      this.loadMoreState = end >= this.dataPool.length ? LoadMoreState.NO_MORE : LoadMoreState.IDLE;
    }
    this.stopSpinAnimation();
    this.isLoadingMore = false;
  }

  // 触摸手势处理
  private handleTouchStart(y: number) {
    this.touchStartY = y;
  }

  private handleTouchMove(y: number) {
    if (!this.isAtTop || this.refreshState === PullRefreshState.REFRESHING) {
      return;
    }
    const delta = y - this.touchStartY;
    if (delta <= 0) {
      return;
    }
    // 阻尼公式
    const damped = PULL_MAX_DISTANCE * (1 - Math.exp(-delta / 160));
    this.pullOffset = damped;
    this.refreshBarHeight = damped * (REFRESH_BAR_HEIGHT / PULL_MAX_DISTANCE);
    this.refreshState = damped >= PULL_THRESHOLD ? PullRefreshState.READY : PullRefreshState.PULLING;
  }

  private handleTouchEnd() {
    if (this.refreshState === PullRefreshState.READY) {
      this.doRefresh();
    } else if (this.refreshState === PullRefreshState.PULLING) {
      // 未达阈值，回弹复位
      this.getUIContext()?.animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.pullOffset = 0;
        this.refreshBarHeight = 0;
      });
      this.refreshState = PullRefreshState.IDLE;
    }
  }

  // 下拉刷新指示区
  @Builder
  refreshIndicator() {
    Row() {
      if (this.refreshState === PullRefreshState.PULLING) {
        Image($r('app.media.ic_arrow_down'))
          .width(18)
          .height(18)
          .fillColor('#888888')
        Text($r('app.string.pull_to_refresh'))
          .fontSize(13)
          .fontColor('#888888')
          .margin({ left: 8 })
      } else if (this.refreshState === PullRefreshState.READY) {
        Image($r('app.media.ic_arrow_up'))
          .width(18)
          .height(18)
          .fillColor($r('app.color.primary_light'))
        Text($r('app.string.refresh_now'))
          .fontSize(13)
          .fontColor($r('app.color.primary_light'))
          .margin({ left: 8 })
      } else if (this.refreshState === PullRefreshState.REFRESHING) {
        Image($r('app.media.ic_loading'))
          .width(22)
          .height(22)
          .fillColor($r('app.color.primary_light'))
          .rotate({ angle: this.spinAngle })
        Text($r('app.string.refreshing'))
          .fontSize(13)
          .fontColor('#888888')
          .margin({ left: 8 })
      } else if (this.refreshState === PullRefreshState.SUCCESS) {
        Image($r('app.media.ic_success'))
          .width(22)
          .height(22)
          .fillColor($r('app.color.primary_light'))
        Text($r('app.string.refresh_success'))
          .fontSize(13)
          .fontColor('#888888')
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .height(this.refreshBarHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .clip(true) // clip 防止溢出
    .backgroundColor('rgb(241, 243, 245)')
  }

  // 上拉加载指示区
  @Builder
  loadMoreIndicator() {
    Row() {
      if (this.loadMoreState === LoadMoreState.LOADING) {
        Image($r('app.media.ic_loading'))
          .width(18)
          .height(18)
          .fillColor('#888888')
          .rotate({ angle: this.spinAngle })
        Text($r('app.string.loading'))
          .fontSize(13)
          .fontColor('#888888')
          .margin({ left: 6 })
      } else if (this.loadMoreState === LoadMoreState.NO_MORE) {
        Text($r('app.string.touch_the_end'))
          .fontSize(13)
          .fontColor('#aaaaaa')
      } else {
        // IDLE 状态：占位，保持底部留白
        Text('')
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  avatarRow(item: MomentListType) {
    Row() {
      Row() {
        Image(item.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)

        Column() {
          Text(item.author)
            .fontSize(14)
            .fontColor($r('sys.color.black'))
          Text(item.signature)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .textAlign(TextAlign.Start)
        }
        .padding({ left: 10 })
        .alignItems(HorizontalAlign.Start)
      }

      Button($r('app.string.follow'))
        .width('20%')
        .height(32)
        .fontSize(13)
        .fontColor('rgb(10, 89, 247)')
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.display_only') });
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12 })
    .padding({ right: 10, left: 10 })
  }

  @Builder
  songCard(item: MomentListType) {
    Row() {
      Image(item.song.img)
        .width(48)
        .aspectRatio(1)
        .borderRadius(5)
        .margin({ left: 12 })
      Column({ space: 6 }) {
        Text(item.song.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.black'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.song.author)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.4)')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 12, right: 12 })

      Image($r('app.media.ic_play_album'))
        .width(32)
        .height(32)
        .fillColor($r('sys.color.black'))
        .alignSelf(ItemAlign.Center)
        .margin({ right: 12 })
    }
    .backdropBlur(71)
    .backgroundImage(item.song.img)
    .backgroundImageSize(ImageSize.Cover)
    .width('92%')
    .height(72)
    .margin({ top: 16 })
    .borderRadius(8)
    .clip(true)
    .onClick(() => {
      AVPlayerManager.singlePlay(item.song);
    })
  }

  @Builder
  icon(img: ResourceStr) {
    Image(img)
      .width(24)
      .height(24)
      .fillColor('#cccccc')
      .onTouch(() => {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.display_only') });
      })
  }

  @Builder
  operationRow() {
    Row() {
      this.icon($r('app.media.ic_love'));
      this.icon($r('app.media.ic_comment'));
      this.icon($r('app.media.ic_share'));
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 12, bottom: 4 })
  }

  // 主体列表
  @Builder
  communityList() {
    List({ space: 10 }) {
      ForEach(this.displayList, (item: MomentListType) => {
        ListItem() {
          Column() {
            this.avatarRow(item);
            Row() {
              Text(item.content)
                .fontSize(13)
                .fontColor($r('sys.color.black'))
            }
            .width('100%')
            .margin({ top: 12 })
            .padding({ right: 10, left: 10 })

            this.songCard(item);
            this.operationRow();
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding({ bottom: 4 })
        }
      })

      // 底部加载指示器
      ListItem() {
        this.loadMoreIndicator();
      }
    }
    .scrollBar(BarState.Off)
    .padding({ right: 12, left: 12 })
    .layoutWeight(1)
    .onScrollIndex((start: number) => {
      this.isAtTop = start === 0;
    })
    .onReachEnd(() => {
      this.doLoadMore();
    })
    // 列表整体随下拉偏移
    .translate({ y: this.pullOffset })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.community'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
      }
      .width('92%')
      .padding({ top: 12, bottom: 12 })

      // 刷新指示区（高度动态撑开）
      this.refreshIndicator();

      // 列表主体
      this.communityList();
    }
    .height('100%')
    .width('100%')
    .backgroundColor('rgb(241, 243, 245)')
    .padding({
      top: AppStorage.get<number>('topHeight'),
      bottom: AppStorage.get<number>('bottomHeight')
    })
    .onTouch((event: TouchEvent) => {
      const touch = event.touches[0];
      if (event.type === TouchType.Down) {
        this.handleTouchStart(touch.y);
      } else if (event.type === TouchType.Move) {
        this.handleTouchMove(touch.y);
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.handleTouchEnd();
      }
    })
  }
}

export default Community;
