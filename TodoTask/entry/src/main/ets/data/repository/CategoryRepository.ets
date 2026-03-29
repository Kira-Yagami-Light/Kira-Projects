import relationalStore from '@ohos.data.relationalStore';
import TaskCategoryData from '../../model/CategoryModel';
import { CategoryDao } from '../database/CategoryDao';
import Logger from '../../common/util/Logger';

/**
 * 分类数据仓库
 * 封装业务逻辑，提供高层次的数据访问接口
 */
export class CategoryRepository {
  private readonly LOG_TAG = '[CategoryRepository]';
  private dao: CategoryDao;

  constructor() {
    this.dao = new CategoryDao();
  }

  /**
   * 获取所有分类
   * @returns Promise<Array<TaskCategoryData>> 分类模型数组
   */
  async getAllCategories(): Promise<Array<TaskCategoryData>> {
    try {
      const records = await this.dao.queryAll();
      return records.map(r => this.recordToModel(r));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get all categories: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 根据 ID 获取分类
   * @param id 分类 ID
   * @returns Promise<TaskCategoryData | null> 分类模型或 null
   */
  async getCategoryById(id: number): Promise<TaskCategoryData | null> {
    try {
      const record = await this.dao.queryById(id);
      return record ? this.recordToModel(record) : null;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get category by ID: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 根据名称搜索分类
   * @param name 分类名称（支持模糊匹配）
   * @returns Promise<Array<TaskCategoryData>> 分类模型数组
   */
  async searchCategoriesByName(name: string): Promise<Array<TaskCategoryData>> {
    try {
      const records = await this.dao.queryByName(name);
      return records.map(r => this.recordToModel(r));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to search categories: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 插入分类
   * @param category 分类模型
   * @returns Promise<boolean> 是否成功，成功后 category.id 会被设置为新 ID
   */
  async insertCategory(category: TaskCategoryData): Promise<boolean> {
    try {
      const valueBucket = this.toValueBucket(category);
      const rowId = await this.dao.insert(valueBucket);

      if (rowId > 0) {
        category.id = rowId;
        Logger.info(this.LOG_TAG, `Category inserted with ID: ${rowId}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to insert category: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 更新分类
   * @param category 分类模型
   * @returns Promise<boolean> 是否成功
   */
  async updateCategory(category: TaskCategoryData): Promise<boolean> {
    try {
      const valueBucket = this.toValueBucket(category);
      const updatedRows = await this.dao.update(category.id, valueBucket);

      if (updatedRows > 0) {
        Logger.info(this.LOG_TAG, `Category updated: ${category.id}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to update category: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 删除分类
   * @param id 分类 ID
   * @returns Promise<boolean> 是否成功
   */
  async deleteCategory(id: number): Promise<boolean> {
    try {
      const deletedRows = await this.dao.deleteById(id);

      if (deletedRows > 0) {
        Logger.info(this.LOG_TAG, `Category deleted: ${id}`);
        return true;
      }
      return false;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to delete category: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 将 TaskCategoryData 转换为 ValuesBucket
   * @param category 分类模型
   * @returns relationalStore.ValuesBucket
   */
  private toValueBucket(category: TaskCategoryData): relationalStore.ValuesBucket {
    return {
      name: category.name,
      color: category.color
    };
  }

  /**
   * 将数据库记录转换为 CategoryModel
   * @param record 数据库记录
   * @returns TaskCategoryData
   */
  private recordToModel(record: Record<string, number | string>): TaskCategoryData {
    const category = new TaskCategoryData();
    category.id = Number(record.id ?? 0);
    category.name = String(record.name ?? '默认清单');
    category.color = String(record.color ?? '#000000');
    return category;
  }
}
