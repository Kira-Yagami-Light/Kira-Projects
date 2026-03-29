import { TaskListData } from '../../model/TaskModel';
import TaskCategoryData from '../../model/CategoryModel';
import { TaskRepository } from '../../data/repository/TaskRepository';
import { CategoryRepository } from '../../data/repository/CategoryRepository';
import NewCategoryDialog from '../components/NewCategoryDialog';
import { dateTimePickerDialog, TimeFormat } from '@ohos/datetimepicker';
import { DDLConstants, UIConstants } from '../../common/constants';
import inputMethod from '@ohos.inputMethod';

@Component
export default struct NewTask {
  @Link categoryList: TaskCategoryData[];
  @Link taskList: TaskListData[];
  taskRepository!: TaskRepository;
  categoryRepository!: CategoryRepository;
  onComplete!: () => void;
  @State taskName: string = '';
  @State taskDetail: string = '';
  @State startDate: Date = new Date();
  @State dueDate: Date = new Date();
  @State taskCategoryID: number = 0;
  @State taskCategoryName: string = '默认清单';
  @State taskCategoryColor: string = '#000000';
  @State tempCategories: TaskCategoryData[] = [];

  aboutToAppear() {
    this.dueDate = new Date();
    this.dueDate.setDate(this.dueDate.getDate() + 1);
    this.dueDate.setSeconds(0);

    this.startDate = new Date();
    this.startDate.setSeconds(0);

    if (this.categoryList && this.categoryList.length > 0) {
      this.taskCategoryID = this.categoryList[0].id;
      this.taskCategoryName = this.categoryList[0].name;
      this.taskCategoryColor = this.categoryList[0].color;
    }
  }

