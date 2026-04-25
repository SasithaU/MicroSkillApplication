import re

with open('/Users/cobsc55/App/MicroSkill/MicroSkill.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# 1. Add file references after A4
old_a4 = '\t\t000000000000000000000000000000A4 /* QuizView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuizView.swift; sourceTree = "<group>"; };'
new_a4 = old_a4 + '\n\t\t000000000000000000000000000000A5 /* LearningPathView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LearningPathView.swift; sourceTree = "<group>"; };\n\t\t000000000000000000000000000000A6 /* QuizResultView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuizResultView.swift; sourceTree = "<group>"; };'
content = content.replace(old_a4, new_a4)

# 2. Add to group children
old_group = '000000000000000000000000000000A3, 000000000000000000000000000000A4, 000000000000000000000000000000A0, 000000000000000000000000000000A1, 000000000000000000000000000000A2'
new_group = '000000000000000000000000000000A3, 000000000000000000000000000000A4, 000000000000000000000000000000A5, 000000000000000000000000000000A6, 000000000000000000000000000000A0, 000000000000000000000000000000A1, 000000000000000000000000000000A2'
content = content.replace(old_group, new_group)

# 3. Add build files after C4
old_c4 = '\t\t000000000000000000000000000000C4 /* QuizView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000000000000000000000A4; };'
new_c4 = old_c4 + '\n\t\t000000000000000000000000000000D0 /* LearningPathView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000000000000000000000A5; };\n\t\t000000000000000000000000000000D1 /* QuizResultView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000000000000000000000A6; };'
content = content.replace(old_c4, new_c4)

# 4. Add to sources build phase
old_sources = '000000000000000000000000000000C3, 000000000000000000000000000000C4'
new_sources = '000000000000000000000000000000C3, 000000000000000000000000000000C4, 000000000000000000000000000000D0, 000000000000000000000000000000D1'
content = content.replace(old_sources, new_sources)

with open('/Users/cobsc55/App/MicroSkill/MicroSkill.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print('Done. LP count:', content.count('LearningPathView'))
print('QR count:', content.count('QuizResultView'))
