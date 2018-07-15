#!/bin/bash

cd `dirname $0`

find . -iname "*.plist" -o -iname "*.ExportJson" | xargs  sed -i ''  -e 's/ //g' -e 's/	//g'


echo clear finish!


