/**
 * 常量统一导出入口
 */
import relationalStore from '@ohos.data.relationalStore';
import { DatabaseConstants, type TableSchema } from './DatabaseConstants';
import { DDLConstants } from './DDLConstants';
import { UIConstants } from './UIConstants';

export { DatabaseConstants, type TableSchema } from './DatabaseConstants';

export { DDLConstants } from './DDLConstants';

export { UIConstants } from './UIConstants';

export { AppConstants } from './AppConstants';

export default class Constants {
  // Database
  static readonly STORE_CONFIG: relationalStore.StoreConfig = DatabaseConstants.STORE_CONFIG;
  static readonly TASK_TABLE_INIT: TableSchema = DatabaseConstants.TASK_TABLE;
  static readonly CATEGORY_TABLE_INIT: TableSchema = DatabaseConstants.CATEGORY_TABLE;
  static readonly COLUMN_TYPE: Map<string, string> = DatabaseConstants.COLUMN_TYPE_MAP;
  // DDL
  static readonly DDL_COLOR: Map<string, string> = DDLConstants.COLOR_MAP;
  // UI
  static readonly CATEGORY_COLOR: string[] = UIConstants.CATEGORY_COLORS;
}
