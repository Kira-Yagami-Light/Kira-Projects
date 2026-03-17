import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import AVPlayerManager from '../utils/AVPlayerManager';
import AVSessionManager from '../utils/AVSessionManager';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/MainPage')
      .then(async () => {
        let win = windowStage.getMainWindowSync();
        let uiContext = win.getUIContext();
        win.setWindowLayoutFullScreen(true);
        AppStorage.setOrCreate(
          'topHeight',
          uiContext.px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
        );
        AppStorage.setOrCreate(
          'bottomHeight',
          uiContext.px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)
        );
        AVPlayerManager.uiContext = uiContext;
        await AVPlayerManager.init();
        AVSessionManager.init(this.context);
      });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
