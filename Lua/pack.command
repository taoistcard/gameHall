cd `dirname $0`

export PATH=${PATH}:${QUICK_COCOS2DX_ROOT}/bin

compile_scripts.sh -i src/hall -o res/app.bin -e xxtea_zip -ek Dragon -es design

compile_scripts.sh -i src/common -o res/common.bin -e xxtea_zip -ek Dragon -es design
