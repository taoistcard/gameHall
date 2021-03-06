-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.loginServer.loginServer.message.s2c_pb')


SYSTEMLOGONMESSAGE = protobuf.Descriptor();
SYSTEMLOGONMESSAGE_ITEM = protobuf.Descriptor();
local SYSTEMLOGONMESSAGE_ITEM_ID_FIELD = protobuf.FieldDescriptor();
local SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD = protobuf.FieldDescriptor();
local SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD = protobuf.FieldDescriptor();
local SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD = protobuf.FieldDescriptor();
local SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD = protobuf.FieldDescriptor();
local SYSTEMLOGONMESSAGE_LIST_FIELD = protobuf.FieldDescriptor();
USERLOGONMESSAGE = protobuf.Descriptor();
USERLOGONMESSAGE_ITEM = protobuf.Descriptor();
local USERLOGONMESSAGE_ITEM_ID_FIELD = protobuf.FieldDescriptor();
local USERLOGONMESSAGE_ITEM_STARTTIME_FIELD = protobuf.FieldDescriptor();
local USERLOGONMESSAGE_ITEM_MSG_FIELD = protobuf.FieldDescriptor();
local USERLOGONMESSAGE_LIST_FIELD = protobuf.FieldDescriptor();
EXCHANGEMESSAGE = protobuf.Descriptor();
local EXCHANGEMESSAGE_MSG_FIELD = protobuf.FieldDescriptor();

SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.name = "id"
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item.id"
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.number = 1
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.index = 0
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.label = 2
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.default_value = 0
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.type = 13
SYSTEMLOGONMESSAGE_ITEM_ID_FIELD.cpp_type = 3

SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.name = "type"
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item.type"
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.number = 2
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.index = 1
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.label = 2
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.default_value = 0
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.type = 13
SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD.cpp_type = 3

SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.name = "startTime"
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item.startTime"
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.number = 3
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.index = 2
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.label = 2
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.default_value = 0
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.type = 13
SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD.cpp_type = 3

SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.name = "msg"
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item.msg"
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.number = 4
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.index = 3
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.label = 2
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.default_value = ""
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.type = 9
SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD.cpp_type = 9

SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.name = "kindID"
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item.kindID"
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.number = 5
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.index = 4
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.label = 1
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.default_value = 0
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.type = 13
SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD.cpp_type = 3

SYSTEMLOGONMESSAGE_ITEM.name = "Item"
SYSTEMLOGONMESSAGE_ITEM.full_name = ".loginServer.message.s2c.SystemLogonMessage.Item"
SYSTEMLOGONMESSAGE_ITEM.nested_types = {}
SYSTEMLOGONMESSAGE_ITEM.enum_types = {}
SYSTEMLOGONMESSAGE_ITEM.fields = {SYSTEMLOGONMESSAGE_ITEM_ID_FIELD, SYSTEMLOGONMESSAGE_ITEM_TYPE_FIELD, SYSTEMLOGONMESSAGE_ITEM_STARTTIME_FIELD, SYSTEMLOGONMESSAGE_ITEM_MSG_FIELD, SYSTEMLOGONMESSAGE_ITEM_KINDID_FIELD}
SYSTEMLOGONMESSAGE_ITEM.is_extendable = false
SYSTEMLOGONMESSAGE_ITEM.extensions = {}
SYSTEMLOGONMESSAGE_ITEM.containing_type = SYSTEMLOGONMESSAGE
SYSTEMLOGONMESSAGE_LIST_FIELD.name = "list"
SYSTEMLOGONMESSAGE_LIST_FIELD.full_name = ".loginServer.message.s2c.SystemLogonMessage.list"
SYSTEMLOGONMESSAGE_LIST_FIELD.number = 1
SYSTEMLOGONMESSAGE_LIST_FIELD.index = 0
SYSTEMLOGONMESSAGE_LIST_FIELD.label = 3
SYSTEMLOGONMESSAGE_LIST_FIELD.has_default_value = false
SYSTEMLOGONMESSAGE_LIST_FIELD.default_value = {}
SYSTEMLOGONMESSAGE_LIST_FIELD.message_type = SYSTEMLOGONMESSAGE.ITEM
SYSTEMLOGONMESSAGE_LIST_FIELD.type = 11
SYSTEMLOGONMESSAGE_LIST_FIELD.cpp_type = 10

SYSTEMLOGONMESSAGE.name = "SystemLogonMessage"
SYSTEMLOGONMESSAGE.full_name = ".loginServer.message.s2c.SystemLogonMessage"
SYSTEMLOGONMESSAGE.nested_types = {SYSTEMLOGONMESSAGE_ITEM}
SYSTEMLOGONMESSAGE.enum_types = {}
SYSTEMLOGONMESSAGE.fields = {SYSTEMLOGONMESSAGE_LIST_FIELD}
SYSTEMLOGONMESSAGE.is_extendable = false
SYSTEMLOGONMESSAGE.extensions = {}
USERLOGONMESSAGE_ITEM_ID_FIELD.name = "id"
USERLOGONMESSAGE_ITEM_ID_FIELD.full_name = ".loginServer.message.s2c.UserLogonMessage.Item.id"
USERLOGONMESSAGE_ITEM_ID_FIELD.number = 1
USERLOGONMESSAGE_ITEM_ID_FIELD.index = 0
USERLOGONMESSAGE_ITEM_ID_FIELD.label = 2
USERLOGONMESSAGE_ITEM_ID_FIELD.has_default_value = false
USERLOGONMESSAGE_ITEM_ID_FIELD.default_value = 0
USERLOGONMESSAGE_ITEM_ID_FIELD.type = 13
USERLOGONMESSAGE_ITEM_ID_FIELD.cpp_type = 3

USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.name = "startTime"
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.full_name = ".loginServer.message.s2c.UserLogonMessage.Item.startTime"
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.number = 2
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.index = 1
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.label = 2
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.has_default_value = false
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.default_value = 0
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.type = 13
USERLOGONMESSAGE_ITEM_STARTTIME_FIELD.cpp_type = 3

USERLOGONMESSAGE_ITEM_MSG_FIELD.name = "msg"
USERLOGONMESSAGE_ITEM_MSG_FIELD.full_name = ".loginServer.message.s2c.UserLogonMessage.Item.msg"
USERLOGONMESSAGE_ITEM_MSG_FIELD.number = 3
USERLOGONMESSAGE_ITEM_MSG_FIELD.index = 2
USERLOGONMESSAGE_ITEM_MSG_FIELD.label = 2
USERLOGONMESSAGE_ITEM_MSG_FIELD.has_default_value = false
USERLOGONMESSAGE_ITEM_MSG_FIELD.default_value = ""
USERLOGONMESSAGE_ITEM_MSG_FIELD.type = 9
USERLOGONMESSAGE_ITEM_MSG_FIELD.cpp_type = 9

USERLOGONMESSAGE_ITEM.name = "Item"
USERLOGONMESSAGE_ITEM.full_name = ".loginServer.message.s2c.UserLogonMessage.Item"
USERLOGONMESSAGE_ITEM.nested_types = {}
USERLOGONMESSAGE_ITEM.enum_types = {}
USERLOGONMESSAGE_ITEM.fields = {USERLOGONMESSAGE_ITEM_ID_FIELD, USERLOGONMESSAGE_ITEM_STARTTIME_FIELD, USERLOGONMESSAGE_ITEM_MSG_FIELD}
USERLOGONMESSAGE_ITEM.is_extendable = false
USERLOGONMESSAGE_ITEM.extensions = {}
USERLOGONMESSAGE_ITEM.containing_type = USERLOGONMESSAGE
USERLOGONMESSAGE_LIST_FIELD.name = "list"
USERLOGONMESSAGE_LIST_FIELD.full_name = ".loginServer.message.s2c.UserLogonMessage.list"
USERLOGONMESSAGE_LIST_FIELD.number = 1
USERLOGONMESSAGE_LIST_FIELD.index = 0
USERLOGONMESSAGE_LIST_FIELD.label = 3
USERLOGONMESSAGE_LIST_FIELD.has_default_value = false
USERLOGONMESSAGE_LIST_FIELD.default_value = {}
USERLOGONMESSAGE_LIST_FIELD.message_type = USERLOGONMESSAGE.ITEM
USERLOGONMESSAGE_LIST_FIELD.type = 11
USERLOGONMESSAGE_LIST_FIELD.cpp_type = 10

USERLOGONMESSAGE.name = "UserLogonMessage"
USERLOGONMESSAGE.full_name = ".loginServer.message.s2c.UserLogonMessage"
USERLOGONMESSAGE.nested_types = {USERLOGONMESSAGE_ITEM}
USERLOGONMESSAGE.enum_types = {}
USERLOGONMESSAGE.fields = {USERLOGONMESSAGE_LIST_FIELD}
USERLOGONMESSAGE.is_extendable = false
USERLOGONMESSAGE.extensions = {}
EXCHANGEMESSAGE_MSG_FIELD.name = "msg"
EXCHANGEMESSAGE_MSG_FIELD.full_name = ".loginServer.message.s2c.ExchangeMessage.msg"
EXCHANGEMESSAGE_MSG_FIELD.number = 1
EXCHANGEMESSAGE_MSG_FIELD.index = 0
EXCHANGEMESSAGE_MSG_FIELD.label = 3
EXCHANGEMESSAGE_MSG_FIELD.has_default_value = false
EXCHANGEMESSAGE_MSG_FIELD.default_value = {}
EXCHANGEMESSAGE_MSG_FIELD.type = 9
EXCHANGEMESSAGE_MSG_FIELD.cpp_type = 9

EXCHANGEMESSAGE.name = "ExchangeMessage"
EXCHANGEMESSAGE.full_name = ".loginServer.message.s2c.ExchangeMessage"
EXCHANGEMESSAGE.nested_types = {}
EXCHANGEMESSAGE.enum_types = {}
EXCHANGEMESSAGE.fields = {EXCHANGEMESSAGE_MSG_FIELD}
EXCHANGEMESSAGE.is_extendable = false
EXCHANGEMESSAGE.extensions = {}

ExchangeMessage = protobuf.Message(EXCHANGEMESSAGE)
SystemLogonMessage = protobuf.Message(SYSTEMLOGONMESSAGE)
SystemLogonMessage.Item = protobuf.Message(SYSTEMLOGONMESSAGE_ITEM)
UserLogonMessage = protobuf.Message(USERLOGONMESSAGE)
UserLogonMessage.Item = protobuf.Message(USERLOGONMESSAGE_ITEM)

