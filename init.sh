#!/bin/bash
# 项目名
PROJ_NAME=$1

# 删除xcuserdata
rm -rv InitDemo.xcodeproj/xcuserdata

# 将project.pbxproj 中InitDemo 替换为 输入的项目名
sed -i '' "s/InitDemo/${PROJ_NAME}/g" InitDemo.xcodeproj/project.pbxproj

# 如果使用pod
# 将project.xcworkspace 中的 contents.xcworkspacedata 中的 InitDemo 替换为 输入的项目名
sed -i '' "s/InitDemo/${PROJ_NAME}/g" InitDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata

# 修改Podfile
sed -i '' "s/InitDemo/${PROJ_NAME}/g" Podfile


# 重命名目录和文件名
mv ${PWD} "$(dirname ${PWD})/${PROJ_NAME}"
mv InitDemo.xcodeproj "${PROJ_NAME}.xcodeproj"
mv InitDemo "${PROJ_NAME}"

# 安装依赖
pod install

echo "${PROJ_NAME} init finish -.-"
