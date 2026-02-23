export interface LyricLine {
  time: number;
  text: string;
}

export interface SongItemType {
  img: ResourceStr;
  name: string;
  author: string;
  src: string;
  id: string;
}

export interface RecommendListType {
  img: ResourceStr;
  title: string;
  count: string;
}

export interface RecommendDailyType {
  img: ResourceStr;
  title: string;
  type: string;
  song: string;
  bottom: string;
}

export interface FavoriteListType {
  name: string;
  nickName: string;
  avatar: ResourceStr;
  songs: SongItemType[];
}

export interface MomentListType {
  author: string;
  avatar: ResourceStr;
  content: string;
  signature: string;
  song: SongItemType;
}

export interface RankSongItem {
  song: string;
  author: string;
}

export interface RankListType {
  img: ResourceStr;
  title1: string;
  title2: string;
  count: string;
  songs: RankSongItem[];
}

// =============================================
// Model 类（合并 interface + Model）
// =============================================

export class SongItemTypeModel implements SongItemType {
  img: ResourceStr = '';
  name: string = '';
  author: string = '';
  src: string = '';
  id: string = '';

  constructor(model?: SongItemType) {
    if (model) {
      this.img = model.img;
      this.name = model.name;
      this.author = model.author;
      this.src = model.src;
      this.id = model.id;
    }
  }
}

export class RecommendListTypeModel implements RecommendListType {
  img: ResourceStr = '';
  title: string = '';
  count: string = '';

  constructor(model?: RecommendListType) {
    if (model) {
      this.img = model.img;
      this.title = model.title;
      this.count = model.count;
    }
  }
}

export class RecommendDailyTypeModel implements RecommendDailyType {
  img: ResourceStr = '';
  title: string = '';
  type: string = '';
  song: string = '';
  bottom: string = '';

  constructor(model?: RecommendDailyType) {
    if (model) {
      this.img = model.img;
      this.title = model.title;
      this.type = model.type;
      this.song = model.song;
      this.bottom = model.bottom;
    }
  }
}

export class FavoriteListTypeModel implements FavoriteListType {
  name: string = '';
  nickName: string = '';
  avatar: ResourceStr = '';
  songs: SongItemType[] = [];

  constructor(model?: FavoriteListType) {
    if (model) {
      this.name = model.name;
      this.nickName = model.nickName;
      this.avatar = model.avatar;
      this.songs = model.songs;
    }
  }
}

export class MomentListTypeModel implements MomentListType {
  author: string = '';
  avatar: ResourceStr = '';
  content: string = '';
  signature: string = '';
  song: SongItemType = new SongItemTypeModel();

  constructor(model?: MomentListType) {
    if (model) {
      this.author = model.author;
      this.avatar = model.avatar;
      this.content = model.content;
      this.signature = model.signature;
      this.song = model.song;
    }
  }
}

export class RankSongItemModel implements RankSongItem {
  song: string = '';
  author: string = '';

  constructor(model?: RankSongItem) {
    if (model) {
      this.song = model.song;
      this.author = model.author;
    }
  }
}

export class RankListTypeModel implements RankListType {
  img: ResourceStr = '';
  title1: string = '';
  title2: string = '';
  count: string = '';
  songs: RankSongItem[] = [];

  constructor(model?: RankListType) {
    if (model) {
      this.img = model.img;
      this.title1 = model.title1;
      this.title2 = model.title2;
      this.count = model.count;
      this.songs = model.songs;
    }
  }
}
