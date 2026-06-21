import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}


extension ThemeColors on BuildContext {
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get textMain => Theme.of(this).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get textDim => Theme.of(this).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get border => Theme.of(this).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
  Color get greyText => Theme.of(this).brightness == Brightness.dark ? Colors.grey : Colors.grey.shade700;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThaClick',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0097A7), // Light Cyber Cyan
          secondary: Color(0xFF00C853), // Light Emerald
          error: Color(0xFFFF5252),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00E676),
          error: Color(0xFFFF5252),
          surface: Color(0xFF161F30),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


class AppStrings {
  static bool get isEs => Platform.localeName.startsWith('es');
  static String get title => 'ThaClick';
  static String get loop => isEs ? 'Bucle' : 'Loop';
  static String get loopSubtitle => isEs ? 'Veces que se ejecuta' : 'Times to execute';
  static String get pattern => isEs ? 'P' : 'P';
  static String get editWait => isEs ? 'Editar Espera' : 'Edit Wait';
  static String get editPoint => isEs ? 'Editar Punto' : 'Edit Point';
  static String get name => isEs ? AppStrings.name : 'Name';
  static String get timeSeconds => isEs ? AppStrings.timeSeconds : 'Time (seconds)';
  static String get cancel => isEs ? AppStrings.cancel : 'Cancel';
  static String get save => isEs ? AppStrings.save : 'Save';
  static String get systemPermissions => isEs ? AppStrings.systemPermissions : 'System Permissions';
  static String get overlayActive => isEs ? AppStrings.overlayActive : 'Overlay Active';
  static String get showOverOtherApps => isEs ? AppStrings.showOverOtherApps : 'Show over other apps';
  static String get antiBotService => isEs ? AppStrings.antiBotService : 'Anti-Bot Service';
  static String get accessibilityRequired => isEs ? AppStrings.accessibilityRequired : 'Accessibility required';
  static String get active => isEs ? AppStrings.active : 'Active';
  static String get tapToActivate => isEs ? AppStrings.tapToActivate : 'Tap to activate';
  static String get injectionEngine => isEs ? AppStrings.injectionEngine : 'Injection Engine';
  static String get stop => isEs ? AppStrings.stop : 'Stop';
  static String get start => isEs ? AppStrings.start : 'Start';
  static String get patterns => isEs ? AppStrings.patterns : 'Patterns';
  static String get random => isEs ? AppStrings.random : 'Random';
  static String get noPoints => isEs ? AppStrings.noPoints : 'No points configured';
  static String get noPointsDesc => isEs ? 'Activa los controles flotantes, abre la app destino, presiona el botón "+" y marca dónde quieres realizar los clics.' : 'Activate floating controls, open the target app, press "+" and mark clicks.';
  static String get page => isEs ? 'Página' : 'Page';
}

class ClickStep {
  String type; // "click" or "swipe"
  double x;
  double y;
  double endX;
  double endY;
  int delay; // milliseconds
  int duration; // milliseconds
  int repeat;
  String name;

  ClickStep({
    required this.type,
    required this.x,
    required this.y,
    this.endX = 0,
    this.endY = 0,
    this.delay = 1000,
    this.duration = 50,
    this.repeat = 1,
    this.name = '',
  });

  factory ClickStep.fromJson(Map<String, dynamic> json) {
    return ClickStep(
      type: json['type'] ?? 'click',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      endX: (json['endX'] as num?)?.toDouble() ?? 0,
      endY: (json['endY'] as num?)?.toDouble() ?? 0,
      delay: json['delay'] ?? 1000,
      duration: json['duration'] ?? 50,
      repeat: json['repeat'] ?? 1,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'endX': endX,
      'endY': endY,
      'delay': delay,
      'duration': duration,
      'repeat': repeat,
      'name': name,
    };
  }
}

class ClickerService {
  static const MethodChannel _channel = MethodChannel('com.touch.touch/clicker');

