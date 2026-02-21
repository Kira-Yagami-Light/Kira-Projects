import TaskCategoryData from '../common/TaskCategoryData';
import CategoryTable from '../database/CategoryTable';
import NewCategoryDialog from './NewCategoryDialog';

@CustomDialog
export default struct CategoryListDialog {
  @Link categoryList: TaskCategoryData[];
  @Link categoryTable: CategoryTable;
  controller: CustomDialogController;
  confirm: (selectedCategory: TaskCategoryData) => void = () => {};
  safeDeleteCheckID: (id: number) => boolean = (id) => true;
  openNewCategoryDialog: () => void = () => {};
  queryCategory: (id: number) => void = (id) => {};

  newCategoryController: CustomDialogController = new CustomDialogController({
    builder: NewCategoryDialog({
      confirm: (newCate: TaskCategoryData) => {
        this.saveNewCategory(newCate);
      }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  saveNewCategory(newCate: TaskCategoryData) {
    this.categoryTable.insertData(newCate, (id: number) => {
      if (id > 0) {
        newCate.id = id;

        this.categoryList = [...this.categoryList, newCate];

        this.confirm(newCate);
        this.controller.close();
      }
    });
  }

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

      Blank()

      Image($r('app.media.ic_back'))
        .width(12)
        .height(12)
        .opacity(0.3)
    }
    .width('100%')
    .height(56)
    .padding({ left: 10, right: 10 })
    .onClick(() => {
      this.confirm(item);
      this.controller.close();
    })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.select_category_type'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#181818')

        Button() {
          Row() {
            Image($r('app.media.ic_back'))
              .width(16)
              .height(16)
              .fillColor('#254ff7')
            Text($r('app.string.new'))
              .fontSize(14)
              .fontColor('#254ff7')
              .margin({ left: 4 })
          }
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.newCategoryController.open();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      List() {
        ForEach(this.categoryList, (item: TaskCategoryData) => {
          ListItem() {
            this.categoryItem(item)
          }
          .border({ width: { bottom: 0.5 }, color: '#F2F2F2' })
        }, (item: TaskCategoryData) => `category-list-${item.id}`)
      }
      .width('100%')
      .height(this.categoryList.length > 5 ? 280 : (this.categoryList.length * 56))
      .edgeEffect(EdgeEffect.Spring)

      Button($r('app.string.cancel'))
        .width('100%')
        .height(45)
        .margin({ top: 20 })
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
