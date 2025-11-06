# Flutter和Dart国内镜像源配置
# 在Windows系统中，可以通过系统环境变量设置以下内容
# 或者在命令行中临时设置

# Flutter镜像源
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Dart镜像源
export PUB_HOSTED_URL=https://pub.flutter-io.cn

# Gradle镜像源
export GRADLE_USER_HOME=d:/Workplace/APP/Flutter/PiliPlus/.gradle

# Android SDK镜像源
export ANDROID_HOME=/path/to/your/android/sdk

# 使用说明：
# 1. 在Windows系统中，可以通过"系统属性"->"高级"->"环境变量"设置上述环境变量
# 2. 或者在PowerShell中临时设置：
#    $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
#    $env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
# 3. 设置完成后，运行以下命令验证：
#    flutter doctor -v
#    dart pub --version