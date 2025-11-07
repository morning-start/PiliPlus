# 工具类 (Utils)

## 概述

PiliPlus 项目中的 `lib/utils` 目录包含了各种工具类和辅助函数，为整个应用提供通用功能支持。这些工具类涵盖了存储、扩展方法、全局数据、主题、网络请求、日期时间处理等多个方面，是项目基础设施的重要组成部分。

## 工具类架构

### 1. 核心工具类

#### 1.1 Utils 类

`utils.dart` 提供了应用中最基础的工具函数：

```dart
abstract class Utils {
  static final Random random = Random();
  
  // 平台检测
  @pragma("vm:platform-const")
  static final bool isMobile = Platform.isAndroid || Platform.isIOS;
  
  @pragma("vm:platform-const")
  static final bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  // 网络状态检测
  static Future<bool> get isWiFi async {
    try {
      return Utils.isMobile &&
          (await Connectivity().checkConnectivity()).contains(
            ConnectivityResult.wifi,
          );
    } catch (_) {
      return true;
    }
  }
  
  // 颜色解析
  static Color parseColor(String color) =>
      Color(int.parse(color.replaceFirst('#', 'FF'), radix: 16));
  
  // 设备信息获取
  static Future<int> get sdkInt async {
    return _sdkInt ??= (await DeviceInfoPlugin().androidInfo).version.sdkInt;
  }
  
  // 文本复制
  static Future<void> copyText(
    String text, {
    bool needToast = true,
    String? toastText,
  }) {
    if (needToast) {
      SmartDialog.showToast(toastText ?? '已复制');
    }
    return Clipboard.setData(ClipboardData(text: text));
  }
  
  // 文本分享
  static Future<void> shareText(String text) async {
    if (Utils.isDesktop) {
      copyText(text);
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: await sharePositionOrigin),
      );
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }
}
```

#### 1.2 全局数据管理

`global_data.dart` 使用单例模式管理全局数据：

```dart
class GlobalData {
  int imgQuality = Pref.picQuality;
  num? coins;
  Set<int> blackMids = Pref.blackMids;
  bool dynamicsWaterfallFlow = Pref.dynamicsWaterfallFlow;

  void afterCoin(num coin) {
    if (coins != null) {
      coins = coins! - coin;
    }
  }

  // 私有构造函数
  GlobalData._();

  // 单例实例
  static final GlobalData _instance = GlobalData._();

  // 获取全局实例
  factory GlobalData() => _instance;
}
```

### 2. 扩展方法

#### 2.1 基础类型扩展

`extension.dart` 提供了丰富的扩展方法：

```dart
// 滚动控制器扩展
extension ScrollControllerExt on ScrollController {
  void animToTop() => animTo(0);

  void animTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    if (!hasClients) return;
    if ((offset - this.offset).abs() >= position.viewportDimension * 7) {
      jumpTo(offset);
    } else {
      animateTo(
        offset,
        duration: duration,
        curve: Curves.easeInOut,
      );
    }
  }

  void jumpToTop() {
    if (!hasClients) return;
    jumpTo(0);
  }
}

// 列表扩展
extension ListExt<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }

  bool removeFirstWhere(bool Function(T) test) {
    final index = indexWhere(test);
    if (index != -1) {
      removeAt(index);
      return true;
    }
    return false;
  }
}

// 字符串扩展
extension StringExt on String? {
  String get http2https => this?.replaceFirst(_regExp, "https://") ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
```

#### 2.2 主题相关扩展

```dart
extension ColorSchemeExt on ColorScheme {
  Color get vipColor =>
      brightness.isLight ? const Color(0xFFFF6699) : const Color(0xFFD44E7D);

  Color get freeColor =>
      brightness.isLight ? const Color(0xFFFF7F24) : const Color(0xFFD66011);

  bool get isLight => brightness.isLight;
  bool get isDark => brightness.isDark;
}

extension ColorExtension on Color {
  Color darken([double amount = .5]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    return Color.lerp(this, Colors.black, amount)!;
  }
}
```

### 3. 存储管理

#### 3.1 GStorage 类

`storage.dart` 使用 Hive 数据库进行本地存储：

