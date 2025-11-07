# 服务层 (Services)

## 概述

PiliPlus 项目中的服务层位于 `lib/services` 目录下，负责处理业务逻辑、状态管理和外部服务交互。服务层采用分层架构，将业务逻辑与UI层分离，提高代码的可维护性和可测试性。

## 目录结构

```
lib/services/
├── account_service.dart        # 账户服务
├── audio_handler.dart          # 音频处理服务
├── audio_session.dart          # 音频会话服务
├── logger.dart                 # 日志服务
├── service_locator.dart       # 服务定位器
└── shutdown_timer_service.dart # 关闭定时器服务
```

## 主要服务介绍

### 1. 服务定位器 (Service Locator)

#### service_locator.dart
服务定位器模式实现，负责管理应用中所有服务的注册和获取。

```dart
// 注册服务
GetIt.instance.registerSingleton<AccountService>(AccountService());

// 获取服务
final accountService = GetIt.instance<AccountService>();
```

**功能特点**:
- 单例模式管理服务实例
- 支持依赖注入
- 服务生命周期管理
- 便于单元测试时替换服务

### 2. 账户服务 (Account Service)

#### account_service.dart
处理用户账户相关的业务逻辑，包括登录状态管理、用户信息获取等。

```dart
class AccountService extends GetxService {
  // 当前登录用户
  final Rx<UserInfo?> currentUser = Rx<UserInfo?>(null);
  
  // 登录状态
  final RxBool isLoggedIn = false.obs;
  
  // 用户信息
  final Rx<UserInfo?> userInfo = Rx<UserInfo?>(null);
  
  // 检查登录状态
  Future<bool> checkLoginStatus() async { ... }
  
  // 获取用户信息
  Future<void> getUserInfo() async { ... }
  
  // 登出
  Future<void> logout() async { ... }
}
```

**主要功能**:
- 用户登录状态管理
- 用户信息获取和缓存
- 多账户切换支持
- 登录状态持久化

### 3. 音频处理服务 (Audio Handler)

#### audio_handler.dart
处理音频播放相关的业务逻辑，基于audio_service实现。

```dart
class AudioHandler extends BaseAudioHandler {
  // 播放音频
  Future<void> playAudio(String url, {String? title}) async { ... }
  
  // 暂停播放
  Future<void> pause() async { ... }
  
  // 停止播放
  Future<void> stop() async { ... }
  
  // 设置播放速度
  Future<void> setSpeed(double speed) async { ... }
}
```

**主要功能**:
- 音频播放控制
- 后台播放支持
- 媒体通知管理
- 播放状态同步

### 4. 音频会话服务 (Audio Session)

#### audio_session.dart
管理音频会话配置，处理音频焦点和路由。

```dart
class AudioSessionService {
  // 初始化音频会话
  Future<void> initialize() async { ... }
  
  // 配置音频会话
  Future<void> configure() async { ... }
  
  // 处理音频焦点变化
  void handleInterruption(AudioInterruption interruption) { ... }
}
```

**主要功能**:
- 音频会话配置
- 音频焦点管理
- 音频路由控制
- 中断事件处理

### 5. 日志服务 (Logger)

#### logger.dart
提供统一的日志记录功能，支持不同级别的日志和输出目标。

```dart
class Logger {
  // 调试日志
  static void debug(String message) { ... }
  
  // 信息日志
  static void info(String message) { ... }
  
  // 警告日志
  static void warning(String message) { ... }
  
  // 错误日志
  static void error(String message, {StackTrace? stackTrace}) { ... }
  
  // 记录网络请求
  static void logRequest(String method, String url, dynamic data) { ... }
  
  // 记录网络响应
  static void logResponse(String url, int statusCode, dynamic data) { ... }
}
```

**主要功能**:
- 多级别日志记录
- 文件和控制台输出
- 日志格式化和时间戳
- 网络请求/响应日志
- 日志文件管理

### 6. 关闭定时器服务 (Shutdown Timer Service)

#### shutdown_timer_service.dart
管理应用关闭前的定时任务，确保资源正确释放。

```dart
class ShutdownTimerService {
  // 启动关闭定时器
  void startShutdownTimer() { ... }
  
  // 取消关闭定时器
  void cancelShutdownTimer() { ... }
  
  // 执行关闭前的清理工作
  Future<void> performCleanup() async { ... }
}
```

