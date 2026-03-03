import { dateTimePickerDialog, TimeFormat } from '@ohos/datetimepicker';

@Entry
@Component
struct Index {
  @State startDate: Date = new Date();
  @State dueDate: Date = new Date();

  aboutToAppear() {
    this.dueDate = new Date();
    this.dueDate.setDate(this.dueDate.getDate() + 1);
    this.dueDate.setSeconds(0);
    this.startDate = new Date();
    this.startDate.setSeconds(0);
  }

  openStartDateTimePicker() {
    const uiContext = this.getUIContext();
    dateTimePickerDialog(
      uiContext,
      {
        data: {
          startYear: 2020,
          endYear: 2030,
          selectedDate: this.startDate,
          resultCb: (date: Date) => {
            this.startDate = date;
          }
        },
        option: {
          timeFormat: TimeFormat.MINUTES,
          isLoop: false
        }
      },
      '开始时间'
    );
  }

  openDueDateTimePicker() {
    const uiContext = this.getUIContext();
    dateTimePickerDialog(
      uiContext,
      {
        data: {
          startYear: 2020,
          endYear: 2030,
          selectedDate: this.dueDate,
          resultCb: (date: Date) => {
            this.dueDate = date;
          }
        },
        option: {
          timeFormat: TimeFormat.MINUTES,
          isLoop: false
        }
      },
      '结束时间'
    );
  }

  formatDateTime(date: Date): string {
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${month}月${day}日 ${hour}:${minute}`;
  }

  build() {
    Column({ space: 20 }) {
      Column({ space: 8 }) {
        Row() {
          Text('开始时间')
            .fontSize(12)
            .fontColor('#999')

          Blank()

          Row() {
            Text('📅')
              .fontSize(16)
              .margin({ right: 4 })

            Text(this.formatDateTime(this.startDate))
              .fontSize(14)
              .fontColor('#0A59F7')
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#f0f5ff')
          .borderRadius(8)
          .onClick(() => {
            this.openStartDateTimePicker();
          })
        }
        .width('100%')
      }
      .width('95%')
      .margin({top:12,bottom:12})
      Column({ space: 8 }) {
        Row() {
          Text('结束时间')
            .fontSize(12)
            .fontColor('#999')

          Blank()

          Row() {
            Text('⏰')
              .fontSize(16)
              .margin({ right: 4 })

            Text(this.formatDateTime(this.dueDate))
              .fontSize(14)
              .fontColor('#E84026')
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#fff0f0')
          .borderRadius(8)
          .onClick(() => {
            this.openDueDateTimePicker();
          })
        }
        .width('100%')
      }
      .width('95%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgb(241, 243, 245)')
  }
}
