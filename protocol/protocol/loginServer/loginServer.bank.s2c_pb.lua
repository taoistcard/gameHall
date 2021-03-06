-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.loginServer.loginServer.bank.s2c_pb')


local BANKRETCODE = protobuf.EnumDescriptor();
local BANKRETCODE_RC_OK_ENUM = protobuf.EnumValueDescriptor();
local BANKRETCODE_RC_STILL_IN_GAME_ENUM = protobuf.EnumValueDescriptor();
local BANKRETCODE_RC_BANK_PREREQUISITE_ENUM = protobuf.EnumValueDescriptor();
local BANKRETCODE_RC_NO_SCORE_INFO_RECORD_ENUM = protobuf.EnumValueDescriptor();
local BANKRETCODE_RC_NOT_ENOUGH_MONEY_ENUM = protobuf.EnumValueDescriptor();
DEPOSIT = protobuf.Descriptor();
local DEPOSIT_CODE_FIELD = protobuf.FieldDescriptor();
local DEPOSIT_MSG_FIELD = protobuf.FieldDescriptor();
local DEPOSIT_SCORE_FIELD = protobuf.FieldDescriptor();
local DEPOSIT_INSURE_FIELD = protobuf.FieldDescriptor();
WITHDRAW = protobuf.Descriptor();
local WITHDRAW_CODE_FIELD = protobuf.FieldDescriptor();
local WITHDRAW_MSG_FIELD = protobuf.FieldDescriptor();
local WITHDRAW_SCORE_FIELD = protobuf.FieldDescriptor();
local WITHDRAW_INSURE_FIELD = protobuf.FieldDescriptor();
QUERY = protobuf.Descriptor();
local QUERY_CODE_FIELD = protobuf.FieldDescriptor();
local QUERY_MSG_FIELD = protobuf.FieldDescriptor();
local QUERY_SCORE_FIELD = protobuf.FieldDescriptor();
local QUERY_INSURE_FIELD = protobuf.FieldDescriptor();

BANKRETCODE_RC_OK_ENUM.name = "RC_OK"
BANKRETCODE_RC_OK_ENUM.index = 0
BANKRETCODE_RC_OK_ENUM.number = 1
BANKRETCODE_RC_STILL_IN_GAME_ENUM.name = "RC_STILL_IN_GAME"
BANKRETCODE_RC_STILL_IN_GAME_ENUM.index = 1
BANKRETCODE_RC_STILL_IN_GAME_ENUM.number = 2
BANKRETCODE_RC_BANK_PREREQUISITE_ENUM.name = "RC_BANK_PREREQUISITE"
BANKRETCODE_RC_BANK_PREREQUISITE_ENUM.index = 2
BANKRETCODE_RC_BANK_PREREQUISITE_ENUM.number = 3
BANKRETCODE_RC_NO_SCORE_INFO_RECORD_ENUM.name = "RC_NO_SCORE_INFO_RECORD"
BANKRETCODE_RC_NO_SCORE_INFO_RECORD_ENUM.index = 3
BANKRETCODE_RC_NO_SCORE_INFO_RECORD_ENUM.number = 4
BANKRETCODE_RC_NOT_ENOUGH_MONEY_ENUM.name = "RC_NOT_ENOUGH_MONEY"
BANKRETCODE_RC_NOT_ENOUGH_MONEY_ENUM.index = 4
BANKRETCODE_RC_NOT_ENOUGH_MONEY_ENUM.number = 5
BANKRETCODE.name = "BankRetCode"
BANKRETCODE.full_name = ".loginServer.bank.s2c.BankRetCode"
BANKRETCODE.values = {BANKRETCODE_RC_OK_ENUM,BANKRETCODE_RC_STILL_IN_GAME_ENUM,BANKRETCODE_RC_BANK_PREREQUISITE_ENUM,BANKRETCODE_RC_NO_SCORE_INFO_RECORD_ENUM,BANKRETCODE_RC_NOT_ENOUGH_MONEY_ENUM}
DEPOSIT_CODE_FIELD.name = "code"
DEPOSIT_CODE_FIELD.full_name = ".loginServer.bank.s2c.Deposit.code"
DEPOSIT_CODE_FIELD.number = 1
DEPOSIT_CODE_FIELD.index = 0
DEPOSIT_CODE_FIELD.label = 2
DEPOSIT_CODE_FIELD.has_default_value = false
DEPOSIT_CODE_FIELD.default_value = nil
DEPOSIT_CODE_FIELD.enum_type = BANKRETCODE
DEPOSIT_CODE_FIELD.type = 14
DEPOSIT_CODE_FIELD.cpp_type = 8

