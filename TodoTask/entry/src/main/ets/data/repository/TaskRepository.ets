import relationalStore from '@ohos.data.relationalStore';
import { TaskListData } from '../../model/TaskModel';
import { TaskDao } from '../database/TaskDao';
import Logger from '../../common/util/Logger';

/**
 * 任务数据仓库
 * 封装业务逻辑，提供高层次的数据访问接口
 */
export class TaskRepository {
  private readonly LOG_TAG = '[TaskRepository]';
  private dao: TaskDao;

  constructor() {
    this.dao = new TaskDao();
  }

  /**
   * 获取所有任务
   * @returns Promise<Array<TaskListData>> 任务模型数组
   */
  async getAllTasks(): Promise<Array<TaskListData>> {
    try {
      const records = await this.dao.queryAll();
      return records.map(r => TaskListData.fromRecord(r));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get all tasks: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 根据 ID 获取任务
   * @param id 任务 ID
   * @returns Promise<TaskListData | null> 任务模型或 null
   */
  async getTaskById(id: number): Promise<TaskListData | null> {
    try {
      const record = await this.dao.queryById(id);
      return record ? TaskListData.fromRecord(record) : null;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get task by ID: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 根据分类获取任务
   * @param categoryId 分类 ID
   * @returns Promise<Array<TaskListData>> 任务模型数组
   */
  async getTasksByCategory(categoryId: number): Promise<Array<TaskListData>> {
    try {
      const records = await this.dao.queryByCategory(categoryId);
      return records.map(r => TaskListData.fromRecord(r));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get tasks by category: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 根据任务名搜索任务
   * @param taskName 任务名（支持模糊匹配）
   * @returns Promise<Array<TaskListData>> 任务模型数组
   */
  async searchTasksByName(taskName: string): Promise<Array<TaskListData>> {
    try {
      const records = await this.dao.queryByName(taskName);
      return records.map(r => TaskListData.fromRecord(r));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to search tasks: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 插入任务
   * @param task 任务模型
   * @returns Promise<boolean> 是否成功，成功后 task.id 会被设置为新 ID
   */
  async insertTask(task: TaskListData): Promise<boolean> {
    try {
      const valueBucket = this.toValueBucket(task);
      const rowId = await this.dao.insert(valueBucket);

      if (rowId > 0) {
        task.id = rowId;
        Logger.info(this.LOG_TAG, `Task inserted with ID: ${rowId}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to insert task: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 更新任务
   * @param task 任务模型
   * @returns Promise<boolean> 是否成功
   */
  async updateTask(task: TaskListData): Promise<boolean> {
    try {
      const valueBucket = this.toValueBucket(task);
      const updatedRows = await this.dao.update(task.id, valueBucket);

      if (updatedRows > 0) {
        Logger.info(this.LOG_TAG, `Task updated: ${task.id}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to update task: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 删除任务
   * @param id 任务 ID
   * @returns Promise<boolean> 是否成功
   */
  async deleteTask(id: number): Promise<boolean> {
    try {
      const deletedRows = await this.dao.deleteById(id);

      if (deletedRows > 0) {
        Logger.info(this.LOG_TAG, `Task deleted: ${id}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to delete task: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 切换任务完成状态
   * @param id 任务 ID
   * @returns Promise<boolean> 是否成功
   */
  async toggleTaskCompletion(id: number): Promise<boolean> {
    try {
      const task = await this.getTaskById(id);
      if (!task) {
        return false;
      }

      task.is_completed = !task.is_completed;
      return await this.updateTask(task);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to toggle task completion: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 将 TaskListData 转换为 ValuesBucket
   * @param task 任务模型
   * @returns relationalStore.ValuesBucket
   */
  private toValueBucket(task: TaskListData): relationalStore.ValuesBucket {
    return {
      task_name: task.task_name,
      detail: task.detail,
      subject: task.subject,
      start_date_stamp: task.start_date_stamp,
      due_date_stamp: task.due_date_stamp,
      is_completed: task.is_completed ? 1 : 0,
      ddl_detail: task.ddl_detail,
      category: task.category
    };
  }
}
