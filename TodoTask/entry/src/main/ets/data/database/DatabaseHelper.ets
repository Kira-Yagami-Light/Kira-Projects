import relationalStore from '@ohos.data.relationalStore';
import Logger from '../../common/util/Logger';
import { DatabaseConstants } from '../../common/constants';

/**
 * 数据库连接管理器（单例模式）
 * 负责创建和管理数据库连接
 */
export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly LOG_TAG = '[DatabaseHelper]';
  private isInitializing: boolean = false;
  private initCallbacks: Function[] = [];

  private constructor() {
  }

  /**
   * 获取 DatabaseHelper 单例实例
   */
  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  /**
   * 初始化数据库
   * @param config 数据库配置
   * @param callback 初始化完成回调
   */
  async initDatabase(
    config: relationalStore.StoreConfig = DatabaseConstants.STORE_CONFIG,
    callback?: () => void
  ): Promise<void> {
    // 如果已经初始化，直接回调
    if (this.rdbStore !== null) {
      callback?.();
      return;
    }

    // 如果正在初始化，将回调加入队列
    if (this.isInitializing) {
      if (callback) {
        this.initCallbacks.push(callback);
      }
      return;
    }

    this.isInitializing = true;
    if (callback) {
      this.initCallbacks.push(callback);
    }

    try {
      const context: Context = getContext(this) as Context;

      this.rdbStore = await relationalStore.getRdbStore(context, config);
      Logger.info(this.LOG_TAG, 'Database initialized successfully');

      // 创建所有表
      await this.createTables();

      // 执行所有等待的回调
      this.initCallbacks.forEach((cb: Function): void => cb());
      this.initCallbacks = [];
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to initialize database: ${error.message}`);
      throw error;
    } finally {
      this.isInitializing = false;
    }
  }

  /**
   * 创建所有表
   */
  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      Logger.error(this.LOG_TAG, 'RdbStore is null, cannot create tables');
      return;
    }

    try {
      // 创建任务表
      await this.rdbStore.executeSql(DatabaseConstants.TASK_TABLE.sqlCreate);
      Logger.debug(this.LOG_TAG, 'Task table created');

      // 创建分类表
      await this.rdbStore.executeSql(DatabaseConstants.CATEGORY_TABLE.sqlCreate);
      Logger.debug(this.LOG_TAG, 'Category table created');
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to create tables: ${error.message}`);
      throw error;
    }
  }

  /**
   * 获取数据库实例
   */
  getRdbStore(): relationalStore.RdbStore | null {
    if (!this.rdbStore) {
      Logger.warn(this.LOG_TAG, 'RdbStore not initialized yet');
    }
    return this.rdbStore;
  }

  /**
   * 添加新列（用于数据库升级）
   * @param tableName 表名
   * @param columnName 列名
   * @param columnType 列类型
   */
  async addColumn(tableName: string, columnName: string, columnType: string): Promise<void> {
    if (!this.rdbStore) {
      Logger.error(this.LOG_TAG, 'RdbStore is null, cannot add column');
      return;
    }

    try {
      const sql = `ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${columnType}`;
      await this.rdbStore.executeSql(sql);
      Logger.info(this.LOG_TAG, `Column ${columnName} added to ${tableName}`);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to add column: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 执行原始 SQL
   * @param sql SQL 语句
   */
  async executeSql(sql: string): Promise<void> {
    if (!this.rdbStore) {
      Logger.error(this.LOG_TAG, 'RdbStore is null, cannot execute SQL');
      return;
    }

    try {
      await this.rdbStore.executeSql(sql);
      Logger.debug(this.LOG_TAG, `SQL executed: ${sql}`);
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to execute SQL: ${error.message}`);
      throw error;
    }
  }

  /**
   * 关闭数据库连接
   */
  async closeDatabase(): Promise<void> {
    if (this.rdbStore) {
      try {
        // 预留接口以备将来需要
        Logger.info(this.LOG_TAG, 'Database connection managed by system');
        this.rdbStore = null;
      } catch (err) {
        Logger.error(this.LOG_TAG, `Failed to close database: ${JSON.stringify(err)}`);
      }
    }
  }
}
