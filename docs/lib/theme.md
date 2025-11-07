# 主题 (Theme)

## 概述

PiliPlus 项目实现了完整的主题系统，支持浅色/深色模式切换、多种颜色主题选择、动态取色以及自定义调色板风格。主题系统基于 Material Design 3 设计规范，使用 `flex_seed_scheme` 包实现动态颜色生成，为用户提供丰富的个性化选择。

## 主题架构

### 1. 主题类型定义

项目定义了三种主题模式：

```dart
enum ThemeType {
  light('浅色'),
  dark('深色'),
  system('跟随系统');

  final String desc;
  const ThemeType(this.desc);

  ThemeMode get toThemeMode => switch (this) {
    ThemeType.light => ThemeMode.light,
    ThemeType.dark => ThemeMode.dark,
    ThemeType.system => ThemeMode.system,
  };

  Icon get icon => switch (this) {
    ThemeType.light => const Icon(MdiIcons.weatherSunny),
    ThemeType.dark => const Icon(MdiIcons.weatherNight),
    ThemeType.system => const Icon(MdiIcons.themeLightDark),
  };
}
```

### 2. 颜色主题定义

项目提供了多种预设颜色主题：

```dart
const List<({Color color, String label})> colorThemeTypes = [
  (color: Color(0xFF5CB67B), label: '默认绿'),
  (color: Color(0xFFFF7299), label: '粉红色'),
  (color: Colors.red, label: '红色'),
  (color: Colors.orange, label: '橙色'),
  (color: Colors.amber, label: '琥珀色'),
  (color: Colors.yellow, label: '黄色'),
  (color: Colors.lime, label: '酸橙色'),
  (color: Colors.lightGreen, label: '浅绿色'),
  (color: Colors.green, label: '绿色'),
  (color: Colors.teal, label: '青色'),
  (color: Colors.cyan, label: '蓝绿色'),
  (color: Colors.lightBlue, label: '浅蓝色'),
  (color: Colors.blue, label: '蓝色'),
  (color: Colors.indigo, label: '靛蓝色'),
  (color: Colors.purple, label: '紫色'),
  (color: Colors.deepPurple, label: '深紫色'),
  (color: Colors.blueGrey, label: '蓝灰色'),
  (color: Colors.brown, label: '棕色'),
  (color: Colors.grey, label: '灰色'),
];
```

### 3. 主题工具类

`ThemeUtils` 类负责生成和配置主题数据：

```dart
abstract class ThemeUtils {
  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
    required FlexSchemeVariant variant,
  }) {
    final appFontWeight = Pref.appFontWeight.clamp(
      -1,
      FontWeight.values.length - 1,
    );
    final fontWeight = appFontWeight == -1
        ? null
        : FontWeight.values[appFontWeight];
    late final textStyle = TextStyle(fontWeight: fontWeight);
    
    ThemeData themeData = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: fontWeight == null
          ? null
          : TextTheme(
              displayLarge: textStyle,
              displayMedium: textStyle,
              displaySmall: textStyle,
              headlineLarge: textStyle,
              headlineMedium: textStyle,
              headlineSmall: textStyle,
              titleLarge: textStyle,
              titleMedium: textStyle,
              titleSmall: textStyle,
              bodyLarge: textStyle,
              bodyMedium: textStyle,
              bodySmall: textStyle,
              labelLarge: textStyle,
              labelMedium: textStyle,
              labelSmall: textStyle,
            ),
      // 更多主题配置...
    );
    
    // 深色主题处理
    if (isDark) {
      if (Pref.isPureBlackTheme) {
        themeData = darkenTheme(themeData);
      }
      if (Pref.darkVideoPage) {
        MyApp.darkThemeData = themeData;
      }
    }
    
    return themeData;
  }

  static ThemeData darkenTheme(ThemeData themeData) {
    // 实现纯黑主题
    final colorScheme = themeData.colorScheme;
    final color = colorScheme.surfaceContainerHighest.darken(0.7);
    return themeData.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: themeData.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      // 更多深色主题配置...
    );
  }
}
```

## 主题初始化

### 1. 应用初始化

