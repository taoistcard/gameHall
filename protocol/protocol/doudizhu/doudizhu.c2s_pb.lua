-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.doudizhu.doudizhu.c2s_pb')


CMD_C_VOUCHERBETTING_PRO = protobuf.Descriptor();
local CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD = protobuf.FieldDescriptor();
CMD_C_CALLSCORE_PRO = protobuf.Descriptor();
local CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD = protobuf.FieldDescriptor();
CMD_C_OUTCARD_PRO = protobuf.Descriptor();
local CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD = protobuf.FieldDescriptor();
local CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD = protobuf.FieldDescriptor();
CMD_C_TUOGUAN_PRO = protobuf.Descriptor();
local CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD = protobuf.FieldDescriptor();
CMD_C_COMMON_PRO = protobuf.Descriptor();

CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.name = "cbIsBet"
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.full_name = ".doudizhu.c2s.CMD_C_VoucherBetting_Pro.cbIsBet"
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.number = 1
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.index = 0
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.label = 2
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.has_default_value = false
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.default_value = 0
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.type = 5
CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD.cpp_type = 1

CMD_C_VOUCHERBETTING_PRO.name = "CMD_C_VoucherBetting_Pro"
CMD_C_VOUCHERBETTING_PRO.full_name = ".doudizhu.c2s.CMD_C_VoucherBetting_Pro"
CMD_C_VOUCHERBETTING_PRO.nested_types = {}
CMD_C_VOUCHERBETTING_PRO.enum_types = {}
CMD_C_VOUCHERBETTING_PRO.fields = {CMD_C_VOUCHERBETTING_PRO_CBISBET_FIELD}
CMD_C_VOUCHERBETTING_PRO.is_extendable = false
CMD_C_VOUCHERBETTING_PRO.extensions = {}
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.name = "cbCallScore"
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.full_name = ".doudizhu.c2s.CMD_C_CallScore_Pro.cbCallScore"
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.number = 1
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.index = 0
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.label = 2
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.has_default_value = false
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.default_value = 0
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.type = 5
CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD.cpp_type = 1

CMD_C_CALLSCORE_PRO.name = "CMD_C_CallScore_Pro"
CMD_C_CALLSCORE_PRO.full_name = ".doudizhu.c2s.CMD_C_CallScore_Pro"
CMD_C_CALLSCORE_PRO.nested_types = {}
CMD_C_CALLSCORE_PRO.enum_types = {}
CMD_C_CALLSCORE_PRO.fields = {CMD_C_CALLSCORE_PRO_CBCALLSCORE_FIELD}
CMD_C_CALLSCORE_PRO.is_extendable = false
CMD_C_CALLSCORE_PRO.extensions = {}
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.name = "cbCardCount"
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.full_name = ".doudizhu.c2s.CMD_C_OutCard_Pro.cbCardCount"
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.number = 1
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.index = 0
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.label = 2
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.has_default_value = false
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.default_value = 0
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.type = 5
CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD.cpp_type = 1

CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.name = "cbCardData"
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.full_name = ".doudizhu.c2s.CMD_C_OutCard_Pro.cbCardData"
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.number = 2
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.index = 1
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.label = 3
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.has_default_value = false
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.default_value = {}
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.type = 5
CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD.cpp_type = 1

CMD_C_OUTCARD_PRO.name = "CMD_C_OutCard_Pro"
CMD_C_OUTCARD_PRO.full_name = ".doudizhu.c2s.CMD_C_OutCard_Pro"
CMD_C_OUTCARD_PRO.nested_types = {}
CMD_C_OUTCARD_PRO.enum_types = {}
CMD_C_OUTCARD_PRO.fields = {CMD_C_OUTCARD_PRO_CBCARDCOUNT_FIELD, CMD_C_OUTCARD_PRO_CBCARDDATA_FIELD}
CMD_C_OUTCARD_PRO.is_extendable = false
CMD_C_OUTCARD_PRO.extensions = {}
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.name = "bTuoGuan"
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.full_name = ".doudizhu.c2s.CMD_C_TuoGuan_Pro.bTuoGuan"
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.number = 1
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.index = 0
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.label = 2
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.has_default_value = false
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.default_value = 0
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.type = 5
CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD.cpp_type = 1

CMD_C_TUOGUAN_PRO.name = "CMD_C_TuoGuan_Pro"
CMD_C_TUOGUAN_PRO.full_name = ".doudizhu.c2s.CMD_C_TuoGuan_Pro"
CMD_C_TUOGUAN_PRO.nested_types = {}
CMD_C_TUOGUAN_PRO.enum_types = {}
CMD_C_TUOGUAN_PRO.fields = {CMD_C_TUOGUAN_PRO_BTUOGUAN_FIELD}
CMD_C_TUOGUAN_PRO.is_extendable = false
CMD_C_TUOGUAN_PRO.extensions = {}
CMD_C_COMMON_PRO.name = "CMD_C_Common_Pro"
CMD_C_COMMON_PRO.full_name = ".doudizhu.c2s.CMD_C_Common_Pro"
CMD_C_COMMON_PRO.nested_types = {}
CMD_C_COMMON_PRO.enum_types = {}
CMD_C_COMMON_PRO.fields = {}
CMD_C_COMMON_PRO.is_extendable = false
CMD_C_COMMON_PRO.extensions = {}

CMD_C_CallScore_Pro = protobuf.Message(CMD_C_CALLSCORE_PRO)
CMD_C_Common_Pro = protobuf.Message(CMD_C_COMMON_PRO)
CMD_C_OutCard_Pro = protobuf.Message(CMD_C_OUTCARD_PRO)
CMD_C_TuoGuan_Pro = protobuf.Message(CMD_C_TUOGUAN_PRO)
CMD_C_VoucherBetting_Pro = protobuf.Message(CMD_C_VOUCHERBETTING_PRO)
