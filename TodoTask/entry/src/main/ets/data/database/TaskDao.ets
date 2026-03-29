import relationalStore from '@ohos.data.relationalStore';
import Logger from '../../common/util/Logger';
import { DatabaseConstants } from '../../common/constants';
import { DatabaseHelper } from './DatabaseHelper';

/**
 * 任务表数据访问对象
 * 只负责与数据库的 CRUD 操作
 */
export class TaskDao {
  private readonly LOG_TAG = '[TaskDao]';
  private dbHelper: DatabaseHelper;
  private readonly tableName: string = DatabaseConstants.TASK_TABLE.tableName;

  constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 插入任务
   * @param valueBucket 要插入的数据
   * @returns Promise<number> 插入的行 ID
   */
  async insert(valueBucket: relationalStore.ValuesBucket): Promise<number> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      throw new Error('Database not initialized');
    }

    try {
      const rowId = await store.insert(this.tableName, valueBucket);
      Logger.debug(this.LOG_TAG, `Task inserted with ID: ${rowId}`);
      return rowId;
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to insert task: ${error.message}`);
      throw error;
    }
  }

  /**
   * 根据 ID 删除任务
   * @param id 任务 ID
   * @returns Promise<number> 删除的行数
   */
  async deleteById(id: number): Promise<number> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.equalTo('id', id);

      const deletedRows = await store.delete(predicates);
      Logger.debug(this.LOG_TAG, `Deleted ${deletedRows} task(s)`);
      return deletedRows;
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to delete task: ${error.message}`);
      throw error;
    }
  }

  /**
   * 更新任务
   * @param id 任务 ID
   * @param valueBucket 要更新的数据
   * @returns Promise<number> 更新的行数
   */
  async update(id: number, valueBucket: relationalStore.ValuesBucket): Promise<number> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      throw new Error('Database not initialized');
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.equalTo('id', id);

      const updatedRows = await store.update(valueBucket, predicates);
      Logger.debug(this.LOG_TAG, `Updated ${updatedRows} task(s)`);
      return updatedRows;
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to update task: ${error.message}`);
      throw error;
    }
  }

  /**
   * 查询所有任务
   * @returns Promise<Array<Record<string, any>>> 任务记录数组
   */
  async queryAll(): Promise<Array<Record<string, number | string | boolean>>> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      const resultSet = await store.query(predicates);

      const results = this.convertResultSet(resultSet);
      resultSet.close();

      Logger.debug(this.LOG_TAG, `Queried ${results.length} task(s)`);
      return results;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query tasks: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 根据 ID 查询任务
   * @param id 任务 ID
   * @returns Promise<Record<string, any> | null> 任务记录或 null
   */
  async queryById(id: number): Promise<Record<string, number | string | boolean> | null> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.equalTo('id', id);

      const resultSet = await store.query(predicates);
      const results = this.convertResultSet(resultSet);
      resultSet.close();

      return results.length > 0 ? results[0] : null;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query task by ID: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 根据分类查询任务
   * @param categoryId 分类 ID
   * @returns Promise<Array<Record<string, any>>> 任务记录数组
   */
  async queryByCategory(categoryId: number): Promise<Array<Record<string, number | string | boolean>>> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.equalTo('category', categoryId);

      const resultSet = await store.query(predicates);
      const results = this.convertResultSet(resultSet);
      resultSet.close();

      Logger.debug(this.LOG_TAG, `Queried ${results.length} task(s) for category ${categoryId}`);
      return results;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query tasks by category: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 根据任务名模糊查询
   * @param taskName 任务名（支持模糊匹配）
   * @returns Promise<Array<Record<string, any>>> 任务记录数组
   */
  async queryByName(taskName: string): Promise<Array<Record<string, number | string | boolean>>> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.like('task_name', `%${taskName}%`);

      const resultSet = await store.query(predicates);
      const results = this.convertResultSet(resultSet);
      resultSet.close();

      Logger.debug(this.LOG_TAG, `Queried ${results.length} task(s) matching "${taskName}"`);
      return results;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query tasks by name: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 转换 ResultSet 为记录数组
   * @param resultSet 查询结果集
   * @returns Array<Record<string, any>> 记录数组
   */
  private convertResultSet(resultSet: relationalStore.ResultSet): Array<Record<string, number | string | boolean>> {
    const results: Array<Record<string, number | string | boolean>> = [];

    if (resultSet.rowCount <= 0) {
      return results;
    }

    resultSet.goToFirstRow();

    for (let i = 0; i < resultSet.rowCount; i++) {
      const record: Record<string, number | string | boolean> = {};

      DatabaseConstants.TASK_TABLE.columns.forEach((columnName) => {
        const columnIndex = resultSet.getColumnIndex(columnName);
        const columnType = DatabaseConstants.COLUMN_TYPE_MAP.get(columnName);

        if (columnType === 'string') {
          record[columnName] = resultSet.getString(columnIndex);
        } else if (columnType === 'boolean') {
          record[columnName] = resultSet.getLong(columnIndex) === 1;
        } else {
          record[columnName] = resultSet.getDouble(columnIndex);
        }
      });

      results.push(record);
      resultSet.goToNextRow();
    }

    return results;
  }
}
