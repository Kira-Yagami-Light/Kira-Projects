import TaskTable from '../database/TaskTable';
import { TaskListData } from '../common/TaskListData';
import Logger from '../common/Logger';
import { TaskDialog } from '../components/TaskDialog';
import Constants from '../common/Constants';
import TaskCategoryData from '../common/TaskCategoryData';
import CategoryTable from '../database/CategoryTable';
import CategoryListDialog from '../components/CategoryListDialog';
import NewCategoryDialog from '../components/NewCategoryDialog';

@Component
export default struct TaskList {
  @Link @Watch('onTaskListChange') taskList: Array<TaskListData>;
  @Link taskTable: TaskTable;
  @Link categoryList: TaskCategoryData[];
  @Link categoryTable: CategoryTable;
  onComplete!: () => void;

  @State unfinishedTasks: TaskListData[] = [];
  @State finishedTasks: TaskListData[] = [];
  @State toppedTasks: TaskListData[] = [];

  @State criticalTasks: TaskListData[] = [];
  @State hardTasks: TaskListData[] = [];
  @State mediumTasks: TaskListData[] = [];
  @State easyTasks: TaskListData[] = [];

  @State @Watch('onTabChange') currentTab: number = 0;
  @State searchQuery: string = '';
  @State isSearching: boolean = false;
  @State taskItem: TaskListData = new TaskListData();
  @State isEditing: boolean = false;
  @State selectedCategoryId: number = 0;
  @State deleteTarget: Array<TaskListData> = [];
  private dialogSelectedIndex: number = -1;
  onTaskUpdate?: (action: string, data: TaskListData) => void;

  onTaskListChange() {
    Logger.info('TaskList', `taskList changed! Length: ${this.taskList.length}`);
    this.refreshGroupedTasks();
  }

  onTabChange() {
    Logger.info('TaskList', `Tab switched to ${this.currentTab === 0 ? 'Unfinished' : 'Finished'}`);
    this.refreshGroupedTasks();
  }

  refreshGroupedTasks(): void {
    if (!this.taskList) {
      Logger.warn('TaskList', 'taskList is null/undefined');
      return;
    }

    Logger.info('TaskList', `Refreshing... Total: ${this.taskList.length} tasks`);

    let baseTasks: TaskListData[] = [...this.taskList];

    if (this.isSearching && this.searchQuery.trim() !== '') {
      if (this.selectedCategoryId > 0) {
        baseTasks = baseTasks.filter((item: TaskListData): boolean => {
          return item.category === this.selectedCategoryId;
        });
      } else {
        baseTasks = baseTasks.filter((item: TaskListData): boolean => {
          const nameMatch = item.task_name.toLowerCase().includes(this.searchQuery.toLowerCase());
          const detailMatch = item.detail ?
          item.detail.toLowerCase().includes(this.searchQuery.toLowerCase()) : false;
          return nameMatch || detailMatch;
        });
      }
    }

    const unfinished = baseTasks.filter((item: TaskListData): boolean => !item.is_completed);
    const finished = baseTasks.filter((item: TaskListData): boolean => item.is_completed);

    unfinished.forEach((item: TaskListData): void => {
      item.setCategoryName(this.categoryList);
    });

    finished.sort((a, b) => b.id - a.id);
    finished.forEach((item: TaskListData): void => {
      item.setCategoryName(this.categoryList);
    });

    this.unfinishedTasks = [...unfinished];
    this.finishedTasks = [...finished];

    Logger.info('TaskList', `Grouped: ${this.unfinishedTasks.length} unfinished, ${this.finishedTasks.length} finished`);

    this.criticalTasks = [...this.unfinishedTasks.filter((t: TaskListData): boolean => t.getDDLState() === 'critical')];
    this.hardTasks = [...this.unfinishedTasks.filter((t: TaskListData): boolean => t.getDDLState() === 'hard')];
    this.mediumTasks = [...this.unfinishedTasks.filter((t: TaskListData): boolean => t.getDDLState() === 'medium')];
    this.easyTasks = [...this.unfinishedTasks.filter((t: TaskListData): boolean => t.getDDLState() === 'easy')];

    Logger.info('TaskList', `Priority: C=${this.criticalTasks.length}, H=${this.hardTasks.length}, M=${this.mediumTasks.length}, E=${this.easyTasks.length}`);
  }

  aboutToAppear() {
    Logger.info('TaskList', 'Component appearing...');
    if (!this.taskList) {
      this.taskList = [];
    }
    this.refreshGroupedTasks();
  }

