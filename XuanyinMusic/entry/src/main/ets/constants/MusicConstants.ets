import {
  FavoriteListType,
  MomentListType,
  RankListType,
  RankSongItem,
  RecommendDailyType,
  RecommendListType,
  SongItemType
} from '../models/Music';
import { TabClass } from '../models/Tab';

export const SONG_KEY: string = 'song_key';

// TabBar 数据
export const TABS_DATA: TabClass[] = [
  {
    title: '首页',
    name: 'firstPage',
    icon: $r('app.media.ic_recommend_gt'),
    iconLight: $r('app.media.ic_recommend_pt')
  },
  {
    title: '最爱',
    name: 'favourite',
    icon: $r('app.media.ic_like_gt'),
    iconLight: $r('app.media.ic_like_pt')
  },
  {
    title: '社区',
    name: 'community',
    icon: $r('app.media.ic_moment_gt'),
    iconLight: $r('app.media.ic_moment_pt')
  },
  {
    title: '我的',
    name: 'mine',
    icon: $r('app.media.ic_mine_gt'),
    iconLight: $r('app.media.ic_mine_pt')
  }
];

// 歌曲列表
export const SONGS: SongItemType[] = [
  {
    img: $r('app.media.ic_img1'),
    name: 'だから僕は音楽を辞めた',
    author: 'ヨルシカ',
    src: '0001.mp3',
    id: '0001'
  },
  {
    img: $r('app.media.ic_img2'),
    name: 'Move Up (Lost Gravity)',
    author: 'Mr. Polska',
    src: '0002.mp3',
    id: '0002'
  },
  {
    img: $r('app.media.ic_img3'),
    name: '零距离的思念',
    author: 'TINY7',
    src: '0003.mp3',
    id: '0003'
  },
  {
    img: $r('app.media.ic_img4'),
    name: '白金ディスコ',
    author: '井口裕香',
    src: '0004.mp3',
    id: '0004'
  },
  {
    img: $r('app.media.ic_img5'),
    name: 'Wasted',
    author: 'Juice WRLD/Lil Uzi Vert',
    src: '0005.mp3',
    id: '0005'
  }
];

// 每日推荐数据
export const DAILY_RECOMMEND: RecommendDailyType[] = [
  {
    img: $r('app.media.ic_img1'),
    title: '日语',
    type: '现在就听',
    song: 'だから僕は音楽を辞めた - ヨルシカ',
    songItem: SONGS[0],
    bottom: 'rgba(0, 0, 0, 0.15)'
  },
  {
    img: $r('app.media.ic_img2'),
    title: '电音',
    type: '新歌推荐',
    song: 'Move Up (Lost Gravity) - Mr. Polska',
    songItem: SONGS[1],
    bottom: 'rgba(0, 0, 0, 0.15)'
  },
  {
    img: $r('app.media.ic_img3'),
    title: '国语',
    type: '新歌推荐',
    song: '零距离的思念 - TINY7',
    songItem: SONGS[2],
    bottom: 'rgba(0, 0, 0, 0.15)'
  }
];

// 推荐歌单数据
export const RECOMMEND_LIST: RecommendListType[] = [
  { img: $r('app.media.ic_img4'), title: '像蛇一样蹦跳玩耍', count: '43W' },
  { img: $r('app.media.ic_img5'), title: '向着大海的方向', count: '37W' },
  { img: $r('app.media.ic_img6'), title: '海风舔舐着肌肤', count: '25W' },
  { img: $r('app.media.ic_img7'), title: '置身黑暗怎能想你', count: '17W' },
  { img: $r('app.media.ic_img8'), title: '我们只剩下心', count: '19W' }
];

