# 通用组件 (Common Components)

## 概述

PiliPlus 项目中的通用组件位于 `lib/common` 目录下，这些组件在整个应用中被广泛使用，提供了统一的UI元素和交互体验。

## 目录结构

```
lib/common/
├── constants.dart          # 常量定义
├── skeleton/              # 骨架屏组件
└── widgets/               # 通用UI组件
    ├── appbar/            # 应用栏组件
    ├── button/            # 按钮组件
    ├── dialog/            # 对话框组件
    ├── draggable_sheet/   # 可拖拽底部表单
    ├── dyn/               # 动态相关组件
    ├── gesture/           # 手势相关组件
    ├── image/             # 图片相关组件
    ├── interactiveviewer_gallery/ # 图片查看器
    ├── loading_widget/    # 加载状态组件
    ├── page/              # 页面相关组件
    ├── progress_bar/      # 进度条组件
    ├── stat/              # 统计数据组件
    ├── text/              # 文本相关组件
    ├── text_field/        # 输入框组件
    └── video_card/        # 视频卡片组件
```

## 主要组件介绍

### 1. 骨架屏组件 (Skeleton)

骨架屏组件在数据加载时提供视觉反馈，提升用户体验。

- `dynamic_card.dart` - 动态卡片骨架屏
- `video_card_h.dart` - 横向视频卡片骨架屏
- `video_card_v.dart` - 纵向视频卡片骨架屏
- `space_opus.dart` - 用户空间内容骨架屏

### 2. 应用栏组件 (Appbar)

提供统一的应用栏样式和功能。

- `appbar.dart` - 自定义应用栏，支持标题、操作按钮等

### 3. 按钮组件 (Button)

提供各种样式的按钮组件。

- `icon_button.dart` - 图标按钮
- `more_btn.dart` - 更多操作按钮
- `toolbar_icon_button.dart` - 工具栏图标按钮

### 4. 对话框组件 (Dialog)

提供各种对话框样式。

- `dialog.dart` - 通用对话框
- `report.dart` - 举报对话框
- `report_member.dart` - 用户举报对话框

### 5. 图片相关组件 (Image)

处理图片显示、缓存和交互。

- `cached_network_svg_image.dart` - SVG网络图片缓存组件
- `network_img_layer.dart` - 网络图片层组件，支持加载状态
- `image_save.dart` - 图片保存功能

### 6. 图片查看器 (InteractiveViewer Gallery)

提供图片预览和交互功能。

- `interactiveviewer_gallery.dart` - 图片查看器主组件
- `interactive_viewer.dart` - 交互式图片查看器
- `hero_dialog_route.dart` - Hero动画路由

### 7. 加载状态组件 (Loading Widget)

显示各种加载状态。

- `loading_widget.dart` - 通用加载组件
- `http_error.dart` - HTTP错误状态组件

### 8. 进度条组件 (Progress Bar)

显示各种进度条。

- `audio_video_progress_bar.dart` - 音视频进度条
- `segment_progress_bar.dart` - 分段进度条
- `video_progress_indicator.dart` - 视频进度指示器

### 9. 文本组件 (Text)

提供各种文本显示和格式化功能。

- `text.dart` - 基础文本组件
- `paragraph.dart` - 段落文本组件
- `rich_text.dart` - 富文本组件

### 10. 输入框组件 (Text Field)

提供各种输入框样式和功能。

- `text_field.dart` - 基础输入框
- `editable.dart` - 可编辑文本
- `controller.dart` - 输入框控制器
- `spell_check.dart` - 拼写检查功能

### 11. 视频卡片组件 (Video Card)

显示视频信息的卡片组件。

- `video_card_h.dart` - 横向视频卡片
- `video_card_v.dart` - 纵向视频卡片

### 12. 其他重要组件

- `custom_toast.dart` - 自定义Toast提示
- `custom_icon.dart` - 自定义图标
- `marquee.dart` - 跑马灯效果
- `refresh_indicator.dart` - 下拉刷新组件
- `view_safe_area.dart` - 安全区域处理

## 使用示例

### 使用视频卡片组件

```dart
import 'package:PiliPlus/common/widgets/video_card/video_card_v.dart';

VideoCardV(
  videoItem: videoData,
  source: 'home',
)
```

### 使用加载组件

```dart
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';

LoadingWidget(
  isLoading: _loading,
  child: contentWidget,
)
```

### 使用自定义Toast

```dart
import 'package:PiliPlus/common/widgets/custom_toast.dart';

CustomToast.show('操作成功');
```

## 设计原则

1. **一致性**: 所有组件遵循统一的设计语言和交互规范
2. **可复用性**: 组件设计为高度可复用，减少代码重复
3. **可定制性**: 提供足够的参数允许组件在不同场景下定制
4. **性能优化**: 组件实现考虑性能，避免不必要的重建

## 最佳实践

1. 在创建新UI元素前，先检查是否已有合适的通用组件
2. 遵循组件的命名约定和使用规范
3. 对于复杂交互，考虑扩展现有组件而非创建全新组件
4. 保持组件的单一职责，避免组件过于复杂