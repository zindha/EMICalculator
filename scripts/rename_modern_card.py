import os
import re

# Rename the file
old_path = "lib/shared/widgets/modern_glass_card.dart"
new_path = "lib/shared/widgets/modern_card.dart"

if os.path.exists(old_path):
    os.rename(old_path, new_path)
    print(f"Renamed {old_path} -> {new_path}")
else:
    print(f"Source file not found: {old_path}")

# Update content in all dart files
for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            original = content
            content = content.replace("modern_glass_card", "modern_card")
            content = content.replace("ModernGlassCard", "ModernCard")
            if content != original:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Updated: {filepath}")
