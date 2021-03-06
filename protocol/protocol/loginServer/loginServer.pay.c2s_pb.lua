-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.loginServer.loginServer.pay.c2s_pb')


QUERYPAYORDERITEM = protobuf.Descriptor();
QUERYFREESCORE = protobuf.Descriptor();
GETFREESCORE = protobuf.Descriptor();
QUERYVIPFREESCORE = protobuf.Descriptor();
GETVIPFREESCORE = protobuf.Descriptor();
local GETVIPFREESCORE_MEMBERTYPE_FIELD = protobuf.FieldDescriptor();
GETGIFTSCORE = protobuf.Descriptor();
local GETGIFTSCORE_GIFT_FIELD = protobuf.FieldDescriptor();
QUERYVIPINFO = protobuf.Descriptor();

QUERYPAYORDERITEM.name = "QueryPayOrderItem"
QUERYPAYORDERITEM.full_name = ".loginServer.pay.c2s.QueryPayOrderItem"
QUERYPAYORDERITEM.nested_types = {}
QUERYPAYORDERITEM.enum_types = {}
QUERYPAYORDERITEM.fields = {}
QUERYPAYORDERITEM.is_extendable = false
QUERYPAYORDERITEM.extensions = {}
QUERYFREESCORE.name = "QueryFreeScore"
QUERYFREESCORE.full_name = ".loginServer.pay.c2s.QueryFreeScore"
QUERYFREESCORE.nested_types = {}
QUERYFREESCORE.enum_types = {}
QUERYFREESCORE.fields = {}
QUERYFREESCORE.is_extendable = false
QUERYFREESCORE.extensions = {}
GETFREESCORE.name = "GetFreeScore"
GETFREESCORE.full_name = ".loginServer.pay.c2s.GetFreeScore"
GETFREESCORE.nested_types = {}
GETFREESCORE.enum_types = {}
GETFREESCORE.fields = {}
GETFREESCORE.is_extendable = false
GETFREESCORE.extensions = {}
QUERYVIPFREESCORE.name = "QueryVipFreeScore"
QUERYVIPFREESCORE.full_name = ".loginServer.pay.c2s.QueryVipFreeScore"
QUERYVIPFREESCORE.nested_types = {}
QUERYVIPFREESCORE.enum_types = {}
QUERYVIPFREESCORE.fields = {}
QUERYVIPFREESCORE.is_extendable = false
QUERYVIPFREESCORE.extensions = {}
GETVIPFREESCORE_MEMBERTYPE_FIELD.name = "memberType"
GETVIPFREESCORE_MEMBERTYPE_FIELD.full_name = ".loginServer.pay.c2s.GetVipFreeScore.memberType"
GETVIPFREESCORE_MEMBERTYPE_FIELD.number = 1
GETVIPFREESCORE_MEMBERTYPE_FIELD.index = 0
GETVIPFREESCORE_MEMBERTYPE_FIELD.label = 1
GETVIPFREESCORE_MEMBERTYPE_FIELD.has_default_value = false
GETVIPFREESCORE_MEMBERTYPE_FIELD.default_value = 0
GETVIPFREESCORE_MEMBERTYPE_FIELD.type = 5
GETVIPFREESCORE_MEMBERTYPE_FIELD.cpp_type = 1

GETVIPFREESCORE.name = "GetVipFreeScore"
GETVIPFREESCORE.full_name = ".loginServer.pay.c2s.GetVipFreeScore"
GETVIPFREESCORE.nested_types = {}
GETVIPFREESCORE.enum_types = {}
GETVIPFREESCORE.fields = {GETVIPFREESCORE_MEMBERTYPE_FIELD}
GETVIPFREESCORE.is_extendable = false
GETVIPFREESCORE.extensions = {}
GETGIFTSCORE_GIFT_FIELD.name = "gift"
GETGIFTSCORE_GIFT_FIELD.full_name = ".loginServer.pay.c2s.GetGiftScore.gift"
GETGIFTSCORE_GIFT_FIELD.number = 1
GETGIFTSCORE_GIFT_FIELD.index = 0
GETGIFTSCORE_GIFT_FIELD.label = 1
GETGIFTSCORE_GIFT_FIELD.has_default_value = false
GETGIFTSCORE_GIFT_FIELD.default_value = 0
GETGIFTSCORE_GIFT_FIELD.type = 3
GETGIFTSCORE_GIFT_FIELD.cpp_type = 2

GETGIFTSCORE.name = "GetGiftScore"
GETGIFTSCORE.full_name = ".loginServer.pay.c2s.GetGiftScore"
GETGIFTSCORE.nested_types = {}
GETGIFTSCORE.enum_types = {}
GETGIFTSCORE.fields = {GETGIFTSCORE_GIFT_FIELD}
GETGIFTSCORE.is_extendable = false
GETGIFTSCORE.extensions = {}
QUERYVIPINFO.name = "QueryVipInfo"
QUERYVIPINFO.full_name = ".loginServer.pay.c2s.QueryVipInfo"
QUERYVIPINFO.nested_types = {}
QUERYVIPINFO.enum_types = {}
QUERYVIPINFO.fields = {}
QUERYVIPINFO.is_extendable = false
QUERYVIPINFO.extensions = {}

GetFreeScore = protobuf.Message(GETFREESCORE)
GetGiftScore = protobuf.Message(GETGIFTSCORE)
GetVipFreeScore = protobuf.Message(GETVIPFREESCORE)
QueryFreeScore = protobuf.Message(QUERYFREESCORE)
QueryPayOrderItem = protobuf.Message(QUERYPAYORDERITEM)
QueryVipFreeScore = protobuf.Message(QUERYVIPFREESCORE)
QueryVipInfo = protobuf.Message(QUERYVIPINFO)

