# 网络请求 (HTTP)

## 概述

PiliPlus 项目使用 Dio 作为网络请求框架，封装了一套完整的网络请求系统。HTTP 模块位于 `lib/http` 目录下，包含 API 端点定义、请求拦截器、重试机制等功能，为应用提供统一的网络请求接口。

## 网络架构

### 1. 基础配置

网络请求基于 Dio 框架，配置了 HTTP/2 支持、代理设置、证书验证等功能：

```dart
BaseOptions options = BaseOptions(
  baseUrl: HttpString.apiBaseUrl,
  connectTimeout: const Duration(milliseconds: 10000),
  receiveTimeout: const Duration(milliseconds: 10000),
  headers: {
    'user-agent': 'Dart/3.6 (dart:io)',
  },
  responseDecoder: _responseDecoder,
  persistentConnection: true,
);
```

### 2. 适配器配置

支持 HTTP/2 和 HTTP/1.1 双协议：

```dart
// HTTP/2 适配器配置
final http2Adapter = Http2Adapter(
  ConnectionManager(
    idleTimeout: const Duration(seconds: 15),
    onClientCreate: (url, config) {
      // 配置代理和证书验证
      config
        ..proxy = proxy
        ..onBadCertificate = (_) => true;
    },
  ),
  fallbackAdapter: http11Adapter,
);

// HTTP/1.1 适配器配置
final http11Adapter = IOHttpClientAdapter(
  createHttpClient: () => HttpClient()
    ..idleTimeout = const Duration(seconds: 15)
    ..autoUncompress = false
    ..findProxy = ((_) => 'PROXY $systemProxyHost:$systemProxyPort')
    ..badCertificateCallback = (cert, host, port) => true,
);
```

### 3. 拦截器系统

#### 重试拦截器

```dart
dio.interceptors.add(RetryInterceptor(Pref.retryCount, Pref.retryDelay));
```

#### 账户管理拦截器

```dart
accountManager = AccountManager();
dio.interceptors.add(accountManager);
```

#### 日志拦截器

```dart
if (kDebugMode) {
  dio.interceptors.add(
    LogInterceptor(
      request: false,
      requestHeader: false,
      responseHeader: false,
    ),
  );
}
```

## API 端点定义

### 1. 视频相关 API

#### 视频基础信息

```dart
// 推荐视频
static const String recommendListApp = '${HttpString.appBaseUrl}/x/v2/feed/index';
static const String recommendListWeb = '/x/web-interface/index/top/feed/rcmd';

// 热门视频
static const String hotList = '/x/web-interface/popular';

// 视频详情
static const String videoIntro = '/x/web-interface/view';

// 视频流
static const String ugcUrl = '/x/player/wbi/playurl';
static const String pgcUrl = '/pgc/player/web/v2/playurl';
static const String pugvUrl = '/pugv/player/web/playurl';

// 字幕信息
static const String playInfo = '/x/player/wbi/v2';

// 相关视频
static const String relatedList = '/x/web-interface/archive/related';
```

#### 视频交互操作

```dart
// 点赞
static const String likeVideo = '${HttpString.appBaseUrl}/x/v2/view/like';

// 投币
static const String coinVideo = '${HttpString.appBaseUrl}/x/v2/view/coin/add';

// 收藏
static const String favVideo = '/x/v3/fav/resource/batch-deal';

// 一键三连
static const String ugcTriple = '/x/web-interface/archive/like/triple';
static const String pgcTriple = '/pgc/season/episode/like/triple';
```

### 2. 用户相关 API

```dart
// 用户信息
static const String userInfo = '/x/web-interface/nav';
static const String userStat = '/x/relation/stat';
static const String userStatOwner = '/x/web-interface/nav/stat';

// 用户关系
static const String relation = '/x/relation';
static const String relations = '/x/relation/relations';
static const String relationMod = '/x/relation/modify';
```

### 3. 收藏相关 API

```dart
// 收藏夹
static const String favFolder = '/x/v3/fav/folder/created/list-all';
static const String favResourceList = '/x/v3/fav/resource/list';

// 收藏操作
static const String favVideo = '/x/v3/fav/resource/batch-deal';
static const String unfavAll = '/x/v3/fav/resource/unfav-all';
static const String copyFav = '/x/v3/fav/resource/copy';
static const String moveFav = '/x/v3/fav/resource/move';
static const String cleanFav = '/x/v3/fav/resource/clean';
static const String sortFav = '/x/v3/fav/resource/sort';
static const String sortFavFolder = '/x/v3/fav/folder/sort';
```

