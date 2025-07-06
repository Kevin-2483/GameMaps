/*
🎯 R6BOX 智能动态显示系统控制指南 - 解决图标闪烁问题

📋 【核心统一参数】:

🎮 主控参数 (第190-205行):
  - _displayAreaMultiplier: 显示区域大小倍数
    • 1.0 = 正常屏幕大小 (推荐)
    • 0.5 = 一半屏幕 (更近，图标更少，性能更好)
    • 2.0 = 两倍屏幕 (更远，图标更多，性能稍差)
    
  - _baseBufferMultiplier: 基础缓冲区倍数
    • 1.5 = 50%基础缓冲 (推荐)
    • 1.2 = 20%基础缓冲 (最小缓冲)
    • 2.0 = 100%基础缓冲 (大缓冲)
    
  - _perspectiveBufferFactor: 透视缓冲调节系数 ⭐NEW⭐
    • 0.0 = 缓冲区不受透视角度影响 (固定缓冲)
    • 0.8 = 透视角度越大缓冲区越大 (推荐，智能调节)
    • 2.0 = 强烈响应透视变化 (最大自适应)

🔄 【窗口自适应系统】⭐NEW⭐:
  - _windowScalingFactor: 窗口大小随动系数 (第214行)
    • 0.0 = 内容大小固定，大窗口显示更多图标 (高密度模式)
    • 0.5 = 内容适度放大，图标数量适度减少 (平衡模式，推荐)
    • 1.0 = 内容完全随窗口缩放，图标数量恒定 (恒定数量模式)
    
  - _baseNodeSpacing: 基础网格间距 (标准1920×1080下的间距)
  - _baseSvgRenderSize: 基础图标大小 (标准1920×1080下的大小)

🎨 【主题兼容系统】⭐NEW⭐:
  - 自动适配亮色/暗色主题的背景颜色
  - SVG图标智能颜色滤镜：暗色主题增亮，亮色主题调暗
  - 微妙的主题色渐变覆盖层，增强视觉层次
  - 主题变化时自动重绘，保证一致的视觉体验

💡 【智能缓冲原理】⭐升级⭐:
  新系统会根据摄像机的透视倾斜程度和显示区域大小自动调整缓冲区：
  - 实际缓冲倍数 = 基础缓冲 × (1 + 透视强度 × 调节系数 × 显示区域倍数)
  - 透视角度大时：缓冲区自动增大，防止图标突然出现
  - 显示区域大时：缓冲区按比例增大，覆盖更大的透视边缘
  - 透视角度小时：缓冲区自动减小，优化性能
  - 创建/删除区域 = 基础显示区域 × 动态缓冲倍数
  - 显示/隐藏区域 = 基础显示区域 × 1.0

📐 【窗口自适应原理】⭐NEW⭐:
  系统根据窗口大小相对于标准尺寸(1920×1080)的变化，智能调整内容大小：
  - 缩放因子 = √(当前窗口面积 / 标准窗口面积)
  - 实际间距 = 基础间距 × (1 + (缩放因子 - 1) × 随动系数)
  - 实际图标大小 = 基础大小 × (1 + (缩放因子 - 1) × 随动系数)
  - 图标数量变化 ≈ 1 / (缩放因子²)

🎯 性能优化参数:
  - _baseNodeSpacing (第219行): 基础网格间距 (80~250) + 窗口自适应
  - _baseSvgRenderSize (第224行): 基础图标大小 (40~180) + 窗口自适应
  - _windowScalingFactor (第214行): 窗口随动系数 (0.0~1.0)
  - enlargementFactor (第908行): 图标放大系数 (1.0~2.5)

💡 快速调整示例:
  【当前配置分析】(显示区域=1.5x, 窗口随动=0.5):
    当前配置为智能平衡模式，窗口放大时内容适度放大，图标数量适度减少
  
  【智能平衡模式】(推荐):
    _displayAreaMultiplier = 1.5, _baseBufferMultiplier = 1.5, _perspectiveBufferFactor = 1, _windowScalingFactor = 0.5
  
  【高密度模式】(小窗口/性能优先):
    _displayAreaMultiplier = 1.2, _baseBufferMultiplier = 1.3, _perspectiveBufferFactor = 1, _windowScalingFactor = 0.2
  
  【恒定数量模式】(图标数量固定):
    _displayAreaMultiplier = 1.5, _baseBufferMultiplier = 1.5, _perspectiveBufferFactor = 1, _windowScalingFactor = 1.0
  
  【视觉效果优先】(大图标):
    _displayAreaMultiplier = 1.8, _baseBufferMultiplier = 2.0, _perspectiveBufferFactor = 1, _windowScalingFactor = 0.7
    
💡 参数调整建议:
  - 如果仍有图标突然出现：增加 _baseBufferMultiplier 到 1.8-2.5 范围
  - 如果大窗口性能不佳：降低 _windowScalingFactor 到 0.2-0.4 范围
  - 如果想要更多图标：降低 _windowScalingFactor 到 0.0-0.3 范围
  - 如果想要固定图标数量：设置 _windowScalingFactor = 1.0
  - 如果透视变换时不够平滑：微调 _baseBufferMultiplier 到 1.5-2.0 范围

🖥️ 【不同窗口尺寸的表现】:
  - 1366×768 (随动0.5): 间距170px, 图标128px, 约60-90个图标
  - 1920×1080 (标准): 间距200px, 图标150px, 约90-130个图标
  - 2560×1440 (随动0.5): 间距224px, 图标168px, 约120-170个图标
  - 3840×2160 (随动0.5): 间距283px, 图标212px, 约180-250个图标
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:jovial_svg/jovial_svg.dart';
import '../../components/layout/main_layout.dart'; // 请确保这个路径是正确的
import '../../components/common/edge_drag_area.dart'; // 边缘拖动区域组件
import '../../providers/user_preferences_provider.dart';
import '../../models/user_preferences.dart';

/// SVG节点数据类
class _SvgNode {
  final String svgPath;
  final Offset worldPosition; // 世界坐标位置
  final ScalableImage svgImage;

  _SvgNode({
    required this.svgPath,
    required this.worldPosition,
    required this.svgImage,
  });

  String get key => '${worldPosition.dx.toInt()}_${worldPosition.dy.toInt()}';
}

/*
🌊 波纹背景效果自定义指南

📋 快速调整参数列表:

🚀 动画速度:
  - 第31行: Duration(seconds: 12) → 修改数值调整波纹速度

📍 波纹中心位置:
  - 第93-94行: size.width * 0.8, size.height * 0.8 → 修改系数调整位置
  - 0.0 = 左/上边缘, 0.5 = 中心, 1.0 = 右/下边缘

🎨 背景颜色:
  - 第99-106行: colors 数组 → 修改颜色值调整背景渐变

🌊 波纹层数和颜色:
  - 第120-122行: _drawRippleLayer 调用 → 添加/删除/修改波纹层

🔄 波纹密度:
  - 第132行: rippleCount = 2 → 修改数值调整每层波纹数量

⏱️ 波纹间隔:
  - 第142行: (i * 0.5) → 修改系数调整波纹间距

📏 波纹扩散距离:
  - 第149行: maxRadius * 2.2 → 修改倍数调整扩散范围

🖌️ 波纹线条粗细:
  - 第170行: 3.0 和 0.5 → 修改数值调整线条宽度

💡 中心发光大小:
  - 第191行: 20 和 * 5 → 修改数值调整发光半径

🌟 发光亮度:
  - 第199行: 0.6 和 0.2 → 修改数值调整发光强度

🎯 中心点大小:
  - 第229行: 3 → 修改数值调整中心亮点大小

🗺️ 地图标记图标大小:
  - 第241行: * 0.75 → 修改系数调整图标大小 (0.8 = 更大, 0.6 = 更小)

🎨 地图标记图标颜色:
  - 第245行: iconOpacity → 修改图标透明度和呼吸效果

📸 透视背景图片控制:

🎬 图片轮播速度:
  - Duration(seconds: 20): 每张图片显示时长 (数值越小 = 切换越快)

🎭 透视角度范围:
  - _initializeBackgroundParams() 中的 60: 最大倾斜角度 (度数)

🔍 摄像机缩放 (图片大小):
  - PerspectiveBackgroundPainter 中的 cameraZoom = 2.0
  - 1.0 = 原始大小, 2.0 = 放大2倍, 0.5 = 缩小一半

🌐 图片覆盖扩展:
  - expansionFactor = 1.8: 防止透视变换露出空白的扩展倍数

🎯 透视强度:
  - perspective.setEntry(3, 2, -0.001): 透视效果强度 (绝对值越大越明显)

💡 使用示例:
  - 让波纹更快: Duration(seconds: 8)
  - 移到左上角: size.width * 0.2, size.height * 0.2  
  - 更密集波纹: rippleCount = 4
  - 更大扩散: maxRadius * 3.0
  - 更快图片切换: Duration(seconds: 10)
  - 更强透视效果: -0.002
  - 更大图片缩放: cameraZoom = 3.0
*/

