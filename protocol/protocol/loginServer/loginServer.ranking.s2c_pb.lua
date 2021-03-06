-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.loginServer.loginServer.ranking.s2c_pb')


WEALTHRANKING = protobuf.Descriptor();
WEALTHRANKING_ITEM = protobuf.Descriptor();
local WEALTHRANKING_ITEM_USERID_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_FACEID_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_GENDER_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_NICKNAME_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_MEDAL_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_LOVELINESS_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_SCORE_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_GIFT_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_SIGNATURE_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_EXPERIENCE_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_PLATFORMID_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_MEMBERORDER_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_ITEM_PLATFORMFACE_FIELD = protobuf.FieldDescriptor();
local WEALTHRANKING_LIST_FIELD = protobuf.FieldDescriptor();
LOVELINESRANKING = protobuf.Descriptor();
LOVELINESRANKING_ITEM = protobuf.Descriptor();
local LOVELINESRANKING_ITEM_USERID_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_FACEID_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_GENDER_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_NICKNAME_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_MEDAL_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_LOVELINESS_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_SCORE_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_GIFT_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_SIGNATURE_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_EXPERIENCE_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_PLATFORMID_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_MEMBERORDER_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD = protobuf.FieldDescriptor();
local LOVELINESRANKING_LIST_FIELD = protobuf.FieldDescriptor();

WEALTHRANKING_ITEM_USERID_FIELD.name = "userID"
WEALTHRANKING_ITEM_USERID_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.userID"
WEALTHRANKING_ITEM_USERID_FIELD.number = 1
WEALTHRANKING_ITEM_USERID_FIELD.index = 0
WEALTHRANKING_ITEM_USERID_FIELD.label = 2
WEALTHRANKING_ITEM_USERID_FIELD.has_default_value = false
WEALTHRANKING_ITEM_USERID_FIELD.default_value = 0
WEALTHRANKING_ITEM_USERID_FIELD.type = 13
WEALTHRANKING_ITEM_USERID_FIELD.cpp_type = 3

WEALTHRANKING_ITEM_FACEID_FIELD.name = "faceID"
WEALTHRANKING_ITEM_FACEID_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.faceID"
WEALTHRANKING_ITEM_FACEID_FIELD.number = 2
WEALTHRANKING_ITEM_FACEID_FIELD.index = 1
WEALTHRANKING_ITEM_FACEID_FIELD.label = 2
WEALTHRANKING_ITEM_FACEID_FIELD.has_default_value = false
WEALTHRANKING_ITEM_FACEID_FIELD.default_value = 0
WEALTHRANKING_ITEM_FACEID_FIELD.type = 5
WEALTHRANKING_ITEM_FACEID_FIELD.cpp_type = 1

WEALTHRANKING_ITEM_GENDER_FIELD.name = "gender"
WEALTHRANKING_ITEM_GENDER_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.gender"
WEALTHRANKING_ITEM_GENDER_FIELD.number = 3
WEALTHRANKING_ITEM_GENDER_FIELD.index = 2
WEALTHRANKING_ITEM_GENDER_FIELD.label = 2
WEALTHRANKING_ITEM_GENDER_FIELD.has_default_value = false
WEALTHRANKING_ITEM_GENDER_FIELD.default_value = 0
WEALTHRANKING_ITEM_GENDER_FIELD.type = 5
WEALTHRANKING_ITEM_GENDER_FIELD.cpp_type = 1

WEALTHRANKING_ITEM_NICKNAME_FIELD.name = "nickName"
WEALTHRANKING_ITEM_NICKNAME_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.nickName"
WEALTHRANKING_ITEM_NICKNAME_FIELD.number = 4
WEALTHRANKING_ITEM_NICKNAME_FIELD.index = 3
WEALTHRANKING_ITEM_NICKNAME_FIELD.label = 2
WEALTHRANKING_ITEM_NICKNAME_FIELD.has_default_value = false
WEALTHRANKING_ITEM_NICKNAME_FIELD.default_value = ""
WEALTHRANKING_ITEM_NICKNAME_FIELD.type = 9
WEALTHRANKING_ITEM_NICKNAME_FIELD.cpp_type = 9

