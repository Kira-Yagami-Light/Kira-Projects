import TaskCategoryData from './TaskCategoryData';

export interface TaskData {
  id: number;
  detail: string;
  task_name: string;
  start_date_stamp: number;
  due_date_stamp: number;
  is_completed: boolean;
  ddl_detail: string;
  category: number;
  topped: boolean;
}

export interface State {
  critical: number;
  hard: number;
  medium: number;
}

@Observed
export class TaskListData implements TaskData {
  static createFromRecord(record: undefined): TaskListData {
    throw new Error('Method not implemented.')
  };

  id: number = -1;
  start_date_stamp: number = 0;
  due_date_stamp: number = 0;
  detail: string = '';
  subject: number = 0;
  task_name: string = '';
  is_completed: boolean = false;
  ddl_detail: string = '0.3-0.5-0.8';
  ddl_state: State = {
    critical: 0.3,
    hard: 0.5,
    medium: 0.8
  };
  category: number = 1;
  categoryName: string = '';
  categoryColor: string = '#999999';
  topped: boolean = false;

  // Static Factory
  static fromRecord(record: Record<string, number | string | boolean>): TaskListData {
    const item = new TaskListData();
    item.id = Number(record.id ?? -1);
    item.start_date_stamp = Number(record.start_date_stamp ?? 0);
    item.due_date_stamp = Number(record.due_date_stamp ?? 0);
    item.detail = String(record.detail ?? '');
    item.task_name = String(record.task_name ?? '');
    item.is_completed = Boolean(record.is_completed ?? false);
    item.ddl_detail = String(record.ddl_detail ?? '0.3-0.5-0.8');
    item.category = Number(record.category ?? 1);
    item.topped = Boolean(record.topped ?? false);
    item.subject = Number(record.subject ?? 0);

    // Reparse the DDL status
    item.initDDLState();
    return item;
  }

  // Initialization method, executed immediately after loading
  initDDLState() {
    let ddl_arr = this.ddl_detail.split('-');
    if (ddl_arr.length >= 3) {
      this.ddl_state.critical = Number(ddl_arr[0]);
      this.ddl_state.hard = Number(ddl_arr[1]);
      this.ddl_state.medium = Number(ddl_arr[2]);
    }
  }

  // Set the category name and color
  setCategoryName(categoryList: TaskCategoryData[]) {
    for (let i = 0; i < categoryList.length; ++i) {
      if (categoryList[i].id === this.category) {
        this.categoryName = categoryList[i].name;
        this.categoryColor = categoryList[i].color;
        break;
      }
    }
  }

  setAll(categoryList: TaskCategoryData[]) {
    if (!this.ddl_state) {
      this.ddl_state = { critical: 0.3, hard: 0.5, medium: 0.8 };
    }

    let ddl_arr = this.ddl_detail.split('-');
    if (ddl_arr.length >= 3) {
      this.ddl_state.critical = Number(ddl_arr[0]);
      this.ddl_state.hard = Number(ddl_arr[1]);
      this.ddl_state.medium = Number(ddl_arr[2]);
    }
    this.setCategoryName(categoryList);
  }

  getDDLState(): string {
    let taskFullTime = this.due_date_stamp - this.start_date_stamp;

    if (taskFullTime <= 0) {
      return 'easy';
    }

    let nowTime = new Date().getTime();
    let remainingTime = this.due_date_stamp - nowTime;
    let resultPercentage = remainingTime / taskFullTime;

    const critical = this.ddl_state?.critical ?? 0.3;
    const hard = this.ddl_state?.hard ?? 0.5;
    const med = this.ddl_state?.medium ?? 0.8;

    if (remainingTime < 0) {
      return 'critical';
    }
    if (resultPercentage < critical) {
      return 'critical';
    }
    if (resultPercentage < hard) {
      return 'hard';
    }
    if (resultPercentage < med) {
      return 'medium';
    }
    return 'easy';
  }

  getDDLPer(): number {
    let taskFullTime = this.due_date_stamp - this.start_date_stamp;

    if (taskFullTime <= 0) {
      return 0;
    }

    let nowTime = new Date().getTime();
    let remainingTime = this.due_date_stamp - nowTime;
    if (remainingTime <= 0) {
      return 0;
    }

    let resultPercentage = remainingTime / taskFullTime;
    return Math.min(100, Math.max(0, resultPercentage * 100));
  }
}