class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // 背景SVG控制
  List<String> _svgPaths = [];
  Map<String, ScalableImage> _cachedSvgs = {}; // 缓存的SVG对象
  bool _svgsCached = false;

  // 无限滚动背景控制
  late Offset _cameraDirection; // 摄像机移动方向（单位向量）
  late double _cameraSpeed; // 摄像机移动速度
  Offset _currentCameraPosition = const Offset(0, 0); // 当前摄像机位置（世界坐标）

  // 网格管理
  final Map<String, _SvgNode> _activeNodes = {}; // 当前活跃的SVG节点

  // 🎯 【SVG重复控制】- 避免相同SVG图标聚集出现的智能分布系统
  final List<String> _recentlyUsedSvgs = []; // 最近使用的SVG路径列表（按时间顺序）

  // 🔧 【从用户偏好设置获取的动态参数】
  // 这些参数现在从用户偏好设置中读取，支持实时调整
  late HomePagePreferences _homePageSettings; // 主页设置

  // 🔧 【主页参数getter】从用户偏好设置获取参数
  double get _displayAreaMultiplier => _homePageSettings.displayAreaMultiplier;
  double get _baseBufferMultiplier => _homePageSettings.baseBufferMultiplier;
  double get _perspectiveBufferFactor =>
      _homePageSettings.perspectiveBufferFactor;
  double get _windowScalingFactor => _homePageSettings.windowScalingFactor;
  double get _baseNodeSpacing => _homePageSettings.baseNodeSpacing;
  double get _baseSvgRenderSize => _homePageSettings.baseSvgRenderSize;
  bool get _enableSvgFilters => _homePageSettings.enableThemeColorFilter;
  String get _homeTitle => _homePageSettings.titleText;
  double get _titleFontSizeMultiplier =>
      _homePageSettings.titleFontSizeMultiplier;
  int get _recentSvgHistorySize => _homePageSettings.recentSvgHistorySize;

  // 🎯 【动态计算】当前实际使用的参数（根据设置和窗口大小自动计算）
  late double _nodeSpacing; // 当前网格间距（动态计算）
  late double _svgRenderSize; // 当前SVG渲染大小（动态计算）

  late double _triangleHeight; // 等边三角形高度 (自动根据_nodeSpacing计算)
  Size _screenSize = const Size(2560, 1440); // 屏幕尺寸

  // 透视变换参数
  late double _perspectiveAngleX;
  late double _perspectiveAngleY;

  // 🔧 【初始化标志】确保某些操作只执行一次
  bool _cameraInitialized = false;

  // 🎯 无限移动控制 - 用于计算连续移动时间
  double? _cameraStartTime;

  // 🔧 【节点管理】定期清理计时器
  double? _lastCleanupTime;

  @override
  void initState() {
    super.initState();

    // 初始化SVG路径
    _svgPaths = [
      'assets/images/r6operators_flat/ace.svg',
      'assets/images/r6operators_flat/alibi.svg',
      'assets/images/r6operators_flat/amaru.svg',
      'assets/images/r6operators_flat/aruni.svg',
      'assets/images/r6operators_flat/ash.svg',
      'assets/images/r6operators_flat/azami.svg',
      'assets/images/r6operators_flat/bandit.svg',
      'assets/images/r6operators_flat/blackbeard.svg',
      'assets/images/r6operators_flat/blitz.svg',
      'assets/images/r6operators_flat/brava.svg',
      'assets/images/r6operators_flat/buck.svg',
      'assets/images/r6operators_flat/capitao.svg',
      'assets/images/r6operators_flat/castle.svg',
      'assets/images/r6operators_flat/caveira.svg',
      'assets/images/r6operators_flat/clash.svg',
      'assets/images/r6operators_flat/deimos.svg',
      'assets/images/r6operators_flat/doc.svg',
      'assets/images/r6operators_flat/dokkaebi.svg',
      'assets/images/r6operators_flat/echo.svg',
      'assets/images/r6operators_flat/ela.svg',
      'assets/images/r6operators_flat/fenrir.svg',
      'assets/images/r6operators_flat/finka.svg',
      'assets/images/r6operators_flat/flores.svg',
      'assets/images/r6operators_flat/frost.svg',
      'assets/images/r6operators_flat/fuze.svg',
      'assets/images/r6operators_flat/glaz.svg',
      'assets/images/r6operators_flat/goyo.svg',
      'assets/images/r6operators_flat/gridlock.svg',
      'assets/images/r6operators_flat/grim.svg',
      'assets/images/r6operators_flat/hibana.svg',
      'assets/images/r6operators_flat/iana.svg',
      'assets/images/r6operators_flat/iq.svg',
      'assets/images/r6operators_flat/jackal.svg',
      'assets/images/r6operators_flat/jager.svg',
      'assets/images/r6operators_flat/kaid.svg',
      'assets/images/r6operators_flat/kali.svg',
      'assets/images/r6operators_flat/kapkan.svg',
      'assets/images/r6operators_flat/lesion.svg',
      'assets/images/r6operators_flat/lion.svg',
      'assets/images/r6operators_flat/maestro.svg',
      'assets/images/r6operators_flat/maverick.svg',
      'assets/images/r6operators_flat/melusi.svg',
      'assets/images/r6operators_flat/mira.svg',
      'assets/images/r6operators_flat/montagne.svg',
      'assets/images/r6operators_flat/mozzie.svg',
      'assets/images/r6operators_flat/mute.svg',
      'assets/images/r6operators_flat/nokk.svg',
      'assets/images/r6operators_flat/nomad.svg',
      'assets/images/r6operators_flat/oryx.svg',
      'assets/images/r6operators_flat/osa.svg',
      'assets/images/r6operators_flat/pulse.svg',
      'assets/images/r6operators_flat/ram.svg',
      'assets/images/r6operators_flat/rauora.svg',
      'assets/images/r6operators_flat/recruit_blue.svg',
      'assets/images/r6operators_flat/recruit_green.svg',
      'assets/images/r6operators_flat/recruit_orange.svg',
      'assets/images/r6operators_flat/recruit_red.svg',
      'assets/images/r6operators_flat/recruit_yellow.svg',
      'assets/images/r6operators_flat/rook.svg',
      'assets/images/r6operators_flat/sens.svg',
      'assets/images/r6operators_flat/sentry.svg',
      'assets/images/r6operators_flat/skopos.svg',
      'assets/images/r6operators_flat/sledge.svg',
      'assets/images/r6operators_flat/smoke.svg',
      'assets/images/r6operators_flat/solis.svg',
      'assets/images/r6operators_flat/striker.svg',
      'assets/images/r6operators_flat/tachanka.svg',
      'assets/images/r6operators_flat/thatcher.svg',
      'assets/images/r6operators_flat/thermite.svg',
      'assets/images/r6operators_flat/thorn.svg',
      'assets/images/r6operators_flat/thunderbird.svg',
      'assets/images/r6operators_flat/tubarao.svg',
      'assets/images/r6operators_flat/twitch.svg',
      'assets/images/r6operators_flat/valkyrie.svg',
      'assets/images/r6operators_flat/vigil.svg',
      'assets/images/r6operators_flat/wamai.svg',
      'assets/images/r6operators_flat/warden.svg',
      'assets/images/r6operators_flat/ying.svg',
      'assets/images/r6operators_flat/zero.svg',
      'assets/images/r6operators_flat/zofia.svg',
    ];

    // 初始化网格参数 - 使用默认值，实际值将在 didChangeDependencies 中计算
    _nodeSpacing = 200.0; // 临时默认值
    _svgRenderSize = 150.0; // 临时默认值
    _triangleHeight = _nodeSpacing * math.sqrt(3) / 2;

    // 🔧 【视觉参数1】波纹动画速度 - 控制背景波纹的扩散速度
    // 增大duration = 波纹扩散更慢，更优雅
    // 建议范围: 8秒(快) ~ 20秒(慢)
    // 💡 修改方法: 改变 Duration(seconds: 12) 中的数字
    _rippleController = AnimationController(
      duration: const Duration(seconds: 12), // 当前: 12秒一个波纹周期
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rippleController, curve: Curves.linear));

    // 🔧 【视觉参数2】背景刷新频率 - 控制摄像机位置更新和节点管理的频率
    // 增大duration = 刷新频率降低，可能略微提升性能，但移动可能不够平滑
    // 减小duration = 刷新频率提高，移动更平滑，但消耗更多资源
    // 建议范围: 16毫秒(60FPS) ~ 33毫秒(30FPS)
    // 💡 修改方法: 改变 Duration(milliseconds: 16) 或保持当前设置
    // 🎯 注意: 摄像机现在是无限移动，不会重复周期，此参数只影响更新频率
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 16), // 当前: 16毫秒刷新频率 (约60FPS)
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.linear, // 使用线性动画实现匀速移动
      ),
    );

    // 注意：摄像机参数初始化延迟到 didChangeDependencies 中进行
    // 因为需要先获取用户偏好设置

    _rippleController.repeat();

    // 注意：SVG缓存和背景动画的启动已移至 didChangeDependencies 中
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TopEdgeDragArea(
        dragHeight: 30.0, // 顶部30像素高度的拖动区域
        child: Stack(
          children: [
            // 动态SVG背景层 - 无限滚动的SVG网格
            if (_svgsCached)
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  // 更新摄像机位置
                  _updateCameraPosition();
                  // 更新可见的SVG节点
                  _updateVisibleNodes();

                  return CustomPaint(
                    painter: InfiniteGridBackgroundPainter(
                      activeNodes: _activeNodes,
                      cameraPosition: _currentCameraPosition,
                      nodeSpacing: _nodeSpacing,
                      svgRenderSize: _svgRenderSize,
                      perspectiveAngleX: _perspectiveAngleX,
                      perspectiveAngleY: _perspectiveAngleY,
                      colorScheme: Theme.of(context).colorScheme, // 🎨 传递主题颜色
                      displayAreaMultiplier:
                          _displayAreaMultiplier, // 🎯 传递显示区域倍数
                      enableSvgFilters: _enableSvgFilters, // 🎨 传递滤镜开关
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            // 动态波纹层
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: RippleBackgroundPainter(
                    _rippleAnimation.value,
                    Theme.of(context).colorScheme,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // 软件标题层 - 左下角显示
            Positioned(
              left: 40,
              bottom: 60,
              child: Text(
                _homeTitle,
                style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.width *
                      _titleFontSizeMultiplier, // 使用设置中的字体大小倍数
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
            // 内容层
            Container(),
          ],
        ),
      ),
    );
  }

  // 📍 初始化摄像机移动参数
  void _initializeCameraMovement() {
    final random = math.Random();

    // 🔧 【性能参数2】透视角度范围 - 控制画面倾斜程度
    // 增大角度 = 更强的透视效果，但需要渲染更多区域
    // 建议范围: 20°(轻微) ~ 60°(强烈)
    // 💡 修改方法: 改变 * 40 中的数字，比如 * 60 表示 ±30°
    _perspectiveAngleX =
        (random.nextDouble() - 0.5) * 40 * math.pi / 180; // 当前: ±20°
    _perspectiveAngleY =
        (random.nextDouble() - 0.5) * 40 * math.pi / 180; // 当前: ±20°

    // 🎯 随机选择一个移动方向 (8个方向)
    final directions = [
      Offset(1, 0), // 向右
      Offset(-1, 0), // 向左
      Offset(0, 1), // 向下
      Offset(0, -1), // 向上
      Offset(1, 1), // 右下 (45度)
      Offset(-1, -1), // 左上 (225度)
      Offset(1, -1), // 右上 (315度)
      Offset(-1, 1), // 左下 (135度)
    ];

    _cameraDirection = _normalizeOffset(
      directions[random.nextInt(directions.length)],
    );

    // 🔧 【性能参数3】摄像机移动速度 - 控制背景滚动速度
    // 降低速度 = 更平滑的移动，但节点更新频率可以降低
    // 建议范围: 30.0(缓慢) ~ 100.0(快速)
    // 💡 修改方法: 直接改变数值，比如 30.0 表示很慢，100.0 表示很快
    _cameraSpeed = 50.0; // 当前: 50px/秒

    debugPrint('🎬 摄像机移动方向: $_cameraDirection');
    debugPrint(
      '📐 透视角度: X=${(_perspectiveAngleX * 180 / math.pi).toStringAsFixed(1)}°, Y=${(_perspectiveAngleY * 180 / math.pi).toStringAsFixed(1)}°',
    );

    // 计算并打印透视区域信息
    _logPerspectiveAreaInfo();
  }

  // 计算动态缓冲倍数（根据透视角度和显示区域倍数调整）
  double _calculateDynamicBufferMultiplier() {
    // 计算当前透视角度的强度
    final perspectiveStrength =
        math.max(_perspectiveAngleX.abs(), _perspectiveAngleY.abs()) /
        (math.pi / 6); // 标准化到[0, 1]范围（基于30度）

    // 🎯 显示区域倍数影响：显示区域越大，透视效果的影响越明显
    // 当显示区域放大时，需要更多的缓冲来覆盖透视变换的边缘区域
    final displayAreaInfluence = _displayAreaMultiplier; // 直接使用显示区域倍数作为影响因子

    // 计算动态缓冲倍数
    // 公式: 基础缓冲 × (1 + 透视强度 × 调节系数 × 显示区域影响)
    final dynamicMultiplier =
        _baseBufferMultiplier *
        (1 +
            perspectiveStrength *
                _perspectiveBufferFactor *
                displayAreaInfluence);

    return dynamicMultiplier.clamp(1.0, 50.0); // 扩大上限以应对大显示区域
  }

  // 记录透视区域信息（调试用）
  void _logPerspectiveAreaInfo() {
    final perspectiveArea = _calculateBaseDisplayArea();
    final factorX = _calculatePerspectiveFactor(_perspectiveAngleY);
    final factorY = _calculatePerspectiveFactor(_perspectiveAngleX);
    final dynamicBufferMultiplier = _calculateDynamicBufferMultiplier();
    final perspectiveStrength =
        math.max(_perspectiveAngleX.abs(), _perspectiveAngleY.abs()) /
        (math.pi / 6);

    debugPrint('📏 智能动态显示区域信息:');
    debugPrint(
      '   - 基础屏幕尺寸: ${_screenSize.width.toInt()} x ${_screenSize.height.toInt()}',
    );
    debugPrint('   - 显示区域倍数: ${_displayAreaMultiplier}x (影响透视缓冲)');
    debugPrint('   - 基础缓冲区倍数: ${_baseBufferMultiplier}x');
    debugPrint('   - 透视缓冲调节系数: ${_perspectiveBufferFactor}x');
    debugPrint('   - 当前透视强度: ${perspectiveStrength.toStringAsFixed(3)} (0~1)');
    debugPrint(
      '   - 动态缓冲区倍数: ${dynamicBufferMultiplier.toStringAsFixed(2)}x (智能计算)',
    );
    debugPrint('   - X方向透视因子: ${factorX.toStringAsFixed(2)}');
    debugPrint('   - Y方向透视因子: ${factorY.toStringAsFixed(2)}');
    debugPrint(
      '   - 基础显示区域: ${perspectiveArea.width.toInt()} x ${perspectiveArea.height.toInt()}',
    );
    debugPrint(
      '   - 缓冲后区域: ${(perspectiveArea.width * dynamicBufferMultiplier).toInt()} x ${(perspectiveArea.height * dynamicBufferMultiplier).toInt()}',
    );
    debugPrint(
      '   - 中心偏移: (${perspectiveArea.center.dx.toInt()}, ${perspectiveArea.center.dy.toInt()})',
    );
    debugPrint('🎯 性能优化信息:');
    debugPrint(
      '   - 基础网格间距: ${_baseNodeSpacing.toInt()}px → 实际间距: ${_nodeSpacing.toInt()}px',
    );
    debugPrint(
      '   - 基础图标大小: ${_baseSvgRenderSize.toInt()}px → 实际大小: ${_svgRenderSize.toInt()}px',
    );
    debugPrint('   - 三角形高度: ${_triangleHeight.toInt()}px (行间距)');
    debugPrint('   - 窗口随动系数: $_windowScalingFactor (影响内容缩放)');
    debugPrint(
      '💡 缓冲计算公式: ${_baseBufferMultiplier} × (1 + ${perspectiveStrength.toStringAsFixed(3)} × ${_perspectiveBufferFactor} × ${_displayAreaMultiplier}) = ${dynamicBufferMultiplier.toStringAsFixed(2)}',
    );
  }

  // 缓存所有SVG文件
  Future<void> _cacheAllSvgs() async {
    debugPrint('🎨 开始缓存SVG文件...');

    for (String svgPath in _svgPaths) {
      try {
        final svgString = await rootBundle.loadString(svgPath);
        final svgImage = ScalableImage.fromSvgString(svgString);
        _cachedSvgs[svgPath] = svgImage;
      } catch (e) {
        debugPrint('❌ 加载SVG失败: $svgPath - $e');
      }
    }

    setState(() {
      _svgsCached = true;
    });

    debugPrint('✅ SVG缓存完成: ${_cachedSvgs.length}个文件');
  }

  // 更新摄像机位置
  void _updateCameraPosition() {
    // 🎯 改进：实现真正的无限移动，不会周期性重置
    // 获取当前时间戳，用于计算连续的移动距离
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0; // 转换为秒

    // 初始化启动时间
    _cameraStartTime ??= currentTime;

    final elapsedTime = currentTime - _cameraStartTime!;
    final movement = _cameraDirection * _cameraSpeed * elapsedTime;
    _currentCameraPosition = movement;
  }

  // 更新可见的SVG节点
  void _updateVisibleNodes() {
    // 计算当前可见区域
    final visibleBounds = _calculateVisibleBounds();

    // 🔧 【优化1】先清理超出范围的节点，释放内存
    final oldNodeCount = _activeNodes.length;
    _activeNodes.removeWhere((key, node) {
      return !_isNodeInBounds(node.worldPosition, visibleBounds);
    });

    // 🔧 【优化2】定期强制清理，防止长时间运行时节点积累
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _lastCleanupTime ??= currentTime;

    // 每30秒强制清理一次，保持节点数量在合理范围
    if (currentTime - _lastCleanupTime! > 30.0) {
      const int targetNodes = 200; // 目标节点数量
      if (_activeNodes.length > targetNodes) {
        _pruneDistantNodes(targetNodes);
        debugPrint('🕐 定期清理: 30秒清理周期，目标节点数 $targetNodes');
      }
      _lastCleanupTime = currentTime;
    }

    // 🔧 【优化3】限制最大节点数量，防止内存泄漏
    const int maxNodes = 500; // 最大节点数限制
    if (_activeNodes.length < maxNodes) {
      // 添加新进入范围的节点
      _generateNodesInBounds(visibleBounds);

      // 🔧 【优化4】如果节点数量仍然过多，清理最远的节点
      if (_activeNodes.length > maxNodes) {
        _pruneDistantNodes(maxNodes);
      }
    }

    // 📊 调试输出节点数量变化
    final newNodeCount = _activeNodes.length;
    if (oldNodeCount != newNodeCount) {
      debugPrint(
        '🎯 节点数量变化: $oldNodeCount → $newNodeCount (删除: ${oldNodeCount - newNodeCount + (_activeNodes.length - oldNodeCount)}, 新增: ${_activeNodes.length - oldNodeCount})',
      );
    }
  }

  // 计算当前可见边界（统一的显示区域系统）
  Rect _calculateVisibleBounds() {
    // 获取屏幕尺寸
    if (context.mounted) {
      _screenSize = MediaQuery.of(context).size;
    }

    // 🎯 统一的显示区域计算
    // 基础显示区域（考虑透视变换）
    final baseDisplayArea = _calculateBaseDisplayArea();

    // 🎮 应用动态缓冲区扩展（根据透视角度自动调节）
    final dynamicBufferMultiplier = _calculateDynamicBufferMultiplier();
    final bufferedWidth = baseDisplayArea.width * dynamicBufferMultiplier;
    final bufferedHeight = baseDisplayArea.height * dynamicBufferMultiplier;

    return Rect.fromCenter(
      center: _currentCameraPosition + baseDisplayArea.center,
      width: bufferedWidth,
      height: bufferedHeight,
    );
  }

  // 计算基础显示区域（考虑透视变换和显示倍数）
  Rect _calculateBaseDisplayArea() {
    // 基础屏幕区域大小（由统一参数控制）
    final baseWidth = _screenSize.width * _displayAreaMultiplier;
    final baseHeight = _screenSize.height * _displayAreaMultiplier;

    // 计算透视变换的影响因子
    final perspectiveFactorX = _calculatePerspectiveFactor(_perspectiveAngleY);
    final perspectiveFactorY = _calculatePerspectiveFactor(_perspectiveAngleX);

    // 根据透视角度调整显示区域大小
    final adjustedWidth = baseWidth * perspectiveFactorX;
    final adjustedHeight = baseHeight * perspectiveFactorY;

    // 计算透视变换导致的中心偏移
    final centerOffsetX = _calculatePerspectiveCenterOffset(
      _perspectiveAngleY,
      baseWidth,
    );
    final centerOffsetY = _calculatePerspectiveCenterOffset(
      _perspectiveAngleX,
      baseHeight,
    );

    return Rect.fromCenter(
      center: Offset(centerOffsetX, centerOffsetY),
      width: adjustedWidth,
      height: adjustedHeight,
    );
  }

  // 计算透视因子（角度越大，需要的面积越大）
  double _calculatePerspectiveFactor(double angle) {
    // 基于透视角度计算缩放因子
    final absAngle = angle.abs();

    // 当角度为0时，因子为1.0
    // 当角度增大时，因子增大（因为透视会"压缩"远处的内容）
    final baseFactor = 1.0;
    final perspectiveMultiplier =
        1.0 + (absAngle / (math.pi / 6)) * 0.8; // 30度时增加80%

    return baseFactor * perspectiveMultiplier;
  }

  // 计算透视变换导致的中心偏移
  double _calculatePerspectiveCenterOffset(
    double angle,
    double screenDimension,
  ) {
    // 透视变换会导致中心点偏移
    // 正角度向一个方向偏移，负角度向另一个方向偏移
    final maxOffset = screenDimension * 0.2; // 最大偏移为屏幕尺寸的20%
    final normalizedAngle = angle / (math.pi / 6); // 标准化到[-1, 1]范围（基于30度）

    return normalizedAngle * maxOffset;
  }

  // 检查节点是否在边界内
  bool _isNodeInBounds(Offset nodePosition, Rect bounds) {
    return bounds.contains(nodePosition);
  }

  // 在指定边界内生成节点
  void _generateNodesInBounds(Rect bounds) {
    // 🔧 【性能优化】限制单次生成的节点数量，避免一次性生成太多
    int generatedCount = 0;
    const int maxGenerationPerFrame = 50; // 每帧最多生成50个节点

    // 计算网格范围
    final int startRow = ((bounds.top - _nodeSpacing) / _triangleHeight)
        .floor();
    final int endRow = ((bounds.bottom + _nodeSpacing) / _triangleHeight)
        .ceil();
    final int startCol = ((bounds.left - _nodeSpacing) / _nodeSpacing).floor();
    final int endCol = ((bounds.right + _nodeSpacing) / _nodeSpacing).ceil();

    // 🔧 【优化】优先生成靠近摄像机的节点
    final List<Offset> pendingPositions = [];

    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        // 计算节点世界位置（交错排列）
        final double x =
            col * _nodeSpacing + (row.isOdd ? _nodeSpacing / 2 : 0);
        final double y = row * _triangleHeight;
        final worldPosition = Offset(x, y);

        // 生成节点key
        final nodeKey =
            '${worldPosition.dx.toInt()}_${worldPosition.dy.toInt()}';

        // 如果节点不存在且在边界内，则加入待生成列表
        if (!_activeNodes.containsKey(nodeKey) &&
            _isNodeInBounds(worldPosition, bounds)) {
          pendingPositions.add(worldPosition);
        }
      }
    }

    // 🎯 按距离摄像机的远近排序，优先生成近距离节点
    pendingPositions.sort((a, b) {
      final distanceA = (a - _currentCameraPosition).distance;
      final distanceB = (b - _currentCameraPosition).distance;
      return distanceA.compareTo(distanceB);
    });

    // 🔧 限制每帧生成的节点数量
    for (final worldPosition in pendingPositions) {
      if (generatedCount >= maxGenerationPerFrame) {
        break; // 达到单帧生成限制
      }

      final nodeKey = '${worldPosition.dx.toInt()}_${worldPosition.dy.toInt()}';

      // 🎯 智能SVG选择：避免最近使用过的SVG重复出现
      final svgPath = _selectDiverseSvg();

      if (_cachedSvgs.containsKey(svgPath)) {
        _activeNodes[nodeKey] = _SvgNode(
          svgPath: svgPath,
          worldPosition: worldPosition,
          svgImage: _cachedSvgs[svgPath]!,
        );
        generatedCount++;

        // 🎯 记录本次使用的SVG到历史记录
        _addToRecentlyUsed(svgPath);
      }
    }

    // 📊 调试输出生成信息
    if (generatedCount > 0) {
      debugPrint(
        '🎨 本帧生成节点: $generatedCount 个 (待生成: ${pendingPositions.length}, 限制: $maxGenerationPerFrame)',
      );
    }
  }

  // 🎯 智能SVG选择：避免最近使用过的SVG重复出现
  String _selectDiverseSvg() {
    final random = math.Random();

    // 如果历史记录还不满，或者所有SVG都被使用过，则随机选择
    if (_recentlyUsedSvgs.length < _recentSvgHistorySize ||
        _recentlyUsedSvgs.length >= _svgPaths.length) {
      return _svgPaths[random.nextInt(_svgPaths.length)];
    }

    // 创建可选择的SVG列表（排除最近使用过的）
    final availableSvgs = _svgPaths
        .where((svg) => !_recentlyUsedSvgs.contains(svg))
        .toList();

    // 如果没有可选择的SVG（理论上不应该发生），回退到随机选择
    if (availableSvgs.isEmpty) {
      return _svgPaths[random.nextInt(_svgPaths.length)];
    }

    // 从可选择的SVG中随机选择一个
    return availableSvgs[random.nextInt(availableSvgs.length)];
  }

  // 🎯 记录最近使用的SVG，维护历史记录
  void _addToRecentlyUsed(String svgPath) {
    // 添加到历史记录的头部
    _recentlyUsedSvgs.insert(0, svgPath);

    // 如果历史记录超过限制，移除最老的记录
    if (_recentlyUsedSvgs.length > _recentSvgHistorySize) {
      _recentlyUsedSvgs.removeRange(
        _recentSvgHistorySize,
        _recentlyUsedSvgs.length,
      );
    }

    // 📊 调试输出：显示SVG分布情况
    if (_recentlyUsedSvgs.length % 5 == 0) {
      // 每5个SVG输出一次统计
      final uniqueCount = _recentlyUsedSvgs.toSet().length;
      final diversity = uniqueCount / _recentlyUsedSvgs.length;
      debugPrint(
        '🎨 SVG分布统计: 历史${_recentlyUsedSvgs.length}个, 独特${uniqueCount}个, 多样性${(diversity * 100).toStringAsFixed(1)}%',
      );
    }
  }

  // 🔧 清理距离摄像机最远的节点，防止节点数量过多
  void _pruneDistantNodes(int maxNodes) {
    if (_activeNodes.length <= maxNodes) return;

    // 计算每个节点到摄像机的距离
    final List<MapEntry<String, double>> nodeDistances = [];

    for (final entry in _activeNodes.entries) {
      final node = entry.value;
      final distance = (node.worldPosition - _currentCameraPosition).distance;
      nodeDistances.add(MapEntry(entry.key, distance));
    }

    // 按距离排序，距离远的在后面
    nodeDistances.sort((a, b) => a.value.compareTo(b.value));

    // 保留距离近的节点，移除距离远的节点
    final nodesToKeep = nodeDistances.take(maxNodes).map((e) => e.key).toSet();

    _activeNodes.removeWhere((key, node) => !nodesToKeep.contains(key));

    debugPrint('🧹 清理远距离节点: 保留 ${nodesToKeep.length} 个最近节点');
  }

  // 🎯 计算窗口自适应参数 - 根据窗口大小和随动系数动态调整内容大小
  void _calculateAdaptiveParameters() {
    // 🎯 计算窗口相对于标准尺寸(1920×1080)的缩放因子
    const standardWidth = 1920.0;
    const standardHeight = 1080.0;

    // 使用面积比例计算整体缩放因子，更准确反映窗口大小变化
    final standardArea = standardWidth * standardHeight;
    final currentArea = _screenSize.width * _screenSize.height;
    final areaSqrtRatio = math.sqrt(currentArea / standardArea); // 开方让缩放更平滑

    // 🎮 应用随动系数：随动系数越大，内容缩放越明显
    // 公式: 实际缩放 = 1.0 + (窗口缩放因子 - 1.0) × 随动系数
    final windowScaleFactor =
        1.0 + (areaSqrtRatio - 1.0) * _windowScalingFactor;

    // 🔧 计算实际使用的网格间距和图标大小
    _nodeSpacing = _baseNodeSpacing * windowScaleFactor;
    _svgRenderSize = _baseSvgRenderSize * windowScaleFactor;

    // 🎯 限制缩放范围，避免极端情况
    _nodeSpacing = _nodeSpacing.clamp(80.0, 400.0); // 间距范围限制
    _svgRenderSize = _svgRenderSize.clamp(40.0, 300.0); // 图标大小范围限制

    // 📊 调试输出：显示自适应计算结果
    debugPrint('🔄 窗口自适应参数计算:');
    debugPrint(
      '   - 当前窗口尺寸: ${_screenSize.width.toInt()}×${_screenSize.height.toInt()}',
    );
    debugPrint('   - 标准尺寸: ${standardWidth.toInt()}×${standardHeight.toInt()}');
    debugPrint('   - 面积缩放因子: ${areaSqrtRatio.toStringAsFixed(3)}');
    debugPrint('   - 随动系数: $_windowScalingFactor');
    debugPrint('   - 最终缩放因子: ${windowScaleFactor.toStringAsFixed(3)}');
    debugPrint(
      '   - 基础网格间距: ${_baseNodeSpacing.toInt()}px → 实际间距: ${_nodeSpacing.toInt()}px',
    );
    debugPrint(
      '   - 基础图标大小: ${_baseSvgRenderSize.toInt()}px → 实际大小: ${_svgRenderSize.toInt()}px',
    );
    debugPrint(
      '   - 预计图标数量变化: ${(1.0 / (windowScaleFactor * windowScaleFactor)).toStringAsFixed(2)}倍',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 获取最新的主页设置
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    _homePageSettings = userPreferences.homePage;

    // 🎯 【首次初始化】摄像机参数（只执行一次）
    if (!_cameraInitialized) {
      _initializeCameraMovement();
      _cameraInitialized = true;

      // 缓存SVG并开始背景动画
      _cacheAllSvgs().then((_) {
        if (mounted) {
          _backgroundController.repeat(); // 无限重复动画
        }
      });
    }

    // 在这里可以安全地访问 MediaQuery，重新计算自适应参数
    if (context.mounted) {
      final oldScreenSize = _screenSize;
      _screenSize = MediaQuery.of(context).size;

      // 🎯 窗口大小改变时重新计算自适应参数
      // 🔧 【优化】增加变化阈值，避免微小变化触发重新计算
      final sizeChange =
          (oldScreenSize.width - _screenSize.width).abs() +
          (oldScreenSize.height - _screenSize.height).abs();
      const double changeThreshold = 10.0; // 变化阈值：10像素

      if (sizeChange > changeThreshold) {
        // 🔧 先清理所有现有节点，避免窗口变化时节点堆积
        _activeNodes.clear();

        _calculateAdaptiveParameters();
        _triangleHeight = _nodeSpacing * math.sqrt(3) / 2; // 更新三角形高度
        debugPrint(
          '🔄 窗口大小变化 ${sizeChange.toStringAsFixed(1)}px，清理旧节点并重新计算自适应参数',
        );
      } else if (oldScreenSize == const Size(2560, 1440)) {
        // 首次加载时也需要计算自适应参数（从默认值变为实际值）
        _calculateAdaptiveParameters();
        _triangleHeight = _nodeSpacing * math.sqrt(3) / 2;
        debugPrint('🔄 首次加载，计算自适应参数');
      }
    }
  }

  // 辅助方法：标准化Offset向量
  Offset _normalizeOffset(Offset offset) {
    final length = math.sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    if (length == 0) return Offset.zero;
    return Offset(offset.dx / length, offset.dy / length);
  }
}

/// 波纹背景绘制器
class RippleBackgroundPainter extends CustomPainter {
  final double rippleValue;
  final ColorScheme colorScheme;

  RippleBackgroundPainter(this.rippleValue, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.9, size.height * 0.9);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    _drawRippleLayer(canvas, center, maxRadius, 0, 1.0, colorScheme.primary);
    _drawCenterGlow(canvas, center, maxRadius);
    _drawMapMarkerIcon(canvas, center, size);
  }

  void _drawRippleLayer(
    Canvas canvas,
    Offset center,
    double maxRadius,
    double phaseOffset,
    double baseOpacity,
    Color color,
  ) {
    const int rippleCount = 5;

    for (int i = 0; i < rippleCount; i++) {
      final progress = (rippleValue + phaseOffset + (i * 0.2)) % 1.0;
      final radius = progress * maxRadius * 2.2;

      if (radius > 10) {
        final fadeOut = math.pow(1.0 - (radius / (maxRadius * 2.2)), 1.5);
        final opacity = (fadeOut * (1.0 - progress * 0.3)).clamp(0.0, 1.0);

        if (opacity > 0.02) {
          final finalColor = color.withValues(alpha: opacity);
          final paint = Paint()
            ..color = finalColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = (2.0 * (1.0 - progress) + 0.5).clamp(0.5, 3.0);
          canvas.drawCircle(center, radius, paint);
        }
      }
    }
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double maxRadius) {
    final glowRadius = 20 + math.sin(rippleValue * math.pi * 4) * 5;
    final glowOpacity = 0.6 + math.sin(rippleValue * math.pi * 6) * 0.2;

    final glowGradient = RadialGradient(
      radius: 0.5,
      colors: [
        colorScheme.primary.withValues(alpha: glowOpacity),
        colorScheme.primary.withValues(alpha: glowOpacity * 0.5),
        Colors.transparent,
      ],
    );

    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );
    canvas.drawCircle(center, glowRadius, glowPaint);

    final centerPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: glowOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerPaint);
  }

  void _drawMapMarkerIcon(Canvas canvas, Offset center, Size size) {
    final iconSize = size.height * 0.9;
    final iconColor = colorScheme.primary;

    final circleRadius = iconSize * 0.3;
    final triangleHeight = iconSize * 0.25;
    final circleCenter = Offset(
      center.dx,
      center.dy - triangleHeight - circleRadius,
    );

    final r = circleRadius;
    final d = center.dy - circleCenter.dy;
    final tangentY = circleCenter.dy + (r * r) / d;
    final yOffsetFromCircleCenter = tangentY - circleCenter.dy;
    final xOffsetFromCircleCenter = math.sqrt(
      (r * r) - (yOffsetFromCircleCenter * yOffsetFromCircleCenter),
    );
    final leftTangentPoint = Offset(
      circleCenter.dx - xOffsetFromCircleCenter,
      tangentY,
    );
    final rightTangentPoint = Offset(
      circleCenter.dx + xOffsetFromCircleCenter,
      tangentY,
    );

    final path = Path();
    path.moveTo(leftTangentPoint.dx, leftTangentPoint.dy);
    path.lineTo(center.dx, center.dy);
    path.lineTo(rightTangentPoint.dx, rightTangentPoint.dy);
    path.close();

    // 创建合成层以支持透明剪切
    canvas.saveLayer(
      Rect.fromCircle(center: circleCenter, radius: circleRadius * 1.2),
      Paint(),
    );

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    // 绘制圆形
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // 使用 BlendMode.clear 剪切出透明的内圆
    final innerCirclePaint = Paint()..blendMode = BlendMode.clear;
    final innerCircleRadius = circleRadius * 0.4;
    canvas.drawCircle(circleCenter, innerCircleRadius, innerCirclePaint);

    // 绘制圆形边框
    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = iconSize * 0.008;
    canvas.drawCircle(circleCenter, circleRadius, borderPaint);

    // 恢复合成层
    canvas.restore();

    // 绘制三角形（在合成层外部，不受透明剪切影响）
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(RippleBackgroundPainter oldDelegate) {
    return oldDelegate.rippleValue != rippleValue;
  }
}

