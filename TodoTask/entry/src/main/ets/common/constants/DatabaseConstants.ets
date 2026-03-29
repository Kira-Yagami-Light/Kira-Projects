import relationalStore from '@ohos.data.relationalStore';

/**
 * 数据库表结构定义
 */
export interface TableSchema {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

/**
 * 数据库存储配置常量
 */
export class DatabaseConstants {
  /**
   * 主数据库配置
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S2
  };
  /**
   * 任务表结构
   */
  static readonly TASK_TABLE: TableSchema = {
    tableName: 'taskTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS taskTable' +
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, task_name TEXT, ' +
      'subject INTEGER, start_date_stamp INTEGER, due_date_stamp INTEGER, ' +
      'is_completed BOOLEAN, detail TEXT, ddl_detail TEXT, category INTEGER)',
    columns: [
      'id',
      'task_name',
      'subject',
      'start_date_stamp',
      'due_date_stamp',
      'is_completed',
      'detail',
      'ddl_detail',
      'category'
    ]
  };
  /**
   * 分类表结构
   */
  static readonly CATEGORY_TABLE: TableSchema = {
    tableName: 'categoryTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS categoryTable' +
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, color TEXT, name TEXT)',
    columns: ['id', 'color', 'name']
  };
  /**
   * 列类型映射（用于数据库字段类型验证）
   */
  static readonly COLUMN_TYPE_MAP: Map<string, string> = new Map([
    ['id', 'integer'],
    ['due_date_stamp', 'integer'],
    ['start_date_stamp', 'integer'],
    ['category', 'integer'],
    ['subject', 'integer'],
    ['detail', 'string'],
    ['task_name', 'string'],
    ['is_completed', 'boolean'],
    ['ddl_detail', 'string']
  ]);
}
