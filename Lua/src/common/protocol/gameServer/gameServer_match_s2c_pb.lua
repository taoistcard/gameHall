-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.gameServer.gameServer.match.s2c_pb')


USERRANKING = protobuf.Descriptor();
local USERRANKING_RANKING_FIELD = protobuf.FieldDescriptor();
local USERRANKING_USERID_FIELD = protobuf.FieldDescriptor();
MATCHINFO = protobuf.Descriptor();
local MATCHINFO_MYRANKING_FIELD = protobuf.FieldDescriptor();
local MATCHINFO_USERCOUNT_FIELD = protobuf.FieldDescriptor();
local MATCHINFO_GAMETIME_FIELD = protobuf.FieldDescriptor();

USERRANKING_RANKING_FIELD.name = "ranking"
USERRANKING_RANKING_FIELD.full_name = ".gameServer.match.s2c.userRanking.ranking"
USERRANKING_RANKING_FIELD.number = 1
USERRANKING_RANKING_FIELD.index = 0
USERRANKING_RANKING_FIELD.label = 2
USERRANKING_RANKING_FIELD.has_default_value = false
USERRANKING_RANKING_FIELD.default_value = 0
USERRANKING_RANKING_FIELD.type = 5
USERRANKING_RANKING_FIELD.cpp_type = 1

USERRANKING_USERID_FIELD.name = "userID"
USERRANKING_USERID_FIELD.full_name = ".gameServer.match.s2c.userRanking.userID"
USERRANKING_USERID_FIELD.number = 2
USERRANKING_USERID_FIELD.index = 1
USERRANKING_USERID_FIELD.label = 1
USERRANKING_USERID_FIELD.has_default_value = false
USERRANKING_USERID_FIELD.default_value = 0
USERRANKING_USERID_FIELD.type = 5
USERRANKING_USERID_FIELD.cpp_type = 1

USERRANKING.name = "userRanking"
USERRANKING.full_name = ".gameServer.match.s2c.userRanking"
USERRANKING.nested_types = {}
USERRANKING.enum_types = {}
USERRANKING.fields = {USERRANKING_RANKING_FIELD, USERRANKING_USERID_FIELD}
USERRANKING.is_extendable = false
USERRANKING.extensions = {}
MATCHINFO_MYRANKING_FIELD.name = "myRanking"
MATCHINFO_MYRANKING_FIELD.full_name = ".gameServer.match.s2c.matchInfo.myRanking"
MATCHINFO_MYRANKING_FIELD.number = 1
MATCHINFO_MYRANKING_FIELD.index = 0
MATCHINFO_MYRANKING_FIELD.label = 2
MATCHINFO_MYRANKING_FIELD.has_default_value = false
MATCHINFO_MYRANKING_FIELD.default_value = 0
MATCHINFO_MYRANKING_FIELD.type = 5
MATCHINFO_MYRANKING_FIELD.cpp_type = 1

MATCHINFO_USERCOUNT_FIELD.name = "userCount"
MATCHINFO_USERCOUNT_FIELD.full_name = ".gameServer.match.s2c.matchInfo.userCount"
MATCHINFO_USERCOUNT_FIELD.number = 2
MATCHINFO_USERCOUNT_FIELD.index = 1
MATCHINFO_USERCOUNT_FIELD.label = 2
MATCHINFO_USERCOUNT_FIELD.has_default_value = false
MATCHINFO_USERCOUNT_FIELD.default_value = 0
MATCHINFO_USERCOUNT_FIELD.type = 5
MATCHINFO_USERCOUNT_FIELD.cpp_type = 1

MATCHINFO_GAMETIME_FIELD.name = "gameTime"
MATCHINFO_GAMETIME_FIELD.full_name = ".gameServer.match.s2c.matchInfo.gameTime"
MATCHINFO_GAMETIME_FIELD.number = 3
MATCHINFO_GAMETIME_FIELD.index = 2
MATCHINFO_GAMETIME_FIELD.label = 2
MATCHINFO_GAMETIME_FIELD.has_default_value = false
MATCHINFO_GAMETIME_FIELD.default_value = 0
MATCHINFO_GAMETIME_FIELD.type = 5
MATCHINFO_GAMETIME_FIELD.cpp_type = 1

MATCHINFO.name = "matchInfo"
MATCHINFO.full_name = ".gameServer.match.s2c.matchInfo"
MATCHINFO.nested_types = {}
MATCHINFO.enum_types = {}
MATCHINFO.fields = {MATCHINFO_MYRANKING_FIELD, MATCHINFO_USERCOUNT_FIELD, MATCHINFO_GAMETIME_FIELD}
MATCHINFO.is_extendable = false
MATCHINFO.extensions = {}

matchInfo = protobuf.Message(MATCHINFO)
userRanking = protobuf.Message(USERRANKING)