  dialogController_view: CustomDialogController = new CustomDialogController({
    builder: TaskDialog({
      taskItem: $taskItem,
      categoryList: $categoryList
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  dialogCategoryList: CustomDialogController = new CustomDialogController({
    builder: CategoryListDialog({
      categoryList: $categoryList,
      categoryTable: $categoryTable,
      confirm: (selectedCategory: TaskCategoryData) => {
        this.selectedCategoryId = selectedCategory.id;
        this.isSearching = true;
        this.searchQuery = selectedCategory.name;
        this.refreshGroupedTasks();
      },
      safeDeleteCheckID: (id) => {
        for (let i = 0; i < this.taskList.length; ++i) {
          if (this.taskList[i].category === id) {
            return false;
          }
        }
        return true;
      },
      openNewCategoryDialog: () => {
        this.dialogNewCategory.open();
      },
      queryCategory: (id) => {
        this.queryCategory(id);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  dialogNewCategory: CustomDialogController = new CustomDialogController({
    builder: NewCategoryDialog({
      confirm: (newCategory: TaskCategoryData) => {
        this.categoryTable.insertData(newCategory, (id: number) => {
          if (id > 0) {
            newCategory.id = id;
            this.categoryList = [...this.categoryList, newCategory];
            Logger.debug(`Category Added. ID: ${id}, Name: ${newCategory.name}`);
          }
        })
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  getDDLText(state: string): string {
    const map: Record<string, string> = {
      'critical': '非常紧急',
      'hard': '紧急',
      'medium': '还有时间',
      'easy': '该开始了'
    };
    return map[state] || state;
  }

  updateExistingTask(taskData: TaskListData) {
    this.taskTable.updateData(taskData, () => {
    })
    taskData.setAll(this.categoryList);
    this.taskList = [...this.taskList];
  }

  deleteSelectedTasks() {
    if (this.deleteTarget.length === 0) {
      return;
    }

    for (let i = 0; i < this.deleteTarget.length; i++) {
      let target = this.deleteTarget[i];
      this.taskTable.deleteData(target, (ret: boolean) => {
        if (ret) {
          let idx = this.taskList.indexOf(target);
          if (idx > -1) {
            this.taskList.splice(idx, 1);
          }
        }
      })
    }
    this.deleteTarget = [];
  }

  queryCategory(categoryId: number) {
    if (categoryId === 0) {
      this.isSearching = false;
      this.searchQuery = '';
      this.selectedCategoryId = 0;
    } else {
      this.isSearching = true;
      this.selectedCategoryId = categoryId;
    }
    this.refreshGroupedTasks();
  }

  @Builder
  TabHeader() {
    Row() {
      Column() {
        Text(`未完成 (${this.unfinishedTasks?.length || 0})`)
          .fontSize(16)
          .fontWeight(this.currentTab === 0 ? 600 : 400)
          .fontColor(this.currentTab === 0 ? '#0A59F7' : '#666')

        if (this.currentTab === 0) {
          Divider()
            .strokeWidth(3)
            .color('#0A59F7')
            .width(20)
            .margin({ top: 6 })
            .lineCap(LineCapStyle.Round)
        }
      }
      .onClick(() => {
        this.getUIContext()?.animateTo({ duration: 200 }, () => {
          this.currentTab = 0;
        })
      })
      .layoutWeight(1)

      Column() {
        Text(`已完成 (${this.finishedTasks?.length || 0})`)
          .fontSize(16)
          .fontWeight(this.currentTab === 1 ? 600 : 400)
          .fontColor(this.currentTab === 1 ? '#0A59F7' : '#666')

        if (this.currentTab === 1) {
          Divider()
            .strokeWidth(3)
            .color('#0A59F7')
            .width(20)
            .margin({ top: 6 })
            .lineCap(LineCapStyle.Round)
        }
      }
      .onClick(() => {
        this.getUIContext()?.animateTo({ duration: 200 }, () => {
          this.currentTab = 1;
        })
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height(52)
    .backgroundColor('#fff')
  }

  @Builder
  TaskListBuilder(item: TaskListData, index: number) {
    Row() {
      if (!this.isEditing) {
        Checkbox()
          .select(item.is_completed)
          .onChange((value: boolean) => {
            this.getUIContext()?.animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              item.is_completed = value;
              this.dialogSelectedIndex = this.taskList.indexOf(item);
              this.updateExistingTask(item);
              if (value && this.currentTab === 0) {
                setTimeout(() => {
                  this.currentTab = 1;
                }, 300)
              }
            })
          })
          .margin({ right: 12 })
      } else {
        Checkbox()
          .select(this.deleteTarget.includes(item))
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.deleteTarget = [...this.deleteTarget, item];
            } else {
              this.deleteTarget = this.deleteTarget.filter(t => t.id !== item.id);
            }
          })
          .margin({ right: 12 })
      }

      Column() {
        Text(item.task_name)
          .fontSize(16)
          .fontWeight(500)
          .fontColor(this.deleteTarget.includes(item) ? '#999' : '#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .decoration({ type: this.deleteTarget.includes(item) ? TextDecorationType.LineThrough : TextDecorationType.None })

        if (item.detail) {
          Text(item.detail)
            .fontSize(12)
            .fontColor('#999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
            .width('100%')
            .opacity(this.deleteTarget.includes(item) ? 0.5 : 1)
        }

        Row() {
          if (item.categoryName) {
            Row() {
              Circle()
                .width(6)
                .height(6)
                .fill(item.categoryColor || '#999')
              Text(item.categoryName)
                .fontSize(10)
                .fontColor('#999')
                .margin({ left: 4 })
            }
          }
          if (item.due_date_stamp) {
            Text(getTimeString(item.due_date_stamp))
              .fontSize(10)
              .fontColor('#999')
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .margin({ top: 8 })
        .opacity(this.deleteTarget.includes(item) ? 0.5 : 1)

        if (item.due_date_stamp && !item.is_completed) {
          Progress({
            value: item.getDDLState() === 'critical' ? 100 :
              item.getDDLState() === 'hard' ? 80 :
                item.getDDLState() === 'medium' ? 50 : 30,
            total: 100,
            type: ProgressType.Linear
          })
            .width('100%')
            .height(4)
            .color(Constants.DDL_COLOR.get(item.getDDLState()) || '#999')
            .backgroundColor('#e0e0e0')
            .margin({ top: 6 })
            .opacity(this.deleteTarget.includes(item) ? 0.5 : 1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (item.topped) {
        Image($r('app.media.ic_back'))
          .width(20)
          .height(20)
          .fillColor('#FFD700')
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.deleteTarget.includes(item) ? '#f5f5f5' : (item.topped ? '#fff8e6' : '#fff'))
    .borderRadius(12)
    .shadow({ radius: item.topped ? 4 : 0, color: '#FFD70020' })
    .opacity(this.deleteTarget.includes(item) ? 0.6 : 1)
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (!this.isEditing) {
            this.getUIContext()?.animateTo({ duration: 200 }, () => {
              item.topped = !item.topped;
              this.dialogSelectedIndex = this.taskList.indexOf(item);
              this.updateExistingTask(item);
            })
          }
        })
    )
    .onClick(() => {
      if (!this.isEditing) {
        this.taskItem = item;
        this.dialogController_view.open();
      }
    })
  }

  @Builder
  EmptyState() {
    Column() {
      Text(this.isSearching ? $r('app.string.not_found') : $r('app.string.not_available'))
        .fontSize(16)
        .fontColor('#999')

      if (!this.isSearching && this.currentTab === 0) {
        Text($r('app.string.click_to_create'))
          .fontSize(14)
          .fontColor('#bbb')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .margin({ top: 100 })
  }

  build() {
    Column() {
      Row() {
        Text(this.isEditing ? $r('app.string.edit_task') : $r('app.string.todo_task'))
          .fontSize(30)
          .fontWeight(700)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ top: 12 })
        Row() {
          Button() {
            Image(this.isEditing ? $r('app.media.ic_done') : $r('app.media.ic_trash'))
              .width(24)
              .height(24)
              .fillColor('#333')
          }
          .backgroundColor('transparent')
          .margin({ left: 16 })
          .onClick(() => {
            this.getUIContext()?.animateTo({ duration: 200 }, () => {
              if (this.isEditing) {
                this.deleteSelectedTasks();
                this.taskList = [...this.taskList];
              }
              this.deleteTarget = [];
              this.isEditing = !this.isEditing;
            })
          })
        }
      }
      .width('100%')
      .height(100)
      .padding({ top: this.getUIContext().px2vp(AppStorage.get<number>('topHeight')), left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#fff')

      Row() {
        Search({ placeholder: $r('app.string.search_for_task'), value: this.searchQuery })
          .onChange((val) => {
            this.searchQuery = val;
            this.selectedCategoryId = 0;
            this.isSearching = val !== '';
            this.refreshGroupedTasks();
          })
          .onSubmit((val) => {
            this.searchQuery = val;
            this.selectedCategoryId = 0;
            this.isSearching = val !== '';
          })
          .margin({
            left: 12,
            right: 12,
            top: 8,
            bottom: 8
          })
          .layoutWeight(1)

        if (this.isSearching && this.selectedCategoryId > 0) {
          Button($r('app.string.clear'))
            .backgroundColor('#f0f0f0')
            .fontColor('#666')
            .height(40)
            .margin({ right: 12 })
            .onClick(() => {
              this.isSearching = false;
              this.searchQuery = '';
              this.selectedCategoryId = 0;
              this.refreshGroupedTasks();
            })
        }
      }
      .width('100%')
      .backgroundColor('rgb(241, 243, 245)')
      .visibility(this.isEditing ? Visibility.None : Visibility.Visible)

      this.TabHeader()

      if (this.currentTab === 0) {
        if ((this.unfinishedTasks?.length || 0) === 0) {
          this.EmptyState();
        } else {
          Scroll() {
            Column() {
              if (this.criticalTasks.length > 0) {
                Column() {
                  Row() {
                    Circle().width(8).height(8).fill(Constants.DDL_COLOR.get('critical') || '#E84026')
                    Text(`🔴 非常紧急 (${this.criticalTasks.length})`)
                      .fontSize(14)
                      .fontWeight(600)
                      .fontColor('#333')
                      .margin({ left: 8 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 8 })

                  List() {
                    ForEach(this.criticalTasks, (item: TaskListData, index: number) => {
                      ListItem() {
                        this.TaskListBuilder(item, index);
                      }
                      .margin({ left: 12, right: 12, bottom: 8 })
                    }, (item: TaskListData) => `critical-${item.id}`)
                  }
                  .divider({ strokeWidth: 0 })
                  .padding({ bottom: 8 })
                }
                .width('100%')
                .margin({ bottom: 12 })
              }

              if (this.hardTasks.length > 0) {
                Column() {
                  Row() {
                    Circle().width(8).height(8).fill(Constants.DDL_COLOR.get('hard') || '#F9A01E')
                    Text(`🟠 紧急 (${this.hardTasks.length})`)
                      .fontSize(14)
                      .fontWeight(600)
                      .fontColor('#333')
                      .margin({ left: 8 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 8 })

                  List() {
                    ForEach(this.hardTasks, (item: TaskListData, index: number) => {
                      ListItem() {
                        this.TaskListBuilder(item, index);
                      }
                      .margin({ left: 12, right: 12, bottom: 8 })
                    }, (item: TaskListData) => `hard-${item.id}`)
                  }
                  .divider({ strokeWidth: 0 })
                  .padding({ bottom: 8 })
                }
                .width('100%')
                .margin({ bottom: 12 })
              }

              if (this.mediumTasks.length > 0) {
                Column() {
                  Row() {
                    Circle().width(8).height(8).fill(Constants.DDL_COLOR.get('medium') || '#F7CE00')
                    Text(`🟡 还有时间 (${this.mediumTasks.length})`)
                      .fontSize(14)
                      .fontWeight(600)
                      .fontColor('#333')
                      .margin({ left: 8 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 8 })

                  List() {
                    ForEach(this.mediumTasks, (item: TaskListData, index: number) => {
                      ListItem() {
                        this.TaskListBuilder(item, index);
                      }
                      .margin({ left: 12, right: 12, bottom: 8 })
                    }, (item: TaskListData) => `medium-${item.id}`)
                  }
                  .divider({ strokeWidth: 0 })
                  .padding({ bottom: 8 })
                }
                .width('100%')
                .margin({ bottom: 12 })
              }

              if (this.easyTasks.length > 0) {
                Column() {
                  Row() {
                    Circle().width(8).height(8).fill(Constants.DDL_COLOR.get('easy') || '#A5D61D')
                    Text(`🟢 该开始了 (${this.easyTasks.length})`)
                      .fontSize(14)
                      .fontWeight(600)
                      .fontColor('#333')
                      .margin({ left: 8 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 8 })

                  List() {
                    ForEach(this.easyTasks, (item: TaskListData, index: number) => {
                      ListItem() {
                        this.TaskListBuilder(item, index);
                      }
                      .margin({ left: 12, right: 12, bottom: 8 })
                    }, (item: TaskListData) => `easy-${item.id}`)
                  }
                  .divider({ strokeWidth: 0 })
                  .padding({ bottom: 8 })
                }
                .width('100%')
                .margin({ bottom: 12 })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .padding({ top: 8, bottom: 20 })
          }
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      } else {
        if ((this.finishedTasks?.length || 0) === 0) {
          this.EmptyState();
        } else {
          List() {
            ForEach(this.finishedTasks, (item: TaskListData, index) => {
              ListItem() {
                this.TaskListBuilder(item, index);
              }
              .margin({ left: 12, right: 12, bottom: 8 })
            }, (item: TaskListData) => `finished-${item.id}`)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .padding({ top: 8, bottom: 20 })
          .edgeEffect(EdgeEffect.Spring)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

function getTimeString(date_stamp: number): string {
  let date: Date = new Date();
  date.setTime(date_stamp);
  let ds: string[] = date.toLocaleDateString().split('/');
  let res: string = `${ds[2]}/${ds[0]}/${ds[1]}`;
  return res + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}
