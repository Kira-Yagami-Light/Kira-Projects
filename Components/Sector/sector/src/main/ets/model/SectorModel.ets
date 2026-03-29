// 边线状态
export interface LineState {
  angle: number;
  tempAngle: number;
  x: number;
  y: number;
}

// 触摸位置枚举
export enum TouchLocation {
  OUTSIDE = 0,
  LINE_ONE = 1,
  LINE_TWO = 2,
  SECTOR = 3,
  ARROW = 4
}

// 几何常量
export class Geometry {
  static readonly TWO_PI: number = 2 * Math.PI;
  static readonly THRESHOLD_ANGLE: number = 0.15;
  static readonly RAD_TO_DEG: number = 180 / Math.PI;
  static readonly DEFAULT_RADIUS: number = 150;
}