DEPOSIT_MSG_FIELD.name = "msg"
DEPOSIT_MSG_FIELD.full_name = ".loginServer.bank.s2c.Deposit.msg"
DEPOSIT_MSG_FIELD.number = 2
DEPOSIT_MSG_FIELD.index = 1
DEPOSIT_MSG_FIELD.label = 1
DEPOSIT_MSG_FIELD.has_default_value = false
DEPOSIT_MSG_FIELD.default_value = ""
DEPOSIT_MSG_FIELD.type = 9
DEPOSIT_MSG_FIELD.cpp_type = 9

DEPOSIT_SCORE_FIELD.name = "score"
DEPOSIT_SCORE_FIELD.full_name = ".loginServer.bank.s2c.Deposit.score"
DEPOSIT_SCORE_FIELD.number = 3
DEPOSIT_SCORE_FIELD.index = 2
DEPOSIT_SCORE_FIELD.label = 1
DEPOSIT_SCORE_FIELD.has_default_value = false
DEPOSIT_SCORE_FIELD.default_value = 0
DEPOSIT_SCORE_FIELD.type = 3
DEPOSIT_SCORE_FIELD.cpp_type = 2

DEPOSIT_INSURE_FIELD.name = "insure"
DEPOSIT_INSURE_FIELD.full_name = ".loginServer.bank.s2c.Deposit.insure"
DEPOSIT_INSURE_FIELD.number = 4
DEPOSIT_INSURE_FIELD.index = 3
DEPOSIT_INSURE_FIELD.label = 1
DEPOSIT_INSURE_FIELD.has_default_value = false
DEPOSIT_INSURE_FIELD.default_value = 0
DEPOSIT_INSURE_FIELD.type = 3
DEPOSIT_INSURE_FIELD.cpp_type = 2

DEPOSIT.name = "Deposit"
DEPOSIT.full_name = ".loginServer.bank.s2c.Deposit"
DEPOSIT.nested_types = {}
DEPOSIT.enum_types = {}
DEPOSIT.fields = {DEPOSIT_CODE_FIELD, DEPOSIT_MSG_FIELD, DEPOSIT_SCORE_FIELD, DEPOSIT_INSURE_FIELD}
DEPOSIT.is_extendable = false
DEPOSIT.extensions = {}
WITHDRAW_CODE_FIELD.name = "code"
WITHDRAW_CODE_FIELD.full_name = ".loginServer.bank.s2c.Withdraw.code"
WITHDRAW_CODE_FIELD.number = 1
WITHDRAW_CODE_FIELD.index = 0
WITHDRAW_CODE_FIELD.label = 2
WITHDRAW_CODE_FIELD.has_default_value = false
WITHDRAW_CODE_FIELD.default_value = nil
WITHDRAW_CODE_FIELD.enum_type = BANKRETCODE
WITHDRAW_CODE_FIELD.type = 14
WITHDRAW_CODE_FIELD.cpp_type = 8

WITHDRAW_MSG_FIELD.name = "msg"
WITHDRAW_MSG_FIELD.full_name = ".loginServer.bank.s2c.Withdraw.msg"
WITHDRAW_MSG_FIELD.number = 2
WITHDRAW_MSG_FIELD.index = 1
WITHDRAW_MSG_FIELD.label = 1
WITHDRAW_MSG_FIELD.has_default_value = false
WITHDRAW_MSG_FIELD.default_value = ""
WITHDRAW_MSG_FIELD.type = 9
WITHDRAW_MSG_FIELD.cpp_type = 9

WITHDRAW_SCORE_FIELD.name = "score"
WITHDRAW_SCORE_FIELD.full_name = ".loginServer.bank.s2c.Withdraw.score"
WITHDRAW_SCORE_FIELD.number = 3
WITHDRAW_SCORE_FIELD.index = 2
WITHDRAW_SCORE_FIELD.label = 1
WITHDRAW_SCORE_FIELD.has_default_value = false
WITHDRAW_SCORE_FIELD.default_value = 0
WITHDRAW_SCORE_FIELD.type = 3
WITHDRAW_SCORE_FIELD.cpp_type = 2