```dart
abstract class GStorage {
  static late final Box<UserInfoData> userInfo;
  static late final Box<dynamic> historyWord;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();

    await Future.wait([
      Hive.openBox<UserInfoData>('userInfo').then((res) => userInfo = res),
      Hive.openBox('localCache').then((res) => localCache = res),
      Hive.openBox('setting').then((res) => setting = res),
      Hive.openBox('historyWord').then((res) => historyWord = res),
      Hive.openBox('video').then((res) => video = res),
      Accounts.init(),
    ]);
  }

  static void regAdapter() {
    Hive
      ..registerAdapter(OwnerAdapter())
      ..registerAdapter(UserInfoDataAdapter())
      ..registerAdapter(LevelInfoAdapter())
      // 注册更多适配器...
  }
}
```

#### 3.2 Pref 类

`storage_pref.dart` 提供了类型安全的设置访问：

```dart
abstract class Pref {
  static final Box _setting = GStorage.setting;
  static final Box _video = GStorage.video;
  static final Box _localCache = GStorage.localCache;

  // 主题模式
  static ThemeMode get themeMode {
    return switch (themeTypeInt) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  // 图片质量
  static int get picQuality =>
      _setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);

  // 黑名单管理
  static Set<int> get blackMids =>
      _localCache.get(LocalCacheKey.blackMids, defaultValue: <int>{});

  static void setBlackMid(int mid) {
    _localCache.put(LocalCacheKey.blackMids, GlobalData().blackMids..add(mid));
  }

  static void removeBlackMid(int mid) {
    _localCache.put(
      LocalCacheKey.blackMids,
      GlobalData().blackMids..remove(mid),
    );
  }
}
```

## 专用工具类

### 1. 账户管理

#### 1.1 Accounts 类

`accounts.dart` 管理用户账户信息：

```dart
abstract class Accounts {
  static late final Box<LoginAccount> account;
  
  static Future<void> init() async {
    account = await Hive.openBox<LoginAccount>(
      'account',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 2;
      },
    );
  }
  
  static LoginAccount? get current => account.get('current');
  
  static Future<void> setCurrent(LoginAccount account) async {
    await Accounts.account.put('current', account);
  }
}
```

### 2. 网络相关

#### 2.1 RequestUtils 类

`request_utils.dart` 提供网络请求工具：

```dart
class RequestUtils {
  static Map<String, String> getHeaders() {
    return {
      'User-Agent': Constants.userAgent,
      'Referer': Constants.referer,
    };
  }
  
  static Future<bool> checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
```

#### 2.2 WbiSign 类

`wbi_sign.dart` 处理 B 站 WBI 签名：

```dart
class WbiSign {
  static Future<Map<String, dynamic>> makSign(Map<String, dynamic> params) async {
    final wbiImg = await _getWbiImg();
    final mixinKey = _getMixinKey(wbiImg);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    params['wts'] = timestamp;
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    final queryString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    final w_rid = _md5('$queryString$mixinKey');
    return {'w_rid': w_rid, ...params};
  }
}
```

### 3. 日期时间工具

#### 3.1 DateUtils 类

`date_utils.dart` 提供日期时间处理：

```dart
class DateUtils {
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
```

### 4. 视频相关工具

#### 4.1 VideoUtils 类

`video_utils.dart` 提供视频处理工具：

```dart
class VideoUtils {
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  static String getViewCount(int view) {
    if (view < 10000) {
      return view.toString();
    } else if (view < 100000000) {
      return '${(view / 10000).toStringAsFixed(1)}万';
    } else {
      return '${(view / 100000000).toStringAsFixed(1)}亿';
    }
  }
}
```

### 5. 图片处理工具

#### 5.1 ImageUtils 类

`image_utils.dart` 提供图片处理工具：

```dart
class ImageUtils {
  static String getAvatarUrl(String face, int size) {
    if (face.contains('noface')) {
      return face;
    }
    return '${face}@${size}w_${size}h_1c_1s.webp';
  }
  
  static String getCoverUrl(String url, int width, int height) {
    return '${url}@${width}w_${height}h_1c.webp';
  }
  
  static Future<Uint8List?> compressImage(Uint8List imageBytes, int quality) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      final compressed = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(compressed);
    } catch (e) {
      return null;
    }
  }
}
```

### 6. 弹幕处理工具

#### 6.1 DanmakuUtils 类

`danmaku_utils.dart` 提供弹幕处理工具：

