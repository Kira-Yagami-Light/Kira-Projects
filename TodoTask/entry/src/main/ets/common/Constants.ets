import relationalStore from '@ohos.data.relationalStore';

class DDLDetail {
  hint: string;
  detail: string;

  constructor(hint: string, detail: string) {
    this.hint = hint;
    this.detail = detail;
  }
}

// Database configuration
interface Table {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

export class DatabaseConfig {
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  static readonly PREF_STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'pref_database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  static readonly CATEGORY_STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'category_database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
}

export class TableConfig {
  static readonly TASK_TABLE: Table = {
    tableName: 'taskTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS taskTable' +
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, task_name TEXT, ' +
      'subject INTEGER, start_date_stamp INTEGER, due_date_stamp INTEGER, ' +
      'is_completed BOOLEAN, detail TEXT, ddl_detail TEXT, category INTEGER, topped BOOLEAN)',
    columns: ['id', 'due_date_stamp', 'start_date_stamp', 'subject', 'detail', 'task_name', 'is_completed',
      'ddl_detail', 'category', 'topped']
  };
  static readonly PREF_TABLE: Table = {
    tableName: 'prefTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS prefTable' +
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, pref TEXT)',
    columns: ['id', 'pref']
  };
  static readonly CATEGORY_TABLE: Table = {
    tableName: 'categoryTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS categoryTable' +
      '(id INTEGER PRIMARY KEY AUTOINCREMENT, color TEXT, name TEXT)',
    columns: ['id', 'color', 'name']
  };
}

// DDL Relevant configurations
export class DDLConfig {
  // Color mapping
  static readonly COLOR: Map<string, string> = new Map([
    ['easy', '#A5D61D'],
    ['medium', '#F7CE00'],
    ['hard', '#F9A01E'],
    ['critical', '#E84026']
  ]);
  // Default options
  static readonly PRESETS: Array<DDLDetail> = [
    new DDLDetail('不急', '0.2-0.45-0.6'),
    new DDLDetail('放松', '0.2-0.5-0.8'),
    new DDLDetail('正常', '0.3-0.5-0.8'),
    new DDLDetail('紧张', '0.3-0.75-0.9'),
    new DDLDetail('困难', '0.5-0.8-0.99')
  ];
}

// Column type mapping
export class ColumnType {
  static readonly MAP: Map<string, string> = new Map([
    ['id', 'double'],
    ['due_date_stamp', 'double'],
    ['start_date_stamp', 'double'],
    ['category', 'double'],
    ['subject', 'string'],
    ['detail', 'string'],
    ['task_name', 'string'],
    ['is_completed', 'boolean'],
    ['ddl_detail', 'string'],
    ['topped', 'boolean'],
  ]);
}

// Color classification preset
export class CategoryConfig {
  static readonly COLORS = [
    '#564AF7',
    '#46B1E3',
    '#64BB5C',
    '#A5D61D',
    '#AC49F5',
    '#E64566',
    '#E84026',
    '#ED6F21'
  ];
}

// Log tag
export class LogConfig {
  static readonly RDB_TAG = '[DebugRDB]';
}

// Backup configuration
export class BackupConfig {
  static readonly FILEPATH = 'Document/TodoTask/backup/';
  static readonly FILENAME = 'backup.png';
}

export default class Constants {
  // Database
  static readonly STORE_CONFIG = DatabaseConfig.STORE_CONFIG;
  static readonly PREF_STORE_CONFIG = DatabaseConfig.PREF_STORE_CONFIG;
  static readonly CATEGORY_STORE_CONFIG = DatabaseConfig.CATEGORY_STORE_CONFIG;
  static readonly TASK_TABLE_INIT = TableConfig.TASK_TABLE;
  static readonly PREF_TABLE_INIT = TableConfig.PREF_TABLE;
  static readonly CATEGORY_TABLE_INIT = TableConfig.CATEGORY_TABLE;
  // DDL
  static readonly DDL_COLOR = DDLConfig.COLOR;
  static readonly DDL_DETAIL_PRESET = DDLConfig.PRESETS;
  // Column type
  static readonly COLUMN_TYPE = ColumnType.MAP;
  // Classification
  static readonly CATEGORY_COLOR = CategoryConfig.COLORS;
  // Log
  static readonly RDB_TAG = LogConfig.RDB_TAG;
  // Backup
  static readonly BACKUP_FILEPATH = BackupConfig.FILEPATH;
  static readonly BACKUP_FILE = BackupConfig.FILENAME;
  // UI
  static readonly COLOR_DEFAULT = '#f1f2f3';
}