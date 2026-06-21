import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# 1. Update state variables
content = content.replace(
    '  List<ClickStep> steps = [];\n  bool isAccessibilityEnabled = false;',
'''  List<List<ClickStep>> patterns = [[]];
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
  
  bool isAccessibilityEnabled = false;'''
)

# 2. Update channel handlers
content = content.replace(
'''        case 'onStepsUpdated':
          final String jsonStr = call.arguments as String;
          try {
            final Map<String, dynamic> decoded = jsonDecode(jsonStr);
            setState(() {
              loopCount = decoded['loopCount'] ?? 1;
              final List<dynamic> stepsList = decoded['steps'] ?? [];
              steps = stepsList.map((e) => ClickStep.fromJson(e)).toList();
            });
          } catch (_) {
            try {
              final List<dynamic> decoded = jsonDecode(jsonStr);
              setState(() {
                steps = decoded.map((e) => ClickStep.fromJson(e)).toList();
              });
            } catch (_) {}
          }
          await saveSteps();
          break;''',
'''        case 'onPatternsUpdated':
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
          break;'''
)

# 3. Update loadSteps
content = content.replace(
'''  Future<void> loadSteps() async {
    try {
      final file = File('/data/data/com.touch.touch/files/steps.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        try {
          final Map<String, dynamic> decoded = jsonDecode(content);
          setState(() {
            loopCount = decoded['loopCount'] ?? 1;
            final List<dynamic> stepsList = decoded['steps'] ?? [];
            steps = stepsList.map((e) => ClickStep.fromJson(e)).toList();
          });
        } catch (_) {
          final List<dynamic> decoded = jsonDecode(content);
          setState(() {
            steps = decoded.map((e) => ClickStep.fromJson(e)).toList();
          });
        }
        await _sendStepsToNative();
      }
    } catch (e) {
      // Ignored
    }
  }''',
'''  Future<void> loadSteps() async {
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
  }'''
)

# 4. Update saveSteps
content = content.replace(
'''  Future<void> saveSteps() async {
    try {
      final directory = Directory('/data/data/com.touch.touch/files');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/steps.json');
      final Map<String, dynamic> data = {
        'loopCount': loopCount,
        'steps': steps.map((e) => e.toJson()).toList(),
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
      'steps': steps.map((e) => e.toJson()).toList(),
    };
    await ClickerService.setSteps(data);
  }''',
'''  Future<void> saveSteps() async {
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
  }'''
)

# 5. Add Patterns UI below Loop Settings
pattern_ui = '''
              // Patterns Settings Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1E293B),
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
                                children: const [
                                  Text(
                                    'GESTOR DE PATRONES',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00E5FF),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Alterna entre macros grabadas',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Aleatorio',
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                                Switch(
                                  value: randomizePatterns,
                                  activeColor: const Color(0xFF00E5FF),
                                  onChanged: (val) {
                                    setState(() { randomizePatterns = val; });
                                    saveSteps();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (int i = 0; i < patterns.length; i++)
                              ChoiceChip(
                                label: Text('P${i + 1}'),
                                selected: activePatternIndex == i,
                                selectedColor: const Color(0xFF00E5FF).withOpacity(0.3),
                                labelStyle: TextStyle(
                                  color: activePatternIndex == i ? const Color(0xFF00E5FF) : Colors.white70,
                                  fontWeight: activePatternIndex == i ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: const Color(0xFF1E293B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: activePatternIndex == i ? const Color(0xFF00E5FF) : Colors.transparent,
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() { activePatternIndex = i; });
                                    saveSteps();
                                  }
                                },
                              ),
                            ActionChip(
                              label: const Icon(Icons.add, size: 18, color: Colors.white),
                              backgroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                              onPressed: () {
                                setState(() {
                                  patterns.add([]);
                                  activePatternIndex = patterns.length - 1;
                                });
                                saveSteps();
                              },
                            ),
                            if (patterns.length > 1)
                              ActionChip(
                                label: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                backgroundColor: const Color(0xFF1E293B),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                                onPressed: () {
                                  setState(() {
                                    patterns.removeAt(activePatternIndex);
                                    if (activePatternIndex >= patterns.length) {
                                      activePatternIndex = patterns.length - 1;
                                    }
                                  });
                                  saveSteps();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
'''

content = content.replace(
    '              // Control panel buttons',
    pattern_ui + '\n              // Control panel buttons'
)

with open('lib/main.dart', 'w') as f:
    f.write(content)
