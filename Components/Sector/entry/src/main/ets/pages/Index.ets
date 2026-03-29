import { SectorController } from 'sector';

@Entry
@Component
struct Index {
  @State azimuth: number = 0;
  @State angle: number = 90;

  build() {
    Column() {
      SectorController({
        centerX: 200,
        centerY: 300,
        radius: 150,
        onChange: (azimuth: number, angle: number) => {
          this.azimuth = azimuth;
          this.angle = angle;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}