# file convert.sh
#!/bin/sh
PROTO_PATH="/Users/apple/Documents/quick-3.3/projects/cocos_games/client/trunk/NewHall/proto"
PROTO_TARGET_PATH="/Users/apple/Documents/quick-3.3/projects/cocos_games/client/trunk/NewHall/protocol"
PROTO_TARGET_PATH_DELETE="/Users/apple/Documents/quick-3.3/projects/cocos_games/client/trunk/NewHall/protocol"

echo $PROTO_TARGET_PATH_DELETE
echo $PROTO_TARGET_PATH
rm -rf $PROTO_TARGET_PATH_DELETE
mkdir $PROTO_TARGET_PATH

cd $PROTO_PATH
for filename in `find . -type d`
do
echo Deal with $filename ...
if [ $filename != '.' ]
then
protoc --lua_out=$PROTO_TARGET_PATH $filename/*.proto
fi
echo "                        [done!]"
done
