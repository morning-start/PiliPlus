# 网络请求 (Network Request)

## 概述

PiliPlus 项目实现了完整的网络请求系统，基于 Dio 框架构建，支持 HTTP/2 协议、请求重试、WBI 签名、Cookie 管理、代理设置等功能。网络请求系统为应用提供了与 B 站 API 交互的能力，包括视频信息获取、用户操作、动态加载等所有网络相关功能。

## 网络架构

### 1. 核心网络类

`Request` 类是网络请求的核心，采用单例模式：

```dart
class Request {
  static const _gzipDecoder = GZipDecoder();
  static const _brotilDecoder = BrotliDecoder();

  static final Request _instance = Request._internal();
  static late AccountManager accountManager;
  static late final Dio dio;
  factory Request() => _instance;

  // 设置cookie
  static void setCookie() {
    accountManager = AccountManager();
    dio.interceptors.add(accountManager);
    Accounts.refresh();
    LoginUtils.setWebCookie();

    if (Accounts.main.isLogin) {
      final coin = Pref.userInfoCache?.money;
      if (coin == null) {
        setCoin();
      } else {
        GlobalData().coins = coin;
      }
    }
  }
  
  // 初始化网络配置
  Request._internal() {
    // 配置基础选项
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
    
    // 配置代理和适配器
    // ...
    
    // 创建Dio实例
    dio = Dio(options)
      ..httpClientAdapter = Pref.enableHttp2 ? Http2Adapter(...) : http11Adapter;
      
    // 添加拦截器
    dio.interceptors.add(RetryInterceptor(Pref.retryCount, Pref.retryDelay));
    
    // 调试模式下添加日志拦截器
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }
}
```

### 2. API 接口定义

`Api` 类集中定义了所有 API 接口路径：

```dart
class Api {
  // 推荐视频
  static const String recommendListApp = '${HttpString.appBaseUrl}/x/v2/feed/index';
  static const String recommendListWeb = '/x/web-interface/index/top/feed/rcmd';

  // 热门视频
  static const String hotList = '/x/web-interface/popular';

  // 视频流
  static const String ugcUrl = '/x/player/wbi/playurl';
  static const String pgcUrl = '/pgc/player/web/v2/playurl';
  static const String pugvUrl = '/pugv/player/web/playurl';

  // 视频详情
  static const String videoIntro = '/x/web-interface/view';

  // 视频操作
  static const String likeVideo = '${HttpString.appBaseUrl}/x/v2/view/like';
  static const String coinVideo = '${HttpString.appBaseUrl}/x/v2/view/coin/add';
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  // 评论相关
  static const String replyList = '/x/v2/reply';
  static const String replyReplyList = '/x/v2/reply/reply';
  static const String likeReply = '/x/v2/reply/action';
  static const String replyAdd = '/x/v2/reply/add';

  // 用户相关
  static const String userInfo = '/x/web-interface/nav';
  static const String userStat = '/x/relation/stat';
  
  // 更多API定义...
}
```

### 3. 请求方法封装

`Request` 类提供了 GET、POST、PUT、DELETE 等 HTTP 方法的封装：

```dart
// GET请求
Future<Response> get<T>(
  String url, {
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
}) async {
  try {
    return await dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  } catch (e) {
    rethrow;
  }
}

// POST请求
Future<Response> post<T>(
  String url, {
  data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
}) async {
  try {
    return await dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  } catch (e) {
    rethrow;
  }
}
```

## 网络拦截器

### 1. 重试拦截器

`RetryInterceptor` 实现了自动重试机制：

