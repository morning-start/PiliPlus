# 数据模型 (Models)

## 概述

PiliPlus 项目使用了两套数据模型系统：
1. **传统模型** (`lib/models`): 基础数据模型，包含抽象类和简单实现
2. **新模型** (`lib/models_new`): 详细的数据模型，对应API响应结构

数据模型采用 Dart 类定义，支持 JSON 序列化和反序列化，为应用提供类型安全的数据结构。

## 模型架构

### 1. 传统模型 (lib/models)

传统模型采用抽象基类和具体实现的方式，定义了通用的数据结构：

#### 基础抽象类

```dart
// 基础视频项模型
abstract class BaseSimpleVideoItemModel {
  late String title;
  String? bvid;
  int? cid;
  String? cover;
  int duration = -1;
  late BaseOwner owner;
  late BaseStat stat;
}

// 扩展视频项模型
abstract class BaseVideoItemModel extends BaseSimpleVideoItemModel {
  int? aid;
  String? desc;
  int? pubdate;
  bool isFollowed = false;
}

// 基础所有者模型
abstract class BaseOwner {
  int? mid;
  String? name;
}

// 基础统计模型
abstract class BaseStat {
  int? view;
  int? like;
  int? danmu;
}
```

#### 具体实现类

```dart
class Stat extends BaseStat {
  Stat.fromJson(Map<String, dynamic> json) {
    view = json["view"];
    like = json["like"];
    danmu = json['danmaku'];
  }
}

class PlayStat extends BaseStat {
  PlayStat.fromJson(Map<String, dynamic> json) {
    view = json['play'];
    danmu = json['danmaku'];
  }
}
```

### 2. 新模型 (lib/models_new)

新模型更贴近 API 响应结构，每个模型对应特定的 API 接口：

```dart
class VideoDetailData {
  String? bvid;
  int? aid;
  int? videos;
  int? tid;
  String? tname;
  String? title;
  int? pubdate;
  String? desc;
  Owner? owner;
  VideoStat? stat;
  // ... 更多字段

  factory VideoDetailData.fromJson(Map<String, dynamic> json) =>
      VideoDetailData(
        bvid: json['bvid'] as String?,
        aid: json['aid'] as int?,
        title: json['title'] as String?,
        owner: json['owner'] == null
            ? null
            : Owner.fromJson(json['owner'] as Map<String, dynamic>),
        stat: json['stat'] == null
            ? null
            : VideoStat.fromJson(json['stat'] as Map<String, dynamic>),
        // ... 更多字段映射
      );
}
```

## 主要模型分类

### 1. 通用模型 (common)

通用模型包含应用中广泛使用的数据类型和枚举：

#### 枚举类型

- **账户类型** (`account_type.dart`): 用户账户类型定义
- **徽章类型** (`badge_type.dart`): 用户徽章类型
- **弹幕屏蔽类型** (`dm_block_type.dart`): 弹幕屏蔽规则类型
- **收藏夹类型** (`fav_type.dart`): 收藏夹类型
- **关注排序类型** (`follow_order_type.dart`): 关注列表排序方式
- **主题类型** (`theme/theme_type.dart`): 应用主题类型
- **视频类型** (`video/video_type.dart`): 视频内容类型

#### 配置模型

- **导航栏配置** (`nav_bar_config.dart`): 导航栏配置
- **超级分辨率类型** (`super_resolution_type.dart`): 视频超分辨率设置

### 2. 视频模型 (video)

#### 传统视频模型

- **基础视频模型** (`model_video.dart`): 视频基础数据结构
- **推荐视频项** (`model_rec_video_item.dart`): 推荐视频项模型
- **热门视频项** (`model_hot_video_item.dart`): 热门视频项模型
- **所有者模型** (`model_owner.dart`): 视频UP主信息

#### 新视频模型

- **视频详情** (`video_detail/`): 视频详细信息
  - `data.dart`: 视频详情主体数据
  - `arc.dart`: 视频归档信息
  - `owner.dart`: UP主信息
  - `stat.dart`: 统计数据
  - `rights.dart`: 版权信息
  - `page.dart`: 视频分页信息
  - `dimension.dart`: 视频分辨率信息

- **视频播放信息** (`video_play_info/`): 视频播放相关数据
  - `data.dart`: 播放信息主体
  - `subtitle.dart`: 字幕信息
  - `interaction.dart`: 互动信息

- **视频AI摘要** (`video_ai_conclusion/`): 视频AI生成摘要
  - `data.dart`: AI摘要主体数据
  - `outline.dart`: 摘要大纲
  - `subtitle.dart`: 摘要字幕

