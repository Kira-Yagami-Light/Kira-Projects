import relationalStore from '@ohos.data.relationalStore';
import { TaskListData } from '../common/TaskListData';
import TaskDB from './TaskDB';
import CommonConstants from '../common/Constants';
import Logger from '../common/Logger';

export default class TaskTable {
  private taskTable = new TaskDB(CommonConstants.TASK_TABLE_INIT.tableName, CommonConstants.TASK_TABLE_INIT.sqlCreate,
    CommonConstants.TASK_TABLE_INIT.columns);

  constructor(callback: Function = () => {
  }) {
    this.taskTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {
  }) {
    this.taskTable.getRdbStore(callback);
  }

  updateColumns(newColumn: string, newColumnType: string) {
    let newColumnData: string = '';
    switch (newColumnType) {
      case 'double':
        newColumnData = 'INTEGER';
        break;
      case 'string':
        newColumnData = 'TEXT';
        break;
      case 'boolean':
        newColumnData = 'BOOLEAN';
      default:
        newColumnData = 'INTEGER';
    }
    Logger.debug(`UpdateColumns: ${newColumn} ${newColumnData}`);
    this.taskTable.updateColumns(newColumn, newColumnData);
  }

  insertData(taskData: TaskListData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(taskData);
    this.taskTable.insertData(valueBucket, callback);
  }

  deleteData(taskData: TaskListData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TASK_TABLE_INIT.tableName);
    predicates.equalTo('id', taskData.id);
    this.taskTable.deleteData(predicates, callback);
  }

  updateData(taskData: TaskListData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(taskData);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TASK_TABLE_INIT.tableName);
    predicates.equalTo('id', taskData.id);
    this.taskTable.updateData(predicates, valueBucket, callback);
  }

  queryTaskName(task_name: string, callback: Function, isAll: boolean = true) {
    let submit: TaskListData = new TaskListData();
    submit.task_name = task_name;
    this.basic_query('task_name', submit, callback, isAll);
  }

  basic_query(query_type: string, queryData: TaskListData, callback: Function, isAll?: boolean) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TASK_TABLE_INIT.tableName);

    // Handling query conditions
    if (!isAll && query_type !== '') {
      const columnType = CommonConstants.COLUMN_TYPE.get(query_type);

      if (columnType === 'string') {
        // Fuzzy query for task names
        predicates.like(query_type, `%${queryData.task_name}%`);
      } else {
        // Exact match on ID or category
        const val = (query_type === 'category') ? queryData.category : queryData.id;
        predicates.equalTo(query_type, val);
      }
    }

    this.taskTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      try {
        let count = resultSet.rowCount;
        if (count <= 0) {
          resultSet.close(); // Safety shutdown
          callback([]);
          return;
        }

        const result: TaskListData[] = [];
        resultSet.goToFirstRow();

        for (let i = 0; i < count; i++) {
          const record: Record<string, number | string | boolean> = {};

          // Assign values to all the columns defined in Constants
          CommonConstants.TASK_TABLE_INIT.columns.forEach((columnName) => {
            const columnIndex = resultSet.getColumnIndex(columnName);
            const columnType = CommonConstants.COLUMN_TYPE.get(columnName);

            if (columnType === 'string') {
              record[columnName] = resultSet.getString(columnIndex);
            } else if (columnType === 'boolean') {
              // Handling boolean value conversion
              record[columnName] = resultSet.getLong(columnIndex) === 1;
            } else {
              record[columnName] = resultSet.getDouble(columnIndex);
            }
          });

          result.push(TaskListData.fromRecord(record));
          resultSet.goToNextRow();
        }

        resultSet.close(); // Safety shutdown
        callback(result);
      } catch (e) {
        if (resultSet) resultSet.close();
        Logger.error('TaskTable Error: ' + e);
        callback([]);
      }
    })
  }
}

function generateBucket(taskData: TaskListData): relationalStore.ValuesBucket {
  const bucket: relationalStore.ValuesBucket = {
    start_date_stamp: taskData.start_date_stamp,
    due_date_stamp: taskData.due_date_stamp,
    detail: taskData.detail,
    subject: taskData.subject,
    task_name: taskData.task_name,
    is_completed: taskData.is_completed ? 1 : 0,
    ddl_detail: taskData.ddl_detail,
    category: taskData.category,
    topped: taskData.topped ? 1 : 0,
  };
  return bucket;
}