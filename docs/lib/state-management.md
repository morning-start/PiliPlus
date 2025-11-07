# 状态管理 (State Management)

## 概述

PiliPlus 项目使用 GetX 作为主要的状态管理框架，结合 Mixin 模式和响应式编程，实现了高效的状态管理。状态管理分布在控制器(Controller)中，通过 GetX 的响应式变量和依赖注入系统，实现了数据与 UI 的自动同步。

## 状态管理架构

### 1. GetX 框架

GetX 是一个轻量级、高性能的 Flutter 状态管理解决方案，提供了状态管理、依赖注入、路由管理等功能：

```dart
// 基本控制器定义
class MyController extends GetxController {
  // 响应式变量
  final RxInt count = 0.obs;
  final RxString title = 'Hello'.obs;
  final RxBool isLoading = false.obs;
  
  // 普通变量
  String normalVar = 'Normal';
  
  // 计算属性
  String get displayText => '$title: $count';
  
  // 方法
  void increment() {
    count.value++;
  }
  
  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑
  }
  
  @override
  void onReady() {
    super.onReady();
    // 组件准备好后的逻辑
  }
  
  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
}
```

### 2. 控制器生命周期

GetX 控制器提供了完整的生命周期管理：

```dart
class LifecycleController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // 初始化时调用，适合进行配置和初始化操作
  }
  
  @override
  void onReady() {
    super.onReady();
    // 组件准备好后调用，适合进行 UI 相关操作
  }
  
  @override
  void onClose() {
    // 清理资源，如关闭流、取消订阅等
    super.onClose();
  }
}
```

### 3. 依赖注入

GetX 提供了强大的依赖注入系统：

```dart
// 注册依赖
Get.put(MyController()); // 单例模式
Get.put(MyController(), permanent: true); // 永久单例
Get.lazyPut(() => MyController()); // 懒加载
Get.create(() => MyController()); // 每次创建新实例

// 获取依赖
MyController controller = Get.find<MyController>();

// 删除依赖
Get.delete<MyController>();
```

## 响应式状态管理

### 1. 响应式变量

GetX 提供了多种响应式变量类型：

```dart
// 基本类型
final RxInt rxInt = 0.obs;
final RxDouble rxDouble = 0.0.obs;
final RxString rxString = ''.obs;
final RxBool rxBool = false.obs;

// 列表类型
final RxList<String> rxList = <String>[].obs;
final RxMap<String, dynamic> rxMap = <String, dynamic>{}.obs;

// 自定义类型
final Rx<MyModel> rxModel = MyModel().obs;

// 使用 .obs 扩展方法
final int count = 0.obs;
final String title = 'Title'.obs;
final List<Item> items = <Item>[].obs;
```

### 2. 响应式 UI 更新

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 使用 GetBuilder
    return GetBuilder<MyController>(
      init: MyController(),
      builder: (controller) {
        return Text('Count: ${controller.count}');
      },
    );
    
    // 或者使用 Obx
    return Obx(() {
      final controller = Get.find<MyController>();
      return Text('Count: ${controller.count.value}');
    });
  }
}
```

### 3. 响应式状态管理最佳实践

```dart
class BestPracticeController extends GetxController {
  // 私有响应式变量
  final RxInt _count = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxList<Item> _items = <Item>[].obs;
  
  // 公开 getter
  int get count => _count.value;
  bool get isLoading => _isLoading.value;
  List<Item> get items => _items;
  
  // 公开 setter
  set count(int value) => _count.value = value;
  set isLoading(bool value) => _isLoading.value = value;
  
  // 计算属性
  bool get hasItems => _items.isNotEmpty;
  int get itemCount => _items.length;
  
  // 方法
  Future<void> fetchData() async {
    try {
      isLoading = true;
      final data = await ApiService.getData();
      _items.assignAll(data);
    } catch (e) {
      // 错误处理
    } finally {
      isLoading = false;
    }
  }
  
