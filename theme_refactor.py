import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add extension for easy colors
theme_extension = """
extension ThemeColors on BuildContext {
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get textMain => Theme.of(this).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get textDim => Theme.of(this).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get border => Theme.of(this).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
  Color get greyText => Theme.of(this).brightness == Brightness.dark ? Colors.grey : Colors.grey[700]!;
}
"""

if "extension ThemeColors" not in content:
    content = content.replace("class MyApp extends StatelessWidget {", theme_extension + "\nclass MyApp extends StatelessWidget {")

# Rewrite MaterialApp theme
old_theme = """theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF), // Cyber Cyan
          secondary: Color(0xFF00E676), // Emerald Green
          error: Color(0xFFFF5252), // Neon Red
          surface: Color(0xFF161F30), // Dark Blue Gray
        ),
        useMaterial3: true,
      ),"""

new_theme = """themeMode: ThemeMode.system,
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
      ),"""
content = content.replace(old_theme, new_theme)

# Strip consts from widgets that will have dynamic colors
const_removals = [
    r'const\s+TextStyle',
    r'const\s+Icon\(',
    r'const\s+BoxDecoration',
    r'const\s+BorderSide',
    r'const\s+Border\(',
    r'const\s+Color\(',
    r'const\s+InputDecoration',
    r'const\s+Row',
    r'const\s+Column',
    r'const\s+Text\(',
    r'const\s+Padding\(',
    r'const\s+Container\(',
    r'const\s+SizedBox\(',
    r'const\s+Expanded\(',
    r'const\s+Center\(',
]
for p in const_removals:
    content = re.sub(p, lambda m: m.group(0).replace('const ', ''), content)

# Remove explicit 'const ' before colors
content = content.replace("const Color(", "Color(")

# Replace hardcoded colors with context getters
content = content.replace("Color(0xFF161F30)", "context.surface")
content = content.replace("Color(0xFF0A0E17)", "context.bg")
content = content.replace("Color(0xFF00E5FF)", "context.primary")
content = content.replace("Color(0xFF00E676)", "context.secondary")
content = content.replace("Color(0xFF1E293B)", "context.border")
content = content.replace("Colors.white70", "context.textDim")
content = content.replace("Colors.white", "context.textMain")
content = content.replace("Colors.grey", "context.greyText")

with open('lib/main.dart', 'w') as f:
    f.write(content)

print("Script written and applied locally")
