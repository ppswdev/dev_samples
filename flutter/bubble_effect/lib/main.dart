import 'dart:math';
import 'dart:ui';

import 'package:bubble_effect/demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const DemoPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<BubbleBean> _list = [];

  final Random _random = Random(DateTime.now().microsecondsSinceEpoch);

  Color getRandomColor() {
    //透明度设置， 0-200， 255不透明
    int a = _random.nextInt(200);
    return Color.fromARGB(
        _random.nextInt(a), _random.nextInt(a), _random.nextInt(a), 255);
  }

  // 使用预定义的颜色
  Color getPredefinedColor() {
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  // 使用 HSL 颜色空间生成颜色
  Color getHSLColor() {
    double hue = _random.nextDouble() * 360;
    double saturation = 0.5 + _random.nextDouble() * 0.5;
    double lightness = 0.5 + _random.nextDouble() * 0.5;
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  final double _maxSpeed = 1.0;

  final double _maxRadius = 100;

  final double _maxTheta = 2 * pi;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 20; i++) {
      BubbleBean bean = BubbleBean();

      //获取随机透明颜色
      //bean.color = getRandomColor();
      //bean.color = getPredefinedColor();
      //bean.color = getHSLColor();
      bean.color = Colors.amber;

      //设置位置
      bean.position = const Offset(-1, -1);

      //设置随机的运动速度
      bean.speed = _random.nextDouble() * _maxSpeed;

      //设置半径
      bean.radius = _random.nextDouble() * _maxRadius;

      //设置角度
      bean.theta = _random.nextDouble() * _maxTheta;

      _list.add(bean);
    }

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animationController.addListener(
      () {
        setState(() {});
      },
    );
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            //第一部分 渐变背景
            buildBackground(),
            //第二部分 气泡
            buildBubbles(),
            //第三部分 高斯模糊
            buildBlurWidget(),
            //第四部分 顶层内容
            buildTopText(),
            buildBottomColumn(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlueAccent.withOpacity(0.3),
              Colors.lightBlue.withOpacity(0.3),
              Colors.blue.withOpacity(0.3),
            ]),
      ),
    );
  }

  buildBubbles() {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: CustomMyPainter(list: _list, random: _random),
    );
  }

  buildBlurWidget() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
      child: Container(
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  buildTopText() {
    return const Positioned(
      left: 0,
      right: 0,
      top: 160,
      child: Center(
        child: Text(
          'Hello World',
          style: TextStyle(
            fontSize: 30,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  buildBottomColumn() {
    return const Positioned(
      left: 0,
      right: 0,
      bottom: 50,
      child: Column(
        children: [
          Text('Item1'),
          Text('Item2'),
          Text('Item3'),
        ],
      ),
    );
  }
}

class BubbleBean {
  //位置
  late Offset position;
  //颜色
  late Color color;
  //速度
  late double speed;
  //角度
  late double theta;
  //半径
  late double radius;
}

//创建画布
class CustomMyPainter extends CustomPainter {
  List<BubbleBean> list;
  Random random;

  CustomMyPainter({required this.list, required this.random});

  final Paint _paint = Paint()..isAntiAlias = true;
  //具体绘制
  @override
  void paint(Canvas canvas, Size size) {
    //绘制前重新计算每个点的位置
    for (var bean in list) {
      Offset newCenterOffset = calculateXY(bean.speed, bean.theta);
      double dx = newCenterOffset.dx + bean.position.dx;
      double dy = newCenterOffset.dy + bean.position.dy;

      if (dx < 0 || dx > size.width || dy < 0 || dy > size.height) {
        dx = random.nextDouble() * size.width;
        dy = random.nextDouble() * size.height;
      }
      bean.position = Offset(dx, dy);
    }

    //绘制
    for (var bean in list) {
      _paint.color = bean.color;

      //绘制气泡
      //canvas.drawCircle(bean.position, bean.radius, _paint);
      // 绘制五角星
      //drawStar(canvas, bean.position, bean.radius, _paint);
      // 绘制心形
      //drawHeart(canvas, bean.position, bean.radius, _paint);
      // 绘制三角形
      //drawTriangle(canvas, bean.position, bean.radius, _paint);
      // 绘制椭圆
      //drawOval(canvas, bean.position, bean.radius, _paint);
      // 绘制六边形
      //drawHexagon(canvas, bean.position, bean.radius, _paint);
      // 绘制3D泡泡
      draw3DBubble(canvas, bean.position, bean.radius, _paint);
      // 绘制3D立体三角形
      //draw3DTriangle(canvas, bean.position, bean.radius, _paint);
      // 绘制3D心形
      //draw3DHeart(canvas, bean.position, bean.radius, _paint);
      // 绘制蒲公英
      //drawDandelion(canvas, bean.position, bean.radius, _paint);
      // 绘制梦幻的图形
      //drawDreamyShape(canvas, bean.position, bean.radius, _paint);
      // 绘制水滴
      //drawWaterDrop(canvas, bean.position, bean.radius, _paint);
    }
  }

  //刷新控制
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  Offset calculateXY(double speed, double theta) {
    return Offset(
        (speed * cos(theta)).toDouble(), (speed * sin(theta)).toDouble());
  }

  void drawStar(Canvas canvas, Offset position, double radius, Paint paint) {
    const int numPoints = 5;
    const double angle = (2 * pi) / numPoints;
    final Path path = Path();

    for (int i = 0; i < numPoints; i++) {
      double x = position.dx + radius * cos(i * angle);
      double y = position.dy + radius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void drawHeart(Canvas canvas, Offset position, double radius, Paint paint) {
    final Path path = Path();
    path.moveTo(position.dx, position.dy + radius / 4);
    path.cubicTo(
        position.dx - radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx - radius * 4 / 3,
        position.dy + radius / 3,
        position.dx,
        position.dy + radius);
    path.cubicTo(
        position.dx + radius * 4 / 3,
        position.dy + radius / 3,
        position.dx + radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx,
        position.dy + radius / 4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void drawTriangle(
      Canvas canvas, Offset position, double radius, Paint paint) {
    final Path path = Path();
    path.moveTo(position.dx, position.dy - radius);
    path.lineTo(position.dx - radius, position.dy + radius);
    path.lineTo(position.dx + radius, position.dy + radius);
    path.close();
    canvas.drawPath(path, paint);
  }

  void drawOval(Canvas canvas, Offset position, double radius, Paint paint) {
    final Rect rect =
        Rect.fromCenter(center: position, width: radius * 2, height: radius);
    canvas.drawOval(rect, paint);
  }

  void drawHexagon(Canvas canvas, Offset position, double radius, Paint paint) {
    final Path path = Path();
    const int numSides = 6;
    const double angle = (2 * pi) / numSides;

    for (int i = 0; i < numSides; i++) {
      double x = position.dx + radius * cos(i * angle);
      double y = position.dy + radius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void draw3DBubble(
      Canvas canvas, Offset position, double radius, Paint paint) {
    // 绘制底部阴影
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(position, radius, shadowPaint);

    // 绘制渐变色泡泡
    final Rect rect = Rect.fromCircle(center: position, radius: radius);
    final Gradient gradient = RadialGradient(
      colors: [
        paint.color.withOpacity(0.8),
        paint.color.withOpacity(0.6),
        paint.color.withOpacity(0.4),
        paint.color.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 0.7, 1.0],
    );
    final Paint bubblePaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(position, radius, bubblePaint);

    // 绘制高光
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(position.dx - radius / 3, position.dy - radius / 3),
        radius / 3,
        highlightPaint);
  }

  void draw3DTriangle(
      Canvas canvas, Offset position, double radius, Paint paint) {
    final Path path = Path();

    // 绘制三角形的三个顶点
    final Offset p1 = Offset(position.dx, position.dy - radius);
    final Offset p2 = Offset(position.dx - radius, position.dy + radius);
    final Offset p3 = Offset(position.dx + radius, position.dy + radius);

    // 绘制三角形的主面
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    // 创建渐变色
    final Rect rect = Rect.fromPoints(p1, p3);
    final Gradient gradient = LinearGradient(
      colors: [
        paint.color.withOpacity(0.8),
        paint.color.withOpacity(0.6),
        paint.color.withOpacity(0.4),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final Paint gradientPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(path, gradientPaint);

    // 绘制阴影
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final Path shadowPath = Path();
    shadowPath.moveTo(p1.dx, p1.dy);
    shadowPath.lineTo(p2.dx, p2.dy);
    shadowPath.lineTo(p3.dx, p3.dy);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // 绘制高光
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final Path highlightPath = Path();
    highlightPath.moveTo(p1.dx, p1.dy);
    highlightPath.lineTo(p2.dx, p2.dy);
    highlightPath.lineTo(p3.dx, p3.dy);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void draw3DHeart(Canvas canvas, Offset position, double radius, Paint paint) {
    // 绘制底部阴影
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final Path shadowPath = Path();
    shadowPath.moveTo(position.dx, position.dy + radius / 4);
    shadowPath.cubicTo(
        position.dx - radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx - radius * 4 / 3,
        position.dy + radius / 3,
        position.dx,
        position.dy + radius);
    shadowPath.cubicTo(
        position.dx + radius * 4 / 3,
        position.dy + radius / 3,
        position.dx + radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx,
        position.dy + radius / 4);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // 绘制渐变色心形
    final Path heartPath = Path();
    heartPath.moveTo(position.dx, position.dy + radius / 4);
    heartPath.cubicTo(
        position.dx - radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx - radius * 4 / 3,
        position.dy + radius / 3,
        position.dx,
        position.dy + radius);
    heartPath.cubicTo(
        position.dx + radius * 4 / 3,
        position.dy + radius / 3,
        position.dx + radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx,
        position.dy + radius / 4);
    heartPath.close();

    final Rect rect = Rect.fromCircle(center: position, radius: radius);
    final Gradient gradient = RadialGradient(
      colors: [
        paint.color.withOpacity(0.8),
        paint.color.withOpacity(0.6),
        paint.color.withOpacity(0.4),
        paint.color.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 0.7, 1.0],
    );
    final Paint heartPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(heartPath, heartPaint);

    // 绘制高光
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final Path highlightPath = Path();
    highlightPath.moveTo(position.dx, position.dy + radius / 4);
    highlightPath.cubicTo(
        position.dx - radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx - radius * 4 / 3,
        position.dy + radius / 3,
        position.dx,
        position.dy + radius);
    highlightPath.cubicTo(
        position.dx + radius * 4 / 3,
        position.dy + radius / 3,
        position.dx + radius * 2 / 3,
        position.dy - radius * 2 / 3,
        position.dx,
        position.dy + radius / 4);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void drawDandelion(
      Canvas canvas, Offset position, double radius, Paint paint) {
    const int numSeeds = 20;
    const double angleStep = (2 * pi) / numSeeds;

    // 绘制蒲公英的中心
    canvas.drawCircle(position, radius / 5, paint);

    // 绘制蒲公英的种子
    for (int i = 0; i < numSeeds; i++) {
      final double angle = i * angleStep;
      final double seedX = position.dx + radius * cos(angle);
      final double seedY = position.dy + radius * sin(angle);
      final Offset seedPosition = Offset(seedX, seedY);

      // 绘制种子的线
      canvas.drawLine(position, seedPosition, paint);

      // 绘制种子的头部
      canvas.drawCircle(seedPosition, radius / 10, paint);
    }
  }

  void drawDreamyShape(
      Canvas canvas, Offset position, double radius, Paint paint) {
    // 创建渐变色
    final Rect rect = Rect.fromCircle(center: position, radius: radius);
    final Gradient gradient = RadialGradient(
      colors: [
        Colors.purple.withOpacity(0.8),
        Colors.blue.withOpacity(0.6),
        Colors.cyan.withOpacity(0.4),
        Colors.white.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 0.7, 1.0],
    );
    final Paint gradientPaint = Paint()..shader = gradient.createShader(rect);

    // 绘制渐变色圆形
    canvas.drawCircle(position, radius, gradientPaint);

    // 创建模糊效果
    final Paint blurPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // 绘制模糊的圆形
    canvas.drawCircle(position, radius * 0.8, blurPaint);

    // 绘制复杂路径
    final Path path = Path();
    path.moveTo(position.dx, position.dy);
    path.cubicTo(position.dx + radius, position.dy - radius,
        position.dx - radius, position.dy - radius, position.dx, position.dy);
    path.cubicTo(position.dx + radius, position.dy + radius,
        position.dx - radius, position.dy + radius, position.dx, position.dy);
    path.close();

    // 使用渐变色绘制路径
    canvas.drawPath(path, gradientPaint);

    // 绘制高光
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(position.dx - radius / 3, position.dy - radius / 3),
        radius / 3,
        highlightPaint);
  }

  void drawWaterDrop(
      Canvas canvas, Offset position, double radius, Paint paint) {
    final Path path = Path();

    // 绘制水滴的形状
    path.moveTo(position.dx, position.dy - radius);
    path.quadraticBezierTo(position.dx + radius, position.dy - radius,
        position.dx + radius, position.dy);
    path.arcToPoint(
      Offset(position.dx - radius, position.dy),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.quadraticBezierTo(position.dx - radius, position.dy - radius,
        position.dx, position.dy - radius);
    path.close();

    // 绘制水滴
    canvas.drawPath(path, paint);

    // 绘制高光
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(position.dx - radius / 3, position.dy - radius / 3),
        radius / 3,
        highlightPaint);
  }
}