  void addItem(Item item) {
    _items.add(item);
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }
}
```

## Mixin 模式

### 1. 滚动与刷新 Mixin

项目中定义了 `ScrollOrRefreshMixin` 来处理滚动和刷新逻辑：

```dart
mixin ScrollOrRefreshMixin {
  ScrollController get scrollController;

  void animateToTop() => scrollController.animToTop();

  Future<void> onRefresh();

  void toTopOrRefresh() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == 0) {
        EasyThrottle.throttle(
          'topOrRefresh',
          const Duration(milliseconds: 500),
          onRefresh,
        );
      } else {
        animateToTop();
      }
    }
  }
}
```

### 2. 通用控制器 Mixin

`CommonController` 提供了通用的数据加载和状态管理功能：

```dart
abstract class CommonController<R, T> extends GetxController
    with ScrollOrRefreshMixin {
  @override
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
  Rx<LoadingState> get loadingState;

  Future<LoadingState<R>> customGetData();

  Future<void> queryData([bool isRefresh = true]);

  bool customHandleResponse(bool isRefresh, Success<R> response) {
    return false;
  }

  bool handleError(String? errMsg) {
    return false;
  }

  @override
  Future<void> onRefresh() {
    return queryData();
  }

  Future<void> onLoadMore() {
    return queryData(false);
  }

  Future<void> onReload() {
    return onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
```

### 3. 使用 Mixin 的控制器

```dart
class MyListController extends CommonController<Data, Item> {
  @override
  final Rx<LoadingState> loadingState = LoadingState.initial.obs;
  
  final RxList<Item> items = <Item>[].obs;
  
  @override
  Future<LoadingState<Data>> customGetData() async {
    try {
      final response = await ApiService.fetchData();
      return LoadingState.success(response);
    } catch (e) {
      return LoadingState.error(e.toString());
    }
  }
  
  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading) return;
    
    isLoading = true;
    loadingState.value = LoadingState.loading();
    
    try {
      final result = await customGetData();
      
      if (result is Success<Data>) {
        if (isRefresh) {
          items.clear();
        }
        items.addAll(result.data.items);
        loadingState.value = LoadingState.success(result.data);
      } else {
        loadingState.value = result;
      }
    } catch (e) {
      loadingState.value = LoadingState.error(e.toString());
    } finally {
      isLoading = false;
    }
  }
}
```

## 状态管理示例

### 1. 主页控制器

```dart
class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, ScrollOrRefreshMixin {
  late List<HomeTabType> tabs;
  late TabController tabController;

  StreamController<bool>? searchBarStream;
  final bool hideSearchBar = Pref.hideSearchBar;
  final bool useSideBar = Pref.useSideBar;

  bool enableSearchWord = Pref.enableSearchWord;
  late final RxString defaultSearch = ''.obs;
  late int lateCheckSearchAt = 0;

  ScrollOrRefreshMixin get controller => tabs[tabController.index].ctr();

  @override
  ScrollController get scrollController => controller.scrollController;

  AccountService accountService = Get.find<AccountService>();

  @override
  void onInit() {
    super.onInit();

    if (hideSearchBar) {
      searchBarStream = StreamController<bool>.broadcast();
    }

    if (enableSearchWord) {
      lateCheckSearchAt = DateTime.now().millisecondsSinceEpoch;
      querySearchDefault();
    }

    setTabConfig();
  }

  @override
  Future<void> onRefresh() {
    return controller.onRefresh().catchError((e) {
      if (kDebugMode) debugPrint(e.toString());
    });
  }

