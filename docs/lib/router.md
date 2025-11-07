# 路由 (Router)

## 概述

PiliPlus 项目使用 GetX 的路由管理系统，结合自定义路由处理和应用协议处理，实现了灵活的页面导航和深度链接功能。路由系统支持页面跳转、参数传递、动画过渡和外部链接处理等多种功能。

## 路由架构

### 1. 路由定义

项目中的路由定义主要位于 `lib/router/app_pages.dart` 文件中：

```dart
class Routes {
  static final List<GetPage<dynamic>> getPages = [
    CustomGetPage(name: '/', page: () => const MainApp()),
    // 首页(推荐)
    CustomGetPage(name: '/home', page: () => const HomePage()),
    // 热门
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    CustomGetPage(name: '/videoV', page: () => const VideoDetailPageV()),
    // 设置
    CustomGetPage(name: '/setting', page: () => const SettingPage()),
    // 收藏
    CustomGetPage(name: '/fav', page: () => const FavPage()),
    // 收藏详情
    CustomGetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    CustomGetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    CustomGetPage(name: '/history', page: () => const HistoryPage()),
    // 搜索页面
    CustomGetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    CustomGetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    CustomGetPage(name: '/dynamics', page: () => const DynamicsPage()),
    // 动态详情
    CustomGetPage(name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    CustomGetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    CustomGetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    CustomGetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    CustomGetPage(name: '/member', page: () => const MemberPage()),
    // 更多页面...
  ];
}
```

### 2. 自定义路由页面

项目使用 `CustomGetPage` 类扩展了 GetX 的路由页面：

```dart
class CustomGetPage<T> extends GetPage<T> {
  CustomGetPage({
    required String name,
    required GetPageBuilder<T> page,
    Transition? transition,
    bool? opaque,
    bool? popGesture,
    Bindings? binding,
    Duration? transitionDuration,
    Curve? transitionCurve,
    List<Bindings>? bindings,
    bool fullscreenDialog = false,
    bool preventDuplicates = true,
    bool showCupertinoParallax = true,
  }) : super(
          name: name,
          page: page,
          transition: transition ?? Transition.rightToLeft,
          opaque: opaque ?? true,
          popGesture: popGesture ?? true,
          binding: binding,
          transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
          transitionCurve: transitionCurve ?? Curves.easeInOut,
          bindings: bindings,
          fullscreenDialog: fullscreenDialog,
          preventDuplicates: preventDuplicates,
          showCupertinoParallax: showCupertinoParallax,
        );
}
```

### 3. 应用协议处理

`lib/utils/app_scheme.dart` 文件处理应用协议和深度链接：