```dart
class RetryInterceptor extends Interceptor {
  final int _count;
  final int _delay;

  RetryInterceptor(this._count, this._delay);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      // 处理重定向
      final options = err.requestOptions;
      if (options.followRedirects && options.maxRedirects > 0) {
        final status = err.response!.statusCode;
        if (status != null && 300 <= status && status < 400) {
          var redirectUrl = err.response!.headers.value('location');
          if (redirectUrl != null) {
            // 处理重定向逻辑
            // ...
          }
        }
      }
      return handler.next(err);
    } else {
      // 处理网络错误
      switch (err.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.unknown:
          if ((err.requestOptions.extra['_rt'] ??= 0) < _count &&
              err.error is! TransportConnectionException) {
            // 延迟重试
            Future.delayed(
              Duration(
                milliseconds: ++err.requestOptions.extra['_rt'] * _delay,
              ),
              () => Request.dio
                  .fetch(err.requestOptions)
                  .then(handler.resolve)
                  .onError<DioException>((error, _) => handler.reject(error)),
            );
          } else {
            handler.next(err);
          }
          return;
        default:
          return handler.next(err);
      }
    }
  }
}
```

### 2. 账户管理拦截器

`AccountManager` 负责管理多个账户的 Cookie 和认证信息：

```dart
class AccountManager extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加账户相关的请求头
    if (options.extra['account'] != null) {
      final account = options.extra['account'] as Account;
      // 设置账户相关的Cookie和认证信息
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 处理响应中的账户信息更新
    handler.next(response);
  }
}
```

## WBI 签名机制

### 1. WBI 签名工具类

`WbiSign` 类实现了 B 站 API 的 WBI 签名机制：

```dart
abstract class WbiSign {
  static Box localCache = GStorage.localCache;
  static final Lock lock = Lock();
  static final RegExp chrFilter = RegExp(r"[!\'\(\)\*]");
  static const mixinKeyEncTab = <int>[
    46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35,
    27, 43, 5, 49, 33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13,
  ];

  // 对 imgKey 和 subKey 进行字符顺序打乱编码
  static String getMixinKey(String orig) {
    return mixinKeyEncTab.map((i) => orig[i]).join();
  }

  // 为请求参数进行 wbi 签名
  static void encWbi(Map<String, dynamic> params, String mixinKey) {
    params['wts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // 按照 key 重排参数
    final List<String> keys = params.keys.toList()..sort();
    final queryStr = keys
        .map(
          (i) =>
              '${Uri.encodeComponent(i)}=${Uri.encodeComponent(params[i].toString().replaceAll(chrFilter, ''))}',
        )
        .join('&');
    params['w_rid'] = md5
        .convert(utf8.encode(queryStr + mixinKey))
        .toString(); // 计算 w_rid
  }

  // 获取最新的 img_key 和 sub_key
  static Future<String> getWbiKeys() async {
    final DateTime nowDate = DateTime.now();
    String? mixinKey = localCache.get(LocalCacheKey.mixinKey);
    if (mixinKey != null &&
        DateTime.fromMillisecondsSinceEpoch(
              localCache.get(LocalCacheKey.timeStamp) as int,
            ).day ==
            nowDate.day) {
      return mixinKey;
    }
    final resp = await Request().get(Api.userInfo);

    try {
      final wbiUrls = resp.data['data']['wbi_img'];

      mixinKey = getMixinKey(
        Utils.getFileName(wbiUrls['img_url'], fileExt: false) +
            Utils.getFileName(wbiUrls['sub_url'], fileExt: false),
      );

      localCache
        ..put(LocalCacheKey.mixinKey, mixinKey)
        ..put(LocalCacheKey.timeStamp, nowDate.millisecondsSinceEpoch);

      return mixinKey;
    } catch (_) {
      return '';
    }
  }

  // 为请求参数添加签名
  static Future<Map<String, dynamic>> makSign(
    Map<String, dynamic> params,
  ) async {
    final String mixinKey = await lock.synchronized(getWbiKeys);
    encWbi(params, mixinKey);
    return params;
  }
}
```

## 网络状态管理

### 1. 加载状态封装

`LoadingState` 类封装了网络请求的状态：