  void setTabConfig() {
    final tabs = GStorage.setting.get(SettingBoxKey.tabBarSort) as List?;
    if (tabs != null) {
      this.tabs = tabs.map((i) => HomeTabType.values[i]).toList();
    } else {
      this.tabs = HomeTabType.values;
    }

    tabController = TabController(
      initialIndex: max(0, this.tabs.indexOf(HomeTabType.rcmd)),
      length: this.tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> querySearchDefault() async {
    try {
      var res = await Request().get(
        Api.searchDefault,
        queryParameters: await WbiSign.makSign({'web_location': 333.1365}),
      );
      if (res.data['code'] == 0) {
        defaultSearch.value = res.data['data']?['name'] ?? '';
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    searchBarStream?.close();
    super.onClose();
  }
}
```

### 2. 主控制器

```dart
class MainController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AccountService accountService = Get.find<AccountService>();

  List<NavigationBarType> navigationBars = <NavigationBarType>[];

  StreamController<bool>? bottomBarStream;
  late bool hideTabBar = Pref.hideTabBar;
  late dynamic controller;
  RxInt selectedIndex = 0.obs;

  RxInt dynCount = 0.obs;
  late DynamicBadgeMode dynamicBadgeMode;
  late bool checkDynamic = Pref.checkDynamic;
  late int dynamicPeriod = Pref.dynamicPeriod * 60 * 1000;
  late int _lastCheckDynamicAt = 0;
  late bool hasDyn = false;
  late final DynamicsController dynamicController = Get.put(
    DynamicsController(),
  );

  late bool hasHome = false;
  late final HomeController homeController = Get.put(HomeController());

  late DynamicBadgeMode msgBadgeMode = Pref.msgBadgeMode;
  late Set<MsgUnReadType> msgUnReadTypes = Pref.msgUnReadTypeV2;
  late final RxString msgUnReadCount = ''.obs;
  late int lastCheckUnreadAt = 0;

  final enableMYBar = Pref.enableMYBar;
  final useSideBar = Pref.useSideBar;
  final mainTabBarView = Pref.mainTabBarView;
  late final optTabletNav = Pref.optTabletNav;

  late bool directExitOnBack = Pref.directExitOnBack;
  late bool showTrayIcon = Pref.showTrayIcon;
  late bool minimizeOnExit = Pref.minimizeOnExit;
  late bool pauseOnMinimize = Pref.pauseOnMinimize;
  late bool isPlaying = false;

  static const _period = 5 * 60 * 1000;
  late int _lastSelectTime = 0;

  @override
  void onInit() {
    super.onInit();
    if (Pref.autoUpdate) {
      Update.checkUpdate();
    }

    setNavBarConfig();

    controller = mainTabBarView
        ? TabController(
            vsync: this,
            initialIndex: selectedIndex.value,
            length: navigationBars.length,
          )
        : PageController(initialPage: selectedIndex.value);

    if (navigationBars.length > 1 && hideTabBar) {
      bottomBarStream = StreamController<bool>.broadcast();
    }
    dynamicBadgeMode = DynamicBadgeMode.values[Pref.dynamicBadgeMode];

    hasDyn = navigationBars.contains(NavigationBarType.dynamics);
    if (dynamicBadgeMode != DynamicBadgeMode.hidden) {
      if (hasDyn) {
        if (checkDynamic) {
          _lastCheckDynamicAt = DateTime.now().millisecondsSinceEpoch;
        }
        getUnreadDynamic();
      }
    }

    hasHome = navigationBars.contains(NavigationBarType.home);
    if (msgBadgeMode != DynamicBadgeMode.hidden) {
      if (hasHome) {
        lastCheckUnreadAt = DateTime.now().millisecondsSinceEpoch;
        queryUnreadMsg();
      }
    }
  }

  Future<void> queryUnreadMsg([bool isChangeType = false]) async {
    if (!accountService.isLogin.value ||
        !hasHome ||
        msgUnReadTypes.isEmpty ||
        msgBadgeMode == DynamicBadgeMode.hidden) {
      msgUnReadCount.value = '';
      return;
    }

    var res = await Future.wait([_msgUnread(), _msgFeedUnread()]);

    int count = res.fold(0, (prev, e) => prev + e);

    final countStr = count == 0
        ? ''
        : count > 99
        ? '99+'
        : count.toString();
    if (msgUnReadCount.value == countStr) {
      if (isChangeType) {
        msgUnReadCount.refresh();
      }
    } else {
      msgUnReadCount.value = countStr;
    }
  }

  void getUnreadDynamic() {
    if (!accountService.isLogin.value || !hasDyn) {
      return;
    }
    DynGrpc.dynRed().then((res) {
      if (res != null) {
        setDynCount(res);
      }
    });
  }

  void setDynCount([int count = 0]) {
    if (!hasDyn) return;
    dynCount.value = count;
  }

  void checkUnreadDynamic() {
    // 实现检查未读动态的逻辑
  }

  void setNavBarConfig() {
    // 实现设置导航栏配置的逻辑
  }
}
```

### 3. 账户服务

```dart
class AccountService extends GetxService {
  // 用户信息
  final RxString mid = ''.obs;
  final RxString name = ''.obs;
  final RxString face = ''.obs;
  final RxString level = ''.obs;
  final RxString sign = ''.obs;
  final RxBool isLogin = false.obs;
  
  // 登录状态
  final RxBool isLoginLoading = false.obs;
  final RxString loginError = ''.obs;
  
  // 用户设置
  final RxBool enableVip = false.obs;
  final RxBool enablePfp = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }
  
  // 加载用户信息
  void _loadUserInfo() {
    final userInfo = GStorage.userInfo.get();
    if (userInfo != null) {
      mid.value = userInfo['mid'] ?? '';
      name.value = userInfo['name'] ?? '';
      face.value = userInfo['face'] ?? '';
      level.value = userInfo['level'] ?? '';
      sign.value = userInfo['sign'] ?? '';
      isLogin.value = userInfo['isLogin'] ?? false;
    }
  }
  
  // 登录
  Future<bool> login(String username, String password) async {
    try {
      isLoginLoading.value = true;
      loginError.value = '';
      
      final response = await Request().post(
        Api.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.data['code'] == 0) {
        final data = response.data['data'];
        mid.value = data['mid'].toString();
        name.value = data['name'];
        face.value = data['face'];
        level.value = data['level'];
        sign.value = data['sign'];
        isLogin.value = true;
        
        _saveUserInfo();
        return true;
      } else {
        loginError.value = response.data['message'];
        return false;
      }
    } catch (e) {
      loginError.value = e.toString();
      return false;
    } finally {
      isLoginLoading.value = false;
    }
  }
  
  // 登出
  void logout() {
    mid.value = '';
    name.value = '';
    face.value = '';
    level.value = '';
    sign.value = '';
    isLogin.value = false;
    
    GStorage.userInfo.remove();
  }
  
  // 保存用户信息
  void _saveUserInfo() {
    GStorage.userInfo.put({
      'mid': mid.value,
      'name': name.value,
      'face': face.value,
      'level': level.value,
      'sign': sign.value,
      'isLogin': isLogin.value,
    });
  }
  
  // 更新用户信息
  Future<void> updateUserInfo() async {
    if (!isLogin.value) return;
    
    try {
      final response = await Request().get(
        Api.userInfo,
        queryParameters: {'mid': mid.value},
      );
      
      if (response.data['code'] == 0) {
        final data = response.data['data'];
        name.value = data['name'];
        face.value = data['face'];
        level.value = data['level'];
        sign.value = data['sign'];
        
        _saveUserInfo();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('更新用户信息失败: $e');
    }
  }
}
```

## 状态管理最佳实践

### 1. 控制器职责分离

- 每个页面/组件应该有自己独立的控制器
- 控制器只负责业务逻辑，不包含 UI 代码
- 使用 Mixin 复用通用逻辑

### 2. 响应式变量使用

- 只对需要触发 UI 更新的数据使用响应式变量
- 对于复杂对象，考虑使用 RxList、RxMap 等
- 使用 getter/setter 封装响应式变量，提供更清晰的 API

### 3. 依赖注入

- 使用 `Get.put()` 注册单例服务
- 使用 `Get.lazyPut()` 注册懒加载服务
- 在控制器中使用 `Get.find()` 获取依赖

### 4. 资源管理

- 在 `onClose()` 方法中释放资源
- 及时关闭 StreamController、取消订阅
- 避免内存泄漏

### 5. 性能优化

- 使用 `GetBuilder` 替代 `Obx` 减少不必要的重建
- 对于复杂计算，考虑使用 `ever()` 或 `once()` 监听变化
- 使用 `worker` 方法处理异步操作

## 状态管理工具

### 1. 状态类型

项目中定义了多种状态类型：

```dart
enum LoadingState {
  initial,
  loading,
  success,
  error,
}

class Success<T> extends LoadingState {
  final T data;
  Success(this.data);
}

class Error extends LoadingState {
  final String message;
  Error(this.message);
}
```

### 2. 状态管理工具类

```dart
class StateManager {
  static void handleLoadingState(
    Rx<LoadingState> state,
    Future<void> Function() operation,
  ) async {
    try {
      state.value = LoadingState.loading();
      await operation();
      state.value = LoadingState.success();
    } catch (e) {
      state.value = LoadingState.error(e.toString());
    }
  }
}
```

### 3. 防抖与节流

```dart
// 使用 EasyThrottle 进行防抖
void onSearchChanged(String query) {
  EasyThrottle.throttle(
    'search',
    const Duration(milliseconds: 500),
    () => performSearch(query),
  );
}

// 使用 EasyDebounce 进行防抖
void onTextChanged(String text) {
  EasyDebounce.debounce(
    'text_change',
    const Duration(milliseconds: 300),
    () => updateText(text),
  );
}
```

## 常见问题与解决方案

### 1. 控制器未找到

**问题**: `Get.find<MyController>()` 抛出异常

**解决方案**: 确保在使用前已注册控制器

```dart
// 在路由中注册
GetPage(
  name: Routes.HOME,
  page: () => HomePage(),
  binding: BindingsBuilder(() => Get.put(HomeController())),
);

// 或在页面中注册
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => Scaffold(...),
    );
  }
}
```

### 2. 状态更新不生效

**问题**: 修改响应式变量后 UI 未更新

**解决方案**: 确保使用正确的语法

```dart
// 错误方式
controller.count = 1;