/// 无限网格背景绘制器
class InfiniteGridBackgroundPainter extends CustomPainter {
  final Map<String, _SvgNode> activeNodes;
  final Offset cameraPosition;
  final double nodeSpacing; // 网格间距
  final double svgRenderSize; // SVG渲染大小
  final double perspectiveAngleX;
  final double perspectiveAngleY;
  final ColorScheme colorScheme; // 🎨 主题颜色方案
  final double displayAreaMultiplier; // 🎯 显示区域倍数
  final bool enableSvgFilters; // 🎨 SVG滤镜开关

  InfiniteGridBackgroundPainter({
    required this.activeNodes,
    required this.cameraPosition,
    required this.nodeSpacing,
    required this.svgRenderSize,
    required this.perspectiveAngleX,
    required this.perspectiveAngleY,
    required this.colorScheme, // 🎨 必需的主题颜色参数
    required this.displayAreaMultiplier, // 🎯 显示区域倍数参数
    required this.enableSvgFilters, // 🎨 SVG滤镜开关参数
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // 🎨 使用主题背景色，兼容亮色和暗色主题
    final backgroundColor = colorScheme.surface; // 使用主题的表面颜色作为背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // 🌟 添加微妙的渐变层，增强主题适配的视觉效果
    _drawThemeGradientOverlay(canvas, size);

    // 应用透视变换
    _applyPerspectiveTransform(canvas, size);

    // 计算摄像机偏移
    final cameraOffset = Offset(-cameraPosition.dx, -cameraPosition.dy);

    // 绘制所有活跃的SVG节点
    for (final node in activeNodes.values) {
      _drawSvgNode(canvas, node, cameraOffset, size);
    }

    canvas.restore();
  }

  void _applyPerspectiveTransform(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final Matrix4 perspective = Matrix4.identity();

    // 设置透视强度（值越大透视效果越明显）
    perspective.setEntry(3, 2, -0.001);

    // 应用旋转变换
    perspective.rotateX(perspectiveAngleX);
    perspective.rotateY(perspectiveAngleY);

    // 可选：添加Z轴旋转以增加视觉变化
    // perspective.rotateZ(perspectiveAngleX * 0.2);

    canvas.transform(perspective.storage);

    canvas.translate(-size.width / 2, -size.height / 2);
  }

  void _drawSvgNode(
    Canvas canvas,
    _SvgNode node,
    Offset cameraOffset,
    Size screenSize,
  ) {
    // 计算节点在屏幕上的位置
    final screenPosition = node.worldPosition + cameraOffset;

    // 🎯 使用统一的可见性边界计算（基于显示区域倍数）
    final renderBounds = _calculateUnifiedVisibilityBounds(screenSize);

    // 只绘制在可见范围内的节点
    if (screenPosition.dx < renderBounds.left ||
        screenPosition.dx > renderBounds.right ||
        screenPosition.dy < renderBounds.top ||
        screenPosition.dy > renderBounds.bottom) {
      return;
    }

    canvas.save();

    // 移动到节点位置
    canvas.translate(
      screenPosition.dx + screenSize.width / 2,
      screenPosition.dy + screenSize.height / 2,
    );

    // 根据透视角度和距离调整节点大小
    final perspectiveScale = _calculateNodePerspectiveScale(
      screenPosition,
      screenSize,
    );

    // 缩放到目标大小（包含透视缩放和额外放大）
    final double baseScale =
        svgRenderSize /
        math.max(node.svgImage.viewport.width, node.svgImage.viewport.height);

    // 🔧 【性能参数6】图标放大系数 - 控制单个图标的显示大小
    // 增大此值 = 图标更大更清晰，但因为可见区域有限，图标总数会减少
    // 建议范围: 1.0(正常) ~ 2.5(超大)
    // 💡 修改方法: 直接改变数值，比如 1.0 表示原始大小，2.0 表示两倍大小
    final double enlargementFactor = 1;

    final double finalScale = baseScale * perspectiveScale * enlargementFactor;
    canvas.scale(finalScale);

    // 居中绘制：移动到SVG的中心位置
    canvas.translate(
      -node.svgImage.viewport.width / 2,
      -node.svgImage.viewport.height / 2,
    );

    // 🎨 根据主题应用颜色滤镜绘制SVG图标
    final isDarkTheme = colorScheme.brightness == Brightness.dark;
    final colorFilter = _getThemeColorFilter(isDarkTheme);

    // 使用saveLayer应用颜色滤镜
    canvas.saveLayer(
      Rect.fromLTWH(
        0,
        0,
        node.svgImage.viewport.width,
        node.svgImage.viewport.height,
      ),
      Paint()..colorFilter = colorFilter,
    );

    // 绘制SVG
    node.svgImage.paint(canvas);

    // 恢复颜色滤镜层
    canvas.restore();

    canvas.restore();
  }

  // 🎯 统一的可见性边界计算（在绘制器中使用）
  Rect _calculateUnifiedVisibilityBounds(Size screenSize) {
    // 使用相同的显示区域倍数，但不含缓冲区（用于渲染判断）
    final baseWidth = screenSize.width * displayAreaMultiplier;
    final baseHeight = screenSize.height * displayAreaMultiplier;

    // 计算透视变换的影响因子
    final perspectiveFactorX = _calculatePerspectiveFactor(perspectiveAngleY);
    final perspectiveFactorY = _calculatePerspectiveFactor(perspectiveAngleX);

    // 根据透视角度调整可见区域大小
    final adjustedWidth = baseWidth * perspectiveFactorX;
    final adjustedHeight = baseHeight * perspectiveFactorY;

    // 计算透视变换导致的中心偏移
    final centerOffsetX = _calculatePerspectiveCenterOffset(
      perspectiveAngleY,
      baseWidth,
    );
    final centerOffsetY = _calculatePerspectiveCenterOffset(
      perspectiveAngleX,
      baseHeight,
    );

    return Rect.fromCenter(
      center: Offset(centerOffsetX, centerOffsetY),
      width: adjustedWidth,
      height: adjustedHeight,
    );
  }

  // 计算透视因子（与状态类中的方法相同）
  double _calculatePerspectiveFactor(double angle) {
    final absAngle = angle.abs();
    final baseFactor = 1.0;
    final perspectiveMultiplier = 1.0 + (absAngle / (math.pi / 6)) * 0.8;
    return baseFactor * perspectiveMultiplier;
  }

  // 计算透视变换导致的中心偏移（与状态类中的方法相同）
  double _calculatePerspectiveCenterOffset(
    double angle,
    double screenDimension,
  ) {
    final maxOffset = screenDimension * 0.2;
    final normalizedAngle = angle / (math.pi / 6);
    return normalizedAngle * maxOffset;
  }

  // 计算节点的透视缩放因子
  double _calculateNodePerspectiveScale(Offset nodePosition, Size screenSize) {
    // 计算节点到屏幕中心的距离
    final centerOffset = nodePosition - Offset.zero;
    final distanceFromCenter = math.sqrt(
      centerOffset.dx * centerOffset.dx + centerOffset.dy * centerOffset.dy,
    );

    // 基于距离和透视角度计算缩放
    final maxDistance =
        math.sqrt(
          screenSize.width * screenSize.width +
              screenSize.height * screenSize.height,
        ) /
        2;

    final normalizedDistance = (distanceFromCenter / maxDistance).clamp(
      0.0,
      1.0,
    );

    // 透视效果：远处的物体看起来更小
    final perspectiveEffect = math.max(
      perspectiveAngleX.abs(),
      perspectiveAngleY.abs(),
    );
    final scaleReduction =
        perspectiveEffect * normalizedDistance * 0.3; // 最多减少30%

    return (1.0 - scaleReduction).clamp(0.3, 1.0); // 确保最小缩放不低于30%
  }

  // 🎨 根据主题获取颜色滤镜
  ColorFilter _getThemeColorFilter(bool isDarkTheme) {
    // 如果用户禁用了滤镜，返回原始颜色
    if (!enableSvgFilters) {
      return ColorFilter.matrix([
        1.0, 0.0, 0.0, 0.0, 0, // 红色通道不变
        0.0, 1.0, 0.0, 0.0, 0, // 绿色通道不变
        0.0, 0.0, 1.0, 0.0, 0, // 蓝色通道不变
        0.0, 0.0, 0.0, 1.0, 0, // 透明度不变
      ]);
    }

    if (isDarkTheme) {
      // 🌙 暗色主题：让图标更亮一些，增加对比度
      return ColorFilter.matrix([
        1.2, 0.0, 0.0, 0.0, 30, // 红色通道增强
        0.0, 1.2, 0.0, 0.0, 30, // 绿色通道增强
        0.0, 0.0, 1.2, 0.0, 30, // 蓝色通道增强
        0.0, 0.0, 0.0, 0.85, 0, // 透明度稍微降低
      ]);
    } else {
      // ☀️ 亮色主题：让图标稍微暗一些，增加可读性
      return ColorFilter.matrix([
        0.75, 0.0, 0.0, 0.0, -20, // 红色通道减弱
        0.0, 0.75, 0.0, 0.0, -20, // 绿色通道减弱
        0.0, 0.0, 0.75, 0.0, -20, // 蓝色通道减弱
        0.0, 0.0, 0.0, 0.8, 0, // 透明度稍微降低
      ]);
    }
  }

  // 🌟 绘制主题适配的渐变覆盖层，增强视觉层次
  void _drawThemeGradientOverlay(Canvas canvas, Size size) {
    final isDarkTheme = colorScheme.brightness == Brightness.dark;

    // 🎨 根据主题创建适合的渐变
    late List<Color> gradientColors;

    if (isDarkTheme) {
      // 🌙 暗色主题：从主色调到更暗的色调的微妙渐变
      gradientColors = [
        colorScheme.surface,
        colorScheme.surface.withValues(alpha: 0.7),
        colorScheme.onSurface.withValues(alpha: 0.03), // 非常微妙的覆盖
      ];
    } else {
      // ☀️ 亮色主题：从主色调到更亮的色调的微妙渐变
      gradientColors = [
        colorScheme.surface,
        colorScheme.surface.withValues(alpha: 0.8),
        colorScheme.primary.withValues(alpha: 0.02), // 非常微妙的主题色覆盖
      ];
    }

    // 📐 创建径向渐变，从中心向外扩散
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.5,
      colors: gradientColors,
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(InfiniteGridBackgroundPainter oldDelegate) {
    return oldDelegate.cameraPosition != cameraPosition ||
        oldDelegate.activeNodes.length != activeNodes.length ||
        oldDelegate.perspectiveAngleX != perspectiveAngleX ||
        oldDelegate.perspectiveAngleY != perspectiveAngleY ||
        oldDelegate.colorScheme != colorScheme; // 🎨 主题颜色变化时重绘
  }
}

/// 透视背景图片绘制器
class PerspectiveBackgroundPainter extends CustomPainter {
  final ui.Image? image;
  final Offset cameraPosition;
  final double perspectiveAngleX;
  final double perspectiveAngleY;

  PerspectiveBackgroundPainter({
    required this.image,
    required this.cameraPosition,
    required this.perspectiveAngleX,
    required this.perspectiveAngleY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) {
      return;
    }

    canvas.save();

    const double expansionFactor = 1.8;
    final expandedSize = Size(
      size.width * expansionFactor,
      size.height * expansionFactor,
    );
    final offsetX = -(expandedSize.width - size.width) / 2;
    final offsetY = -(expandedSize.height - size.height) / 2;

    _applyPerspectiveTransform(canvas, size);

    final imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
    final scaleX = expandedSize.width / imageSize.width;
    final scaleY = expandedSize.height / imageSize.height;
    final baseScale = math.max(scaleX, scaleY);

    const double cameraZoom = 2.0;
    final finalScale = baseScale * cameraZoom;
    final finalImageSize = Size(
      imageSize.width * finalScale,
      imageSize.height * finalScale,
    );

    final imageX =
        offsetX +
        (expandedSize.width - finalImageSize.width) * cameraPosition.dx;
    final imageY =
        offsetY +
        (expandedSize.height - finalImageSize.height) * cameraPosition.dy;

    final srcRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
    final destRect = Rect.fromLTWH(
      imageX,
      imageY,
      finalImageSize.width,
      finalImageSize.height,
    );

    canvas.drawImageRect(image!, srcRect, destRect, Paint());

    canvas.restore();
  }

  void _applyPerspectiveTransform(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final Matrix4 perspective = Matrix4.identity();
    perspective.setEntry(3, 2, -0.001);
    perspective.rotateX(perspectiveAngleX);
    perspective.rotateY(perspectiveAngleY);

    canvas.transform(perspective.storage);

    canvas.translate(-size.width / 2, -size.height / 2);
  }

  @override
  bool shouldRepaint(PerspectiveBackgroundPainter oldDelegate) {
    return oldDelegate.cameraPosition != cameraPosition ||
        oldDelegate.perspectiveAngleX != perspectiveAngleX ||
        oldDelegate.perspectiveAngleY != perspectiveAngleY ||
        oldDelegate.image != image;
  }
}