WEALTHRANKING_ITEM_MEDAL_FIELD.name = "medal"
WEALTHRANKING_ITEM_MEDAL_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.medal"
WEALTHRANKING_ITEM_MEDAL_FIELD.number = 5
WEALTHRANKING_ITEM_MEDAL_FIELD.index = 4
WEALTHRANKING_ITEM_MEDAL_FIELD.label = 2
WEALTHRANKING_ITEM_MEDAL_FIELD.has_default_value = false
WEALTHRANKING_ITEM_MEDAL_FIELD.default_value = 0
WEALTHRANKING_ITEM_MEDAL_FIELD.type = 3
WEALTHRANKING_ITEM_MEDAL_FIELD.cpp_type = 2

WEALTHRANKING_ITEM_LOVELINESS_FIELD.name = "loveLiness"
WEALTHRANKING_ITEM_LOVELINESS_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.loveLiness"
WEALTHRANKING_ITEM_LOVELINESS_FIELD.number = 6
WEALTHRANKING_ITEM_LOVELINESS_FIELD.index = 5
WEALTHRANKING_ITEM_LOVELINESS_FIELD.label = 2
WEALTHRANKING_ITEM_LOVELINESS_FIELD.has_default_value = false
WEALTHRANKING_ITEM_LOVELINESS_FIELD.default_value = 0
WEALTHRANKING_ITEM_LOVELINESS_FIELD.type = 3
WEALTHRANKING_ITEM_LOVELINESS_FIELD.cpp_type = 2

WEALTHRANKING_ITEM_SCORE_FIELD.name = "score"
WEALTHRANKING_ITEM_SCORE_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.score"
WEALTHRANKING_ITEM_SCORE_FIELD.number = 7
WEALTHRANKING_ITEM_SCORE_FIELD.index = 6
WEALTHRANKING_ITEM_SCORE_FIELD.label = 2
WEALTHRANKING_ITEM_SCORE_FIELD.has_default_value = false
WEALTHRANKING_ITEM_SCORE_FIELD.default_value = 0
WEALTHRANKING_ITEM_SCORE_FIELD.type = 3
WEALTHRANKING_ITEM_SCORE_FIELD.cpp_type = 2

WEALTHRANKING_ITEM_GIFT_FIELD.name = "gift"
WEALTHRANKING_ITEM_GIFT_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.gift"
WEALTHRANKING_ITEM_GIFT_FIELD.number = 8
WEALTHRANKING_ITEM_GIFT_FIELD.index = 7
WEALTHRANKING_ITEM_GIFT_FIELD.label = 2
WEALTHRANKING_ITEM_GIFT_FIELD.has_default_value = false
WEALTHRANKING_ITEM_GIFT_FIELD.default_value = 0
WEALTHRANKING_ITEM_GIFT_FIELD.type = 3
WEALTHRANKING_ITEM_GIFT_FIELD.cpp_type = 2

WEALTHRANKING_ITEM_SIGNATURE_FIELD.name = "signature"
WEALTHRANKING_ITEM_SIGNATURE_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.signature"
WEALTHRANKING_ITEM_SIGNATURE_FIELD.number = 9
WEALTHRANKING_ITEM_SIGNATURE_FIELD.index = 8
WEALTHRANKING_ITEM_SIGNATURE_FIELD.label = 1
WEALTHRANKING_ITEM_SIGNATURE_FIELD.has_default_value = false
WEALTHRANKING_ITEM_SIGNATURE_FIELD.default_value = ""
WEALTHRANKING_ITEM_SIGNATURE_FIELD.type = 9
WEALTHRANKING_ITEM_SIGNATURE_FIELD.cpp_type = 9

WEALTHRANKING_ITEM_EXPERIENCE_FIELD.name = "experience"
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.experience"
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.number = 10
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.index = 9
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.label = 1
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.has_default_value = false
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.default_value = 0
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.type = 5
WEALTHRANKING_ITEM_EXPERIENCE_FIELD.cpp_type = 1