```dart
sealed class LoadingState<T> {
  const LoadingState();

  factory LoadingState.loading() = Loading;

  bool get isSuccess => this is Success<T>;

  T get data => switch (this) {
    Success(:var response) => response,
    _ => throw this,
  };

  T? get dataOrNull => switch (this) {
    Success(:var response) => response,
    _ => null,
  };

  void toast() => SmartDialog.showToast(toString());
}

class Loading extends LoadingState<Never> {
  const Loading._internal();
  static const Loading _instance = Loading._internal();
  factory Loading() => _instance;
  
  @override
  String toString() {
    return 'ApiException: loading';
  }
}

class Success<T> extends LoadingState<T> {
  final T response;
  const Success(this.response);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Success) {
      return response == other.response;
    }
    return false;
  }

  @override
  int get hashCode => response.hashCode;
}

class Error extends LoadingState<Never> {
  final int? code;
  final String? errMsg;
  const Error(this.errMsg, {this.code});
  
  @override
  String toString() {
    return errMsg ?? code?.toString() ?? '';
  }
}
```

## 业务网络请求

### 1. 视频相关请求

`VideoHttp` 类封装了视频相关的网络请求：

```dart
class VideoHttp {
  // 获取视频详情
  static Future videoDetail({
    required bvid,
    required aid,
  }) async {
    var res = await Request().get(
      Api.videoIntro,
      queryParameters: {
        'bvid': bvid,
        'aid': aid,
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': VideoDetailModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  // 获取视频流地址
  static Future videoUrl({
    required bvid,
    required cid,
    required qn,
  }) async {
    final params = await WbiSign.makSign({
      'bvid': bvid,
      'cid': cid,
      'qn': qn,
      'fourk': 1,
    });
    
    var res = await Request().get(
      Api.ugcUrl,
      queryParameters: params,
    );
    
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': VideoUrlModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  // 视频点赞
  static Future likeVideo({
    required bvid,
    required aid,
    required like,
  }) async {
    var res = await Request().post(
      Api.likeVideo,
      data: {
        'bvid': bvid,
        'aid': aid,
        'like': like ? 1 : 2,
      },
    );
    
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  // 更多视频相关请求...
}
```

### 2. 搜索相关请求

`SearchHttp` 类封装了搜索相关的网络请求：

```dart
class SearchHttp {
  // 获取搜索建议
  static Future searchSuggest({required String term}) async {
    var res = await Request().get(
      Api.searchSuggest,
      queryParameters: {
        'term': term,
        'main_ver': 'v1',
        'highlight': term,
      },
    );
    if (res.data is String) {
      Map<String, dynamic> resultMap = json.decode(res.data);
      if (resultMap['code'] == 0) {
        if (resultMap['result'] is Map) {
          return {
            'status': true,
            'data': SearchSuggestModel.fromJson(resultMap['result']),
          };
        }
      }
    }
    return {'status': false, 'msg': '请求错误'};
  }

  // 搜索视频
  static Future<LoadingState<SearchResultData>> searchVideo({
    required String keyword,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final params = await WbiSign.makSign({
      'keyword': keyword,
      'page': pageNum,
      'page_size': pageSize,
      'search_type': 'video',
    });
    
    final res = await Request().get(
      Api.searchAll,
      queryParameters: params,
    );
    
    if (res.data['code'] == 0) {
      return Success(SearchResultData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  // 更多搜索相关请求...
}
```

## 请求工具类

### 1. 请求工具

`RequestUtils` 类提供了常用的网络请求工具方法：

