import { DateTimeSolar } from './DateTimeSolar';

class DateTimeRangeClass {
  readonly dateTimeSolar: DateTimeSolar = new DateTimeSolar();

  public getSolar(): DateTimeSolar {
    return this.dateTimeSolar;
  }

  public getStartYear() {
    return this.dateTimeSolar.getStartSolarYear();
  }

  public setYearRange(startYear: number, endYear: number): void {
    this.dateTimeSolar.setYearRange(startYear, endYear);
  }

  public yearRange(): string[] {
    return this.dateTimeSolar.yearRange();
  }

  public monthRange(year: number): string[] {
    return this.dateTimeSolar.monthRange();
  }

  public dayRange(year: number, month: number): string[] {
    return this.dateTimeSolar.dayRange(year, month);
  }

  public hourRange(): string[] {
    return this.dateTimeSolar.hourRange();
  }

  public minutesRange(): string[] {
    return this.dateTimeSolar.minutesRange();
  }

  public secondsRange(): string[] {
    return this.dateTimeSolar.secondsRange();
  }
}

export const DATE_TIME_RANGE = new DateTimeRangeClass();