// 社区动态歌曲数据
export const SONGS_COMMENT: SongItemType[] = [
  {
    img: $r('app.media.ic_img1'),
    name: 'だから僕は音楽を辞めた',
    author: 'ヨルシカ',
    src: SONGS[0].src,
    id: 'c0001'
  },
  {
    img: $r('app.media.ic_img2'),
    name: 'Move Up (Lost Gravity)',
    author: 'Mr. Polska',
    src: SONGS[1].src,
    id: 'c0002'
  },
  {
    img: $r('app.media.ic_img3'),
    name: '零距离的思念',
    author: 'TINY7',
    src: SONGS[2].src,
    id: 'c0003'
  },
  {
    img: $r('app.media.ic_img4'),
    name: '白金ディスコ',
    author: '井口裕香',
    src: SONGS[3].src,
    id: 'c0004'
  },
  {
    img: $r('app.media.ic_img5'),
    name: 'Wasted',
    author: 'Juice WRLD/Lil Uzi Vert',
    src: SONGS[4].src,
    id: 'c0005'
  }
];

// 喜欢列表
export const FAVORITE_LIST: FavoriteListType = {
  name: '我喜欢的音乐',
  nickName: '玄酱',
  avatar: $r('app.media.ic_logo'),
  songs: SONGS
};

// 社区动态列表
export const MOMENT_LIST: MomentListType[] = [
  {
    author: '云端少女',
    avatar: $r("app.media.ic_img_user"),
    content: '日系忧郁系 | ヨルシカ新专必听',
    signature: '用音乐感受世界',
    song: SONGS_COMMENT[0]
  },
  {
    author: '深海回声',
    avatar: $r("app.media.ic_img_user"),
    content: '电音节拍 | 跑步必备能量神曲',
    signature: '声音是最美的语言',
    song: SONGS_COMMENT[1]
  },
  {
    author: '晨风独奏',
    avatar: $r("app.media.ic_img_user"),
    content: '清晨通勤必备 | 元气满满开启新一天',
    signature: '每天都要充满活力',
    song: SONGS_COMMENT[2]
  },
  {
    author: '蹦蹦跳跳',
    avatar: $r("app.media.ic_img_user"),
    content: '萌系旋律 | 舒缓一天的疲劳',
    signature: '二次元爱好者',
    song: SONGS_COMMENT[3]
  },
  {
    author: '霓虹漫步者',
    avatar: $r("app.media.ic_img_user"),
    content: '电子氛围 | 永不WASTED',
    signature: '节奏感是一切',
    song: SONGS_COMMENT[4]
  }
];

// 排行榜数据
export const RANK_LIST: RankListType[] = [
  {
    img: $r('app.media.ic_img1'),
    title1: 'APEX',
    title2: '热歌榜',
    count: '105746万',
    songs: [
      { song: 'だから僕は音楽を辞めた', author: 'ヨルシカ' } as RankSongItem,
      { song: 'Move Up (Lost Gravity)', author: 'Mr. Polska' } as RankSongItem,
      { song: '零距离的思念', author: 'TINY7' } as RankSongItem
    ]
  },
  {
    img: $r('app.media.ic_img2'),
    title1: 'APEX',
    title2: '新歌榜',
    count: '87320万',
    songs: [
      { song: '世间美好与你环环相扣', author: '柏松' } as RankSongItem,
      { song: '云与海', author: '行书Xingshu' } as RankSongItem,
      { song: '白月光与朱砂痣', author: '大籽' } as RankSongItem
    ]
  },
  {
    img: $r('app.media.ic_img3'),
    title1: 'APEX',
    title2: '飙升榜',
    count: '63481万',
    songs: [
      { song: '知足', author: '五月天' } as RankSongItem,
      { song: '说散就散', author: '袁小葱' } as RankSongItem,
      { song: '可能否', author: '鹿晗' } as RankSongItem
    ]
  },
  {
    img: $r('app.media.ic_img4'),
    title1: 'APEX',
    title2: '古风榜',
    count: '51209万',
    songs: [
      { song: '红昭愿', author: '音阙诗听' } as RankSongItem,
      { song: '江南', author: '林俊杰' } as RankSongItem,
      { song: '花田错', author: '弦子' } as RankSongItem
    ]
  },
  {
    img: $r('app.media.ic_img5'),
    title1: 'APEX',
    title2: '电音榜',
    count: '44867万',
    songs: [
      { song: 'Bad Guy', author: 'Billie Eilish' } as RankSongItem,
      { song: 'Levitating', author: 'Dua Lipa' } as RankSongItem,
      { song: 'Blinding Lights', author: 'The Weeknd' } as RankSongItem
    ]
  }
];