```dart
abstract class RequestUtils {
  // 同步历史记录状态
  static Future<void> syncHistoryStatus() async {
    final account = Accounts.history;
    if (!account.isLogin) {
      return;
    }
    var res = await UserHttp.historyStatus(account: account);
    if (res['status']) {
      GStorage.localCache.put(LocalCacheKey.historyPause, res['data']);
    }
  }

  // 私信分享
  static Future<void> pmShare({
    required int receiverId,
    required Map content,
    String? message,
  }) async {
    SmartDialog.showLoading();

    final ownerMid = Accounts.main.mid;
    final contentRes = await ImGrpc.sendMsg(
      senderUid: ownerMid,
      receiverId: receiverId,
      content: jsonEncode(content),
      msgType: content['source'] is String
          ? MsgType.EN_MSG_TYPE_COMMON_SHARE_CARD
          : MsgType.EN_MSG_TYPE_SHARE_V2,
    );

    if (contentRes.isSuccess) {
      if (message?.isNotEmpty == true) {
        var msgRes = await MsgHttp.sendMsg(
          senderUid: ownerMid,
          receiverId: receiverId,
          content: jsonEncode({"content": message}),
          msgType: 1,
        );
        Get.back();
        if (msgRes['status']) {
          SmartDialog.showToast('分享成功');
        } else {
          SmartDialog.showToast('内容分享成功，但消息分享失败: ${msgRes['msg']}');
        }
      } else {
        Get.back();
        SmartDialog.showToast('分享成功');
      }
    } else {
      SmartDialog.showToast('分享失败: ${(contentRes as Error).errMsg}');
    }
    SmartDialog.dismiss();
  }

  // 关注/取消关注
  static Future<void> actionRelationMod({
    required BuildContext context,
    required dynamic mid,
    required bool isFollow,
    required ValueChanged<int>? callback,
    Map? followStatus,
  }) async {
    if (mid == null) {
      return;
    }
    feedBack();
    if (!isFollow) {
      var res = await VideoHttp.relationMod(
        mid: mid,
        act: 1,
        reSrc: 11,
      );
      SmartDialog.showToast(res['status'] ? "关注成功" : res['msg']);
      if (res['status']) {
        callback?.call(2);
      }
    } else {
      // 处理取消关注逻辑
      // ...
    }
  }

  // 更多工具方法...
}
```

## 网络配置

### 1. HTTP/2 支持

项目支持 HTTP/2 协议，通过 `Http2Adapter` 实现：

```dart
final http11Adapter = IOHttpClientAdapter(
  createHttpClient: enableSystemProxy
      ? () => HttpClient()
          ..idleTimeout = const Duration(seconds: 15)
          ..autoUncompress = false
          ..findProxy = ((_) => 'PROXY $systemProxyHost:$systemProxyPort')
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true
      : () => HttpClient()
          ..idleTimeout = const Duration(seconds: 15)
          ..autoUncompress = false,
);

dio = Dio(options)
  ..httpClientAdapter = Pref.enableHttp2
      ? Http2Adapter(
          ConnectionManager(
            idleTimeout: const Duration(seconds: 15),
            onClientCreate: enableSystemProxy
                ? (_, config) {
                    config
                      ..proxy = proxy
                      ..onBadCertificate = (_) => true;
                  }
                : Pref.badCertificateCallback
                ? (_, config) {
                    config.onBadCertificate = (_) => true;
                  }
                : null,
          ),
          fallbackAdapter: http11Adapter,
        )
      : http11Adapter;
```

### 2. 代理设置

项目支持系统代理配置：

```dart
final bool enableSystemProxy;
late final String systemProxyHost;
late final int? systemProxyPort;
if (Pref.enableSystemProxy) {
  systemProxyHost = Pref.systemProxyHost;
  systemProxyPort = int.tryParse(Pref.systemProxyPort);
  enableSystemProxy = systemProxyPort != null && systemProxyHost.isNotEmpty;
} else {
  enableSystemProxy = false;
}
```

## 最佳实践

### 1. 错误处理

- 使用 `LoadingState` 封装请求状态
- 统一错误处理和提示
- 区分网络错误和业务错误

