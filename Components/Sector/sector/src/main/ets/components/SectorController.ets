import { LineState, TouchLocation, Geometry } from '../model/SectorModel';
import { normalizeAngle, angleDiff, calculateRotation, isAngleBetween, getBisector } from '../util/Calculate';
import { SectorRenderer } from '../canvas/Renderer';

@Component
export struct SectorController {
  @Prop centerX: number = 185;
  @Prop centerY: number = 300;
  @Prop radius: number = 150;
  onChange?: (azimuth: number, angle: number) => void;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private renderer: SectorRenderer | null = null;
  @State lineOne: LineState = {
    angle: 0,
    tempAngle: 0,
    x: 0,
    y: 0
  };
  @State lineTwo: LineState = {
    angle: Math.PI / 2,
    tempAngle: 0,
    x: 0,
    y: 0
  };
  @State azimuth: number = 135;
  @State includedAngle: number = 90;
  @State touchLoc: TouchLocation = TouchLocation.OUTSIDE;
  private startX: number = 0;
  private startY: number = 0;

  aboutToAppear() {
    this.updatePositions();
    this.renderer = new SectorRenderer(this.context, this.centerX, this.centerY, this.radius);
  }

  private updatePositions() {
    this.lineOne.x = this.centerX + this.radius * Math.cos(this.lineOne.angle);
    this.lineOne.y = this.centerY + this.radius * Math.sin(this.lineOne.angle);
    this.lineTwo.x = this.centerX + this.radius * Math.cos(this.lineTwo.angle);
    this.lineTwo.y = this.centerY + this.radius * Math.sin(this.lineTwo.angle);
  }

  private judgeLocation(x: number, y: number): TouchLocation {
    const distSq = x * x + y * y;
    const dist = Math.sqrt(distSq);
    if (dist > this.radius) {
      return TouchLocation.OUTSIDE;
    }
    let touchAngle = Math.atan2(y, x);
    if (touchAngle < 0) {
      touchAngle += 2 * Math.PI;
    }

    const a1 = normalizeAngle(this.lineOne.angle);
    const a2 = normalizeAngle(this.lineTwo.angle);

    // 边线判定
    if (Math.abs(angleDiff(touchAngle, a1)) < Geometry.THRESHOLD_ANGLE) {
      return TouchLocation.LINE_ONE;
    }
    if (Math.abs(angleDiff(touchAngle, a2)) < Geometry.THRESHOLD_ANGLE) {
      return TouchLocation.LINE_TWO;
    }

    // 扇形内部（包括圆心附近）
    if (isAngleBetween(touchAngle, a1, a2) || dist < this.radius * 0.6) {
      return TouchLocation.SECTOR;
    }
    return TouchLocation.OUTSIDE;
  }

  private updateData() {
    const a1 = normalizeAngle(this.lineOne.angle);
    const a2 = normalizeAngle(this.lineTwo.angle);
    const diff = Math.abs(a1 - a2);
    const sweep = diff > Math.PI ? 2 * Math.PI - diff : diff;

    this.includedAngle = Number((sweep / (2 * Math.PI) * 360).toFixed(2));
    let bisector = getBisector(a1, a2);
    this.azimuth = Number((normalizeAngle(bisector + Math.PI / 2) / (2 * Math.PI) * 360).toFixed(2));
    this.onChange?.(this.azimuth, this.includedAngle);
  }

  private draw() {
    if (!this.renderer) {
      return;
    }
    this.renderer.clear();
    this.renderer.drawSector(this.lineOne, this.lineTwo);
    this.renderer.drawCenterPoint();
    this.renderer.drawArrow(this.lineOne, this.lineTwo);
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.renderer = new SectorRenderer(this.context, this.centerX, this.centerY, this.radius);
          this.draw();
        })
        .onAreaChange(() => this.draw())

      Row() {
        Column() {
          Text('方位角')
            .fontSize(18)
            .margin(5)
          Text(`${this.azimuth}°`)
            .fontSize(14)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height('70%')
          .color('#c0c0c0')
          .opacity(0.6)

        Column() {
          Text('夹角')
            .fontSize(18)
            .margin(5)
          Text(`${this.includedAngle}°`)
            .fontSize(14)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('60%')
      .height('10%')
      .borderRadius(10)
      .shadow({
        radius: 12,
        color: '#c0c0c0',
        offsetX: 5,
        offsetY: 10
      })
      .backgroundColor('#FFFFFF')
      .offset({ top: -this.centerY })
    }
    .width('100%')
    .height('100%')
    .gesture(
      PanGesture()
        .onActionStart((e) => {
          const t = e.fingerList[0];
          this.startX = t.localX;
          this.startY = t.localY;
          this.lineOne.tempAngle = this.lineOne.angle;
          this.lineTwo.tempAngle = this.lineTwo.angle;

          this.touchLoc = this.judgeLocation(this.startX - this.centerX, this.startY - this.centerY);
        })
        .onActionUpdate((e) => {
          if (this.touchLoc === TouchLocation.OUTSIDE) {
            return;
          }
          const cx = this.startX + e.offsetX;
          const cy = this.startY + e.offsetY;
          const rot = calculateRotation(this.centerX, this.centerY, this.startX, this.startY, cx, cy);

          switch (this.touchLoc) {
            case TouchLocation.LINE_ONE:
              this.lineOne.angle = normalizeAngle(this.lineOne.tempAngle + rot);
              this.updatePositions();
              break;
            case TouchLocation.LINE_TWO:
              this.lineTwo.angle = normalizeAngle(this.lineTwo.tempAngle + rot);
              this.updatePositions();
              break;
            case TouchLocation.SECTOR:
              this.lineOne.angle = normalizeAngle(this.lineOne.tempAngle + rot);
              this.lineTwo.angle = normalizeAngle(this.lineTwo.tempAngle + rot);
              this.updatePositions();
              break;
          }

          this.draw();
          this.updateData();
        })
        .onActionEnd(() => {
          this.touchLoc = TouchLocation.OUTSIDE;
        })
    )
  }
}