在 `main.dart` 中初始化主题：

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取动态颜色
    final Color? lightDynamic = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.light,
    ).surfaceTint;
    final Color? darkDynamic = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.dark,
    ).surfaceTint;
    
    // 生成颜色方案
    late ColorScheme lightColorScheme;
    late ColorScheme darkColorScheme;
    if (isDynamicColor && lightDynamic != null && darkDynamic != null) {
      lightColorScheme = ColorScheme.fromSeed(
        seedColor: lightDynamic,
        brightness: Brightness.light,
        variant: variant,
      );
      darkColorScheme = ColorScheme.fromSeed(
        seedColor: darkDynamic,
        brightness: Brightness.dark,
        variant: variant,
      );
    } else {
      lightColorScheme = SeedColorScheme.fromSeeds(
        primaryKey: brandColor,
        brightness: Brightness.light,
        variant: variant,
      );
      darkColorScheme = SeedColorScheme.fromSeeds(
        primaryKey: brandColor,
        brightness: Brightness.dark,
        variant: variant,
      );
    }

    return GetMaterialApp(
      title: Constants.appName,
      theme: ThemeUtils.getThemeData(
        colorScheme: lightColorScheme,
        isDynamic: lightDynamic != null && isDynamicColor,
        variant: variant,
      ),
      darkTheme: ThemeUtils.getThemeData(
        colorScheme: darkColorScheme,
        isDynamic: darkDynamic != null && isDynamicColor,
        isDark: true,
        variant: variant,
      ),
      themeMode: Pref.themeMode,
      // 其他配置...
    );
  }
}
```

## 主题选择界面

### 1. 颜色选择页面

`ColorSelectPage` 提供了完整的主题选择界面：

```dart
class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ColorSelectController ctr = Get.put(ColorSelectController());
  FlexSchemeVariant _dynamicSchemeVariant =
      FlexSchemeVariant.values[Pref.schemeVariant];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('选择应用主题')),
      body: ListView(
        children: [
          // 主题模式选择
          ListTile(
            onTap: () async {
              ThemeType? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<ThemeType>(
                    title: '主题模式',
                    value: ctr.themeType.value,
                    values: ThemeType.values.map((e) => (e, e.desc)).toList(),
                  );
                },
              );
              if (result != null) {
                try {
                  Get.find<MineController>().themeType.value = result;
                } catch (_) {}
                ctr.themeType.value = result;
                GStorage.setting.put(SettingBoxKey.themeMode, result.index);
                Get.changeThemeMode(result.toThemeMode);
              }
            },
            leading: Container(
              width: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.flashlight_on_outlined),
            ),
            title: Text('主题模式', style: titleStyle),
            subtitle: Obx(
              () => Text(
                '当前模式：${ctr.themeType.value.desc}',
                style: subTitleStyle,
              ),
            ),
          ),
          
          // 调色板风格选择
          Obx(
            () => ListTile(
              enabled: !ctr.dynamicColor.value,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('调色板风格'),
                  PopupMenuButton(
                    enabled: !ctr.dynamicColor.value,
                    initialValue: _dynamicSchemeVariant,
                    onSelected: (item) {
                      _dynamicSchemeVariant = item;
                      GStorage.setting.put(
                        SettingBoxKey.schemeVariant,
                        item.index,
                      );
                      Get.forceAppUpdate();
                    },
                    itemBuilder: (context) => FlexSchemeVariant.values
                        .map(
                          (item) => PopupMenuItem<FlexSchemeVariant>(
                            value: item,
                            child: Text(item.variantName),
                          ),
                        )
                        .toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dynamicSchemeVariant.variantName,
                          style: TextStyle(
                            height: 1,
                            fontSize: 13,
                            color: ctr.dynamicColor.value
                                ? theme.colorScheme.outline.withValues(
                                    alpha: 0.8,
                                  )
                                : theme.colorScheme.secondary,
                          ),
                          strutStyle: const StrutStyle(leading: 0, height: 1),
                        ),
                        Icon(
                          size: 20,
                          Icons.keyboard_arrow_right,
                          color: ctr.dynamicColor.value
                              ? theme.colorScheme.outline.withValues(
                                  alpha: 0.8,
                                )
                              : theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              leading: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.palette_outlined),
              ),
              subtitle: Text(
                _dynamicSchemeVariant.description,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          
          // 动态取色开关
          Obx(
            () => CheckboxListTile(
              title: const Text('动态取色'),
              controlAffinity: ListTileControlAffinity.leading,
              value: ctr.dynamicColor.value,
              onChanged: (val) {
                ctr
                  ..dynamicColor.value = val!
                  ..setting.put(SettingBoxKey.dynamicColor, val);
                Get.forceAppUpdate();
              },
            ),
          ),
          
          // 颜色选择网格
          Padding(
            padding: padding,
            child: AnimatedSize(
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 200),
              child: Obx(
                () => ctr.dynamicColor.value
                    ? const SizedBox.shrink(key: ValueKey(false))
                    : Padding(
                        key: const ValueKey(true),
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 22,
                          runSpacing: 18,
                          children: colorThemeTypes.indexed.map(
                            (e) {
                              final index = e.$1;
                              final item = e.$2;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  ctr.brandColor.value = item.color;
                                  GStorage.setting.put(
                                    SettingBoxKey.brandColor,
                                    item.color.value,
                                  );
                                  Get.forceAppUpdate();
                                },
                                child: ColorPalette(
                                  color: item.color,
                                  selected: ctr.brandColor.value == item.color,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 颜色调色板组件

`ColorPalette` 组件用于显示颜色选择器：

```dart
class ColorPalette extends StatelessWidget {
  final Color color;
  final bool selected;

  const ColorPalette({
    super.key,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Hct hct = Hct.fromInt(color.toARGB32());
    final primary = Color(Hct.from(hct.hue, 20.0, 90.0).toInt());
    final tertiary = Color(Hct.from(hct.hue + 50, 20.0, 85.0).toInt());
    final primaryContainer = Color(Hct.from(hct.hue, 30.0, 50.0).toInt());
    
    Widget coloredBox(Color color) => Expanded(
      child: ColoredBox(
        color: color,
        child: const SizedBox.expand(),
      ),
    );
    
    Widget child = ClipOval(
      child: Column(
        children: [
          coloredBox(primary),
          Expanded(
            child: Row(
              children: [
                coloredBox(tertiary),
                coloredBox(primaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
    
    if (selected) {
      child = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          child,
          Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: Color(Hct.from(hct.hue, 30.0, 40.0).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: primary,
              size: 12,
            ),
          ),
        ],
      );
    }
    
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onInverseSurface,
        borderRadius: StyleString.mdRadius,
      ),
      child: child,
    );
  }
}
```

## 主题配置选项

### 1. 主题模式

- **浅色模式**: 使用浅色背景和深色文字
- **深色模式**: 使用深色背景和浅色文字
- **跟随系统**: 根据系统设置自动切换浅色/深色模式

### 2. 调色板风格

项目支持多种 `FlexSchemeVariant` 调色板风格：

- **默认**: 标准的 Material Design 3 调色板
- **色调**: 基于色调的调色板
- **内容**: 基于内容类型的调色板
- **表达**: 更具表现力的调色板
- **鲜艳**: 更鲜艳的颜色
- **彩虹**: 彩虹色调色板

### 3. 动态取色

- **启用**: 从系统壁纸提取颜色作为主题色
- **禁用**: 使用用户选择的预设颜色

### 4. 纯黑主题

在深色模式下，可以选择纯黑主题，将背景色设置为纯黑色：

```dart
static ThemeData darkenTheme(ThemeData themeData) {
  final colorScheme = themeData.colorScheme;
  final color = colorScheme.surfaceContainerHighest.darken(0.7);
  return themeData.copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: themeData.appBarTheme.copyWith(
      backgroundColor: Colors.black,
    ),
    cardTheme: themeData.cardTheme.copyWith(
      color: Colors.black,
    ),
    // 更多组件设置为纯黑...
  );
}
```

## 主题持久化

主题设置通过 `GStorage` 和 `Pref` 类进行持久化：

```dart
// 保存主题模式
GStorage.setting.put(SettingBoxKey.themeMode, result.index);

// 保存品牌颜色
GStorage.setting.put(SettingBoxKey.brandColor, item.color.value);

// 保存动态取色设置
ctr.setting.put(SettingBoxKey.dynamicColor, val);

// 保存调色板风格
GStorage.setting.put(SettingBoxKey.schemeVariant, item.index);
```

## 主题应用

### 1. 应用主题更改

```dart
// 更改主题模式
Get.changeThemeMode(result.toThemeMode);

// 强制应用更新
Get.forceAppUpdate();
```

### 2. 在组件中使用主题

```dart
// 获取当前主题
final theme = Theme.of(context);

// 使用主题颜色
color: theme.colorScheme.primary,
backgroundColor: theme.colorScheme.surface,

// 使用主题文本样式
title: Text('标题', style: theme.textTheme.titleLarge),
```

## 最佳实践

### 1. 主题一致性

- 确保所有UI组件使用主题颜色，而不是硬编码颜色
- 使用 `Theme.of(context)` 获取当前主题
- 为自定义组件提供主题适配

### 2. 颜色使用

- 优先使用语义化颜色（如 `colorScheme.primary`）
- 避免直接使用颜色值，而是使用主题定义的颜色
- 为不同状态（如选中、禁用）使用适当的颜色

### 3. 深色模式适配

- 确保深色模式下的可读性
- 为深色模式调整阴影和边框
- 考虑在深色模式下使用纯黑主题

### 4. 性能优化

- 避免在构建方法中频繁创建主题数据
- 使用常量定义颜色和样式
- 合理使用动画和过渡效果

## 常见问题与解决方案

### 1. 主题不生效

**问题**: 更改主题后某些组件未更新

**解决方案**: 确保组件使用 `Theme.of(context)` 获取主题，而不是硬编码颜色

```dart
// 错误方式
Container(color: Colors.blue)

// 正确方式
Container(color: Theme.of(context).colorScheme.primary)
```

### 2. 深色模式文字不清晰

**问题**: 深色模式下文字对比度不足

**解决方案**: 使用主题的 `onSurface`、`onPrimary` 等语义化颜色

```dart
// 错误方式
Text('标题', style: TextStyle(color: Colors.black))

// 正确方式
Text('标题', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
```

### 3. 动态取色不工作

**问题**: 启用动态取色后主题色未改变

**解决方案**: 检查系统是否支持动态取色，并确保应用有权限访问壁纸

```dart
// 检查动态颜色支持
final Color? lightDynamic = ColorScheme.fromSeed(
  seedColor: brandColor,
  brightness: Brightness.light,
).surfaceTint;

if (lightDynamic != null) {
  // 支持动态取色
} else {
  // 不支持动态取色，使用默认颜色
}
```

### 4. 主题切换闪烁

**问题**: 切换主题时出现闪烁

**解决方案**: 使用 `Get.forceAppUpdate()` 强制更新，并确保主题数据在应用启动时已初始化

```dart
// 在切换主题后强制更新
Get.changeThemeMode(newThemeMode);
Get.forceAppUpdate();
```