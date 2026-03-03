# 日期时间选择器

## 介绍

集成日期选择器和时间选择器，一个弹窗可实现同时选择日期时间。

## 工程目录

```
├──dateTimePicker/src/main/ets                      // har包类型
│  ├──dialog
│  │  └──DateTimePickerDialog.ets                   // 日期时间选择器弹窗 
│  ├──model
│  │  └──PickerInterface.ets                        // 日期时间选择器参数接口     
│  ├──pages
│  │  └──DateTimePicker.ets                         // 日期时间选择器
│  └──utils
│     ├──DateTimeBase.ets                           // 日期时间基类
│     ├──DateTimeRange.ets                          // 日期时间范围
│     └──DateTimeSolar.ets                          // 日期时间公历类
├──dateTimePicker/src/main/resources                // 应用资源目录
│
├──entry/src/main/ets                               // 代码区
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──entrybackupablility 
│  │  └──EntryBackupAbility.ets
│  └──pages
│     └──Index.ets                                  // 演示
└──entry/src/main/resources                         // 应用资源目录
```