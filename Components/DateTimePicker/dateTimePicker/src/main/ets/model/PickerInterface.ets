export enum DateIndex {
  YEAR = 0,
  MONTH = 1,
  DAY = 2,
  HOURS = 3,
  MINUTES = 4,
  SECOND = 5
}

export enum TimeFormat {
  NONE = 0,
  HOUR = 1,
  MINUTES = 2,
  SECOND = 3
}

export interface DateTimePickerOption {
  isLoop?: boolean;
  timeFormat?: TimeFormat;
}

export interface DateTimePickerStyle {
  backgroundColor?: ResourceColor;
  borderColor?: ResourceColor | EdgeColors | LocalizedEdgeColors;
  borderWidth?: Length | EdgeWidths | LocalizedEdgeWidths;
  borderRadius?: Length | BorderRadiuses | LocalizedBorderRadiuses;
  margin?: Margin | Length | LocalizedMargin;
}

export interface DateTimePickerData {
  startYear: number;
  endYear: number;
  selectedDate?: Date;
  resultCb: Callback<Date>;
}

export interface DateTimePickerParam {
  data: DateTimePickerData;
  option?: DateTimePickerOption;
  style?: DateTimePickerStyle;
}