```dart
abstract final class PiliScheme {
  static late AppLinks appLinks;
  static StreamSubscription? listener;
  static final uriDigitRegExp = RegExp(r'/(\d+)');
  static final _prefixRegex = RegExp(r'^\S+://');

  static void init() {
    appLinks = AppLinks();
    listener?.cancel();
    listener = appLinks.uriLinkStream.listen(routePush);
  }

  /// 路由跳转
  static Future<bool> routePush(
    Uri uri, {
    bool selfHandle = false,
    bool off = false,
    Map? parameters,
    int? businessId,
    int? oid,
  }) async {
    final String scheme = uri.scheme;
    final String host = uri.host;
    final String path = uri.path;

    switch (scheme) {
      case 'bilibili':
        switch (host) {
          case 'root':
            Navigator.popUntil(
              Get.context!,
              (Route<dynamic> route) => route.isFirst,
            );
            return true;
          case 'pgc':
            // 处理番剧链接
            String? id = uriDigitRegExp.firstMatch(path)?.group(1);
            if (id != null) {
              bool isEp = path.contains('/ep/');
              PageUtils.viewPgc(
                seasonId: isEp ? null : id,
                epId: isEp ? id : null,
                progress: uri.queryParameters['start_progress'],
              );
              return true;
            }
            return false;
          case 'space':
            // 处理用户空间链接
            String? mid = uriDigitRegExp.firstMatch(path)?.group(1);
            if (mid != null) {
              if (path.startsWith('/realname')) {
                RequestUtils.showUserRealName(mid);
                return true;
              }
              PageUtils.toDupNamed('/member?mid=$mid', off: off);
              return true;
            }
            return false;
          case 'video':
            // 处理视频链接
            final queryParameters = uri.queryParameters;
            if (queryParameters['comment_root_id'] != null) {
              // 跳转到视频评论
              String? oid = uriDigitRegExp.firstMatch(path)?.group(1);
              int? rpid = int.tryParse(queryParameters['comment_root_id']!);
              if (oid != null && rpid != null) {
                VideoReplyReplyPanel.toReply(
                  oid: int.parse(oid),
                  rootId: rpid,
                  rpIdStr: queryParameters['comment_secondary_id'],
                  type: 1,
                  uri: uri.replace(query: ''),
                );
                return true;
              }
              return false;
            }

            // 跳转到视频页面
            String? aid = uriDigitRegExp.firstMatch(path)?.group(1);
            String? bvid = IdUtils.bvRegex.firstMatch(path)?.group(0);
            if (aid != null || bvid != null) {
              final cid = queryParameters['cid'];
              if (cid != null) {
                bvid ??= IdUtils.av2bv(int.parse(aid!));
                final progress = queryParameters['dm_progress'];
                PageUtils.toVideoPage(
                  bvid: bvid,
                  cid: int.parse(cid),
                  progress: progress == null ? null : int.parse(progress),
                  off: off,
                );
              } else {
                videoPush(
                  aid != null ? int.parse(aid) : null,
                  bvid,
                  off: off,
                  progress: queryParameters['dm_progress'],
                );
              }
              return true;
            }
            return false;
          // 其他协议处理...
        }
      case 'http' || 'https':
        return _fullPathPush(
          uri,
          selfHandle: selfHandle,
          off: off,
          parameters: parameters,
        );
      default:
        // 默认处理逻辑
        return false;
    }
  }
}
```

## 页面导航工具

### 1. PageUtils 类

`lib/utils/page_utils.dart` 提供了页面导航的辅助方法：

```dart
abstract class PageUtils {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  // 图片预览
  static Future<void> imageView({
    int initialPage = 0,
    required List<SourceModel> imgList,
    int? quality,
  }) {
    return Get.key.currentState!.push<void>(
      HeroDialogRoute(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InteractiveviewerGallery(
              sources: imgList,
              initIndex: initialPage,
              quality: quality ?? GlobalData().imgQuality,
            ),
      ),
    );
  }

  // 视频页面跳转
  static Future<void> toVideoPage({
    String? bvid,
    int? aid,
    int? cid,
    int? progress,
    String? pic,
    String? title,
    String? desc,
    String? owner,
    int? mid,
    bool off = false,
    bool? isLive,
  }) async {
    await Get.toNamed(
      '/videoV',
      arguments: {
        'videoId': bvid ?? aid,
        'cid': cid,
        'progress': progress,
        'pic': pic,
        'title': title,
        'desc': desc,
        'owner': owner,
        'mid': mid,
        'isLive': isLive,
      },
      preventDuplicates: false,
    );
  }

  // 直播间跳转
  static Future<void> toLiveRoom(
    int roomId, {
    bool off = false,
  }) async {
    await Get.toNamed(
      '/liveRoom',
      arguments: {'roomId': roomId},
      preventDuplicates: false,
    );
  }

  // 番剧页面跳转
  static Future<void> viewPgc({
    String? seasonId,
    String? epId,
    String? progress,
  }) async {
    await Get.toNamed(
      '/pgc',
      arguments: {
        'seasonId': seasonId,
        'epId': epId,
        'progress': progress,
      },
      preventDuplicates: false,
    );
  }

  // 通用页面跳转方法
  static Future<T?> toDupNamed<T>(
    String page, {
    Object? arguments,
    bool preventDuplicates = true,
    bool off = false,
    Map<String, String>? parameters,
    dynamic Function(dynamic)? then,
  }) async {
    if (off) {
      return await Get.offNamed<T>(
        page,
        arguments: arguments,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
      );
    }
    return await Get.toNamed<T>(
      page,
      arguments: arguments,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  // 定时关闭功能
  static void scheduleExit(
    BuildContext context,
    isFullScreen, [
    bool isLive = false,
  ]) {
    // 实现定时关闭逻辑
  }
}
```

