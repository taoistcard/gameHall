#!/bin/sh
for filename in `find . -name *.proto`
do
echo Deal with $filename ...
if [ $filename != '.' ]
then
protoc --proto_path=./ --lua_out=../Lua/src/common $filename
fi
done

cd `dirname $0`
cd ../Lua/src/common/protocol
#pwd

for filename in `find . -name *_pb.lua`
do
#echo $filename
length=${#filename}
#echo $length
name=${filename:(2):($length-6)}
#echo $name
rename=${name//./_}
#echo $rename
#echo ./$rename.png
mv $filename ./$rename.lua
#echo next
done