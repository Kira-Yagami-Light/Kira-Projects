/**
 * DDL (Deadline) 紧急度相关常量
 */
export class DDLConstants {
  /**
   * 紧急度等级
   */
  static readonly LEVEL_EASY = 'easy';
  static readonly LEVEL_MEDIUM = 'medium';
  static readonly LEVEL_HARD = 'hard';
  static readonly LEVEL_CRITICAL = 'critical';

  /**
   * 紧急度颜色映射
   */
  static readonly COLOR_MAP: Map<string, string> = new Map([
    [DDLConstants.LEVEL_EASY, '#A5D61D'], // 绿色 - 该开始了
    [DDLConstants.LEVEL_MEDIUM, '#F7CE00'], // 黄色 - 还有时间
    [DDLConstants.LEVEL_HARD, '#F9A01E'], // 橙色 - 紧急
    [DDLConstants.LEVEL_CRITICAL, '#E84026']// 红色 - 非常紧急
  ]);

  /**
   * 默认紧急度阈值（正常模式）
   */
  static readonly DEFAULT_THRESHOLDS = '0.3-0.5-0.8';
}
