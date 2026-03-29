import TaskCategoryData from '../../model/CategoryModel';
import { CategoryRepository } from '../../data/repository/CategoryRepository';

@CustomDialog
export default struct CategoryListDialog {
  @Link categoryList: TaskCategoryData[];
  categoryRepository!: CategoryRepository;
  controller!: CustomDialogController;
  confirm: (selectedCategory: TaskCategoryData | null) => void = () => {
  };

  @Builder
  categoryItem(item: TaskCategoryData) {
    Row() {
      Circle()
        .width(14)
        .height(14)
        .fill(item.color)

      Text(item.name)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 15 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 10, right: 10 })
    .onClick(() => {
      this.controller.close();
      this.confirm(item);
    })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.select_category_type'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#181818')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 20 })

      List() {
        ForEach(this.categoryList, (item: TaskCategoryData) => {
          ListItem() {
            this.categoryItem(item);
          }
          .border({ width: { bottom: 0.5 }, color: '#F2F2F2' })
        }, (item: TaskCategoryData) => `category-list-${item.id}`)
      }
      .width('100%')
      .height(this.categoryList.length > 5 ? 280 : (this.categoryList.length * 56))
      .edgeEffect(EdgeEffect.Spring)

      Button($r('app.string.display_all'))
        .width('100%')
        .height(45)
        .margin({ top: 12 })
        .backgroundColor('#f0f5ff')
        .fontColor('#0A59F7')
        .borderRadius(12)
        .onClick(() => {
          this.controller.close();
          this.confirm(null);
        })

      Button($r('app.string.cancel'))
        .width('100%')
        .height(45)
        .margin({ top: 8 })
        .backgroundColor($r('sys.color.icon_on_primary'))
        .fontColor('#666666')
        .borderRadius(12)
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('95%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(24)
  }
}