### 3. 用户模型 (user)

- **用户信息** (`info.dart`): 用户基本信息
- **用户统计** (`stat.dart`): 用户统计数据
- **弹幕屏蔽** (`danmaku_block.dart`): 用户弹幕屏蔽设置
- **弹幕规则** (`danmaku_rule.dart`): 弹幕过滤规则

### 4. 动态模型 (dynamics)

- **动态结果** (`result.dart`): 动态列表响应
- **UP主信息** (`up.dart`): 动态UP主信息
- **投票模型** (`vote_model.dart`): 动态投票数据
- **文章内容** (`article_content_model.dart`): 动态文章内容

### 5. 收藏模型 (fav)

#### 收藏夹模型

- **收藏夹详情** (`fav_detail/`): 收藏夹详细信息
  - `data.dart`: 收藏夹主体数据
  - `info.dart`: 收藏夹基本信息
  - `media.dart`: 媒体内容信息

- **视频收藏** (`fav_video/`): 视频收藏相关
- **文章收藏** (`fav_article/`): 文章收藏相关
- **番剧收藏** (`fav_pgc/`): 番剧收藏相关
- **笔记收藏** (`fav_note/`): 笔记收藏相关
- **话题收藏** (`fav_topic/`): 话题收藏相关

### 6. 直播模型 (live)

- **直播间信息** (`live_room_info_h5/`): 直播间详细信息
- **直播播放信息** (`live_room_play_info/`): 直播流播放信息
- **直播弹幕** (`live_danmaku/`): 直播弹幕数据
- **直播区域** (`live_area_list/`): 直播分区列表
- **直播关注** (`live_follow/`): 关注的直播间
- **直播搜索** (`live_search/`): 直播搜索结果

### 7. 搜索模型 (search)

- **搜索结果** (`result.dart`): 搜索结果数据
- **搜索建议** (`suggest.dart`): 搜索建议数据

### 8. 历史模型 (history)

- **历史记录项** (`list.dart`): 历史记录列表项
- **历史记录详情** (`history.dart`): 历史记录详细信息

### 9. 空间模型 (space)

- **用户空间视频** (`space_archive/`): 用户空间视频列表
- **用户空间系列** (`space_season_series/`): 用户空间视频系列
- **用户空间收藏** (`space_fav/`): 用户空间收藏夹

## 模型使用示例

### 1. 视频详情模型使用

```dart
// 从API获取视频详情
final response = await Api.getVideoDetail(bvid: 'BV1234567890');
final videoDetail = VideoDetailData.fromJson(response.data);

// 访问视频信息
print('视频标题: ${videoDetail.title}');
print('UP主: ${videoDetail.owner?.name}');
print('播放量: ${videoDetail.stat?.view}');

// 更新视频信息
final updatedVideo = videoDetail.copyWith(
  title: '新标题',
);
```

### 2. 动态模型使用

```dart
// 获取动态列表
final response = await Api.getDynamicsList();
final dynamicsData = DynamicsDataModel.fromJson(response.data);

// 遍历动态列表
for (final dynamicItem in dynamicsData.items ?? []) {
  final author = dynamicItem.modules.moduleAuthor;
  final content = dynamicItem.modules.moduleDynamic?.desc?.text;
  
  print('作者: ${author?.name}');
  print('内容: $content');
}
```

### 3. 搜索模型使用

```dart
// 搜索视频
final response = await Api.searchVideo(keyword: 'Flutter');
final searchResult = SearchResultModel.fromJson(response.data);

// 处理搜索结果
for (final video in searchResult.list ?? []) {
  print('标题: ${video.title}');
  print('作者: ${video.author}');
  print('播放量: ${video.play}');
}
```

## 模型生成工具

### 1. JSON 序列化代码生成

使用 `json_serializable` 包自动生成序列化代码：

```yaml
# pubspec.yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

```dart
import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final String bvid;
  final int aid;
  final String? title;
  
  VideoModel({
    required this.bvid,
    required this.aid,
    this.title,
  });
  
  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$VideoModelToJson(this);
}
```

运行代码生成：

```bash
flutter packages pub run build_runner build
```

### 2. Freezed 模型生成

使用 `freezed` 包生成不可变模型：

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  freezed: ^2.4.6
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String bvid,
    required int aid,
    String? title,
  }) = _VideoModel;
  
  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}
```

## 模型扩展与工具

### 1. 扩展方法

为模型添加便捷的扩展方法：

