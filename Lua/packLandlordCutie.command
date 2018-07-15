cd `dirname $0`

export PATH=${PATH}:${QUICK_COCOS2DX_ROOT}/bin

compile_scripts.sh -i src/landlordCutie -o res/landlordCutie/landlordCutie.bin -e xxtea_zip -ek Dragon -es design
