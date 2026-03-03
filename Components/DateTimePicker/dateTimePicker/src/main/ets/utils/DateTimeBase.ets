export class DateTimeBase {
  public hourRange(): string[] {
    return this.range(0, 23, '时');
  }

  public minutesRange(): string[] {
    return this.range(0, 59, '分');
  }

  public secondsRange(): string[] {
    return this.range(0, 59, '秒');
  }

  public range(start: number, end: number, unit: string): string[] {
    let min = (start > end) ? end : start;
    let max = (start > end) ? start : end;

    let range: string[] = [];
    for (let i = min; i <= max; i++) {
      range.push(i.toString() + unit);
    }
    return range;
  }

  public isLeapYear(year: number): boolean {
    if ((year % 400 === Number(0)) ||
      (year % 4 === Number(0) && year % 100 !== Number(0))) {
      return true;
    }
    return false;
  }
}
