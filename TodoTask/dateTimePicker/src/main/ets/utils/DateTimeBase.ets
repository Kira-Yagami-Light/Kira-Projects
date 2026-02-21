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

import { Constants } from '../common/Constants';

export class DateTimeBase {
  public hourRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_HOUR, '时');
  }

  public minutesRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_MINUTE, '分');
  }

  public secondsRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_MINUTE, '秒');
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
    if ((year % Constants.FOUR_HUNDRED === Number(Constants.ZERO)) ||
      (year % Constants.FOUR === Number(Constants.ZERO) && year % Constants.ONE_HUNDRED !== Number(Constants.ZERO))) {
      return true;
    }
    return false;
  }
}