### 4. 评论相关 API

```dart
// 评论列表
static const String replyList = '/x/v2/reply';

// 楼中楼
static const String replyReplyList = '/x/v2/reply/reply';

// 评论操作
static const String likeReply = '/x/v2/reply/action';
static const String hateReply = '/x/v2/reply/hate';
static const String replyAdd = '/x/v2/reply/add';
static const String replyDel = '/x/v2/reply/del';
```

### 5. 直播相关 API

```dart
// 直播间信息
static const String liveRoomInfo = '/xlive/web-room/v1/index/getInfoByRoom';
static const String liveRoomPlayInfo = '/xlive/web-room/v2/index/getRoomPlayInfo';

// 直播弹幕
static const String liveDanmaku = '/xlive/web-room/v1/dM/list';

// 直播分区
static const String liveAreaList = '/xlive/web-interface/v1/second/getList';
```

### 6. 动态相关 API

```dart
// 动态列表
static const String dynamicsList = '/x/polymer/web-dynamic/v1/feed/all';

// 动态详情
static const String dynamicsDetail = '/x/polymer/web-dynamic/v1/detail';

// 发布动态
static const String dynamicsPublish = '/x/vu/web/add';
```

## 请求封装

### 1. 基础请求方法

```dart
class Request {
  static final Request _instance = Request._internal();
  factory Request() => _instance;

  // GET 请求
  Future<Response> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // POST 请求
  Future<Response> post<T>(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
```

### 2. 业务请求封装

各业务模块对基础请求方法进行封装，提供更具体的接口：

```dart
class VideoHttp {
  // 获取视频详情
  static Future videoInfo({required bvid}) async {
    var response = await Request().get(
      Api.videoIntro,
      queryParameters: {'bvid': bvid},
    );
    return response.data;
  }

  // 获取视频流
  static Future videoUrl({
    required bvid,
    required cid,
    int qn = 80,
  }) async {
    var response = await Request().get(
      Api.ugcUrl,
      queryParameters: {
        'bvid': bvid,
        'cid': cid,
        'qn': qn,
      },
    );
    return response.data;
  }

  // 点赞视频
  static Future likeVideo({
    required bvid,
    required like,
  }) async {
    var response = await Request().post(
      Api.likeVideo,
      data: {
        'bvid': bvid,
        'like': like,
      },
    );
    return response.data;
  }
}
```

## 响应处理

### 1. 响应解码

```dart
static String _responseDecoder(
  List<int> responseBytes,
  RequestOptions options,
  ResponseBody responseBody,
) {
  final contentEncoding = responseBody.headers['content-encoding'];
  if (contentEncoding?.contains('br') == true) {
    return utf8.decode(_brotilDecoder.decodeBytes(responseBytes));
  } else if (contentEncoding?.contains('gzip') == true) {
    return utf8.decode(_gzipDecoder.decodeBytes(responseBytes));
  } else {
    return utf8.decode(responseBytes);
  }
}
```

### 2. 错误处理

```dart
try {
  final response = await Request().get(url);
  return response.data;
} on DioException catch (e) {
  // 处理 Dio 异常
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw '连接超时';
    case DioExceptionType.sendTimeout:
      throw '请求超时';
    case DioExceptionType.receiveTimeout:
      throw '响应超时';
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          throw '服务器错误';
        } else if (statusCode == 401) {
          throw '未授权，请登录';
        } else if (statusCode == 403) {
          throw '禁止访问';
        } else if (statusCode == 404) {
          throw '资源不存在';
        }
      }
      throw '请求失败: ${e.message}';
    case DioExceptionType.cancel:
      throw '请求已取消';
    case DioExceptionType.connectionError:
      throw '网络连接错误';
    case DioExceptionType.badCertificate:
      throw '证书验证失败';
    case DioExceptionType.unknown:
      throw '未知错误: ${e.message}';
  }
} catch (e) {
  throw '请求异常: $e';
}
```

## 认证与授权

### 1. Cookie 管理

```dart
class AccountManager extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加认证信息
    final account = options.extra['account'] as Account?;
    if (account != null && account.isLogin) {
      options.headers['cookie'] = account.cookie;
      options.headers['authorization'] = account.token;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 更新认证信息
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final account = response.requestOptions.extra['account'] as Account?;
      if (account != null) {
        account.updateCookies(cookies);
      }
    }
    super.onResponse(response, handler);
  }
}
```

### 2. Buvid 激活

