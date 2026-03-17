import { ComponentContent, promptAction } from '@kit.ArkUI';
import { DateTimePickerParam, TimeFormat } from '../model/PickerInterface';
import { DateTimePicker } from '../pages/DateTimePicker';

interface DateTimePickerDialogConfig {
  context: UIContext;
  content: ComponentContent<ESObject>;
}

interface DateTimePickerDialogParam {
  txt: ResourceStr;
  node: number;
  param: DateTimePickerParam;
}

let mapContext: Map<number, DateTimePickerDialogConfig> = new Map();

@Builder
function dateTimePickerDialogBuilder(param: DateTimePickerDialogParam) {
  DateTimePickerDialog({
    node: param.node,
    param: param.param,
    txt: param.txt
  })
}

@Extend(Button)
function buttonStyles() {
  .width('50%')
  .layoutWeight(1)
  .fontColor("#FF007DFF")
  .backgroundColor(Color.Transparent)
}

@Component
struct DateTimePickerDialog {
  @Prop txt: ResourceStr;
  @Prop node: number;
  @Prop param: DateTimePickerParam;
  @State selectDate: Date = this.param.data.selectedDate!
  private timeFormat: TimeFormat = TimeFormat.MINUTES;
  updateSelectData = (date: Date) => {
    this.selectDate = date;
  }

  aboutToAppear(): void {
    this.timeFormat = this.param.option?.timeFormat ?? TimeFormat.MINUTES;
  }

  closeDialog() {
    if (mapContext.has(this.node)) {
      let config = mapContext.get(this.node);
      config?.context.getPromptAction().closeCustomDialog(config.content);
      mapContext.delete(this.node);
    }
  }

  build() {
    Column() {
      Text(this.txt)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 16 })

      DateTimePicker({
        data: {
          startYear: this.param.data.startYear,
          endYear: this.param.data.endYear,
          selectedDate: this.param.data.selectedDate,
          resultCb: this.updateSelectData,
        },
        option: {
          timeFormat: TimeFormat.MINUTES
        },
        style: undefined
      })
        .height(200)
        .width('85%')


      Row({ space: 8 }) {
        Button($r('app.string.cancel'))
          .buttonStyles()
          .fontSize(16)
          .fontColor($r('sys.color.black'))
          .onClick(() => {
            this.closeDialog();
          })
        Divider()
          .vertical(true)
          .height(32)
        Button($r('app.string.confirm'))
          .buttonStyles()
          .fontSize(16)
          .fontColor('rgb(10, 89, 247)')
          .onClick(() => {
            this.param.data.resultCb(this.selectDate);
            this.closeDialog();
          })
      }
      .width('100%')
      .height('20%')
      .margin({ top: 12 })
      .padding(8)
    }
    .width('92%')
    .height('42%')
    .backgroundColor(this.param.style?.backgroundColor ? this.param.style.backgroundColor : Color.White)
    .borderRadius(24)
    .margin({ top: 80 })
  }
}

export function dateTimePickerDialog(uiContext: UIContext, param: DateTimePickerParam, txt: ResourceStr,
  dialogOptions?: promptAction.BaseDialogOptions) {
  let now: number = Date.now();
  let contentNode = new ComponentContent(uiContext, wrapBuilder(dateTimePickerDialogBuilder), {
    node: now,
    param: param,
    txt: txt
  } as DateTimePickerDialogParam);
  uiContext.getPromptAction().openCustomDialog(contentNode, dialogOptions);
  mapContext.set(now, { context: uiContext, content: contentNode });
}