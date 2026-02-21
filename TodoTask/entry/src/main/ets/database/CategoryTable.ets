import relationalStore from '@ohos.data.relationalStore';
import TaskCategoryData from '../common/TaskCategoryData';
import TaskDB from './TaskDB';
import CommonConstants from '../common/Constants';
import Logger from '../common/Logger';

export default class CategoryTable {
  private cateTable =
    new TaskDB(CommonConstants.CATEGORY_TABLE_INIT.tableName, CommonConstants.CATEGORY_TABLE_INIT.sqlCreate,
      CommonConstants.CATEGORY_TABLE_INIT.columns, CommonConstants.CATEGORY_STORE_CONFIG);

  constructor(callback: Function = () => {
  }) {
    this.cateTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {
  }) {
    this.cateTable.getRdbStore(callback);
  }

  insertData(prefData: TaskCategoryData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucketWithoutId(prefData);
    this.cateTable.insertData(valueBucket, callback);
  }

  deleteData(prefData: TaskCategoryData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.CATEGORY_TABLE_INIT.tableName);
    predicates.equalTo('id', prefData.id);
    this.cateTable.deleteData(predicates, callback);
  }

  updateData(prefData: TaskCategoryData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(prefData);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.CATEGORY_TABLE_INIT.tableName);
    predicates.equalTo('id', prefData.id);
    this.cateTable.updateData(predicates, valueBucket, callback);
  }

  query(queryID: number, callback: Function) {
    let tmp = new TaskCategoryData();
    tmp.id = queryID;
    this.basic_query('id', tmp, callback, (queryID === 0));
  }

  private basic_query(query_type: string, queryData: TaskCategoryData, callback: Function, isAll: boolean = true) {
    Logger.debug(`TaskTable query_type: ${query_type},  query_data: ${JSON.stringify(queryData)},  visit: ${queryData.id}`);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.CATEGORY_TABLE_INIT.tableName);
    if (!isAll) {
      switch (query_type) {
        case 'id':
          predicates.like('id', queryData.id.toString());
          break;
        case 'name':
          predicates.like('name', queryData.name);
          break;
        case 'color':
          predicates.like('color', queryData.color);
          break;
      }
    }
    this.cateTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      Logger.debug(`Category Table number: ${count}`);
      if (count === 0 || typeof count === 'string') {
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: TaskCategoryData[] = [];
        for (let i = 0; i < count; ++i) {
          let tmp: TaskCategoryData = new TaskCategoryData();
          for (let t = 0; t < CommonConstants.CATEGORY_TABLE_INIT.columns.length; ++t) {
            const nowColumn = CommonConstants.CATEGORY_TABLE_INIT.columns[t];
            const nowIndex = resultSet.getColumnIndex(nowColumn);

            switch (nowColumn) {
              case 'id':
                tmp.id = resultSet.getDouble(nowIndex);
                break;
              case 'name':
                tmp.name = resultSet.getString(nowIndex);
                break;
              case 'color':
                tmp.color = resultSet.getString(nowIndex);
                break;
            }
          }
          result[i] = tmp;
          Logger.debug(`CateTable Reading DATA: ${JSON.stringify(tmp)}`);
          resultSet.goToNextRow();
        }
        callback(result)
      }
    })
  }
}

function generateBucketWithoutId(data: TaskCategoryData): relationalStore.ValuesBucket {
  const obj: relationalStore.ValuesBucket = {
    name: data.name,
    color: data.color
  };
  return obj;
}

// Only for update
function generateBucket(data: TaskCategoryData): relationalStore.ValuesBucket {
  const map = new Map<string, string | number>([
    ['id', data.id],
    ['name', data.name],
    ['color', data.color]
  ]);
  const obj: relationalStore.ValuesBucket = {};
  map.forEach((val, key) => {
    obj[key] = val;
  });
  return obj;
}