## 路由类型

### 1. 页面路由

页面路由是应用中最常见的路由类型，用于在不同页面之间导航：

```dart
// 基本页面跳转
Get.toNamed('/home');

// 带参数的页面跳转
Get.toNamed('/videoV', arguments: {'bvid': 'BV1234567890'});

// 替换当前页面
Get.offNamed('/login');

// 清除所有页面并跳转
Get.offAllNamed('/home');

// 返回上一页
Get.back();

// 返回并携带结果
Get.back(result: 'success');
```

### 2. 弹窗路由

弹窗路由用于显示模态对话框或底部表单：

```dart
// 显示对话框
Get.dialog(AlertDialog(
  title: Text('提示'),
  content: Text('这是一个对话框'),
));

// 显示底部表单
Get.bottomSheet(
  Container(
    height: 200,
    child: Center(child: Text('底部表单')),
  ),
);

// 显示自定义路由
Get.to(
  CustomDialog(),
  fullscreenDialog: true,
);
```

### 3. 嵌套路由

嵌套路由用于在页面内实现子导航：

```dart
// 使用 GetX 的嵌套路由
Get.to(
  GetPageRoute(
    page: () => ParentPage(),
    children: [
      GetPage(name: '/child1', page: () => Child1Page()),
      GetPage(name: '/child2', page: () => Child2Page()),
    ],
  ),
);
```

## 路由参数传递

### 1. 路径参数

路径参数直接嵌入在路由路径中：

```dart
// 定义路由
CustomGetPage(name: '/user/:id', page: () => UserPage()),

// 跳转并传递参数
Get.toNamed('/user/123'),

// 在目标页面获取参数
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取路径参数
    final String userId = Get.parameters['id'] ?? '';
    return Text('用户ID: $userId');
  }
}
```

### 2. 查询参数

查询参数以键值对形式附加在URL后面：

```dart
// 跳转并传递查询参数
Get.toNamed('/search', parameters: {'keyword': 'Flutter', 'page': '1'}),

// 在目标页面获取查询参数
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String keyword = Get.parameters['keyword'] ?? '';
    final int page = int.tryParse(Get.parameters['page'] ?? '0') ?? 0;
    return Text('搜索关键词: $keyword, 页码: $page');
  }
}
```

### 3. 参数对象

通过 `arguments` 传递复杂对象：

```dart
// 跳转并传递对象
Get.toNamed('/videoDetail', arguments: {
  'video': VideoModel(id: '123', title: '视频标题'),
  'autoplay': true,
}),

// 在目标页面获取参数
class VideoDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final VideoModel video = args['video'] as VideoModel;
    final bool autoplay = args['autoplay'] as bool;
    return Column(
      children: [
        Text('视频标题: ${video.title}'),
        Text('自动播放: $autoplay'),
      ],
    );
  }
}
```

## 路由中间件

### 1. 路由守卫

路由守卫用于在导航前进行权限检查或其他逻辑处理：

```dart
// 定义路由守卫
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 检查用户是否已登录
    if (!UserService.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

// 应用路由守卫
CustomGetPage(
  name: '/profile',
  page: () => ProfilePage(),
  middlewares: [AuthMiddleware()],
),
```

### 2. 路由拦截器

路由拦截器可以在导航前后执行自定义逻辑：