WITHDRAW_INSURE_FIELD.name = "insure"
WITHDRAW_INSURE_FIELD.full_name = ".loginServer.bank.s2c.Withdraw.insure"
WITHDRAW_INSURE_FIELD.number = 4
WITHDRAW_INSURE_FIELD.index = 3
WITHDRAW_INSURE_FIELD.label = 1
WITHDRAW_INSURE_FIELD.has_default_value = false
WITHDRAW_INSURE_FIELD.default_value = 0
WITHDRAW_INSURE_FIELD.type = 3
WITHDRAW_INSURE_FIELD.cpp_type = 2

WITHDRAW.name = "Withdraw"
WITHDRAW.full_name = ".loginServer.bank.s2c.Withdraw"
WITHDRAW.nested_types = {}
WITHDRAW.enum_types = {}
WITHDRAW.fields = {WITHDRAW_CODE_FIELD, WITHDRAW_MSG_FIELD, WITHDRAW_SCORE_FIELD, WITHDRAW_INSURE_FIELD}
WITHDRAW.is_extendable = false
WITHDRAW.extensions = {}
QUERY_CODE_FIELD.name = "code"
QUERY_CODE_FIELD.full_name = ".loginServer.bank.s2c.Query.code"
QUERY_CODE_FIELD.number = 1
QUERY_CODE_FIELD.index = 0
QUERY_CODE_FIELD.label = 2
QUERY_CODE_FIELD.has_default_value = false
QUERY_CODE_FIELD.default_value = nil
QUERY_CODE_FIELD.enum_type = BANKRETCODE
QUERY_CODE_FIELD.type = 14
QUERY_CODE_FIELD.cpp_type = 8

QUERY_MSG_FIELD.name = "msg"
QUERY_MSG_FIELD.full_name = ".loginServer.bank.s2c.Query.msg"
QUERY_MSG_FIELD.number = 2
QUERY_MSG_FIELD.index = 1
QUERY_MSG_FIELD.label = 1
QUERY_MSG_FIELD.has_default_value = false
QUERY_MSG_FIELD.default_value = ""
QUERY_MSG_FIELD.type = 9
QUERY_MSG_FIELD.cpp_type = 9

QUERY_SCORE_FIELD.name = "score"
QUERY_SCORE_FIELD.full_name = ".loginServer.bank.s2c.Query.score"
QUERY_SCORE_FIELD.number = 3
QUERY_SCORE_FIELD.index = 2
QUERY_SCORE_FIELD.label = 1
QUERY_SCORE_FIELD.has_default_value = false
QUERY_SCORE_FIELD.default_value = 0
QUERY_SCORE_FIELD.type = 3
QUERY_SCORE_FIELD.cpp_type = 2

QUERY_INSURE_FIELD.name = "insure"
QUERY_INSURE_FIELD.full_name = ".loginServer.bank.s2c.Query.insure"
QUERY_INSURE_FIELD.number = 4
QUERY_INSURE_FIELD.index = 3
QUERY_INSURE_FIELD.label = 1
QUERY_INSURE_FIELD.has_default_value = false
QUERY_INSURE_FIELD.default_value = 0
QUERY_INSURE_FIELD.type = 3
QUERY_INSURE_FIELD.cpp_type = 2

QUERY.name = "Query"
QUERY.full_name = ".loginServer.bank.s2c.Query"
QUERY.nested_types = {}
QUERY.enum_types = {}
QUERY.fields = {QUERY_CODE_FIELD, QUERY_MSG_FIELD, QUERY_SCORE_FIELD, QUERY_INSURE_FIELD}
QUERY.is_extendable = false
QUERY.extensions = {}

Deposit = protobuf.Message(DEPOSIT)
Query = protobuf.Message(QUERY)
RC_BANK_PREREQUISITE = 3
RC_NOT_ENOUGH_MONEY = 5
RC_NO_SCORE_INFO_RECORD = 4
RC_OK = 1
RC_STILL_IN_GAME = 2
Withdraw = protobuf.Message(WITHDRAW)

