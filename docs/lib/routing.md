# 路由管理文档

## 概述

PiliPlus 项目使用 GetX 框架的路由系统进行页面导航和跳转，结合自定义路由处理类实现了灵活的页面跳转逻辑。项目支持多种路由跳转方式，包括命名路由、URL解析、协议跳转等，为用户提供了流畅的导航体验。

## 核心架构

### 1. 路由定义与配置

#### 路由表定义

路由表定义在 `lib/router/app_pages.dart` 文件中：

```dart
class Routes {
  static final List<GetPage<dynamic>> getPages = [
    CustomGetPage(name: '/', page: () => const MainApp()),
    CustomGetPage(name: '/home', page: () => const HomePage()),
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    CustomGetPage(name: '/videoV', page: () => const VideoDetailPageV()),
    // ... 更多路由定义
  ];
}
```

#### 自定义路由页面

项目使用 `CustomGetPage` 类扩展了 GetX 的 `GetPage`，添加了自定义过渡效果：

```dart
class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    bool fullscreen = false,
    super.transitionDuration,
  }) : super(
         curve: Curves.linear,
         transition: pageTransition,
         showCupertinoParallax: false,
         popGesture: false,
         fullscreenDialog: fullscreen,
       );
  static Transition pageTransition = Transition.values[Pref.pageTransition];
}
```

### 2. 路由跳转工具类

#### PageUtils 工具类

`lib/utils/page_utils.dart` 文件中的 `PageUtils` 类提供了各种页面跳转的便捷方法：

- `toDupNamed` - 命名路由跳转，支持参数传递
- `toVideoPage` - 视频页面跳转
- `toLiveRoom` - 直播间跳转
- `viewPgc` - PGC内容（番剧）查看
- `pushDynDetail` - 动态详情跳转
- `handleWebview` - WebView页面处理

#### 应用协议处理

`lib/utils/app_scheme.dart` 文件中的 `PiliScheme` 类处理应用协议跳转：

```dart
abstract final class PiliScheme {
  static late AppLinks appLinks;
  static StreamSubscription? listener;
  
  static void init() {
    appLinks = AppLinks();
    listener?.cancel();
    listener = appLinks.uriLinkStream.listen(routePush);
  }
  
  static Future<bool> routePush(Uri uri, {...}) async {
    // 处理各种协议跳转
  }
}
```

## 路由跳转方式

### 1. 命名路由跳转

```dart
// 基本命名路由跳转
Get.toNamed('/home');

// 带参数的命名路由跳转
Get.toNamed('/member', parameters: {'mid': '123456'});

// 替换当前路由
Get.offNamed('/loginPage');

// 清除所有路由并跳转
Get.offAllNamed('/home');
```

### 2. URL解析跳转

项目支持解析各种URL格式并进行相应页面跳转：

```dart
// 解析B站视频URL
PageUtils.matchUrlPush('https://www.bilibili.com/video/BV1xx411c7mD');

// 解析直播间URL
PageUtils.matchUrlPush('https://live.bilibili.com/123456');

// 解析用户空间URL
PageUtils.matchUrlPush('https://space.bilibili.com/123456');
```

### 3. 应用协议跳转

支持处理 `bilibili://` 协议的深度链接：

```dart
// 视频协议
bilibili://video/BV1xx411c7mD

// 用户空间协议
bilibili://space/123456

// 直播间协议
bilibili://live/123456

// 番剧协议
bilibili://pgc/season/ss12345
```

## 特殊路由处理

### 1. 视频路由处理

视频路由处理支持多种参数和场景：

```dart
static void toVideoPage({
  String? bvid,
  int? aid,
  int? cid,
  String? pic,
  int? progress,
  bool off = false,
  Map? arguments,
}) {
  // 视频页面跳转逻辑
}
```

### 2. 动态路由处理

动态路由根据不同类型跳转到相应页面：

```dart
static Future<void> pushDynDetail(
  DynamicItemModel item, {
  bool isPush = false,
}) async {
  // 根据动态类型跳转不同页面
  switch (item.type) {
    case 'DYNAMIC_TYPE_AV':
      // 视频动态
      break;
    case 'DYNAMIC_TYPE_ARTICLE':
      // 专栏文章
      break;
    // ... 其他类型
  }
}
```

### 3. PGC内容路由处理

处理番剧、电影等PGC内容：

```dart
static Future<void> viewPgc({
  String? seasonId,
  String? epId,
  String? progress,
}) {
  // PGC内容跳转逻辑
}
```

## 路由参数传递

### 1. 查询参数

通过URL查询参数传递数据：

```dart
Get.toNamed('/searchResult?keyword=flutter');
```

### 2. 路径参数

通过路径参数传递数据：

```dart
Get.toNamed('/member/123456');
```

### 3. 参数对象

通过arguments传递复杂对象：

```dart
Get.toNamed('/videoDetail', arguments: {
  'videoItem': videoItem,
  'autoPlay': true,
});
```

## 路由中间件与拦截

### 1. 登录状态检查

某些页面需要登录状态，可以在路由跳转前检查：

```dart
void checkLoginAndNavigate(String route) {
  if (Get.find<AccountService>().isLogin.value) {
    Get.toNamed(route);
  } else {
    Get.toNamed('/loginPage');
  }
}
```

### 2. 路由守卫

通过GetX的中间件功能实现路由守卫：

```dart
GetMaterialApp(
  // ...
  routingCallback: (routing) {
    // 路由变化回调
  },
);
```

## 路由最佳实践

### 1. 路由命名规范

- 使用小写字母和下划线
- 路由名应具有描述性
- 保持路由名简洁明了

```dart
'/home'           // 首页
'/video_detail'   // 视频详情
'/user_profile'   // 用户资料
```

### 2. 参数传递规范

- 使用有意义的参数名
- 复杂数据使用arguments传递
- 避免在URL中传递敏感信息

### 3. 路由组织

- 按功能模块组织路由
- 使用路由常量避免硬编码
- 定期清理未使用的路由

## 常见问题与解决方案

### 1. 路由不匹配

**问题**：定义的路由与实际使用不一致

**解决方案**：
- 检查路由表定义
- 确保路由名称完全匹配
- 使用路由常量避免拼写错误

### 2. 参数传递失败

**问题**：路由参数无法正确接收

**解决方案**：
- 检查参数名称是否一致
- 确保参数格式正确
- 使用正确的参数获取方式

### 3. 页面返回异常

**问题**：页面返回时出现异常

**解决方案**：
- 检查页面栈是否正确
- 确保使用正确的返回方法
- 处理可能的空页面栈情况

## 总结

PiliPlus 项目的路由系统基于 GetX 框架，通过自定义路由类和工具类实现了灵活多样的页面跳转功能。项目支持命名路由、URL解析、协议跳转等多种跳转方式，并提供了完善的参数传递机制。通过遵循路由命名规范和最佳实践，可以确保路由系统的稳定性和可维护性。