```dart
static Future<void> buvidActive(Account account) async {
  if (account.activited) return;
  account.activited = true;
  
  try {
    final String randPngEnd = base64.encode(
      List<int>.generate(32, (_) => Utils.random.nextInt(256)) +
          List<int>.filled(4, 0) +
          [73, 69, 78, 68] +
          List<int>.generate(4, (_) => Utils.random.nextInt(256)),
    );

    String jsonData = json.encode({
      '3064': 1,
      '39c8': '333.1387.fp.risk',
      '3c43': {
        'adca': 'Linux',
        'bfe9': randPngEnd.substring(randPngEnd.length - 50),
      },
    });

    await Request().post(
      Api.activateBuvidApi,
      data: {'payload': jsonData},
      options: Options(
        extra: {'account': account},
        contentType: Headers.jsonContentType,
      ),
    );
  } catch (_) {}
}
```

## 重试机制

```dart
class RetryInterceptor extends Interceptor {
  final int retryCount;
  final int retryDelay;

  RetryInterceptor(this.retryCount, this.retryDelay);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    if (retryCount < this.retryCount) {
      extra['retryCount'] = retryCount + 1;
      
      // 延迟重试
      await Future.delayed(Duration(milliseconds: retryDelay));
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 重试失败，继续传递错误
      }
    }
    
    super.onError(err, handler);
  }
}
```

## 缓存策略

### 1. 内存缓存

```dart
class MemoryCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  
  static T? get<T>(String key) {
    final time = _cacheTime[key];
    if (time != null && DateTime.now().difference(time).inMinutes < 5) {
      return _cache[key] as T?;
    }
    _cache.remove(key);
    _cacheTime.remove(key);
    return null;
  }
  
  static void set(String key, dynamic value) {
    _cache[key] = value;
    _cacheTime[key] = DateTime.now();
  }
}
```

### 2. 磁盘缓存

```dart
class DiskCache {
  static Future<T?> get<T>(String key) async {
    try {
      final file = await _getFile(key);
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        final time = DateTime.parse(data['time']);
        if (DateTime.now().difference(time).inHours < 24) {
          return data['value'] as T?;
        }
        await file.delete();
      }
    } catch (e) {
      // 处理异常
    }
    return null;
  }
  
  static Future<void> set(String key, dynamic value) async {
    try {
      final file = await _getFile(key);
      final data = {
        'time': DateTime.now().toIso8601String(),
        'value': value,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // 处理异常
    }
  }
}
```

## 网络状态监测

```dart
class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  bool _isConnected = true;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get networkStream => _controller.stream;
  bool get isConnected => _isConnected;

  void init() {
    Connectivity().onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      
      if (wasConnected != _isConnected) {
        _controller.add(_isConnected);
      }
    });
  }
}
```

## 最佳实践

### 1. 请求封装

- 为每个业务模块创建专门的 HTTP 类
- 统一错误处理和响应格式
- 提供类型安全的接口

### 2. 错误处理

- 区分网络错误和业务错误
- 提供用户友好的错误提示
- 实现自动重试机制

### 3. 性能优化

- 使用 HTTP/2 提高请求效率
- 实现合理的缓存策略
- 避免重复请求

### 4. 安全考虑

- 使用 HTTPS 加密传输
- 验证服务器证书
- 妥善处理敏感信息

## 常见问题与解决方案

### 1. 请求超时

**问题**: 网络请求经常超时

**解决方案**: 
- 增加超时时间
- 实现重试机制
- 优化网络环境

```dart
BaseOptions options = BaseOptions(
  connectTimeout: const Duration(milliseconds: 15000),
  receiveTimeout: const Duration(milliseconds: 30000),
);
```

### 2. 证书验证失败

**问题**: 在某些环境下证书验证失败

**解决方案**: 
- 配置证书验证回调
- 允许特定证书
- 使用系统代理

```dart
final httpAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // 验证证书逻辑
      return true; // 仅用于开发环境
    };
    return client;
  },
);
```

### 3. 并发请求限制

**问题**: 过多并发请求导致性能问题

**解决方案**: 
- 实现请求队列
- 限制并发数量
- 合并相似请求

```dart
class RequestQueue {
  static final Queue<Future<void>> _queue = Queue();
  static final Semaphore _semaphore = Semaphore(5); // 限制5个并发
  
  static Future<T> add<T>(Future<T> Function() request) async {
    await _semaphore.acquire();
    try {
      return await request();
    } finally {
      _semaphore.release();
    }
  }
}
```