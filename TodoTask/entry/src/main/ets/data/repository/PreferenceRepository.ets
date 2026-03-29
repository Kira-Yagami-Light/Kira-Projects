import { PreferenceDao } from '../database/PreferenceDao';
import Logger from '../../common/util/Logger';
import { AppConstants } from '../../common/constants';

/**
 * 偏好设置数据仓库
 * 提供类型安全的偏好设置访问接口
 */
export class PreferenceRepository {
  private readonly LOG_TAG = '[PreferenceRepository]';
  private dao: PreferenceDao;

  constructor() {
    this.dao = new PreferenceDao();
  }

  /**
   * 初始化偏好设置存储
   */
  async init(): Promise<void> {
    try {
      await this.dao.init();
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      Logger.error(this.LOG_TAG, `Failed to initialize preference repository: ${error.message}`);
      throw error;
    }
  }

  /**
   * 检查是否是首次打开应用
   * @returns Promise<boolean> 是否首次打开
   */
  async isFirstOpen(): Promise<boolean> {
    try {
      const value = await this.dao.get(AppConstants.PREF_KEY_FIRST_OPEN, '');
      return value === '';
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to check first open: ${JSON.stringify(err)}`);
      return true;
    }
  }

  /**
   * 设置已打开过应用
   */
  async setAppOpened(): Promise<void> {
    try {
      await this.dao.put(AppConstants.PREF_KEY_FIRST_OPEN, 'true');
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to set app opened: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取当前数据库列信息
   * @returns Promise<string[]> 列名数组
   */
  async getCurrentColumns(): Promise<string[]> {
    try {
      const value = await this.dao.get(AppConstants.PREF_KEY_CURRENT_VERSION, '[]');
      return JSON.parse(value.toString());
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get current columns: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 保存当前数据库列信息
   * @param columns 列名数组
   */
  async saveCurrentColumns(columns: string[]): Promise<void> {
    try {
      await this.dao.put(AppConstants.PREF_KEY_CURRENT_VERSION, JSON.stringify(columns));
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to save current columns: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取语言设置
   * @returns Promise<string> 语言代码（如 'zh_CN', 'en_US'）
   */
  async getLanguage(): Promise<string> {
    try {
      const value = await this.dao.get(AppConstants.PREF_KEY_LANGUAGE, 'zh_CN');
      return value.toString();
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get language: ${JSON.stringify(err)}`);
      return 'zh_CN';
    }
  }

  /**
   * 设置语言
   * @param language 语言代码
   */
  async setLanguage(language: string): Promise<void> {
    try {
      await this.dao.put(AppConstants.PREF_KEY_LANGUAGE, language);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to set language: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取主题设置
   * @returns Promise<string> 主题名称
   */
  async getTheme(): Promise<string> {
    try {
      const value = await this.dao.get(AppConstants.PREF_KEY_THEME, 'light');
      return value.toString();
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get theme: ${JSON.stringify(err)}`);
      return 'light';
    }
  }

  /**
   * 设置主题
   * @param theme 主题名称
   */
  async setTheme(theme: string): Promise<void> {
    try {
      await this.dao.put(AppConstants.PREF_KEY_THEME, theme);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to set theme: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 通用的获取偏好设置方法
   * @param key 键
   * @param defaultValue 默认值
   * @returns Promise<string> 值
   */
  async getString(key: string, defaultValue: string = ''): Promise<string> {
    try {
      const value = await this.dao.get(key, defaultValue);
      return value.toString();
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to get preference: ${JSON.stringify(err)}`);
      return defaultValue;
    }
  }

  /**
   * 通用的保存偏好设置方法
   * @param key 键
   * @param value 值
   */
  async putString(key: string, value: string): Promise<void> {
    try {
      await this.dao.put(key, value);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to put preference: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 删除偏好设置
   * @param key 键
   */
  async remove(key: string): Promise<void> {
    try {
      await this.dao.delete(key);
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to remove preference: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 清除所有偏好设置
   */
  async clearAll(): Promise<void> {
    try {
      await this.dao.clear();
    } catch (err) {
      Logger.error(this.LOG_TAG, `Failed to clear all preferences: ${JSON.stringify(err)}`);
    }
  }
}
