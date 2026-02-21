import { Settings } from './Settings';
import TaskList from './TaskList';
import { TaskListData } from '../common/TaskListData';
import TaskTable from '../database/TaskTable';
import Logger from '../common/Logger';
import CategoryTable from '../database/CategoryTable';
import TaskCategoryData from '../common/TaskCategoryData';
import PreferenceDB from '../database/PreferenceDB';
import CommonConstants from '../common/Constants';
import NewTask from './NewTask';

interface PreferenceInterface {
  id: number;
}

class PreferenceData implements PreferenceInterface {
  id: number = 1;
}

interface TaskStorage {
  taskTable: number;
}

let storage = new LocalStorage({ taskTable: 1 } as TaskStorage);

@Entry(storage)
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State taskList: Array<TaskListData> = [];
  @State categoryList: Array<TaskCategoryData> = [];
  @State taskTable: TaskTable = new TaskTable(() => {
  });
  @State categoryTable: CategoryTable = new CategoryTable(() => {
  });
  @State prefData: PreferenceData = new PreferenceData();
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private controller: TabsController = new TabsController();

  async aboutToAppear() {
    await PreferenceDB.getPreferenceStorage();
    let prefFirstTimeOpen = await PreferenceDB.getPreference('firstOpen');
    Logger.debug(`PrefDB: query = ${prefFirstTimeOpen}`);
    if (prefFirstTimeOpen === '') {
      await PreferenceDB.putPreference('firstOpen', 'true');
      await PreferenceDB.putPreference('nowVerColumn', JSON.stringify(CommonConstants.TASK_TABLE_INIT.columns));
      this.pageInfos.pushPathByName('Guide', null);
    } else {
      let last_columns: string[] = JSON.parse(await PreferenceDB.getPreference('nowVerColumn'));
      if (last_columns.length ===
      CommonConstants.TASK_TABLE_INIT.columns.length) {
        Logger.debug(`PrefDB: TaskTable Columns up to date`);
      } else {
        this.taskTable.getRdbStore(() => {
          CommonConstants.TASK_TABLE_INIT.columns.forEach((column) => {
            if (last_columns.indexOf(column) === -1) {
              Logger.debug(`PrefDB: New Column detected: ${column}`);
              this.taskTable.updateColumns(column, CommonConstants.COLUMN_TYPE[column]);
            }
          })
        })
      }
    }

    this.categoryTable.getRdbStore(() => {
      this.categoryTable.query(0, (res: TaskCategoryData[]) => {
        if (res.length === 0) {
          Logger.debug('first install, loading Category');
          let newData = new TaskCategoryData();
          this.categoryTable.insertData(newData, (id: number) => {
            newData.id = id;
            this.categoryList = [newData];
          })
        } else {
          this.categoryList = [...res];
        }

        this.taskTable.getRdbStore(() => {
          this.taskTable.queryTaskName('', (result: TaskListData[]) => {
            this.taskList = result.map(item => {
              let task = new TaskListData();
              task.id = item.id;
              task.task_name = item.task_name;
              task.detail = item.detail;

              task.is_completed = Number(item.is_completed) === 1;
              task.topped = Number(item.topped) === 1;

              task.start_date_stamp = item.start_date_stamp;
              task.due_date_stamp = item.due_date_stamp;
              task.subject = item.subject;
              task.category = item.category;
              task.ddl_detail = item.ddl_detail;

              task.setAll(this.categoryList);
              return task;
            });
            Logger.debug(`TaskList loaded: ${this.taskList.length} tasks`);
          }, true);
        });
      });
    });
  }

  handleTaskComplete() {
    this.currentIndex = 0;
    this.controller.changeIndex(0);
  }

  @Builder
  tabBuilder(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, originalImg: ResourceStr) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : originalImg)
        .width(this.currentIndex === targetIndex ? 28 : 24)
        .height(this.currentIndex === targetIndex ? 28 : 24)
        .fillColor(this.currentIndex === targetIndex ? '#0A59F7' : '#6B6B6B')
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === targetIndex ? '#0A59F7' : '#6B6B6B')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8 })
  }

  build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
            TabContent() {
              TaskList({
                taskList: $taskList,
                taskTable: $taskTable,
                categoryList: $categoryList,
                categoryTable: $categoryTable
              })
            }
            .tabBar(this.tabBuilder($r('app.string.tab0'), 0, $r('app.media.ic_list_task_filled'), $r('app.media.ic_list_task')))

            TabContent() {
              NewTask({
                categoryList: $categoryList,
                taskList: $taskList,
                taskTable: this.taskTable,
                categoryTable: this.categoryTable,
                onComplete: () => {
                  this.handleTaskComplete();
                }
              })
            }
            .tabBar({ icon: '', text: '' })

            TabContent() {
              Settings({ tasks: $taskList })
            }
            .tabBar(this.tabBuilder($r('app.string.tab2'), 2, $r("app.media.ic_settings_filled"), $r("app.media.ic_settings")))
          }
          .scrollable(false)
          .barHeight(60)
          .padding({
            bottom: this.getUIContext().px2vp(AppStorage.get<number>('bottomHeight'))
          })
          .onContentWillChange((current: number, comingIndex: number) => {
            this.currentIndex = comingIndex;
            return true;
          })
        }
        .width('100%')
        .height('100%')

        Column(){
          Column() {
            Image(this.currentIndex === 1 ? $r('app.media.ic_plus_filled') : $r('app.media.ic_plus'))
              .width(32)
              .height(32)
              .fillColor(Color.White)
          }
          .width(80)
          .height(80)
          .backgroundColor(this.currentIndex === 1 ? '#0A59F7' : '#ffffff')
          .borderRadius(40)
          .shadow({ radius: 12, color: '#40000000', offsetY: 6 })
          .justifyContent(FlexAlign.Center)

          Text($r('app.string.new_task'))
            .fontSize(12)
            .margin({ top: 8 })
            .fontColor(this.currentIndex === 1 ? '#0A59F7' : '#6B6B6B')
        }
        .onClick(() => {
          this.currentIndex = 1;
          this.controller.changeIndex(1);
        })
        .offset({ y: -12 - (this.getUIContext().px2vp(AppStorage.get<number>('bottomHeight')) / 2) })
        .hitTestBehavior(HitTestMode.Block)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.white'))
    }
    .hideTitleBar(true)
  }
}
