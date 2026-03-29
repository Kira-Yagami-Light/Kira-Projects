/**
 * DDL 详情数据模型
 * 用于表示紧急度预设选项
 */
export class DDLDetailModel {
  hint: string;
  detail: string;

  constructor(hint: string, detail: string) {
    this.hint = hint;
    this.detail = detail;
  }
}