```dart
extension VideoExtension on VideoDetailData {
  // 格式化播放时长
  String get durationFormatted {
    if (duration == null) return '--:--';
    final minutes = (duration! ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  // 格式化播放量
  String get viewCountFormatted {
    if (stat?.view == null) return '0';
    final count = stat!.view!;
    if (count < 10000) {
      return count.toString();
    } else if (count < 100000000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    }
  }
}
```

### 2. 模型转换

在不同模型之间进行转换：

```dart
// 从视频详情转换为推荐项
RecVideoItemModel toRecVideoItem(VideoDetailData video) {
  return RecVideoItemModel(
    bvid: video.bvid,
    aid: video.aid,
    title: video.title,
    cover: video.pic,
    duration: video.duration,
    owner: video.owner?.name,
  );
}

// 从历史记录转换为视频项
VideoItemModel fromHistoryItem(HistoryItemModel history) {
  return VideoItemModel(
    bvid: history.history.bvid,
    aid: history.history.aid,
    title: history.title,
    cover: history.cover,
    duration: history.duration,
    progress: history.progress,
  );
}
```

## 常见问题与解决方案

### 1. JSON 解析错误

**问题**: API 返回的数据结构与模型不匹配

**解决方案**: 
- 使用可空类型处理可能缺失的字段
- 提供默认值处理异常数据
- 添加数据验证逻辑

```dart
class VideoModel {
  late String bvid;
  late String title;
  
  VideoModel.fromJson(Map<String, dynamic> json) {
    bvid = json['bvid'] ?? '';
    title = json['title'] ?? '未知标题';
    
    // 验证必要字段
    if (bvid.isEmpty) {
      throw ArgumentError('视频BV号不能为空');
    }
  }
}
```

### 2. 模型嵌套过深

**问题**: 模型嵌套层级过多导致访问困难

**解决方案**: 
- 使用扩展方法提供便捷访问
- 创建扁平化的视图模型
- 使用计算属性简化访问

```dart
class VideoDetailModel {
  final VideoData video;
  final OwnerData owner;
  final StatData stat;
  
  // 计算属性提供便捷访问
  String get ownerName => owner.name ?? '';
  int get viewCount => stat.view ?? 0;
  String get coverUrl => video.pic ?? '';
}

// 扩展方法
extension VideoDetailExtension on VideoDetailModel {
  String get displayTitle {
    if (video.title?.isNotEmpty == true) {
      return video.title!;
    }
    return '无标题';
  }
}
```

### 3. 模型更新困难

**问题**: 不可变模型更新复杂

**解决方案**: 
- 使用 copyWith 方法
- 使用 Freezed 自动生成 copyWith
- 对于复杂更新使用构建器模式

```dart
class VideoModel {
  final String bvid;
  final String title;
  final int viewCount;
  final bool isLiked;
  
  VideoModel({
    required this.bvid,
    required this.title,
    required this.viewCount,
    this.isLiked = false,
  });
  
  VideoModel copyWith({
    String? bvid,
    String? title,
    int? viewCount,
    bool? isLiked,
  }) {
    return VideoModel(
      bvid: bvid ?? this.bvid,
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

// 使用 copyWith 更新模型
final updatedVideo = video.copyWith(
  viewCount: video.viewCount + 1,
  isLiked: true,
);
```

### 4. 性能优化

**问题**: 大量模型创建和序列化影响性能

**解决方案**: 
- 使用 const 构造函数
- 实现缓存机制
- 使用 Isolate 进行复杂计算

```dart
// 使用 const 构造函数
@immutable
class VideoModel {
  final String bvid;
  final String title;
  
  const VideoModel({
    required this.bvid,
    required this.title,
  });
}

// 实现缓存
class ModelCache {
  static final Map<String, VideoModel> _cache = {};
  
  static VideoModel getVideo(String bvid) {
    return _cache.putIfAbsent(
      bvid,
      () => VideoModel(bvid: bvid, title: '加载中...'),
    );
  }
}
```

## 最佳实践

1. **使用类型安全**: 尽量使用强类型，避免使用 `dynamic`
2. **处理空值**: 合理使用可空类型和默认值
3. **模型分离**: 将大型模型拆分为更小的单元
4. **序列化优化**: 使用代码生成工具处理 JSON 序列化
5. **文档注释**: 为模型字段添加详细的文档注释
6. **单元测试**: 为模型编写单元测试，确保序列化正确性
7. **版本兼容**: 考虑 API 版本兼容性，处理字段变更

## 总结

PiliPlus 的数据模型系统提供了类型安全、结构化的数据表示方式，支持复杂业务场景。通过合理的模型设计和工具使用，可以高效地处理应用中的数据流转和状态管理。无论是传统模型还是新模型，都遵循了良好的设计原则，为应用提供了稳定可靠的数据基础。