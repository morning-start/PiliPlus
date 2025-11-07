# 页面 (Pages)

## 概述

PiliPlus 项目的页面层位于 `lib/pages` 目录下，采用 MVC 架构模式组织代码。每个功能模块通常包含 view.dart（视图层）和 controller.dart（控制器层）文件，复杂页面还会包含 widgets 子目录存放自定义组件。

## 页面架构

### 基本结构

每个页面模块通常遵循以下结构：

```
pages/
├── 功能模块/
│   ├── controller.dart      # 控制器，处理业务逻辑和状态管理
│   ├── view.dart           # 视图层，UI展示
│   └── widgets/            # 自定义组件（可选）
│       ├── component1.dart
│       └── component2.dart
```

### MVC 架构

- **Model**: 数据模型，主要在 `lib/models` 目录下定义
- **View**: 视图层，负责UI展示，对应各模块的 `view.dart` 文件
- **Controller**: 控制器层，处理业务逻辑和状态管理，对应各模块的 `controller.dart` 文件

## 主要页面模块

### 1. 核心页面

#### 主页 (main)
- **文件**: `pages/main/`
- **功能**: 应用主界面，包含底部导航栏和主要页面容器
- **组件**: 主页布局、导航栏、页面切换逻辑

#### 首页 (home)
- **文件**: `pages/home/`
- **功能**: 推荐内容展示，包括视频、直播、文章等推荐
- **组件**: 推荐列表、分类标签、刷新控件

#### 热门 (hot)
- **文件**: `pages/hot/`
- **功能**: 热门内容排行榜，展示各类热门视频和内容
- **组件**: 排行榜列表、分类切换、时间筛选

### 2. 视频相关页面

#### 视频播放 (video)
- **文件**: `pages/video/`
- **功能**: 视频播放页面，包含播放器、弹幕、评论等
- **组件**: 视频播放器、弹幕系统、评论区、推荐视频

#### 视频详情 (video_detail)
- **文件**: `pages/video_detail/`
- **功能**: 视频详细信息展示，包括简介、UP主信息、相关推荐等
- **组件**: 视频信息卡片、UP主信息、相关推荐列表

### 3. 用户相关页面

#### 用户中心 (member)
- **文件**: `pages/member/`
- **功能**: 用户个人信息展示，包括头像、昵称、个人简介等
- **组件**: 用户信息卡片、统计数据、操作按钮

#### 用户主页 (member_home)
- **文件**: `pages/member_home/`
- **功能**: 用户个人主页，展示用户发布的视频、动态等内容
- **组件**: 内容列表、分类标签、统计信息

#### 登录 (login)
- **文件**: `pages/login/`
- **功能**: 用户登录界面，支持多种登录方式
- **组件**: 登录表单、验证码输入、第三方登录按钮

### 4. 动态相关页面

#### 动态列表 (dynamics)
- **文件**: `pages/dynamics/`
- **功能**: 展示关注用户的动态内容
- **组件**: 动态列表、发布按钮、刷新控件

#### 动态详情 (dynamics_detail)
- **文件**: `pages/dynamics_detail/`
- **功能**: 单条动态的详细内容展示
- **组件**: 动态内容、评论列表、点赞转发等交互

#### 创建动态 (dynamics_create)
- **文件**: `pages/dynamics_create/`
- **功能**: 发布新动态的编辑界面
- **组件**: 文本编辑器、图片上传、话题选择

### 5. 收藏相关页面

#### 收藏夹 (fav)
- **文件**: `pages/fav/`
- **功能**: 用户收藏夹列表管理
- **组件**: 收藏夹列表、创建收藏夹、收藏夹分类

#### 收藏夹详情 (fav_detail)
- **文件**: `pages/fav_detail/`
- **功能**: 单个收藏夹的内容展示
- **组件**: 收藏内容列表、排序选项、批量操作

### 6. 直播相关页面

