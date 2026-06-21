import os
import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# 1. Wrap Scaffold in GestureDetector
content = content.replace(
'''  @override
  Widget build(BuildContext context) {
    return Scaffold(''',
'''  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold('''
)
# Add closing parenthesis for GestureDetector
content = content.replace(
'''    );
  }

  Widget _buildPermissionCard({''',
'''      ),
    );
  }

  Widget _buildPermissionCard({'''
)

# 2. Add copy button
content = content.replace(
'''                            if (patterns.length > 1)
                              ActionChip(
                                label: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),''',
'''                            ActionChip(
                              label: const Icon(Icons.copy, size: 18, color: Colors.white),
                              backgroundColor: const Color(0xFF1E293B),
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
                            if (patterns.length > 1)
                              ActionChip(
                                label: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),'''
)

# 3. Replace SliverList with SliverReorderableList and editable text fields
list_old_start = "                SliverList("
list_old_end = "              const SliverToBoxAdapter("

reorderable_list_code = '''                SliverReorderableList(
                  itemCount: steps.length,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) newIndex -= 1;
                      final item = steps.removeAt(oldIndex);
                      steps.insert(newIndex, item);
                    });
                    saveSteps();
                  },
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    final isWait = step.type == 'wait';
                    return Material(
                      key: ValueKey('step_${step.hashCode}_$index'),
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161F30),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Reorder Drag Handle
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.drag_indicator_rounded, color: Colors.grey, size: 24),
                              ),
                            ),
                            // Point circle/icon indicator
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isWait ? const Color(0xFF00E5FF) : const Color(0xFFFF5252),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isWait
                                  ? const Icon(Icons.timer_rounded, color: Colors.black, size: 18)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Point details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    key: ValueKey('step_name_${index}_${step.name}'),
                                    initialValue: step.name.isNotEmpty 
                                        ? step.name 
                                        : (isWait ? 'Espera' : 'Punto ${index + 1}'),
                                    onChanged: (val) {
                                      step.name = val;
                                      saveSteps();
                                    },
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[200]),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: 'Nombre...',
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text('T (s): ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          key: ValueKey('delay_${index}_${step.hashCode}'),
                                          initialValue: (step.delay / 1000).toStringAsFixed(1),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(bottom: 4)),
                                          onChanged: (val) {
                                            final parsed = double.tryParse(val.replaceAll(',', '.'));
                                            if (parsed != null && parsed > 0) {
                                              step.delay = (parsed * 1000).toInt();
                                              saveSteps();
                                            }
                                          },
                                        ),
                                      ),
                                      if (!isWait) ...[
                                        const SizedBox(width: 8),
                                        const Text('X: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        SizedBox(
                                          width: 45,
                                          child: TextFormField(
                                            key: ValueKey('x_${index}_${step.hashCode}'),
                                            initialValue: step.x.toInt().toString(),
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(bottom: 4)),
                                            onChanged: (val) {
                                              final parsed = double.tryParse(val);
                                              if (parsed != null) {
                                                step.x = parsed;
                                                saveSteps();
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Y: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        SizedBox(
                                          width: 45,
                                          child: TextFormField(
                                            key: ValueKey('y_${index}_${step.hashCode}'),
                                            initialValue: step.y.toInt().toString(),
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(bottom: 4)),
                                            onChanged: (val) {
                                              final parsed = double.tryParse(val);
                                              if (parsed != null) {
                                                step.y = parsed;
                                                saveSteps();
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () => removeStep(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
'''

# We need to find the exact substring to replace
start_idx = content.find(list_old_start)
end_idx = content.find(list_old_end)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + reorderable_list_code + content[end_idx:]

# 4. Remove tutorial code
# Search for the tutorial card within the file.
tutorial_start = "              SliverToBoxAdapter("
tutorial_end = "              const SliverToBoxAdapter("
tutorial_regex = r"              SliverToBoxAdapter\(\s*child: Padding\(\s*padding: const EdgeInsets\.symmetric\(horizontal: 20\.0, vertical: 20\),\s*child: Container\(.*?GUÍA DE DESPLIEGUE EN COC.*?\)\s*\)\s*,\s*\)\s*,"
content = re.sub(tutorial_regex, "", content, flags=re.DOTALL)

with open('lib/main.dart', 'w') as f:
    f.write(content)