```dart
class DanmakuUtils {
  static List<DanmakuModel> filterDanmaku(List<DanmakuModel> danmakus, RuleFilter rule) {
    return danmakus.where((danmaku) {
      // 检查用户黑名单
      if (rule.blackMids.contains(danmaku.mid)) {
        return false;
      }
      
      // 检查关键词过滤
      for (final keyword in rule.keywords) {
        if (danmaku.text.contains(keyword)) {
          return false;
        }
      }
      
      // 检查弹幕类型
      if (rule.blockTypes.contains(danmaku.mode)) {
        return false;
      }
      
      return true;
    }).toList();
  }
}
```

## 使用示例

### 1. 存储使用示例

```dart
// 保存设置
await GStorage.setting.put('theme', 'dark');

// 读取设置
final theme = GStorage.setting.get('theme', defaultValue: 'light');

// 使用 Pref 类
final picQuality = Pref.picQuality;
Pref.picQuality = 20;

// 黑名单管理
Pref.setBlackMid(12345);
Pref.removeBlackMid(12345);
```

### 2. 扩展方法使用示例

```dart
// 滚动控制器
ScrollController scrollController = ScrollController();
scrollController.animToTop(); // 滚动到顶部
scrollController.animTo(100); // 滚动到指定位置

// 列表操作
List<String> items = ['a', 'b', 'c'];
final item = items.getOrNull(1); // 安全获取元素
items.removeFirstWhere((item) => item == 'b'); // 移除第一个匹配项

// 字符串操作
String? url = 'http://example.com';
final httpsUrl = url.http2https; // 转换为 https
final isEmpty = url.isNullOrEmpty; // 检查是否为空
```

### 3. 工具类使用示例

```dart
// Utils 类
await Utils.copyText('Hello World'); // 复制文本
await Utils.shareText('Check this out!'); // 分享文本
final color = Utils.parseColor('#FF0000'); // 解析颜色

// 视频工具
final durationStr = VideoUtils.formatDuration(3600); // "01:00:00"
final viewStr = VideoUtils.getViewCount(12345); // "1.2万"

// 日期工具
final dateStr = DateUtils.formatDate(DateTime.now()); // "2023-12-01"
final timeStr = DateUtils.formatTime(DateTime.now()); // "14:30"
```

## 最佳实践

### 1. 工具类设计原则

- **单一职责**: 每个工具类专注于特定功能领域
- **无状态**: 工具类通常是无状态的，提供静态方法
- **类型安全**: 使用强类型和泛型确保类型安全
- **错误处理**: 提供适当的错误处理机制

### 2. 扩展方法设计

- **命名清晰**: 扩展方法名称应清晰表达其功能
- **避免冲突**: 避免创建可能与现有方法冲突的扩展
- **文档完整**: 为扩展方法提供完整的文档说明

### 3. 存储管理

- **类型安全**: 使用类型化的 Box 存储数据
- **默认值**: 为存储的键提供合理的默认值
- **数据迁移**: 考虑数据结构变化时的迁移策略

### 4. 性能考虑

- **缓存计算**: 对于复杂计算考虑缓存结果
- **延迟加载**: 对于大型数据结构使用延迟加载
- **资源释放**: 及时释放不再使用的资源

## 常见问题与解决方案

### 1. Hive 数据库问题

**问题**: Hive 数据库访问失败

**解决方案**: 确保正确初始化 Hive 并注册所有适配器

```dart
await Hive.initFlutter(path);
Hive.registerAdapter(MyAdapter());
await Hive.openBox('myBox');
```

### 2. 扩展方法冲突

**问题**: 扩展方法与现有方法冲突

**解决方案**: 使用明确的命名避免冲突

```dart
// 好的命名
extension StringExt on String {
  String get toHttps => replaceFirst('http://', 'https://');
}

// 避免冲突的命名
extension StringExt on String {
  String get toHttpsProtocol => replaceFirst('http://', 'https://');
}
```

### 3. 全局状态管理

**问题**: 全局状态管理混乱

**解决方案**: 使用单例模式管理全局状态

```dart
class GlobalData {
  static final GlobalData _instance = GlobalData._();
  factory GlobalData() => _instance;
  GlobalData._();
  
  // 全局状态
  int _counter = 0;
  int get counter => _counter;
  set counter(int value) => _counter = value;
}
```