import { LineState, Geometry } from '../model/SectorModel';
import { normalizeAngle, getBisector } from '../util/Calculate';

export class SectorRenderer {
  private ctx: CanvasRenderingContext2D;
  private centerX: number;
  private centerY: number;
  private radius: number;

  constructor(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number
  ) {
    this.ctx = ctx;
    this.centerX = centerX;
    this.centerY = centerY;
    this.radius = radius;
  }

  clear(): void {
    this.ctx.clearRect(0, 0, 1000, 1000);
  }

  drawSector(lineOne: LineState, lineTwo: LineState): void {
    this.ctx.beginPath();
    this.ctx.lineWidth = 3;
    const grad = this.ctx.createRadialGradient(
      this.centerX, this.centerY, 0,
      this.centerX, this.centerY, 200
    );
    grad.addColorStop(0.0, '#8000ff00');
    grad.addColorStop(1.0, '#2000ff00');
    this.ctx.strokeStyle = grad;
    this.ctx.moveTo(this.centerX, this.centerY);
    this.ctx.lineTo(lineOne.x, lineOne.y);
    this.ctx.moveTo(this.centerX, this.centerY);
    this.ctx.lineTo(lineTwo.x, lineTwo.y);
    this.ctx.stroke();

    // 填充
    this.ctx.beginPath();
    this.ctx.fillStyle = '#3000FF00';
    this.ctx.moveTo(this.centerX, this.centerY);

    const a1 = normalizeAngle(lineOne.angle);
    const a2 = normalizeAngle(lineTwo.angle);
    let diff = a1 - a2;
    if (diff < 0) {
      diff += Geometry.TWO_PI;
    }
    if (diff < Math.PI) {
      this.ctx.arc(this.centerX, this.centerY, this.radius, a2, a1, false);
    } else {
      this.ctx.arc(this.centerX, this.centerY, this.radius, a1, a2, false);
    }
    this.ctx.closePath();
    this.ctx.fill();
  }

  drawCenterPoint(): void {
    const size = 10;
    this.ctx.beginPath();
    this.ctx.lineWidth = 2;
    this.ctx.strokeStyle = '#00AA00';

    this.ctx.moveTo(this.centerX - size, this.centerY);
    this.ctx.lineTo(this.centerX + size, this.centerY);
    this.ctx.moveTo(this.centerX, this.centerY - size);
    this.ctx.lineTo(this.centerX, this.centerY + size);
    this.ctx.stroke();

    this.ctx.beginPath();
    this.ctx.arc(this.centerX, this.centerY, 3, 0, Geometry.TWO_PI, false);
    this.ctx.fillStyle = '#00AA00';
    this.ctx.fill();
  }

  drawArrow(lineOne: LineState, lineTwo: LineState): void {
    const a1 = normalizeAngle(lineOne.angle);
    const a2 = normalizeAngle(lineTwo.angle);
    const bisector = getBisector(a1, a2);

    const sx = this.centerX;
    const sy = this.centerY;
    // 固定为半径长度
    const ex = sx + this.radius * Math.cos(bisector);
    const ey = sy + this.radius * Math.sin(bisector);

    // 箭杆
    this.ctx.beginPath();
    this.ctx.lineWidth = 4;
    this.ctx.strokeStyle = '#FF4444';
    this.ctx.lineCap = 'round';
    this.ctx.moveTo(sx, sy);
    this.ctx.lineTo(ex, ey);
    this.ctx.stroke();

    // 箭头
    const headLen = 12;
    const ha = Math.PI / 6;
    const a1h = bisector + Math.PI - ha;
    const a2h = bisector + Math.PI + ha;

    this.ctx.beginPath();
    this.ctx.fillStyle = '#FF4444';
    this.ctx.moveTo(ex, ey);
    this.ctx.lineTo(ex + headLen * Math.cos(a1h), ey + headLen * Math.sin(a1h));
    this.ctx.lineTo(ex + headLen * Math.cos(a2h), ey + headLen * Math.sin(a2h));
    this.ctx.closePath();
    this.ctx.fill();
  }
}