@echo off
echo 正在设置Flutter和Dart国内镜像源...

REM 设置Flutter镜像源
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM 设置Dart镜像源
set PUB_HOSTED_URL=https://pub.flutter-io.cn

echo 环境变量设置完成！
echo FLUTTER_STORAGE_BASE_URL=%FLUTTER_STORAGE_BASE_URL%
echo PUB_HOSTED_URL=%PUB_HOSTED_URL%

echo.
echo 验证配置...
flutter doctor -v
echo.
echo 配置完成！现在可以使用Flutter和Dart的国内镜像源了。
pause