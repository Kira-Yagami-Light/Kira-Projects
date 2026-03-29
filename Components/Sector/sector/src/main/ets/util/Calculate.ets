import { Geometry } from '../model/SectorModel';

export function normalizeAngle(angle: number): number {
  angle = angle % Geometry.TWO_PI;
  if (angle < 0) {
    angle += Geometry.TWO_PI;
  }
  return angle;
}

export function angleDiff(a: number, b: number): number {
  let diff = a - b;
  while (diff > Math.PI) {
    diff -= Geometry.TWO_PI;
  }
  while (diff < -Math.PI) {
    diff += Geometry.TWO_PI;
  }
  return diff;
}

export function calculateRotation(
  centerX: number,
  centerY: number,
  startX: number,
  startY: number,
  endX: number,
  endY: number
): number {
  const x1 = startX - centerX;
  const y1 = startY - centerY;
  const x2 = endX - centerX;
  const y2 = endY - centerY;

  const len1 = Math.sqrt(x1 * x1 + y1 * y1);
  const len2 = Math.sqrt(x2 * x2 + y2 * y2);
  if (len1 === 0 || len2 === 0) {
    return 0;
  }

  let cosValue = (x1 * x2 + y1 * y2) / (len1 * len2);
  cosValue = Math.max(-1, Math.min(1, cosValue));
  const angle = Math.acos(cosValue);
  const cross = x1 * y2 - x2 * y1;
  return cross >= 0 ? angle : -angle;
}

export function getBisector(a1: number, a2: number): number {
  const diff = Math.abs(a1 - a2);
  let bisector = diff > Math.PI ? (a1 + a2) / 2 + Math.PI : (a1 + a2) / 2;
  return normalizeAngle(bisector);
}

export function isAngleBetween(touchAngle: number, a1: number, a2: number): boolean {
  let diff = Math.abs(a1 - a2);
  if (diff > Math.PI) {
    diff = Geometry.TWO_PI - diff;
  }
  const d1 = Math.abs(angleDiff(touchAngle, a1));
  const d2 = Math.abs(angleDiff(touchAngle, a2));
  const sum = d1 + d2;
  return Math.abs(sum - diff) < 0.01 || sum < diff + 0.01;
}