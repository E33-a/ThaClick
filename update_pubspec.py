import re

with open('pubspec.yaml', 'r') as f:
    content = f.read()

content = content.replace('image_path: "assets/thaclick_icon.png"', 'image_path: "assets/thaclick_logo.png"')
content = content.replace('adaptive_icon_foreground: "assets/thaclick_icon.png"', 'adaptive_icon_foreground: "assets/thaclick_logo.png"')
content = content.replace('image: "assets/thaclick_icon.png"', 'image: "assets/thaclick_logo.png"')
content = content.replace('image_dark: "assets/thaclick_icon.png"', 'image_dark: "assets/thaclick_logo.png"')

with open('pubspec.yaml', 'w') as f:
    f.write(content)

print("Pubspec modified successfully")
