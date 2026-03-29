import relationalStore from '@ohos.data.relationalStore';
import Logger from '../../common/util/Logger';
import { DatabaseConstants } from '../../common/constants';
import { DatabaseHelper } from './DatabaseHelper';

/**
 * 分类表数据访问对象
 * 只负责与数据库的 CRUD 操作，不包含业务逻辑
 */
export class CategoryDao {
  private readonly LOG_TAG = '[CategoryDao]';
  private dbHelper: DatabaseHelper;
  private readonly tableName: string = DatabaseConstants.CATEGORY_TABLE.tableName;

  constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  /**
   * 插入分类
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
      Logger.debug(this.LOG_TAG, `Category inserted with ID: ${rowId}`);
      return rowId;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to insert category: ${err.message}`);
      const error = err instanceof Error ? err : new Error(String(err));
      throw error;
    }
  }

  /**
   * 根据 ID 删除分类
   * @param id 分类 ID
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
      Logger.debug(this.LOG_TAG, `Deleted ${deletedRows} category(s)`);
      return deletedRows;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to delete category: ${err.message}`);
      const error = err instanceof Error ? err : new Error(String(err));
      throw error;
    }
  }

  /**
   * 更新分类
   * @param id 分类 ID
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
      Logger.debug(this.LOG_TAG, `Updated ${updatedRows} category(s)`);
      return updatedRows;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to update category: ${err.message}`);
      const error = err instanceof Error ? err : new Error(String(err));
      throw error;
    }
  }

  /**
   * 查询所有分类
   * @returns Promise<Array<Record<string, any>>> 分类记录数组
   */
  async queryAll(): Promise<Array<Record<string, number | string>>> {
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

      Logger.debug(this.LOG_TAG, `Queried ${results.length} category(s)`);
      return results;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query categories: ${err.message}`);
      return [];
    }
  }

  /**
   * 根据 ID 查询分类
   * @param id 分类 ID
   * @returns Promise<Record<string, any> | null> 分类记录或 null
   */
  async queryById(id: number): Promise<Record<string, number | string> | null> {
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
      Logger.error(this.LOG_TAG, `Failed to query category by ID: ${err.message}`);
      return null;
    }
  }

  /**
   * 根据名称查询分类
   * @param name 分类名称
   * @returns Promise<Array<Record<string, any>>> 分类记录数组
   */
  async queryByName(name: string): Promise<Array<Record<string, number | string>>> {
    const store = this.dbHelper.getRdbStore();
    if (!store) {
      Logger.error(this.LOG_TAG, 'RdbStore is null');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.like('name', `%${name}%`);

      const resultSet = await store.query(predicates);
      const results = this.convertResultSet(resultSet);
      resultSet.close();

      Logger.debug(this.LOG_TAG, `Queried ${results.length} category(s) matching "${name}"`);
      return results;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to query categories by name: ${err.message}`);
      return [];
    }
  }

  /**
   * 转换 ResultSet 为记录数组
   * @param resultSet 查询结果集
   * @returns Array<Record<string, any>> 记录数组
   */
  private convertResultSet(resultSet: relationalStore.ResultSet): Array<Record<string, number | string>> {
    const results: Array<Record<string, number | string>> = [];

    if (resultSet.rowCount <= 0) {
      return results;
    }

    resultSet.goToFirstRow();

    for (let i = 0; i < resultSet.rowCount; i++) {
      const record: Record<string, number | string> = {};

      DatabaseConstants.CATEGORY_TABLE.columns.forEach((columnName) => {
        const columnIndex = resultSet.getColumnIndex(columnName);

        if (columnName === 'id') {
          record[columnName] = resultSet.getDouble(columnIndex);
        } else {
          record[columnName] = resultSet.getString(columnIndex);
        }
      });

      results.push(record);
      resultSet.goToNextRow();
    }

    return results;
  }
}