WEALTHRANKING_ITEM_PLATFORMID_FIELD.name = "platformID"
WEALTHRANKING_ITEM_PLATFORMID_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.platformID"
WEALTHRANKING_ITEM_PLATFORMID_FIELD.number = 11
WEALTHRANKING_ITEM_PLATFORMID_FIELD.index = 10
WEALTHRANKING_ITEM_PLATFORMID_FIELD.label = 1
WEALTHRANKING_ITEM_PLATFORMID_FIELD.has_default_value = false
WEALTHRANKING_ITEM_PLATFORMID_FIELD.default_value = 0
WEALTHRANKING_ITEM_PLATFORMID_FIELD.type = 5
WEALTHRANKING_ITEM_PLATFORMID_FIELD.cpp_type = 1

WEALTHRANKING_ITEM_MEMBERORDER_FIELD.name = "memberOrder"
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.memberOrder"
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.number = 12
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.index = 11
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.label = 1
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.has_default_value = false
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.default_value = 0
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.type = 5
WEALTHRANKING_ITEM_MEMBERORDER_FIELD.cpp_type = 1

WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.name = "platformFace"
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.Item.platformFace"
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.number = 13
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.index = 12
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.label = 1
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.has_default_value = false
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.default_value = ""
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.type = 9
WEALTHRANKING_ITEM_PLATFORMFACE_FIELD.cpp_type = 9

WEALTHRANKING_ITEM.name = "Item"
WEALTHRANKING_ITEM.full_name = ".loginServer.ranking.s2c.WealthRanking.Item"
WEALTHRANKING_ITEM.nested_types = {}
WEALTHRANKING_ITEM.enum_types = {}
WEALTHRANKING_ITEM.fields = {WEALTHRANKING_ITEM_USERID_FIELD, WEALTHRANKING_ITEM_FACEID_FIELD, WEALTHRANKING_ITEM_GENDER_FIELD, WEALTHRANKING_ITEM_NICKNAME_FIELD, WEALTHRANKING_ITEM_MEDAL_FIELD, WEALTHRANKING_ITEM_LOVELINESS_FIELD, WEALTHRANKING_ITEM_SCORE_FIELD, WEALTHRANKING_ITEM_GIFT_FIELD, WEALTHRANKING_ITEM_SIGNATURE_FIELD, WEALTHRANKING_ITEM_EXPERIENCE_FIELD, WEALTHRANKING_ITEM_PLATFORMID_FIELD, WEALTHRANKING_ITEM_MEMBERORDER_FIELD, WEALTHRANKING_ITEM_PLATFORMFACE_FIELD}
WEALTHRANKING_ITEM.is_extendable = false
WEALTHRANKING_ITEM.extensions = {}
WEALTHRANKING_ITEM.containing_type = WEALTHRANKING
WEALTHRANKING_LIST_FIELD.name = "list"
WEALTHRANKING_LIST_FIELD.full_name = ".loginServer.ranking.s2c.WealthRanking.list"
WEALTHRANKING_LIST_FIELD.number = 1
WEALTHRANKING_LIST_FIELD.index = 0
WEALTHRANKING_LIST_FIELD.label = 3
WEALTHRANKING_LIST_FIELD.has_default_value = false
WEALTHRANKING_LIST_FIELD.default_value = {}
WEALTHRANKING_LIST_FIELD.message_type = WEALTHRANKING.ITEM
WEALTHRANKING_LIST_FIELD.type = 11
WEALTHRANKING_LIST_FIELD.cpp_type = 10

WEALTHRANKING.name = "WealthRanking"
WEALTHRANKING.full_name = ".loginServer.ranking.s2c.WealthRanking"
WEALTHRANKING.nested_types = {WEALTHRANKING_ITEM}
WEALTHRANKING.enum_types = {}
WEALTHRANKING.fields = {WEALTHRANKING_LIST_FIELD}
WEALTHRANKING.is_extendable = false
WEALTHRANKING.extensions = {}
LOVELINESRANKING_ITEM_USERID_FIELD.name = "userID"
LOVELINESRANKING_ITEM_USERID_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.userID"
LOVELINESRANKING_ITEM_USERID_FIELD.number = 1
LOVELINESRANKING_ITEM_USERID_FIELD.index = 0
LOVELINESRANKING_ITEM_USERID_FIELD.label = 2
LOVELINESRANKING_ITEM_USERID_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_USERID_FIELD.default_value = 0
LOVELINESRANKING_ITEM_USERID_FIELD.type = 13
LOVELINESRANKING_ITEM_USERID_FIELD.cpp_type = 3