```dart
class LoggingMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    print('导航到页面: ${page?.name}');
    return page;
  }

  @override
  void onPageDispose() {
    print('页面销毁');
  }
}
```

## 路由动画

### 1. 内置过渡动画

GetX 提供了多种内置过渡动画：

```dart
CustomGetPage(
  name: '/page',
  page: () => MyPage(),
  transition: Transition.rightToLeft, // 从右到左
  // transition: Transition.fade, // 淡入淡出
  // transition: Transition.size, // 缩放
  // transition: Transition.topToBottom, // 从上到下
  // transition: Transition.zoom, // 缩放
  transitionDuration: Duration(milliseconds: 500),
  transitionCurve: Curves.easeInOut,
),
```

### 2. 自定义过渡动画

可以创建自定义的过渡动画：

```dart
class CustomTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve ?? Curves.linear,
      )),
      child: child,
    );
  }
}

// 使用自定义过渡
CustomGetPage(
  name: '/page',
  page: () => MyPage(),
  transition: Transition.custom,
  customTransition: CustomTransition(),
),
```

## 深度链接

### 1. 应用协议注册

应用通过 `app_links` 插件处理深度链接：

```dart
// 在 main.dart 中初始化
void main() async {
  await PiliScheme.init();
  runApp(MyApp());
}
```

### 2. URL 处理

`PiliScheme` 类处理各种 URL 格式：

```dart
// bilibili://video/BV1234567890
// bilibili://space/12345678
// bilibili://live/123456
// https://www.bilibili.com/video/BV1234567890
```

## 最佳实践

### 1. 路由命名规范

- 使用有意义的路由名称，如 `/videoDetail` 而不是 `/page1`
- 保持路由名称的一致性，全部使用小写和下划线
- 为相关路由添加前缀，如 `/setting/general`、`/setting/privacy`

### 2. 参数传递规范

- 对于简单数据，使用路径参数或查询参数
- 对于复杂对象，使用 `arguments` 传递
- 避免在 URL 中传递敏感信息

### 3. 路由组织

- 按功能模块组织路由，将相关路由放在一起
- 为复杂页面创建单独的路由文件
- 使用常量定义路由名称，避免硬编码

### 4. 错误处理

- 为无效路由提供默认页面或错误提示
- 在路由守卫中处理异常情况
- 记录路由导航日志，便于调试

## 常见问题与解决方案

### 1. 路由不匹配

**问题**: 输入的路由名称与定义的路由不匹配

**解决方案**: 检查路由名称是否正确，确保大小写和拼写无误

```dart
// 确保路由名称一致
CustomGetPage(name: '/videoDetail', page: () => VideoDetailPage()),
Get.toNamed('/videoDetail'); // 正确
// Get.toNamed('/video_details'); // 错误
```

### 2. 参数传递失败

**问题**: 传递的参数在目标页面中无法获取

**解决方案**: 检查参数传递方式和类型转换

```dart
// 使用 arguments 传递复杂对象
Get.toNamed('/page', arguments: {'key': 'value'});

// 在目标页面正确获取
final args = Get.arguments as Map<String, dynamic>;
final value = args['key'];
```

### 3. 深度链接不工作

**问题**: 点击深度链接无法打开应用或跳转到正确页面

**解决方案**: 确保应用协议已正确注册，且路由处理逻辑正确

```dart
// 检查协议处理逻辑
static Future<bool> routePush(Uri uri) async {
  // 添加日志输出
  print('处理深度链接: $uri');
  
  // 确保所有情况都有返回值
  switch (uri.host) {
    case 'video':
      // 处理视频链接
      return true;
    default:
      // 未知链接处理
      return false;
  }
}
```

### 4. 页面重复创建

**问题**: 多次点击导致同一页面被重复创建

**解决方案**: 使用 `preventDuplicates` 参数防止重复创建

```dart
Get.toNamed(
  '/page',
  preventDuplicates: true, // 防止重复创建
);
```