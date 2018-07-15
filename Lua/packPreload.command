cd `dirname $0`

export PATH=${PATH}:${QUICK_COCOS2DX_ROOT}/bin

compile_scripts.sh -i src/preload -o res/preload.zip -e xxtea_zip -ek Dragon -es design
