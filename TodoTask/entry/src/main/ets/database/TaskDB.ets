import relationalStore from '@ohos.data.relationalStore';
import Logger from '../common/Logger';
import CommonConstants from '../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';

export default class TaskDB {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;
  private RDB_TAG: string = '[DEBUG_RDB]';
  private StoreConfig: relationalStore.StoreConfig;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>,
    Config: relationalStore.StoreConfig = CommonConstants.STORE_CONFIG) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
    this.StoreConfig = Config;
  }

  getRdbStore(callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(this.RDB_TAG, 'getRdbStore() has no callback!');
      return;
    }
    if (this.rdbStore !== null) {
      callback();
      return;
    }
    let context: Context = getContext(this) as Context;
    relationalStore.getRdbStore(context, this.StoreConfig, (err, rdb) => {
      if (err) {
        Logger.error(this.RDB_TAG, `gerRdbStore() failed, err: ${err}`);
        return;
      }
      this.rdbStore = rdb;
      this.rdbStore.executeSql(this.sqlCreateTable);
      callback();
    })
  }

  updateColumns(newColumn: string, newColumnData: string) {
    if (!this.rdbStore) {
      return;
    }
    this.rdbStore.executeSql(`ALTER TABLE ${this.tableName} ADD COLUMN ${newColumn} ${newColumnData}`);
  }

  insertData(data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(this.RDB_TAG, 'insertData() has no callback!');
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = data
    if (this.rdbStore) {
      Logger.debug(this.RDB_TAG, this.tableName);
      this.rdbStore.insert(this.tableName, valueBucket, (err, ret) => {
        if (err) {
          Logger.error(this.RDB_TAG,
            `insertData() failed, err: ${err.code}, ${err.name}, ${err.message}, valueB = ${JSON.stringify(valueBucket)}, ret = ${ret}`);
          callback(false);
          return;
        }
        Logger.debug(this.RDB_TAG, `insert finished: ${ret}`);
        callback(ret);
      })
    }
  }

  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(this.RDB_TAG, 'deleteData() has no callback!');
      return;
    }
    if (this.rdbStore) {
      this.rdbStore.delete(predicates, (err, ret) => {
        if (err) {
          Logger.error(this.RDB_TAG, `deleteData() failed, err: ${err}`);
          callback(false);
          return;
        }
        Logger.info(this.RDB_TAG, `deleteData() finished: ${ret}`);
        callback(true);
      })
    }
  }

  updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(this.RDB_TAG, 'updateDate() has no callback!');
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = data
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicates, (err, ret) => {
        if (err) {
          Logger.error(this.RDB_TAG, `updateData() failed, err: ${err}`);
          callback(false);
          return;
        }
        Logger.info(this.RDB_TAG, `updateData() finished: ${ret}`);
        callback(true);
      })
    }
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {}) {
    if (!callback) {
      Logger.info(this.RDB_TAG, 'query() has no callback!');
      return;
    }
    if (this.rdbStore) {
      this.rdbStore.query(predicates).then((resultSet) => {
        Logger.debug(this.RDB_TAG, `query finished. RowCount: ${resultSet.rowCount}`);
        // No more resultSet.close()，Hand it over to the business layer for processing
        callback(resultSet);
      }).catch((err: BusinessError) => {
        Logger.error(this.RDB_TAG, `query failed, err: ${err}`);
      })
    }
  }
}