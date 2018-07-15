cd `dirname $0`

export PATH=${PATH}:${QUICK_COCOS2DX_ROOT}/bin

compile_scripts.sh -i src/launcher -p launcher -o res/launcher.bin -e xxtea_zip -ek Dragon -es design