#### 直播间 (live_room)
- **文件**: `pages/live_room/`
- **功能**: 直播观看界面，包含视频流、弹幕、礼物等
- **组件**: 直播播放器、弹幕系统、礼物面板、观众列表

#### 直播分类 (live_area)
- **文件**: `pages/live_area/`
- **功能**: 直播分区和直播间列表
- **组件**: 分区导航、直播间列表、筛选选项

### 7. 搜索相关页面

#### 搜索 (search)
- **文件**: `pages/search/`
- **功能**: 搜索输入界面，包含搜索建议和历史记录
- **组件**: 搜索框、搜索建议、历史记录

#### 搜索结果 (search_result)
- **文件**: `pages/search_result/`
- **功能**: 搜索结果展示，支持多种内容类型
- **组件**: 结果列表、分类筛选、排序选项

### 8. 设置相关页面

#### 设置 (setting)
- **文件**: `pages/setting/`
- **功能**: 应用设置中心，包含各类配置选项
- **组件**: 设置列表、开关控件、选择器

#### 视频设置 (video_setting)
- **文件**: `pages/video_setting/`
- **功能**: 视频播放相关设置
- **组件**: 播放器设置、清晰度选项、弹幕设置

### 9. 通用页面

#### 通用列表 (common)
- **文件**: `pages/common/`
- **功能**: 提供通用的列表页面和控制器
- **组件**: 通用列表视图、数据加载控制器、下拉刷新

#### 网页视图 (webview)
- **文件**: `pages/webview/`
- **功能**: 内嵌浏览器页面，用于展示网页内容
- **组件**: WebView容器、导航栏、加载指示器

## 页面开发模式

### 1. 控制器模式

每个页面通常有一个对应的控制器，使用 GetX 的 GetxController：

```dart
class VideoController extends GetxController {
  // 状态变量
  final Rx<VideoInfo?> videoInfo = Rx<VideoInfo?>(null);
  final RxBool isLoading = false.obs;
  final RxList<Comment> comments = <Comment>[].obs;
  
  // 业务逻辑方法
  Future<void> loadVideo(String bvid) async {
    isLoading.value = true;
    try {
      final result = await VideoApi.getVideoInfo(bvid);
      videoInfo.value = result;
    } catch (e) {
      // 错误处理
    } finally {
      isLoading.value = false;
    }
  }
  
  // 生命周期
  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑
  }
}
```

### 2. 视图构建

视图层使用 GetBuilder 或 Obx 响应状态变化：

```dart
class VideoView extends GetView<VideoController> {
  const VideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频详情')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final video = controller.videoInfo.value;
        if (video == null) {
          return const Center(child: Text('视频不存在'));
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              VideoPlayer(video: video),
              VideoInfo(video: video),
              CommentList(comments: controller.comments),
            ],
          ),
        );
      }),
    );
  }
}
```

### 3. 路由绑定

在路由配置中绑定页面和控制器：

```dart
CustomGetPage(
  name: '/video',
  page: () => const VideoView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => VideoController());
  }),
)
```

## 通用组件

### 1. 通用控制器

`pages/common/` 目录下提供了多个通用控制器：

- **CommonController**: 基础控制器，提供通用功能
- **CommonDataController**: 数据加载控制器，处理分页和刷新
- **CommonListController**: 列表控制器，管理列表状态和数据
- **CommonSearchController**: 搜索控制器，处理搜索逻辑

### 2. 通用页面

- **CommonPage**: 通用页面结构，包含加载、错误、空数据状态
- **CommonSearchPage**: 通用搜索页面，提供搜索输入和结果展示

### 3. 通用功能

- **多选功能**: `common/multi_select/` 提供多选操作支持
- **发布功能**: `common/publish/` 提供内容发布相关组件
- **滑动页面**: `common/slide/` 提供滑动交互支持

## 页面间通信

### 1. 参数传递

通过路由参数传递数据：

