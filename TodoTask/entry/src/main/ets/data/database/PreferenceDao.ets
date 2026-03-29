import dataPreferences from '@ohos.data.preferences';
import Logger from '../../common/util/Logger';

/**
 * 偏好设置数据访问对象
 * 负责与 Preferences 存储的交互
 */
export class PreferenceDao {
  private readonly LOG_TAG = '[PreferenceDao]';
  private preference: dataPreferences.Preferences | null = null;
  private readonly dbName: string = 'Pref.db';
  private isInitialized: boolean = false;

  /**
   * 初始化 Preferences 存储
   */
  async init(): Promise<void> {
    if (this.isInitialized && this.preference) {
      return;
    }

    try {
      const context: Context = getContext(this) as Context;
      this.preference = await dataPreferences.getPreferences(context, this.dbName);
      this.isInitialized = true;
      Logger.info(this.LOG_TAG, 'Preference storage initialized');
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to initialize preference storage: ${error.message}`);
      throw error;
    }
  }

  /**
   * 存储偏好设置
   * @param key 键
   * @param value 值
   */
  async put(key: string, value: string | number | boolean): Promise<void> {
    await this.ensureInitialized();

    try {
      await this.preference!.put(key, value);
      await this.preference!.flush();
      Logger.debug(this.LOG_TAG, `Preference saved: ${key}`);
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to save preference: ${error.message}`);
      throw error;
    }
  }

  /**
   * 获取偏好设置
   * @param key 键
   * @param defaultValue 默认值
   * @returns Promise<string | number | boolean> 值
   */
  async get(key: string, defaultValue: string | number | boolean = ''): Promise<string | number | boolean> {
    await this.ensureInitialized();

    try {
      const value = await this.preference!.get(key, defaultValue);
      Logger.debug(this.LOG_TAG, `Preference retrieved: ${key}`);

      // 处理 bigint 类型
      if (typeof value === 'bigint') {
        return Number(value);
      }

      return value as string | number | boolean;
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get preference: ${JSON.stringify(err)}`);
      return defaultValue;
    }
  }

  /**
   * 删除偏好设置
   * @param key 键
   */
  async delete(key: string): Promise<void> {
    await this.ensureInitialized();

    try {
      await this.preference!.delete(key);
      await this.preference!.flush();
      Logger.debug(this.LOG_TAG, `Preference deleted: ${key}`);
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to delete preference: ${error.message}`);
      throw error;
    }
  }

  /**
   * 检查偏好设置是否存在
   * @param key 键
   * @returns Promise<boolean> 是否存在
   */
  async has(key: string): Promise<boolean> {
    await this.ensureInitialized();

    try {
      return await this.preference!.has(key);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to check preference: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 清除所有偏好设置
   */
  async clear(): Promise<void> {
    await this.ensureInitialized();

    try {
      await this.preference!.clear();
      await this.preference!.flush();
      Logger.info(this.LOG_TAG, 'All preferences cleared');
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to clear preferences: ${error.message}`);
      throw error;
    }
  }

  /**
   * 确保 Preferences 已初始化
   */
  private async ensureInitialized(): Promise<void> {
    if (!this.isInitialized || !this.preference) {
      await this.init();
    }
  }
}
