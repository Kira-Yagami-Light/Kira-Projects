/**
 * UI 界面相关常量
 */
export class UIConstants {
  /**
   * 分类颜色预设
   */
  static readonly CATEGORY_COLORS = [
    '#564AF7', // 紫色
    '#46B1E3', // 蓝色
    '#64BB5C', // 绿色
    '#A5D61D', // 黄绿色
    '#AC49F5', // 紫罗兰色
    '#E64566', // 玫红色
    '#E84026', // 红色
    '#ED6F21'// 橙色
  ];

  /**
   * 输入限制
   */
  static readonly MAX_TASK_NAME_LENGTH = 50;
  static readonly MAX_TASK_DETAIL_LENGTH = 500;
  static readonly MAX_CATEGORY_NAME_LENGTH = 20;

  /**
   * 动画时长（毫秒）
   */
  static readonly ANIMATION_DURATION_SHORT = 200;
  static readonly ANIMATION_DURATION_NORMAL = 300;
}