  newCategoryController: CustomDialogController = new CustomDialogController({
    builder: NewCategoryDialog({
      confirm: (newCate: TaskCategoryData) => {
        newCate.id = -Date.now();
        this.tempCategories = [...this.tempCategories, newCate];
        this.selectCategory(newCate);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  openStartDateTimePicker() {
    const uiContext = this.getUIContext();
    // 创建一个新的Date对象，确保日期选择器能正确读取
    const initialDate = new Date(
      this.startDate.getFullYear(),
      this.startDate.getMonth(),
      this.startDate.getDate(),
      this.startDate.getHours(),
      this.startDate.getMinutes(),
      0,
      0
    );

    dateTimePickerDialog(
      uiContext,
      {
        data: {
          startYear: 2020,
          endYear: 2030,
          selectedDate: initialDate,
          resultCb: (date: Date) => {
            this.startDate = new Date(date.getTime());
          }
        },
        option: {
          timeFormat: TimeFormat.MINUTES,
          isLoop: false
        }
      },
      $r('app.string.select_start_time')
    );
  }

  openDueDateTimePicker() {
    const uiContext = this.getUIContext();
    // 创建一个新的Date对象，确保日期选择器能正确读取
    const initialDate = new Date(
      this.dueDate.getFullYear(),
      this.dueDate.getMonth(),
      this.dueDate.getDate(),
      this.dueDate.getHours(),
      this.dueDate.getMinutes(),
      0,
      0
    );

    dateTimePickerDialog(
      uiContext,
      {
        data: {
          startYear: 2020,
          endYear: 2030,
          selectedDate: initialDate,
          resultCb: (date: Date) => {
            this.dueDate = new Date(date.getTime());
          }
        },
        option: {
          timeFormat: TimeFormat.MINUTES,
          isLoop: false
        }
      },
      $r('app.string.select_due_time')
    );
  }

  async submitTask() {
    if (this.taskName.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.please_text_input') });
      return;
    }
    if (this.dueDate.getTime() <= this.startDate.getTime()) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.ddl_must_later') });
      return;
    }

    const selectedCategory = this.tempCategories.find(c => c.id === this.taskCategoryID);
    let finalCategoryId = this.taskCategoryID;

    if (selectedCategory && selectedCategory.id < 0) {
      const success = await this.categoryRepository.insertCategory(selectedCategory);
      if (success) {
        finalCategoryId = selectedCategory.id;
        this.categoryList = [...this.categoryList, selectedCategory];
        this.tempCategories = this.tempCategories.filter(c => c.id !== selectedCategory.id);
      }
    }

    await this.saveTask(finalCategoryId);
  }

  async saveTask(categoryId: number) {
    const newTask = new TaskListData();
    newTask.task_name = this.taskName.trim();
    newTask.detail = this.taskDetail.trim();
    newTask.start_date_stamp = this.startDate.getTime();
    newTask.due_date_stamp = this.dueDate.getTime();
    newTask.category = categoryId;
    newTask.ddl_detail = DDLConstants.DEFAULT_THRESHOLDS;
    newTask.is_completed = false;

    const success = await this.taskRepository.insertTask(newTask);
    if (success) {
      newTask.setAll(this.categoryList);
      this.taskList = [...this.taskList, newTask];

      this.getUIContext().getPromptAction().showToast({
        message: '已保存至 "' + this.taskCategoryName + '"',
        duration: 2000
      });

      this.dismissKeyboard();
      this.resetForm();

      if (this.onComplete) {
        setTimeout(() => {
          this.onComplete();
        }, UIConstants.ANIMATION_DURATION_NORMAL);
      }
    }
  }

  selectCategory(category: TaskCategoryData) {
    this.taskCategoryID = category.id;
    this.taskCategoryName = category.name;
    this.taskCategoryColor = category.color;
  }

  dismissKeyboard(): void {
    try {
      inputMethod.getController().stopInputSession();
    } catch (err) {
    }
  }

  resetForm(): void {
    this.taskName = '';
    this.taskDetail = '';
    this.startDate = new Date();
    this.startDate.setSeconds(0);
    this.dueDate = new Date();
    this.dueDate.setDate(this.dueDate.getDate() + 1);
    this.dueDate.setSeconds(0);
    this.tempCategories = [];

    if (this.categoryList && this.categoryList.length > 0) {
      this.taskCategoryID = this.categoryList[0].id;
      this.taskCategoryName = this.categoryList[0].name;
      this.taskCategoryColor = this.categoryList[0].color;
    }
  }

  formatDateTime(date: Date): string {
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${month}月${day}日 ${hour}:${minute}`;
  }

  getAllCategories(): TaskCategoryData[] {
    return [...this.categoryList, ...this.tempCategories];
  }

  build() {
    Column() {
      Row() {
        Button($r('app.string.cancel'))
          .backgroundColor('transparent')
          .fontColor('#666')
          .onClick(() => {
            this.dismissKeyboard();
            this.tempCategories = [];
            if (this.onComplete) {
              this.onComplete();
            }
          })

        Text($r('app.string.new_task'))
          .fontSize(30)
          .fontWeight(700)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ top: 12 })

        Button($r('app.string.save'))
          .backgroundColor('transparent')
          .fontColor('#0A59F7')
          .fontWeight(600)
          .onClick(() => this.submitTask())
      }
      .width('100%')
      .height(100)
      .padding({
        top: this.getUIContext().px2vp(AppStorage.get<number>('topHeight')),
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#fff')

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 8 }) {
            Row() {
              Text($r('app.string.task_name'))
                .fontSize(14)
                .fontColor('#666')

              Text(`${this.taskName.length}/${UIConstants.MAX_TASK_NAME_LENGTH}`)
                .fontSize(12)
                .fontColor(this.taskName.length >= UIConstants.MAX_TASK_NAME_LENGTH ? '#E84026' : '#999')
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            TextInput({
              placeholder: $r('app.string.task_input'),
              text: $$this.taskName
            })
              .height(48)
              .backgroundColor('#fff')
              .borderRadius(8)
              .fontSize(16)
              .maxLength(UIConstants.MAX_TASK_NAME_LENGTH)
              .onChange((value: string) => {
                if (value.length > UIConstants.MAX_TASK_NAME_LENGTH) {
                  this.taskName = value.substring(0, UIConstants.MAX_TASK_NAME_LENGTH);
                }
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text($r('app.string.category_type'))
              .fontSize(14)
              .fontColor('#666')
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
              ForEach(this.getAllCategories(), (cate: TaskCategoryData) => {
                Button() {
                  Row() {
                    Text(cate.name)
                      .fontColor(this.taskCategoryID === cate.id ? '#fff' : '#333')
                      .fontSize(14)

                    if (cate.id < 0) {
                      Text(' *')
                        .fontColor(this.taskCategoryID === cate.id ? '#fff' : '#FF6B6B')
                        .fontSize(12)
                    }
                  }
                }
                .backgroundColor(this.taskCategoryID === cate.id ? cate.color : '#f0f0f0')
                .height(36)
                .padding({ left: 16, right: 16 })
                .borderRadius(18)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.selectCategory(cate))
              }, (item: TaskCategoryData) => `category-${item.id}`)

              Button() {
                Text($r('app.string.plus_new'))
                  .fontColor('#0A59F7')
                  .fontSize(14)
              }
              .backgroundColor('#e6eeff')
              .height(36)
              .padding({ left: 16, right: 16 })
              .borderRadius(18)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.newCategoryController.open();
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            Text($r('app.string.time_arrangement'))
              .fontSize(14)
              .fontColor('#666')
              .width('100%')

            Column({ space: 8 }) {
              Row() {
                Text($r('app.string.start_time'))
                  .fontSize(12)
                  .fontColor('#999')

                Blank()

                Row() {
                  Text('📅')
                    .fontSize(16)
                    .margin({ right: 4 })

                  Text(this.formatDateTime(this.startDate))
                    .fontSize(14)
                    .fontColor('#0A59F7')
                }
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8
                })
                .backgroundColor('#f0f5ff')
                .borderRadius(8)
                .onClick(() => {
                  this.openStartDateTimePicker();
                })
              }
              .width('100%')
            }

            Column({ space: 8 }) {
              Row() {
                Text($r('app.string.due_time'))
                  .fontSize(12)
                  .fontColor('#999')

                Blank()

                Row() {
                  Text('⏰')
                    .fontSize(16)
                    .margin({ right: 4 })

                  Text(this.formatDateTime(this.dueDate))
                    .fontSize(14)
                    .fontColor('#E84026')
                }
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8
                })
                .backgroundColor('#fff0f0')
                .borderRadius(8)
                .onClick(() => {
                  this.openDueDateTimePicker();
                })
              }
              .width('100%')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Row() {
              Text($r('app.string.detailed_description'))
                .fontSize(14)
                .fontColor('#666')

              Text(`${this.taskDetail.length}/${UIConstants.MAX_TASK_DETAIL_LENGTH}`)
                .fontSize(12)
                .fontColor(this.taskDetail.length >= UIConstants.MAX_TASK_DETAIL_LENGTH ? '#E84026' : '#999')
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            TextArea({
              placeholder: $r('app.string.add_detailed_description'),
              text: $$this.taskDetail
            })
              .height(120)
              .backgroundColor('#fff')
              .borderRadius(8)
              .fontSize(14)
              .maxLength(UIConstants.MAX_TASK_DETAIL_LENGTH)
              .onChange((value: string) => {
                if (value.length > UIConstants.MAX_TASK_DETAIL_LENGTH) {
                  this.taskDetail = value.substring(0, UIConstants.MAX_TASK_DETAIL_LENGTH);
                }
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgb(241, 243, 245)')
  }
}