// 正确方式
controller.count.value = 1;

// 或者使用 update()
controller.update();
```

### 3. 内存泄漏

**问题**: 控制器未正确释放导致内存泄漏

**解决方案**: 确保在适当时候释放控制器

```dart
@override
void onClose() {
  // 关闭流
  streamController?.close();
  
  // 取消订阅
  subscription?.cancel();
  
  // 释放控制器
  Get.delete<MyController>();
  
  super.onClose();
}
```

### 4. 过度重建

**问题**: 使用 Obx 导致整个页面重建

**解决方案**: 使用 GetBuilder 或拆分小组件

```dart
// 使用 GetBuilder 只重建必要部分
GetBuilder<Controller>(
  builder: (controller) => Text(controller.count.toString()),
)

// 或者拆分小组件
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(Get.find<Controller>().count.value.toString()));
  }
}
```

## 状态持久化

### 1. 使用 GStorage

项目使用 GStorage 进行状态持久化：

```dart
// 保存数据
GStorage.setting.put(SettingBoxKey.themeType, themeType.index);

// 读取数据
final themeTypeIndex = GStorage.setting.get(SettingBoxKey.themeType);
final themeType = ThemeType.values[themeTypeIndex ?? 0];
```

### 2. 用户信息持久化

```dart
class AccountService extends GetxService {
  // ... 其他代码
  
