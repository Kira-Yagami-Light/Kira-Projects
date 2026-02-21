/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import { ComponentContent, promptAction } from '@kit.ArkUI';
import { DateTimePickerParam, TimeFormat } from '../interface/DateTimePickerInterface';
import { DateTimePicker } from '../pages/DateTimePicker';
import { Constants } from '../common/Constants';

interface DateTimePickerDialogConfig {
  context: UIContext
  content: ComponentContent<ESObject>
}

interface DateTimePickerDialogParam {
  txt: ResourceStr
  node: number
  param: DateTimePickerParam
}

let mapContext: Map<number, DateTimePickerDialogConfig> = new Map();

@Builder
function dateTimePickerDialogBuilder(param: DateTimePickerDialogParam) {
  DateTimePickerDialogComponent({
    node: param.node,
    param: param.param,
    txt: param.txt
  })
}

@Extend(Button)
function buttonStyles() {
  .width(Constants.HALF_WIDTH)
  .layoutWeight(Constants.LAYOUT_WEIGHT)
  .fontColor(Constants.FONT_COLOR)
  .backgroundColor(Color.Transparent)
}

@Component
struct DateTimePickerDialogComponent {
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
        .fontSize(Constants.BIG_FONT)
        .fontWeight(FontWeight.Bold)
        .margin({ top: Constants.TOP_MARGIN, bottom: Constants.BOTTOM_MARGIN })

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
        .height(Constants.CENTER_HEIGHT)
        .width(Constants.CENTER_WIDTH)


      Row({ space: Constants.SPACE }) {
        Button($r('app.string.cancel'))
          .buttonStyles()
          .fontSize(Constants.SMALL_FONT)
          .fontColor($r('sys.color.black'))
          .onClick(() => {
            this.closeDialog();
          })
        Divider()
          .vertical(true)
          .height(Constants.DIVIDER_HEIGHT)
        Button($r('app.string.confirm'))
          .buttonStyles()
          .fontSize(Constants.SMALL_FONT)
          .fontColor(Constants.BLUE_COLOR)
          .onClick(() => {
            this.param.data.resultCb(this.selectDate);
            this.closeDialog();
          })
      }
      .width(Constants.FULL_WIDTH)
      .height(Constants.BUTTON_HEIGHT)
      .margin({ top: Constants.TOP_MARGIN_TWO })
      .padding(Constants.PADDING)
    }
    .width(Constants.DIALOG_WIDTH)
    .height(Constants.DIALOG_HEIGHT)
    .backgroundColor(this.param.style?.backgroundColor ? this.param.style.backgroundColor : Color.White)
    .borderRadius(Constants.RADIUS) // 设置圆角边框
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