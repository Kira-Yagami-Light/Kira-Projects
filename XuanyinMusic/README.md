# 玄音音乐

## 介绍

一款基于 HarmonyOS 原生开发的本地音乐播放器，界面风格参考主流音乐 App，具备完整的播放控制、歌词同步、播放队列管理等功能。

## 效果预览

<img src="Screenshots/show1.png" width="200">  <img src="Screenshots/show2.png" width="200">  <img src="Screenshots/show3.png" width="200">  

<img src="Screenshots/show4.png" width="200">  <img src="Screenshots/show5.png" width="200">  <img src="Screenshots/show6.png" width="200">  

## 技术实现

| 模块     | 技术方案                                                  |
|--------|-------------------------------------------------------|
| 音频播放   | AVPlayer 状态机（idle → initialized → prepared → playing） |
| 系统媒体控制 | AVSession（锁屏通知栏控制播放）                                  |
| 后台播放   | backgroundTaskManager AUDIO_PLAYBACK 模式               |
| 音频焦点   | audioInterrupt 事件处理来电/闹钟打断与恢复                         |
| 歌词解析   | 自实现 LRC 解析器，支持 `[mm:ss.xx]` 格式，过滤元数据行                 |
| 状态管理   | AppStorage + @StorageLink 跨组件共享，@Watch 手动同步 @State 字段 |
| 数据持久化  | Preferences 保存播放状态，退出应用时清空队列                          |
| 动画     | animateTo 显式动画 + Animator 帧动画驱动唱盘旋转                   |

## 工程目录

```
entry/src/main/ets/ 
├── components 
│   └── PlayerNav.ets                      // 模拟播放栏
├── constants 
│   └── MusicConstants.ets                 // 音乐数据 
├── entryability 
│   └── EntryAbility.ets 
├── entryformability 
│   └── EntryFormAbility.ets           
├── models 
│   ├── Tab.ets                            // 导航栏数据
│   ├── Music.ets                          // 音乐数据
│   └── PlayState.ets                      // 传输数据的结构 
├── pages 
│   ├── Community.ets                      // “社区”页 
│   ├── Favourite.ets                      // “最爱列表”页 
│   ├── FirstPage.ets                      // 首页 
│   ├── Mine.ets                           // “我的”页
│   ├── Play.ets                           // "播放"页 
│   └── MainPage.ets                       // 主页
└── utils 
    ├── AVPlayerManager.ets                // 播放器创建 
    ├── AVSessionManager.ets               // 媒体会话 
    └── Logger.ets                         // 日志
entry/src/main/resources/rawfile/
├── 0001.mp3 / 0001.lrc
├── 0002.mp3 / 0002.lrc
├── 0003.mp3 / 0003.lrc
├── 0004.mp3 / 0004.lrc
└── 0005.mp3 / 0005.lrc
```