  // 保存用户信息
  void _saveUserInfo() {
    GStorage.userInfo.put({
      'mid': mid.value,
      'name': name.value,
      'face': face.value,
      'level': level.value,
      'sign': sign.value,
      'isLogin': isLogin.value,
    });
  }
  
  // 加载用户信息
  void _loadUserInfo() {
    final userInfo = GStorage.userInfo.get();
    if (userInfo != null) {
      mid.value = userInfo['mid'] ?? '';
      name.value = userInfo['name'] ?? '';
      face.value = userInfo['face'] ?? '';
      level.value = userInfo['level'] ?? '';
      sign.value = userInfo['sign'] ?? '';
      isLogin.value = userInfo['isLogin'] ?? false;
    }
  }
}
```

### 3. 设置持久化

```dart
class SettingService extends GetxService {
  // 主题设置
  final Rx<ThemeType> themeType = ThemeType.system.obs;
  
  // 语言设置
  final Rx<String> language = 'zh_CN'.obs;
  
  // 其他设置
  final Rx<bool> enableNotification = true.obs;
  final Rx<bool> autoPlay = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  void _loadSettings() {
    // 加载主题设置
    final themeTypeIndex = GStorage.setting.get(SettingBoxKey.themeType);
    themeType.value = ThemeType.values[themeTypeIndex ?? 0];
    
    // 加载语言设置
    language.value = GStorage.setting.get(SettingBoxKey.language) ?? 'zh_CN';
    
    // 加载其他设置
    enableNotification.value = GStorage.setting.get(SettingBoxKey.enableNotification) ?? true;
    autoPlay.value = GStorage.setting.get(SettingBoxKey.autoPlay) ?? false;
  }
  
  void saveThemeType(ThemeType type) {
    themeType.value = type;
    GStorage.setting.put(SettingBoxKey.themeType, type.index);
  }
  
  void saveLanguage(String lang) {
    language.value = lang;
    GStorage.setting.put(SettingBoxKey.language, lang);
  }
  
  void saveNotification(bool enable) {
    enableNotification.value = enable;
    GStorage.setting.put(SettingBoxKey.enableNotification, enable);
  }
  
  void saveAutoPlay(bool enable) {
    autoPlay.value = enable;
    GStorage.setting.put(SettingBoxKey.autoPlay, enable);
  }
}
```