```dart
// 发送页面
Get.toNamed('/video', arguments: {'bvid': 'BV1234567890'});

// 接收页面
class VideoController extends GetxController {
  late String bvid;
  
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    bvid = args?['bvid'] ?? '';
    loadVideo();
  }
}
```

### 2. 结果返回

页面间返回结果：

```dart
// 发送页面并等待结果
final result = await Get.toNamed('/search');
if (result != null) {
  // 处理返回结果
}

// 目标页面返回结果
Get.back(result: selectedData);
```

### 3. 服务共享

通过共享的服务进行页面间通信：

```dart
// 在服务中定义状态和方法
class VideoService extends GetxService {
  final Rx<VideoInfo?> currentVideo = Rx<VideoInfo?>(null);
  
  void playVideo(VideoInfo video) {
    currentVideo.value = video;
  }
}

// 在不同页面中使用
class VideoListController extends GetxController {
  final VideoService videoService = Get.find();
  
  void onVideoTap(VideoInfo video) {
    videoService.playVideo(video);
    Get.toNamed('/video');
  }
}

class VideoController extends GetxController {
  final VideoService videoService = Get.find();
  
  VideoInfo? get video => videoService.currentVideo.value;
}
```

## 页面性能优化

### 1. 懒加载

使用 Get.lazyPut 实现控制器的懒加载：

```dart
CustomGetPage(
  name: '/video',
  page: () => const VideoView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => VideoController());
  }),
)
```

### 2. 自动释放

使用 GetxController 的自动释放机制：

```dart
class VideoController extends GetxController {
  // 控制器会在页面销毁时自动释放
  
  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
}
```

### 3. 状态管理优化

合理使用 Obx 和 GetBuilder：

```dart
// Obx 适用于细粒度响应
Obx(() => Text(controller.count.toString()))

// GetBuilder 适用于整体重建
GetBuilder<VideoController>(
  builder: (controller) => VideoPlayer(video: controller.video),
)
```

## 最佳实践

1. **单一职责**: 每个控制器只负责一个页面的逻辑
2. **状态分离**: 将UI状态和业务状态分离管理
3. **错误处理**: 统一的错误处理和用户提示
4. **资源管理**: 及时释放不需要的资源和监听器
5. **代码复用**: 提取通用逻辑到基类或工具类
6. **测试友好**: 编写易于测试的控制器和视图

## 常见问题与解决方案

### 1. 页面重建问题

**问题**: 页面不必要的重建导致性能问题

**解决方案**: 
- 合理使用 Obx 和 GetBuilder
- 将不变的部分提取为独立组件
- 使用 const 构造函数

```dart
// 错误做法：整个页面使用 Obx
Obx(() => Scaffold(
  appBar: AppBar(title: Text('Title')), // 标题不需要响应状态变化
  body: Text(controller.count.toString()),
))

// 正确做法：只对需要响应的部分使用 Obx
Scaffold(
  appBar: AppBar(title: const Text('Title')),
  body: Obx(() => Text(controller.count.toString())),
)
```

### 2. 控制器生命周期

**问题**: 控制器未正确释放导致内存泄漏

**解决方案**: 
- 使用 GetxController 的生命周期方法
- 在页面销毁时手动释放资源

```dart
class VideoController extends GetxController {
  StreamSubscription? _subscription;
  
  @override
  void onInit() {
    super.onInit();
    _subscription = someStream.listen((data) {
      // 处理数据
    });
  }
  
  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
```

### 3. 页面间数据传递

**问题**: 复杂数据在页面间传递困难

**解决方案**: 
- 使用服务共享数据
- 对于简单数据使用路由参数
- 对于复杂数据使用全局状态管理

```dart
// 使用服务共享数据
class DataService extends GetxService {
  final RxMap<String, dynamic> sharedData = <String, dynamic>{}.obs;
  
  void setData(String key, dynamic value) {
    sharedData[key] = value;
  }
  
  T? getData<T>(String key) {
    return sharedData[key] as T?;
  }
}
```