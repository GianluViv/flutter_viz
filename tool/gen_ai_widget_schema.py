#!/usr/bin/env python3
"""Generates lib/widgets/ai_widget_schema.g.dart.

Scans the real widget classes and lists, for every widget `subType`, the full
set of property keys its `fromJson` accepts. This is what the AI catalog needs:
a `TextClass()` serialized by hand only emits the few non-null layout flags, so
the runtime catalog can't reveal keys like `text`/`fontSize`/`textColor`. Here
we read them straight from the source, so the schema never drifts from the code.

Re-run after adding/renaming widget properties:
    python tool/gen_ai_widget_schema.py
"""
import re
import glob
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        return f.read()


# 1) constant name -> string value (WidgetTypeText -> "Text")
consts = {}
for line in read("lib/utils/AppConstant.dart").splitlines():
    m = re.match(r"const\s+(\w+)\s*=\s*[\"']([^\"']*)[\"']", line.strip())
    if m:
        consts[m.group(1)] = m.group(2)

# 2) subType value -> ClassName (from ScreenJsonData.fromJson dispatch)
sub_to_class = {}
for line in read("lib/model/screen_json_data.dart").splitlines():
    m = re.search(r"json\[(\w+)\][^;]*new\s+(\w+)\.fromJson", line)
    if m:
        sub = consts.get(m.group(1), m.group(1))
        sub_to_class.setdefault(sub, m.group(2))

# 3) ClassName -> source file (scan widgetsClass/)
class_to_file = {}
for path in glob.glob(os.path.join(ROOT, "lib", "widgetsClass", "*.dart")):
    src = open(path, encoding="utf-8").read()
    for m in re.finditer(r"class\s+(\w+)\b", src):
        class_to_file.setdefault(m.group(1), path)

# 4) For each class, extract keys read inside its `fromJson` constructor body.
def from_json_keys(class_name):
    path = class_to_file.get(class_name)
    if not path:
        return []
    src = open(path, encoding="utf-8").read()
    # isolate the `<Class>.fromJson(...) { ... }` body
    start = src.find(f"{class_name}.fromJson")
    if start == -1:
        return []
    brace = src.find("{", start)
    depth, i = 0, brace
    while i < len(src):
        if src[i] == "{":
            depth += 1
        elif src[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    body = src[brace : i + 1]
    keys = []
    for m in re.finditer(r"""json\[\s*['"]([^'"]+)['"]\s*\]""", body):
        if m.group(1) not in keys:
            keys.append(m.group(1))
    return keys


schema = {}
for sub, cls in sub_to_class.items():
    keys = from_json_keys(cls)
    if keys:
        schema[sub] = keys

# 5) Emit Dart
out = [
    "// GENERATED FILE - do not edit by hand.",
    "// Run: python tool/gen_ai_widget_schema.py",
    "//",
    "// Maps each widget `subType` to the full list of property keys its",
    "// fromJson accepts. Used by the AI panel to build ai/_catalog.json.",
    "",
    "const Map<String, List<String>> kAiWidgetPropertyKeys = {",
]
for sub in sorted(schema):
    keys = ", ".join(f'"{k}"' for k in schema[sub])
    out.append(f'  "{sub}": [{keys}],')
out.append("};")
out.append("")

dest = os.path.join(ROOT, "lib", "widgets", "ai_widget_schema.g.dart")
with open(dest, "w", encoding="utf-8") as f:
    f.write("\n".join(out))

print(f"Wrote {dest}")
print(f"{len(schema)} widget subtypes documented")
missing = sorted(set(sub_to_class) - set(schema))
if missing:
    print("No keys found for:", ", ".join(missing))
