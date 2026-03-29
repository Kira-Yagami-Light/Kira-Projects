import { Settings } from '../view/settings/SettingsView';
import TaskList from '../view/task/TaskListView';
import { TaskListData } from '../model/TaskModel';
import { DatabaseHelper } from '../data/database/DatabaseHelper';
import { TaskRepository } from '../data/repository/TaskRepository';
import { CategoryRepository } from '../data/repository/CategoryRepository';
import { PreferenceRepository } from '../data/repository/PreferenceRepository';
import Logger from '../common/util/Logger';
import TaskCategoryData from '../model/CategoryModel';
import { DatabaseConstants } from '../common/constants';
import NewTask from '../view/task/NewTaskView';
import inputMethod from '@ohos.inputMethod';

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
  @State taskRepository: TaskRepository = new TaskRepository();
  @State categoryRepository: CategoryRepository = new CategoryRepository();
  @State preferenceRepository: PreferenceRepository = new PreferenceRepository();
  @State prefData: PreferenceData = new PreferenceData();
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private controller: TabsController = new TabsController();

  async aboutToAppear() {
    try {
      // 初始化数据库
      const dbHelper = DatabaseHelper.getInstance();
      await dbHelper.initDatabase();
      Logger.info('MainPage', 'Database initialized');

      // 初始化偏好设置
      await this.preferenceRepository.init();
      Logger.info('MainPage', 'Preferences initialized');

      // 检查首次打开
      const prefFirstTimeOpen = await this.preferenceRepository.getString('firstOpen', '');
      Logger.debug(`PrefDB: query = ${prefFirstTimeOpen}`);

      if (prefFirstTimeOpen === '') {
        await this.preferenceRepository.putString('firstOpen', 'true');
        await this.preferenceRepository.putString('nowVerColumn', JSON.stringify(DatabaseConstants.TASK_TABLE.columns));
        this.pageInfos.pushPathByName('Guide', null);
      } else {
        // 检查数据库升级
        const last_columns: string[] = JSON.parse(await this.preferenceRepository.getString('nowVerColumn', '[]'));

        if (last_columns.length === DatabaseConstants.TASK_TABLE.columns.length) {
          Logger.debug(`PrefDB: TaskTable Columns up to date`);
        } else {
          DatabaseConstants.TASK_TABLE.columns.forEach(async (column) => {
            if (last_columns.indexOf(column) === -1) {
              Logger.debug(`PrefDB: New Column detected: ${column}`);
              const columnType = DatabaseConstants.COLUMN_TYPE_MAP.get(column) || 'string';
              const sqlType = this.mapColumnType(columnType);
              await dbHelper.addColumn(DatabaseConstants.TASK_TABLE.tableName, column, sqlType);
            }
          });
          await this.preferenceRepository.putString('nowVerColumn',
            JSON.stringify(DatabaseConstants.TASK_TABLE.columns));
        }
      }

      // 加载分类数据
      const categories = await this.categoryRepository.getAllCategories();

      if (categories.length === 0) {
        Logger.debug('first install, loading Category');
        const newData = new TaskCategoryData();
        const success = await this.categoryRepository.insertCategory(newData);

        if (success) {
          this.categoryList = [newData];
        }
      } else {
        this.categoryList = [...categories];
      }

      // 加载任务数据
      const tasks = await this.taskRepository.getAllTasks();
      this.taskList = tasks.map(item => {
        item.setAll(this.categoryList);
        return item;
      });
      Logger.debug(`TaskList loaded: ${this.taskList.length} tasks`);
    } catch (err) {
      Logger.error('MainPage', `Initialization error: ${JSON.stringify(err)}`);
    }
  }

  dismissKeyboard(): void {
    try {
      inputMethod.getController().stopInputSession();
    } catch (err) {
    }
  }

  // 列类型映射方法
  mapColumnType(type: string): string {
    switch (type) {
      case 'double':
        return 'INTEGER';
      case 'string':
        return 'TEXT';
      case 'boolean':
        return 'BOOLEAN';
      default:
        return 'INTEGER';
    }
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
                taskRepository: this.taskRepository,
                categoryList: $categoryList,
                categoryRepository: this.categoryRepository
              })
            }
            .tabBar(this.tabBuilder($r('app.string.tab0'), 0, $r('app.media.ic_list_task_filled'),
              $r('app.media.ic_list_task')))

            TabContent() {
              NewTask({
                categoryList: $categoryList,
                taskList: $taskList,
                taskRepository: this.taskRepository,
                categoryRepository: this.categoryRepository,
                onComplete: () => {
                  this.handleTaskComplete();
                }
              })
            }
            .tabBar({ icon: '', text: '' })

            TabContent() {
              Settings({ tasks: $taskList })
            }
            .tabBar(this.tabBuilder($r('app.string.tab2'), 2, $r('app.media.ic_settings_filled'),
              $r('app.media.ic_settings')))
          }
          .scrollable(false)
          .barHeight(60)
          .padding({
            bottom: this.getUIContext().px2vp(AppStorage.get<number>('bottomHeight'))
          })
          .onContentWillChange((current: number, comingIndex: number) => {
            this.currentIndex = comingIndex;
            this.dismissKeyboard();
            return true;
          })
        }
        .width('100%')
        .height('100%')

        Column() {
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
          this.dismissKeyboard();
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
