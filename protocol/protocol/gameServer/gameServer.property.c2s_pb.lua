-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.gameServer.gameServer.property.c2s_pb')


BUYPROPERTY = protobuf.Descriptor();
local BUYPROPERTY_PROPERTYID_FIELD = protobuf.FieldDescriptor();
local BUYPROPERTY_PROPERTYCOUNT_FIELD = protobuf.FieldDescriptor();
USEPROPERTY = protobuf.Descriptor();
local USEPROPERTY_PROPERTYID_FIELD = protobuf.FieldDescriptor();
local USEPROPERTY_PROPERTYCOUNT_FIELD = protobuf.FieldDescriptor();
local USEPROPERTY_TARGETUSERID_FIELD = protobuf.FieldDescriptor();
SENDTRUMPET = protobuf.Descriptor();
local SENDTRUMPET_TRUMPETID_FIELD = protobuf.FieldDescriptor();
local SENDTRUMPET_COLOR_FIELD = protobuf.FieldDescriptor();
local SENDTRUMPET_MSG_FIELD = protobuf.FieldDescriptor();

BUYPROPERTY_PROPERTYID_FIELD.name = "propertyID"
BUYPROPERTY_PROPERTYID_FIELD.full_name = ".gameServer.property.c2s.BuyProperty.propertyID"
BUYPROPERTY_PROPERTYID_FIELD.number = 1
BUYPROPERTY_PROPERTYID_FIELD.index = 0
BUYPROPERTY_PROPERTYID_FIELD.label = 2
BUYPROPERTY_PROPERTYID_FIELD.has_default_value = false
BUYPROPERTY_PROPERTYID_FIELD.default_value = 0
BUYPROPERTY_PROPERTYID_FIELD.type = 13
BUYPROPERTY_PROPERTYID_FIELD.cpp_type = 3

BUYPROPERTY_PROPERTYCOUNT_FIELD.name = "propertyCount"
BUYPROPERTY_PROPERTYCOUNT_FIELD.full_name = ".gameServer.property.c2s.BuyProperty.propertyCount"
BUYPROPERTY_PROPERTYCOUNT_FIELD.number = 2
BUYPROPERTY_PROPERTYCOUNT_FIELD.index = 1
BUYPROPERTY_PROPERTYCOUNT_FIELD.label = 2
BUYPROPERTY_PROPERTYCOUNT_FIELD.has_default_value = false
BUYPROPERTY_PROPERTYCOUNT_FIELD.default_value = 0
BUYPROPERTY_PROPERTYCOUNT_FIELD.type = 13
BUYPROPERTY_PROPERTYCOUNT_FIELD.cpp_type = 3

BUYPROPERTY.name = "BuyProperty"
BUYPROPERTY.full_name = ".gameServer.property.c2s.BuyProperty"
BUYPROPERTY.nested_types = {}
BUYPROPERTY.enum_types = {}
BUYPROPERTY.fields = {BUYPROPERTY_PROPERTYID_FIELD, BUYPROPERTY_PROPERTYCOUNT_FIELD}
BUYPROPERTY.is_extendable = false
BUYPROPERTY.extensions = {}
USEPROPERTY_PROPERTYID_FIELD.name = "propertyID"
USEPROPERTY_PROPERTYID_FIELD.full_name = ".gameServer.property.c2s.UseProperty.propertyID"
USEPROPERTY_PROPERTYID_FIELD.number = 1
USEPROPERTY_PROPERTYID_FIELD.index = 0
USEPROPERTY_PROPERTYID_FIELD.label = 2
USEPROPERTY_PROPERTYID_FIELD.has_default_value = false
USEPROPERTY_PROPERTYID_FIELD.default_value = 0
USEPROPERTY_PROPERTYID_FIELD.type = 13
USEPROPERTY_PROPERTYID_FIELD.cpp_type = 3

USEPROPERTY_PROPERTYCOUNT_FIELD.name = "propertyCount"
USEPROPERTY_PROPERTYCOUNT_FIELD.full_name = ".gameServer.property.c2s.UseProperty.propertyCount"
USEPROPERTY_PROPERTYCOUNT_FIELD.number = 2
USEPROPERTY_PROPERTYCOUNT_FIELD.index = 1
USEPROPERTY_PROPERTYCOUNT_FIELD.label = 2
USEPROPERTY_PROPERTYCOUNT_FIELD.has_default_value = false
USEPROPERTY_PROPERTYCOUNT_FIELD.default_value = 0
USEPROPERTY_PROPERTYCOUNT_FIELD.type = 13
USEPROPERTY_PROPERTYCOUNT_FIELD.cpp_type = 3

