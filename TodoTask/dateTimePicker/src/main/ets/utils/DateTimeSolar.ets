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

import { DateTimeBase } from './DateTimeBase';
import { Constants } from '../common/Constants'

export class DateTimeSolar extends DateTimeBase {
  private startYear: number = Constants.ZERO;
  private endYear: number = Constants.ZERO;

  public setYearRange(startYear: number, endYear: number) {
    let minYear = (startYear > endYear) ? endYear : startYear;
    let maxYear = (startYear > endYear) ? startYear : endYear;

    this.startYear = minYear;
    this.endYear = maxYear;
  }

  public getStartSolarYear(): number {
    return this.startYear;
  }

  public yearRange(): string[] {
    return this.range(this.startYear, this.endYear, '年');
  }

  public monthRange(): string[] {
    return this.range(Constants.ONE, Constants.CURRENT_MONTH, '月');
  }

  public dayRange(year: number, month: number): string[] {
    let mapDays = new Map<number, number>([
      [1, 31], [2, this.isLeapYear(year) ? 29 : 28], [3, 31], [4, 30], [5, 31], [6, 30],
      [7, 31], [8, 31], [9, 30], [10, 31], [11, 30], [12, 31]
    ]);

    return this.range(Constants.ONE, mapDays.get(month) ?? Constants.CURRENT_DAY, '日');
  }
}