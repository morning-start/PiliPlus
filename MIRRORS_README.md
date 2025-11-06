# Flutter Android配置国内镜像源

本项目已配置为使用国内镜像源，以提高依赖下载速度。

## 已修改的文件

1. **android/settings.gradle.kts**
   - 添加了阿里云镜像源作为主要仓库
   - 保留了官方源作为备用

2. **android/build.gradle.kts**
   - 添加了阿里云镜像源作为项目仓库
   - 保留了官方源作为备用

3. **android/gradle.properties**
   - 添加了Gradle优化配置
   - 启用了并行构建和缓存

## 新增的配置文件

1. **.flutter-tools**
   - Flutter工具配置文件，设置国内镜像源

2. **env_config.sh**
   - 环境变量配置说明文件

3. **setup_mirrors.bat**
   - Windows批处理文件，用于快速设置环境变量

## 使用方法

### 方法一：使用批处理文件（推荐）
在Windows系统中，双击运行 `setup_mirrors.bat` 文件，即可快速设置环境变量。

### 方法二：手动设置环境变量
在Windows系统中，通过"系统属性"->"高级"->"环境变量"设置以下内容：
```
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### 方法三：PowerShell临时设置
在PowerShell中运行以下命令：
```powershell
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
```

## 验证配置

运行以下命令验证配置是否生效：
```bash
flutter doctor -v
```

## 清理缓存（可选）

如果配置后仍有问题，可以尝试清理缓存：
```bash
flutter clean
flutter pub cache repair
```

## 注意事项

1. 首次配置后，建议执行 `flutter clean` 和 `flutter pub get` 重新获取依赖
2. 如果遇到下载问题，可以尝试切换到官方源
3. 配置完成后，依赖下载速度应显著提高