LOVELINESRANKING_ITEM_FACEID_FIELD.name = "faceID"
LOVELINESRANKING_ITEM_FACEID_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.faceID"
LOVELINESRANKING_ITEM_FACEID_FIELD.number = 2
LOVELINESRANKING_ITEM_FACEID_FIELD.index = 1
LOVELINESRANKING_ITEM_FACEID_FIELD.label = 2
LOVELINESRANKING_ITEM_FACEID_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_FACEID_FIELD.default_value = 0
LOVELINESRANKING_ITEM_FACEID_FIELD.type = 5
LOVELINESRANKING_ITEM_FACEID_FIELD.cpp_type = 1

LOVELINESRANKING_ITEM_GENDER_FIELD.name = "gender"
LOVELINESRANKING_ITEM_GENDER_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.gender"
LOVELINESRANKING_ITEM_GENDER_FIELD.number = 3
LOVELINESRANKING_ITEM_GENDER_FIELD.index = 2
LOVELINESRANKING_ITEM_GENDER_FIELD.label = 2
LOVELINESRANKING_ITEM_GENDER_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_GENDER_FIELD.default_value = 0
LOVELINESRANKING_ITEM_GENDER_FIELD.type = 5
LOVELINESRANKING_ITEM_GENDER_FIELD.cpp_type = 1

LOVELINESRANKING_ITEM_NICKNAME_FIELD.name = "nickName"
LOVELINESRANKING_ITEM_NICKNAME_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.nickName"
LOVELINESRANKING_ITEM_NICKNAME_FIELD.number = 4
LOVELINESRANKING_ITEM_NICKNAME_FIELD.index = 3
LOVELINESRANKING_ITEM_NICKNAME_FIELD.label = 2
LOVELINESRANKING_ITEM_NICKNAME_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_NICKNAME_FIELD.default_value = ""
LOVELINESRANKING_ITEM_NICKNAME_FIELD.type = 9
LOVELINESRANKING_ITEM_NICKNAME_FIELD.cpp_type = 9

LOVELINESRANKING_ITEM_MEDAL_FIELD.name = "medal"
LOVELINESRANKING_ITEM_MEDAL_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.medal"
LOVELINESRANKING_ITEM_MEDAL_FIELD.number = 5
LOVELINESRANKING_ITEM_MEDAL_FIELD.index = 4
LOVELINESRANKING_ITEM_MEDAL_FIELD.label = 2
LOVELINESRANKING_ITEM_MEDAL_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_MEDAL_FIELD.default_value = 0
LOVELINESRANKING_ITEM_MEDAL_FIELD.type = 3
LOVELINESRANKING_ITEM_MEDAL_FIELD.cpp_type = 2

LOVELINESRANKING_ITEM_LOVELINESS_FIELD.name = "loveLiness"
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.loveLiness"
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.number = 6
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.index = 5
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.label = 2
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.default_value = 0
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.type = 3
LOVELINESRANKING_ITEM_LOVELINESS_FIELD.cpp_type = 2

LOVELINESRANKING_ITEM_SCORE_FIELD.name = "score"
LOVELINESRANKING_ITEM_SCORE_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.score"
LOVELINESRANKING_ITEM_SCORE_FIELD.number = 7
LOVELINESRANKING_ITEM_SCORE_FIELD.index = 6
LOVELINESRANKING_ITEM_SCORE_FIELD.label = 2
LOVELINESRANKING_ITEM_SCORE_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_SCORE_FIELD.default_value = 0
LOVELINESRANKING_ITEM_SCORE_FIELD.type = 3
LOVELINESRANKING_ITEM_SCORE_FIELD.cpp_type = 2

LOVELINESRANKING_ITEM_GIFT_FIELD.name = "gift"
LOVELINESRANKING_ITEM_GIFT_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.gift"
LOVELINESRANKING_ITEM_GIFT_FIELD.number = 8
LOVELINESRANKING_ITEM_GIFT_FIELD.index = 7
LOVELINESRANKING_ITEM_GIFT_FIELD.label = 2
LOVELINESRANKING_ITEM_GIFT_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_GIFT_FIELD.default_value = 0
LOVELINESRANKING_ITEM_GIFT_FIELD.type = 3
LOVELINESRANKING_ITEM_GIFT_FIELD.cpp_type = 2