**主要功能**:
- 应用关闭前资源清理
- 定时任务管理
- 状态持久化
- 异步操作完成等待

## 服务初始化

服务在应用启动时通过服务定位器进行初始化：

```dart
Future<void> setupServiceLocator() async {
  // 注册服务
  GetIt.instance.registerSingleton<AccountService>(AccountService());
  GetIt.instance.registerSingleton<AudioHandler>(AudioHandler());
  GetIt.instance.registerSingleton<AudioSessionService>(AudioSessionService());
  GetIt.instance.registerSingleton<ShutdownTimerService>(ShutdownTimerService());
  
  // 初始化服务
  await GetIt.instance.allReady();
}
```

## 使用示例

### 使用账户服务

```dart
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/services/account_service.dart';

class HomePage extends StatelessWidget {
  final AccountService accountService = GetIt.instance<AccountService>();
  
  Widget build(BuildContext context) {
    return Obx(() {
      if (accountService.isLoggedIn.value) {
        return LoggedInView(user: accountService.userInfo.value!);
      } else {
        return LoginView();
      }
    });
  }
}
```

### 使用音频处理服务

```dart
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/services/audio_handler.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioHandler audioHandler = GetIt.instance<AudioHandler>();
  
  void playAudio(String url) {
    audioHandler.playAudio(url);
  }
  
  void pauseAudio() {
    audioHandler.pause();
  }
  
  // ...
}
```

### 使用日志服务

```dart
import 'package:PiliPlus/services/logger.dart';

class VideoRepository {
  Future<VideoData> fetchVideo(String id) async {
    try {
      Logger.info('Fetching video: $id');
      final response = await http.get(Uri.parse('https://api.example.com/videos/$id'));
      Logger.logResponse('videos/$id', response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        return VideoData.fromJson(jsonDecode(response.body));
      } else {
        Logger.error('Failed to fetch video: ${response.statusCode}');
        throw Exception('Failed to load video');
      }
    } catch (e, stackTrace) {
      Logger.error('Error fetching video: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
```

## 服务间通信

服务之间可以通过以下方式进行通信：

1. **直接依赖**: 服务A直接注入服务B并调用其方法
2. **事件总线**: 使用GetX的事件系统进行服务间通信
3. **共享状态**: 通过共享的状态对象进行通信

```dart
// 示例：账户服务通知音频服务用户状态变化
class AccountService extends GetxService {
  final AudioHandler audioHandler = GetIt.instance<AudioHandler>();
  
  Future<void> logout() async {
    // 清除用户信息
    currentUser.value = null;
    isLoggedIn.value = false;
    
    // 通知音频服务停止播放
    await audioHandler.stop();
    
    // 发送登出事件
    Get.find<EventBus>().fire(LogoutEvent());
  }
}
```

## 最佳实践

1. **单一职责**: 每个服务应专注于特定领域的功能
2. **依赖注入**: 使用服务定位器进行依赖注入，便于测试和维护
3. **异步操作**: 服务中的耗时操作应使用异步方法
4. **错误处理**: 提供适当的错误处理机制，避免服务崩溃
5. **状态管理**: 使用响应式编程管理服务状态
6. **资源清理**: 在服务销毁时正确释放资源

## 测试策略

服务层应进行充分的单元测试，可以使用模拟对象替代依赖：

```dart
// 示例：测试账户服务
void main() {
  group('AccountService', () {
    late AccountService accountService;
    late MockHttpService mockHttpService;
    
    setUp(() {
      mockHttpService = MockHttpService();
      accountService = AccountService(httpService: mockHttpService);
    });
    
    test('should login successfully with valid credentials', () async {
      // Arrange
      when(mockHttpService.post(any, any))
          .thenAnswer((_) async => Response('{"success": true}', 200));
      
      // Act
      final result = await accountService.login('username', 'password');
      
      // Assert
      expect(result, isTrue);
      expect(accountService.isLoggedIn.value, isTrue);
    });
  });
}
```

## 注意事项

1. 避免在服务中直接访问UI层，保持服务层的独立性
2. 服务中的状态变更应通过响应式方式通知UI层
3. 考虑服务的生命周期，及时释放资源
4. 对于耗时操作，应提供取消机制
5. 服务间的依赖关系应保持简单，避免循环依赖