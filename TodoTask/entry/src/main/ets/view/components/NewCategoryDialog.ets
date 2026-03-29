import TaskCategoryData from '../../model/CategoryModel';
import {UIConstants} from '../../common/constants';

@CustomDialog
export default struct NewCategoryDialog {
  @State cateName: string = '';
  @State cateColor: string = UIConstants.CATEGORY_COLORS[0];
  controller: CustomDialogController;
  confirm: (newCategory: TaskCategoryData) => void = () => {};

  aboutToAppear() {
    this.cateName = '';
    this.cateColor = UIConstants.CATEGORY_COLORS[0];
  }

  @Builder
  ColorItem(color: string) {
    Stack() {
      Circle()
        .width(this.cateColor === color ? 36 : 30)
        .height(this.cateColor === color ? 36 : 30)
        .fill(color)
        .onClick(() => {
          this.cateColor = color;
        })

      // Outer ring halo
      if (this.cateColor === color) {
        Circle()
          .width(42)
          .height(42)
          .fill(Color.Transparent)
          .stroke(color)
          .strokeWidth(2)
      }
    }
    .width(48)
    .height(48)
    .alignContent(Alignment.Center)
  }

  build() {
    Column() {
      Text($r('app.string.add_new_category'))
        .margin({ top: 20, bottom: 12 })
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: $r('app.string.category_name'), text: this.cateName })
        .onChange((value) => {
          this.cateName = value;
        })
        .margin({ bottom: 20 })
        .width('90%')

      Text($r('app.string.choose_category_color'))
        .fontSize(14)
        .fontColor(Color.Gray)
        .alignSelf(ItemAlign.Start)
        .margin({ left: '5%', bottom: 8 })

      // Color selection list
      Scroll() {
        Row() {
          ForEach(UIConstants.CATEGORY_COLORS, (color: string) => {
            this.ColorItem(color);
          })
        }
        .padding({ left: 10, right: 10 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 24 })

      Row() {
        Button($r('app.string.cancel'))
          .backgroundColor(Color.Transparent)
          .fontColor('#666666')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Divider()
          .vertical(true)
          .height(24)
          .strokeWidth(1)
          .color('#eeeeee')

        Button($r('app.string.confirm'))
          .fontColor('#254ff7')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onClick(() => {
            if (this.cateName.trim() === '') {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.category_name_not_null') });
              return;
            }
            let newCate = new TaskCategoryData();
            newCate.name = this.cateName;
            newCate.color = this.cateColor;
            this.confirm(newCate);
            this.controller.close();
          })
      }
      .width('100%')
      .border({ width: { top: 1 }, color: '#f5f5f5' })
      .height(56)
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(24)
  }
}