LOVELINESRANKING_ITEM_SIGNATURE_FIELD.name = "signature"
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.signature"
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.number = 9
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.index = 8
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.label = 1
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.default_value = ""
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.type = 9
LOVELINESRANKING_ITEM_SIGNATURE_FIELD.cpp_type = 9

LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.name = "experience"
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.experience"
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.number = 10
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.index = 9
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.label = 1
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.default_value = 0
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.type = 5
LOVELINESRANKING_ITEM_EXPERIENCE_FIELD.cpp_type = 1

LOVELINESRANKING_ITEM_PLATFORMID_FIELD.name = "platformID"
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.platformID"
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.number = 11
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.index = 10
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.label = 1
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.default_value = 0
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.type = 5
LOVELINESRANKING_ITEM_PLATFORMID_FIELD.cpp_type = 1

LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.name = "memberOrder"
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.memberOrder"
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.number = 12
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.index = 11
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.label = 1
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.default_value = 0
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.type = 5
LOVELINESRANKING_ITEM_MEMBERORDER_FIELD.cpp_type = 1

LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.name = "platformFace"
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item.platformFace"
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.number = 13
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.index = 12
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.label = 1
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.has_default_value = false
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.default_value = ""
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.type = 9
LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD.cpp_type = 9

LOVELINESRANKING_ITEM.name = "Item"
LOVELINESRANKING_ITEM.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.Item"
LOVELINESRANKING_ITEM.nested_types = {}
LOVELINESRANKING_ITEM.enum_types = {}
LOVELINESRANKING_ITEM.fields = {LOVELINESRANKING_ITEM_USERID_FIELD, LOVELINESRANKING_ITEM_FACEID_FIELD, LOVELINESRANKING_ITEM_GENDER_FIELD, LOVELINESRANKING_ITEM_NICKNAME_FIELD, LOVELINESRANKING_ITEM_MEDAL_FIELD, LOVELINESRANKING_ITEM_LOVELINESS_FIELD, LOVELINESRANKING_ITEM_SCORE_FIELD, LOVELINESRANKING_ITEM_GIFT_FIELD, LOVELINESRANKING_ITEM_SIGNATURE_FIELD, LOVELINESRANKING_ITEM_EXPERIENCE_FIELD, LOVELINESRANKING_ITEM_PLATFORMID_FIELD, LOVELINESRANKING_ITEM_MEMBERORDER_FIELD, LOVELINESRANKING_ITEM_PLATFORMFACE_FIELD}
LOVELINESRANKING_ITEM.is_extendable = false
LOVELINESRANKING_ITEM.extensions = {}
LOVELINESRANKING_ITEM.containing_type = LOVELINESRANKING
LOVELINESRANKING_LIST_FIELD.name = "list"
LOVELINESRANKING_LIST_FIELD.full_name = ".loginServer.ranking.s2c.LoveLinesRanking.list"
LOVELINESRANKING_LIST_FIELD.number = 1
LOVELINESRANKING_LIST_FIELD.index = 0
LOVELINESRANKING_LIST_FIELD.label = 3
LOVELINESRANKING_LIST_FIELD.has_default_value = false
LOVELINESRANKING_LIST_FIELD.default_value = {}
LOVELINESRANKING_LIST_FIELD.message_type = LOVELINESRANKING.ITEM
LOVELINESRANKING_LIST_FIELD.type = 11
LOVELINESRANKING_LIST_FIELD.cpp_type = 10

LOVELINESRANKING.name = "LoveLinesRanking"
LOVELINESRANKING.full_name = ".loginServer.ranking.s2c.LoveLinesRanking"
LOVELINESRANKING.nested_types = {LOVELINESRANKING_ITEM}
LOVELINESRANKING.enum_types = {}
LOVELINESRANKING.fields = {LOVELINESRANKING_LIST_FIELD}
LOVELINESRANKING.is_extendable = false
LOVELINESRANKING.extensions = {}

LoveLinesRanking = protobuf.Message(LOVELINESRANKING)
LoveLinesRanking.Item = protobuf.Message(LOVELINESRANKING_ITEM)
WealthRanking = protobuf.Message(WEALTHRANKING)
WealthRanking.Item = protobuf.Message(WEALTHRANKING_ITEM)