USEPROPERTY_TARGETUSERID_FIELD.name = "targetUserID"
USEPROPERTY_TARGETUSERID_FIELD.full_name = ".gameServer.property.c2s.UseProperty.targetUserID"
USEPROPERTY_TARGETUSERID_FIELD.number = 3
USEPROPERTY_TARGETUSERID_FIELD.index = 2
USEPROPERTY_TARGETUSERID_FIELD.label = 2
USEPROPERTY_TARGETUSERID_FIELD.has_default_value = false
USEPROPERTY_TARGETUSERID_FIELD.default_value = 0
USEPROPERTY_TARGETUSERID_FIELD.type = 13
USEPROPERTY_TARGETUSERID_FIELD.cpp_type = 3

USEPROPERTY.name = "UseProperty"
USEPROPERTY.full_name = ".gameServer.property.c2s.UseProperty"
USEPROPERTY.nested_types = {}
USEPROPERTY.enum_types = {}
USEPROPERTY.fields = {USEPROPERTY_PROPERTYID_FIELD, USEPROPERTY_PROPERTYCOUNT_FIELD, USEPROPERTY_TARGETUSERID_FIELD}
USEPROPERTY.is_extendable = false
USEPROPERTY.extensions = {}
SENDTRUMPET_TRUMPETID_FIELD.name = "trumpetID"
SENDTRUMPET_TRUMPETID_FIELD.full_name = ".gameServer.property.c2s.SendTrumpet.trumpetID"
SENDTRUMPET_TRUMPETID_FIELD.number = 1
SENDTRUMPET_TRUMPETID_FIELD.index = 0
SENDTRUMPET_TRUMPETID_FIELD.label = 2
SENDTRUMPET_TRUMPETID_FIELD.has_default_value = false
SENDTRUMPET_TRUMPETID_FIELD.default_value = 0
SENDTRUMPET_TRUMPETID_FIELD.type = 13
SENDTRUMPET_TRUMPETID_FIELD.cpp_type = 3

SENDTRUMPET_COLOR_FIELD.name = "color"
SENDTRUMPET_COLOR_FIELD.full_name = ".gameServer.property.c2s.SendTrumpet.color"
SENDTRUMPET_COLOR_FIELD.number = 2
SENDTRUMPET_COLOR_FIELD.index = 1
SENDTRUMPET_COLOR_FIELD.label = 2
SENDTRUMPET_COLOR_FIELD.has_default_value = false
SENDTRUMPET_COLOR_FIELD.default_value = 0
SENDTRUMPET_COLOR_FIELD.type = 13
SENDTRUMPET_COLOR_FIELD.cpp_type = 3

SENDTRUMPET_MSG_FIELD.name = "msg"
SENDTRUMPET_MSG_FIELD.full_name = ".gameServer.property.c2s.SendTrumpet.msg"
SENDTRUMPET_MSG_FIELD.number = 3
SENDTRUMPET_MSG_FIELD.index = 2
SENDTRUMPET_MSG_FIELD.label = 2
SENDTRUMPET_MSG_FIELD.has_default_value = false
SENDTRUMPET_MSG_FIELD.default_value = ""
SENDTRUMPET_MSG_FIELD.type = 9
SENDTRUMPET_MSG_FIELD.cpp_type = 9

SENDTRUMPET.name = "SendTrumpet"
SENDTRUMPET.full_name = ".gameServer.property.c2s.SendTrumpet"
SENDTRUMPET.nested_types = {}
SENDTRUMPET.enum_types = {}
SENDTRUMPET.fields = {SENDTRUMPET_TRUMPETID_FIELD, SENDTRUMPET_COLOR_FIELD, SENDTRUMPET_MSG_FIELD}
SENDTRUMPET.is_extendable = false
SENDTRUMPET.extensions = {}

BuyProperty = protobuf.Message(BUYPROPERTY)
SendTrumpet = protobuf.Message(SENDTRUMPET)
UseProperty = protobuf.Message(USEPROPERTY)