```dart
// 使用 LoadingState
Future<LoadingState<VideoModel>> getVideoDetail(String bvid) async {
  try {
    var res = await Request().get(Api.videoIntro, queryParameters: {'bvid': bvid});
    if (res.data['code'] == 0) {
      return Success(VideoModel.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  } catch (e) {
    return Error(e.toString());
  }
}

// 在控制器中使用
class VideoController extends GetxController {
  final videoState = LoadingState<VideoModel>.loading().obs;
  
  Future<void> fetchVideoDetail(String bvid) async {
    videoState.value = LoadingState.loading();
    final result = await VideoHttp.videoDetail(bvid: bvid);
    videoState.value = result;
    if (!result.isSuccess) {
      result.toast();
    }
  }
}
```

### 2. 请求优化

- 合理使用缓存
- 避免重复请求
- 适当使用请求取消

```dart
// 避免重复请求
class VideoController extends GetxController {
  final videoState = LoadingState<VideoModel>.loading().obs;
  CancelToken? _cancelToken;
  
  Future<void> fetchVideoDetail(String bvid) async {
    // 取消之前的请求
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    
    videoState.value = LoadingState.loading();
    final result = await VideoHttp.videoDetail(
      bvid: bvid,
      cancelToken: _cancelToken,
    );
    videoState.value = result;
  }
  
  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }
}
```

### 3. 安全性

- 敏感数据使用 HTTPS
- 重要接口使用 WBI 签名
- 避免在 URL 中传递敏感信息

```dart
// 使用 WBI 签名
static Future<LoadingState<SearchResultData>> searchVideo({
  required String keyword,
  int pageNum = 1,
}) async {
  // 添加签名
  final params = await WbiSign.makSign({
    'keyword': keyword,
    'page': pageNum,
    'search_type': 'video',
  });
  
  final res = await Request().get(
    Api.searchAll,
    queryParameters: params,
  );
  
  if (res.data['code'] == 0) {
    return Success(SearchResultData.fromJson(res.data['data']));
  } else {
    return Error(res.data['message']);
  }
}
```

## 常见问题与解决方案

### 1. 请求超时

**问题**: 网络请求经常超时

**解决方案**: 
- 检查网络连接
- 调整超时时间
- 使用重试机制

```dart
// 调整超时时间
BaseOptions options = BaseOptions(
  connectTimeout: const Duration(milliseconds: 15000), // 增加连接超时
  receiveTimeout: const Duration(milliseconds: 15000), // 增加接收超时
);

// 使用重试机制
dio.interceptors.add(RetryInterceptor(3, 1000)); // 重试3次，每次延迟1秒
```

### 2. 证书错误

**问题**: SSL 证书验证失败

**解决方案**: 
- 信任所有证书（仅开发环境）
- 配置正确的证书

```dart
// 信任所有证书（仅开发环境）
final http11Adapter = IOHttpClientAdapter(
  createHttpClient: () => HttpClient()
    ..idleTimeout = const Duration(seconds: 15)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true,
);
```

### 3. 请求被拦截

**问题**: 请求被 B 站风控系统拦截

**解决方案**: 
- 使用正确的 User-Agent
- 添加 WBI 签名
- 模拟正常用户行为

```dart
// 设置正确的 User-Agent
headers: {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  'Referer': 'https://www.bilibili.com',
},

// 添加 WBI 签名
final params = await WbiSign.makSign({
  'keyword': keyword,
  'page': pageNum,
});
```

### 4. Cookie 失效

**问题**: 登录状态丢失

**解决方案**: 
- 定期刷新 Cookie
- 检查登录状态
- 使用多账户管理

```dart
// 定期刷新 Cookie
static void setCookie() {
  accountManager = AccountManager();
  dio.interceptors.add(accountManager);
  Accounts.refresh();
  LoginUtils.setWebCookie();
}

// 检查登录状态
if (Accounts.main.isLogin) {
  // 执行需要登录的操作
} else {
  // 提示用户登录
}
```