  static Future<bool> isAccessibilityEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      // Ignored
    }
  }

  static Future<bool> isOverlayEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isOverlayEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (e) {
      // Ignored
    }
  }

  static Future<bool> showOverlay() async {
    try {
      return await _channel.invokeMethod<bool>('showOverlay') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hideOverlay() async {
    try {
      return await _channel.invokeMethod<bool>('hideOverlay') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setSteps(Map<String, dynamic> data) async {
    try {
      final String stepsJson = jsonEncode(data);
      return await _channel.invokeMethod<bool>('setSteps', stepsJson) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> startClicking() async {
    try {
      return await _channel.invokeMethod<bool>('startClicking') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> stopClicking() async {
    try {
      return await _channel.invokeMethod<bool>('stopClicking') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isRunning') ?? false;
    } catch (e) {
      return false;
    }
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if(mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          )
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/thaclick_logo.svg', width: 140, height: 140),
                const SizedBox(height: 24),
                const Text(
                  'ThaClick',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<List<ClickStep>> patterns = [[]];
  int activePatternIndex = 0;
  bool randomizePatterns = false;
  
  List<ClickStep> get steps {
    if (patterns.isEmpty) patterns = [[]];
    if (activePatternIndex >= patterns.length) activePatternIndex = 0;
    return patterns[activePatternIndex];
  }
  set steps(List<ClickStep> value) {
    if (patterns.isEmpty) patterns = [value];
    else patterns[activePatternIndex] = value;
  }
  
  bool isAccessibilityEnabled = false;
  bool isOverlayEnabled = false;
  bool isRunning = false;
  bool isOverlayVisible = false;
  int loopCount = 1;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupChannelHandlers();
    _checkStatusAndLoad();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissions();
    }
  }

  void _setupChannelHandlers() {
    ClickerService._channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPatternsUpdated':
          final String jsonStr = call.arguments as String;
          try {
            final Map<String, dynamic> decoded = jsonDecode(jsonStr);
            setState(() {
              loopCount = decoded['loopCount'] ?? 1;
              randomizePatterns = decoded['randomize'] ?? false;
              activePatternIndex = decoded['activePatternIndex'] ?? 0;
              
              if (decoded.containsKey('patterns')) {
                final List<dynamic> pList = decoded['patterns'];
                patterns = pList.map((p) => (p as List).map((e) => ClickStep.fromJson(e)).toList()).toList();
              }
              if (patterns.isEmpty) patterns = [[]];
              if (activePatternIndex >= patterns.length) activePatternIndex = 0;
            });
          } catch (_) {}
          await saveSteps();
          break;
        case 'onStatusChanged':
          setState(() {
            isRunning = call.arguments as bool;
          });
          break;
      }
    });
  }

  Future<void> _checkStatusAndLoad() async {
    await checkPermissions();
    await loadSteps();
  }

  Future<void> checkPermissions() async {
    final bool access = await ClickerService.isAccessibilityEnabled();
    final bool overlay = await ClickerService.isOverlayEnabled();
    final bool running = await ClickerService.isRunning();
    setState(() {
      isAccessibilityEnabled = access;
      isOverlayEnabled = overlay;
      isRunning = running;
    });
  }

  Future<void> loadSteps() async {
    try {
      final file = File('/data/data/com.touch.touch/files/patterns.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        try {
          final Map<String, dynamic> decoded = jsonDecode(content);
          setState(() {
            loopCount = decoded['loopCount'] ?? 1;
            randomizePatterns = decoded['randomize'] ?? false;
            activePatternIndex = decoded['activePatternIndex'] ?? 0;
            
            if (decoded.containsKey('patterns')) {
              final List<dynamic> pList = decoded['patterns'];
              patterns = pList.map((p) => (p as List).map((e) => ClickStep.fromJson(e)).toList()).toList();
            }
            if (patterns.isEmpty) patterns = [[]];
            if (activePatternIndex >= patterns.length) activePatternIndex = 0;
          });
        } catch (_) {}
      } else {
        final oldFile = File('/data/data/com.touch.touch/files/steps.json');
        if (await oldFile.exists()) {
           final content = await oldFile.readAsString();
           try {
             final Map<String, dynamic> decoded = jsonDecode(content);
             setState(() {
               loopCount = decoded['loopCount'] ?? 1;
               final List<dynamic> sList = decoded['steps'] ?? [];
               patterns = [sList.map((e) => ClickStep.fromJson(e)).toList()];
             });
           } catch (_) {}
        }
      }
      await _sendStepsToNative();
    } catch (e) {
      // Ignored
    }
  }

  Future<void> saveSteps() async {
    try {
      final directory = Directory('/data/data/com.touch.touch/files');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/patterns.json');
      final Map<String, dynamic> data = {
        'loopCount': loopCount,
        'randomize': randomizePatterns,
        'activePatternIndex': activePatternIndex,
        'patterns': patterns.map((p) => p.map((e) => e.toJson()).toList()).toList(),
      };
      final content = jsonEncode(data);
      await file.writeAsString(content);
      await _sendStepsToNative();
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _sendStepsToNative() async {
    final Map<String, dynamic> data = {
      'loopCount': loopCount,
      'randomize': randomizePatterns,
      'activePatternIndex': activePatternIndex,
      'patterns': patterns.map((p) => p.map((e) => e.toJson()).toList()).toList(),
    };
    await ClickerService.setSteps(data);
  }

  void addWaitStep() async {
    setState(() {
      steps.add(ClickStep(
        type: 'wait',
        x: 0,
        y: 0,
        delay: 5000,
        duration: 0,
        repeat: 1,
      ));
    });
    await saveSteps();
  }

  Future<void> toggleOverlay() async {
    if (!isAccessibilityEnabled || !isOverlayEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, activa primero los permisos necesarios.'),
          backgroundColor: Color(0xFFFF5252),
        ),
      );
      return;
    }

    if (isOverlayVisible) {
      final success = await ClickerService.hideOverlay();
      if (success) {
        if (!mounted) return;
        setState(() {
          isOverlayVisible = false;
        });
      }
    } else {
      final success = await ClickerService.showOverlay();
      if (success) {
        if (!mounted) return;
        setState(() {
          isOverlayVisible = true;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo mostrar el menú. Asegúrate de activar el Servicio de Accesibilidad.'),
            backgroundColor: Color(0xFFFF5252),
          ),
        );
      }
    }
  }

  Future<void> clearSteps() async {
    setState(() {
      steps.clear();
    });
    await saveSteps();
  }

  void removeStep(int index) async {
    setState(() {
      steps.removeAt(index);
    });
    await saveSteps();
  }

  void adjustDelay(int index, int delta) async {
    setState(() {
      steps[index].delay = (steps[index].delay + delta).clamp(50, 10000);
    });
    await saveSteps();
  }

  void adjustRepeat(int index, int delta) async {
    setState(() {
      steps[index].repeat = (steps[index].repeat + delta).clamp(1, 100);
    });
    await saveSteps();
  }


  void _showEditDialog(int index) {
    final step = steps[index];
    final isWait = step.type == 'wait';
    final nameController = TextEditingController(text: step.name);
    final delayController = TextEditingController(text: (step.delay / 1000).toStringAsFixed(1));
    final xController = TextEditingController(text: step.x.toInt().toString());
    final yController = TextEditingController(text: step.y.toInt().toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.surface,
          title: Text(isWait ? AppStrings.editWait : AppStrings.editPoint, style: TextStyle(color: context.textMain)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: context.textMain),
                  decoration: InputDecoration(labelText: AppStrings.name, labelStyle: TextStyle(color: context.greyText)),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: delayController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: context.textMain),
                  decoration: InputDecoration(labelText: AppStrings.timeSeconds, labelStyle: TextStyle(color: context.greyText)),
                ),
                if (!isWait) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: xController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: context.textMain),
                          decoration: InputDecoration(labelText: 'X', labelStyle: TextStyle(color: context.greyText)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: yController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: context.textMain),
                          decoration: InputDecoration(labelText: 'Y', labelStyle: TextStyle(color: context.greyText)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: TextStyle(color: context.greyText)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  step.name = nameController.text;
                  final delayParsed = double.tryParse(delayController.text.replaceAll(',', '.'));
                  if (delayParsed != null) step.delay = (delayParsed * 1000).clamp(50, 1000000).toInt();
                  if (!isWait) {
                    final screenSize = MediaQuery.of(context).size;
                    final xParsed = double.tryParse(xController.text);
                    if (xParsed != null) step.x = xParsed.clamp(0.0, screenSize.width);
                    final yParsed = double.tryParse(yController.text);
                    if (yParsed != null) step.y = yParsed.clamp(0.0, screenSize.height);
                  }
                });
                saveSteps();
                Navigator.pop(context);
              },
              child: Text(AppStrings.save, style: TextStyle(color: context.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    int totalPages = (steps.length / 10).ceil();
    if (totalPages == 0) totalPages = 1;
    if (currentPage >= totalPages) currentPage = totalPages - 1;
    final paginatedSteps = steps.skip(currentPage * 10).take(10).toList();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.border,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                             BoxShadow(
                              color: context.primary.withAlpha(51),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.bolt_rounded,
                          color: context.primary,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'THACLICK',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: context.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Permissions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTADO DE PERMISOS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.greyText,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          // Accessibility Card
                          Expanded(
                            child: _buildPermissionCard(
                              title: 'Accesibilidad',
                              description: 'Simular clics',
                              isEnabled: isAccessibilityEnabled,
                              onTap: () => ClickerService.openAccessibilitySettings(),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Overlay Card
                          Expanded(
                            child: _buildPermissionCard(
                              title: 'Superposición',
                              description: 'Mostrar botones',
                              isEnabled: isOverlayEnabled,
                              onTap: () => ClickerService.openOverlaySettings(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


              // Patterns Settings Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GESTOR DE PATRONES',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: context.primary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Alterna entre macros grabadas',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.greyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(AppStrings.random,
                                  style: TextStyle(fontSize: 12, color: context.textDim),
                                ),
                                Switch(
                                  value: randomizePatterns,
                                  activeThumbColor: context.primary,
                                  onChanged: (val) {
                                    setState(() { randomizePatterns = val; });
                                    saveSteps();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < patterns.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ChoiceChip(
                                        label: Text(AppStrings.pattern + '${i + 1}'),
                                        selected: activePatternIndex == i,
                                        selectedColor: context.primary.withValues(alpha: 0.3),
                                        labelStyle: TextStyle(
                                          color: activePatternIndex == i ? context.primary : context.textDim,
                                          fontWeight: activePatternIndex == i ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        backgroundColor: context.border,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: activePatternIndex == i ? context.primary : Colors.transparent,
                                          ),
                                        ),
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() { activePatternIndex = i; });
                                            saveSteps();
                                          }
                                        },
                                      ),
                                    ),
                                  ActionChip(
                                    label: Icon(Icons.add, size: 18, color: context.textMain),
                                    backgroundColor: context.border,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                    onPressed: () {
                                      setState(() {
                                        patterns.add([]);
                                        activePatternIndex = patterns.length - 1;
                                      });
                                      saveSteps();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                ActionChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy, size: 14, color: context.textMain),
                                      SizedBox(width: 4),
                                      Text(AppStrings.isEs ? 'Clonar' : 'Clone', style: TextStyle(color: context.textMain, fontSize: 12)),
                                    ],
                                  ),
                                  backgroundColor: context.border,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                  onPressed: () {
                                    setState(() {
                                      List<ClickStep> currentPattern = patterns[activePatternIndex].map((s) => ClickStep.fromJson(s.toJson())).toList();
                                      patterns.add(currentPattern);
                                      activePatternIndex = patterns.length - 1;
                                    });
                                    saveSteps();
                                  },
                                ),
                                SizedBox(width: 8),
                                if (patterns.length > 1)
                                  ActionChip(
                                    label: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    backgroundColor: context.border,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                    onPressed: () {
                                      setState(() {
                                        patterns.removeAt(activePatternIndex);
                                        activePatternIndex = 0;
                                      });
                                      saveSteps();
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Control panel buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: toggleOverlay,
                                  icon: Icon(
                                    isOverlayVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    isOverlayVisible
                                        ? 'OCULTAR CONTROLES'
                                        : 'MOSTRAR CONTROLES',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: context.primary.withAlpha(102),
                                    elevation: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: addWaitStep,
                                  icon: Icon(Icons.timer_rounded, color: context.primary),
                                  label: Text(
                                    'ESPERA',
                                    style: TextStyle(
                                      color: context.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: context.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: steps.isEmpty ? null : clearSteps,
                                  icon: Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF5252)),
                                  label: Text(
                                    'LIMPIAR',
                                    style: TextStyle(
                                      color: Color(0xFFFF5252),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFFFF5252)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Loop Settings Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.loop.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                AppStrings.loopSubtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: loopCount <= 0 ? null : () {
                                setState(() {
                                  loopCount = loopCount - 1;
                                });
                                saveSteps();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.border,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: loopCount <= 0 ? context.greyText : context.primary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                loopCount == 0 ? 'Infinito ♾️' : '${loopCount}x',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.textMain,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  loopCount = loopCount + 1;
                                });
                                saveSteps();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.border,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: context.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active steps list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SECUENCIA DE ATAQUE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.greyText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.border,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${steps.length}',
                              style: TextStyle(
                                color: context.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (steps.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            isRunning ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                            color: isRunning ? Color(0xFFFFD600) : context.secondary,
                            size: 28,
                          ),
                          onPressed: () async {
                            if (isRunning) {
                              await ClickerService.stopClicking();
                            } else {
                              await ClickerService.startClicking();
                            }
                            checkPermissions();
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Steps List or Empty View
              if (steps.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 48,
                          color: context.greyText.withAlpha(128),
                        ),
                        SizedBox(height: 16),
                        Text(AppStrings.noPoints,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(AppStrings.noPointsDesc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverReorderableList(
                  itemCount: paginatedSteps.length,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) newIndex -= 1;
                      int absoluteOld = (currentPage * 10) + oldIndex;
                      int absoluteNew = (currentPage * 10) + newIndex;
                      final item = steps.removeAt(absoluteOld);
                      steps.insert(absoluteNew, item);
                    });
                    saveSteps();
                  },
                  itemBuilder: (context, index) {
                    int absoluteIndex = (currentPage * 10) + index;
                    final step = paginatedSteps[index];
                    final isWait = step.type == 'wait';
                    return Material(
                      key: ValueKey('step_${step.hashCode}_$index'),
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: context.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Reorder Drag Handle
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.drag_indicator_rounded, color: context.greyText, size: 24),
                              ),
                            ),
                            // Point circle/icon indicator
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isWait ? context.primary : Color(0xFFFF5252),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isWait
                                  ? Icon(Icons.timer_rounded, color: Colors.black, size: 18)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: context.textMain),
                                    ),
                            ),
                            SizedBox(width: 12),
                            // Point details
                            Expanded(
                              child: InkWell(
                                onTap: () => _showEditDialog(absoluteIndex),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        step.name.isNotEmpty ? step.name : (isWait ? 'Espera' : 'Punto ${index + 1}'),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textMain),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isWait ? 'T: ${(step.delay / 1000).toStringAsFixed(1)}s' : 'T: ${(step.delay / 1000).toStringAsFixed(1)}s • X: ${step.x.toInt()} • Y: ${step.y.toInt()}',
                                        style: TextStyle(color: context.greyText, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.copy, color: context.greyText, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () {
                                    setState(() {
                                      steps.insert(index + 1, ClickStep.fromJson(step.toJson()));
                                    });
                                    saveSteps();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: context.greyText, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () => removeStep(absoluteIndex),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (steps.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left_rounded),
                          color: currentPage > 0 ? context.primary : context.greyText.withValues(alpha: 0.3),
                          onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                        ),
                        Text('${AppStrings.page} ${currentPage + 1} / $totalPages', style: TextStyle(color: context.textMain, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.chevron_right_rounded),
                          color: currentPage < totalPages - 1 ? context.primary : context.greyText.withValues(alpha: 0.3),
                          onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: Column(
                    children: [
                      Text(
                        'v1.0.0',
                        style: TextStyle(color: context.greyText, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'E33-a',
                        style: TextStyle(color: context.greyText.withValues(alpha: 0.4), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? context.secondary.withAlpha(77)
                : Color(0xFFFF5252).withAlpha(77),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isEnabled ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: isEnabled ? context.secondary : Color(0xFFFF5252),
                  size: 24,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade600,
                  size: 14,
                )
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              isEnabled ? AppStrings.active : AppStrings.tapToActivate,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? context.secondary : context.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
