
import { Constants } from '../common/Constants';
import {
  DateIndex,
  DateTimePickerData,
  DateTimePickerOption,
  DateTimePickerParam,
  DateTimePickerStyle,
  TimeFormat
} from '../interface/DateTimePickerInterface';
import { DATE_TIME_RANGE } from '../utils/DateTimeRange';

function isVisibility(dateIndex: DateIndex, timeFormat?: TimeFormat): Visibility {
  let format: DateIndex[] = [DateIndex.DAY, DateIndex.HOURS, DateIndex.MINUTES, DateIndex.SECOND];
  return (dateIndex <= format[timeFormat ?? TimeFormat.MINUTES]) ? Visibility.Visible : Visibility.None;
}

@Observed
class PickerClass {
  @Track range: string[] = []
  @Track selected: number = Constants.ZERO
  @Track dateIndex: DateIndex = DateIndex.YEAR
  @Track option?: DateTimePickerOption
  callback = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
  }
}

@Builder
function customPicker(picker: PickerClass) {
  TextPicker({ range: picker.range, selected: picker.selected })
    .layoutWeight(Constants.LAYOUT_WEIGHT)
    .canLoop(picker.option?.isLoop ?? false)
    .visibility(isVisibility(picker.dateIndex, picker.option?.timeFormat))
    .onChange((value: string | string[], index: number | number[]) => {
      picker.callback(picker.dateIndex, value, index)
    })
}

@Builder
export function dateTimePickerBuilder(param: DateTimePickerParam) {
  DateTimePicker({
    data: param.data,
    option: param.option,
    style: param.style
  })
}

@Component
export struct DateTimePicker {
  @Prop @Require data: DateTimePickerData;
  @Prop @Watch('onChangedOption') option: DateTimePickerOption | undefined;
  @Prop style: DateTimePickerStyle | undefined;
  @State @Watch('onChangedSelectDate') selectDate: Date = new Date();
  @State yearRange: string[] = [];
  @State monthRange: string[] = [];
  @State dayRange: string[] = [];
  @State currentYear: number = this.selectDate.getFullYear();
  @State currentMonth: number = this.selectDate.getMonth() + Constants.ONE;
  @State currentDay: number = this.selectDate.getDate();
  @State monthIndex: number = this.selectDate.getMonth();
  @State dayIndex: number = this.selectDate.getDate() - Constants.ONE;

  aboutToAppear(): void {
    DATE_TIME_RANGE.setYearRange(this.data.startYear, this.data.endYear);
    // 如果传入了selectedDate，使用它；否则使用当前时间
    this.selectDate = this.data.selectedDate ?? this.selectDate;

    // 🔧 修复：重新计算基于selectedDate的年月日
    this.currentYear = this.selectDate.getFullYear();
    this.currentMonth = this.selectDate.getMonth() + Constants.ONE;
    this.currentDay = this.selectDate.getDate();
    this.monthIndex = this.selectDate.getMonth();
    this.dayIndex = this.selectDate.getDate() - Constants.ONE;

    this.onChangedOption();
  }

  onChangedSelectDate() {
    this.data.resultCb(this.selectDate);
  }

  onChangedOption() {
    this.yearRange = DATE_TIME_RANGE.yearRange();
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);

    this.monthIndex = this.currentMonth - Constants.ONE;
    this.dayIndex = this.currentDay - Constants.ONE;
  }

  updateSelectedDate = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
    if (Array.isArray(value) || Array.isArray(index)) {
      return;
    }

    switch (dateIndex) {
      case DateIndex.YEAR:
        this.dealSelectedYear(value, index);
        break;
      case DateIndex.MONTH:
        this.dealSelectedMonth(value, index);
        break;
      case DateIndex.DAY:
        this.dealSelectedDay(value, index);
        break;
      default:
        this.dealSelectedTime(dateIndex, value, index);
        break;
    }
  }

  dealSelectedYear(value: string, index: number) {
    this.currentYear = Number(value.slice(Constants.ZERO, -Constants.ONE));
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedMonth(value: string, index: number) {
    this.currentMonth = Number(value.slice(Constants.ZERO, -Constants.ONE));
    this.monthIndex = index;
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedDay(value: string, index: number) {
    this.currentDay = index + Constants.ONE;
    this.dayIndex = index;
    this.updateDateTime();
  }

  dealSelectedTime(dateIndex: DateIndex, value: string, index: number) {
    switch (dateIndex) {
      case DateIndex.HOURS:
        this.selectDate.setHours(index);
        break;
      case DateIndex.MINUTES:
        this.selectDate.setMinutes(index);
        break;
      case DateIndex.SECOND:
        this.selectDate.setSeconds(index);
        break;
      default:
        break;
    }
  }

  updateDateTime() {
    this.updateSolarDate();
  }

  updateSolarDate() {
    this.selectDate = new Date(
      this.currentYear,
      this.currentMonth - Constants.ONE,
      this.currentDay,
      this.selectDate.getHours(),
      this.selectDate.getMinutes(),
      this.selectDate.getSeconds()
    );
  }

  build() {
    Row() {
      customPicker({
        // 年
        range: this.yearRange,
        selected: this.currentYear - DATE_TIME_RANGE.getStartYear(),
        dateIndex: DateIndex.YEAR,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 月
        range: this.monthRange,
        selected: this.monthIndex,
        dateIndex: DateIndex.MONTH,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 日
        range: this.dayRange,
        selected: this.dayIndex,
        dateIndex: DateIndex.DAY,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 时
        range: DATE_TIME_RANGE.hourRange(),
        selected: this.selectDate.getHours(),
        dateIndex: DateIndex.HOURS,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 分
        range: DATE_TIME_RANGE.minutesRange(),
        selected: this.selectDate.getMinutes(),
        dateIndex: DateIndex.MINUTES,
        callback: this.updateSelectedDate,
        option: this.option
      })
      customPicker({
        // 秒
        range: DATE_TIME_RANGE.secondsRange(),
        selected: this.selectDate.getSeconds(),
        dateIndex: DateIndex.SECOND,
        callback: this.updateSelectedDate,
        option: this.option
      })
    }
    .backgroundColor(this.style?.backgroundColor ? this.style.backgroundColor : Color.Transparent)
    .borderColor(this.style?.borderColor ? this.style.borderColor : Color.Transparent)
    .borderWidth(this.style?.borderWidth ? this.style.borderWidth : Constants.ZERO)
    .borderRadius(this.style?.borderRadius ? this.style.borderRadius : Constants.ZERO)
    .margin(this.style?.margin ? this.style.margin : Constants.ZERO)
  }
}