-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.gameServer.gameServer.misc.s2c_pb')


USERSCORE = protobuf.Descriptor();
local USERSCORE_USERID_FIELD = protobuf.FieldDescriptor();
local USERSCORE_SCORE_FIELD = protobuf.FieldDescriptor();
local USERSCORE_INSURE_FIELD = protobuf.FieldDescriptor();
local USERSCORE_GRADE_FIELD = protobuf.FieldDescriptor();
local USERSCORE_MEDAL_FIELD = protobuf.FieldDescriptor();
local USERSCORE_GIFT_FIELD = protobuf.FieldDescriptor();
local USERSCORE_PRESENT_FIELD = protobuf.FieldDescriptor();
local USERSCORE_EXPERIENCE_FIELD = protobuf.FieldDescriptor();
local USERSCORE_LOVELINESS_FIELD = protobuf.FieldDescriptor();
local USERSCORE_WINCOUNT_FIELD = protobuf.FieldDescriptor();
local USERSCORE_LOSTCOUNT_FIELD = protobuf.FieldDescriptor();
local USERSCORE_DRAWCOUNT_FIELD = protobuf.FieldDescriptor();
local USERSCORE_FLEECOUNT_FIELD = protobuf.FieldDescriptor();
PAYMENTNOTIFY = protobuf.Descriptor();
local PAYMENTNOTIFY_ORDERID_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_CURRENCYTYPE_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_PAYID_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_SCORE_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_MEMBERORDER_FIELD = protobuf.FieldDescriptor();
local PAYMENTNOTIFY_USERRIGHT_FIELD = protobuf.FieldDescriptor();

USERSCORE_USERID_FIELD.name = "userID"
USERSCORE_USERID_FIELD.full_name = ".gameServer.misc.s2c.UserScore.userID"
USERSCORE_USERID_FIELD.number = 1
USERSCORE_USERID_FIELD.index = 0
USERSCORE_USERID_FIELD.label = 2
USERSCORE_USERID_FIELD.has_default_value = false
USERSCORE_USERID_FIELD.default_value = 0
USERSCORE_USERID_FIELD.type = 13
USERSCORE_USERID_FIELD.cpp_type = 3

USERSCORE_SCORE_FIELD.name = "score"
USERSCORE_SCORE_FIELD.full_name = ".gameServer.misc.s2c.UserScore.score"
USERSCORE_SCORE_FIELD.number = 2
USERSCORE_SCORE_FIELD.index = 1
USERSCORE_SCORE_FIELD.label = 2
USERSCORE_SCORE_FIELD.has_default_value = false
USERSCORE_SCORE_FIELD.default_value = 0
USERSCORE_SCORE_FIELD.type = 3
USERSCORE_SCORE_FIELD.cpp_type = 2

USERSCORE_INSURE_FIELD.name = "insure"
USERSCORE_INSURE_FIELD.full_name = ".gameServer.misc.s2c.UserScore.insure"
USERSCORE_INSURE_FIELD.number = 3
USERSCORE_INSURE_FIELD.index = 2
USERSCORE_INSURE_FIELD.label = 2
USERSCORE_INSURE_FIELD.has_default_value = false
USERSCORE_INSURE_FIELD.default_value = 0
USERSCORE_INSURE_FIELD.type = 3
USERSCORE_INSURE_FIELD.cpp_type = 2

USERSCORE_GRADE_FIELD.name = "grade"
USERSCORE_GRADE_FIELD.full_name = ".gameServer.misc.s2c.UserScore.grade"
USERSCORE_GRADE_FIELD.number = 4
USERSCORE_GRADE_FIELD.index = 3
USERSCORE_GRADE_FIELD.label = 2
USERSCORE_GRADE_FIELD.has_default_value = false
USERSCORE_GRADE_FIELD.default_value = 0
USERSCORE_GRADE_FIELD.type = 3
USERSCORE_GRADE_FIELD.cpp_type = 2

USERSCORE_MEDAL_FIELD.name = "medal"
USERSCORE_MEDAL_FIELD.full_name = ".gameServer.misc.s2c.UserScore.medal"
USERSCORE_MEDAL_FIELD.number = 5
USERSCORE_MEDAL_FIELD.index = 4
USERSCORE_MEDAL_FIELD.label = 2
USERSCORE_MEDAL_FIELD.has_default_value = false
USERSCORE_MEDAL_FIELD.default_value = 0
USERSCORE_MEDAL_FIELD.type = 3
USERSCORE_MEDAL_FIELD.cpp_type = 2

USERSCORE_GIFT_FIELD.name = "gift"
USERSCORE_GIFT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.gift"
USERSCORE_GIFT_FIELD.number = 6
USERSCORE_GIFT_FIELD.index = 5
USERSCORE_GIFT_FIELD.label = 2
USERSCORE_GIFT_FIELD.has_default_value = false
USERSCORE_GIFT_FIELD.default_value = 0
USERSCORE_GIFT_FIELD.type = 3
USERSCORE_GIFT_FIELD.cpp_type = 2

USERSCORE_PRESENT_FIELD.name = "present"
USERSCORE_PRESENT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.present"
USERSCORE_PRESENT_FIELD.number = 7
USERSCORE_PRESENT_FIELD.index = 6
USERSCORE_PRESENT_FIELD.label = 2
USERSCORE_PRESENT_FIELD.has_default_value = false
USERSCORE_PRESENT_FIELD.default_value = 0
USERSCORE_PRESENT_FIELD.type = 3
USERSCORE_PRESENT_FIELD.cpp_type = 2

USERSCORE_EXPERIENCE_FIELD.name = "experience"
USERSCORE_EXPERIENCE_FIELD.full_name = ".gameServer.misc.s2c.UserScore.experience"
USERSCORE_EXPERIENCE_FIELD.number = 8
USERSCORE_EXPERIENCE_FIELD.index = 7
USERSCORE_EXPERIENCE_FIELD.label = 2
USERSCORE_EXPERIENCE_FIELD.has_default_value = false
USERSCORE_EXPERIENCE_FIELD.default_value = 0
USERSCORE_EXPERIENCE_FIELD.type = 3
USERSCORE_EXPERIENCE_FIELD.cpp_type = 2

USERSCORE_LOVELINESS_FIELD.name = "loveliness"
USERSCORE_LOVELINESS_FIELD.full_name = ".gameServer.misc.s2c.UserScore.loveliness"
USERSCORE_LOVELINESS_FIELD.number = 9
USERSCORE_LOVELINESS_FIELD.index = 8
USERSCORE_LOVELINESS_FIELD.label = 2
USERSCORE_LOVELINESS_FIELD.has_default_value = false
USERSCORE_LOVELINESS_FIELD.default_value = 0
USERSCORE_LOVELINESS_FIELD.type = 3
USERSCORE_LOVELINESS_FIELD.cpp_type = 2

USERSCORE_WINCOUNT_FIELD.name = "winCount"
USERSCORE_WINCOUNT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.winCount"
USERSCORE_WINCOUNT_FIELD.number = 10
USERSCORE_WINCOUNT_FIELD.index = 9
USERSCORE_WINCOUNT_FIELD.label = 2
USERSCORE_WINCOUNT_FIELD.has_default_value = false
USERSCORE_WINCOUNT_FIELD.default_value = 0
USERSCORE_WINCOUNT_FIELD.type = 13
USERSCORE_WINCOUNT_FIELD.cpp_type = 3

USERSCORE_LOSTCOUNT_FIELD.name = "lostCount"
USERSCORE_LOSTCOUNT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.lostCount"
USERSCORE_LOSTCOUNT_FIELD.number = 11
USERSCORE_LOSTCOUNT_FIELD.index = 10
USERSCORE_LOSTCOUNT_FIELD.label = 2
USERSCORE_LOSTCOUNT_FIELD.has_default_value = false
USERSCORE_LOSTCOUNT_FIELD.default_value = 0
USERSCORE_LOSTCOUNT_FIELD.type = 13
USERSCORE_LOSTCOUNT_FIELD.cpp_type = 3

USERSCORE_DRAWCOUNT_FIELD.name = "drawCount"
USERSCORE_DRAWCOUNT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.drawCount"
USERSCORE_DRAWCOUNT_FIELD.number = 12
USERSCORE_DRAWCOUNT_FIELD.index = 11
USERSCORE_DRAWCOUNT_FIELD.label = 2
USERSCORE_DRAWCOUNT_FIELD.has_default_value = false
USERSCORE_DRAWCOUNT_FIELD.default_value = 0
USERSCORE_DRAWCOUNT_FIELD.type = 13
USERSCORE_DRAWCOUNT_FIELD.cpp_type = 3

USERSCORE_FLEECOUNT_FIELD.name = "fleeCount"
USERSCORE_FLEECOUNT_FIELD.full_name = ".gameServer.misc.s2c.UserScore.fleeCount"
USERSCORE_FLEECOUNT_FIELD.number = 13
USERSCORE_FLEECOUNT_FIELD.index = 12
USERSCORE_FLEECOUNT_FIELD.label = 2
USERSCORE_FLEECOUNT_FIELD.has_default_value = false
USERSCORE_FLEECOUNT_FIELD.default_value = 0
USERSCORE_FLEECOUNT_FIELD.type = 13
USERSCORE_FLEECOUNT_FIELD.cpp_type = 3

USERSCORE.name = "UserScore"
USERSCORE.full_name = ".gameServer.misc.s2c.UserScore"
USERSCORE.nested_types = {}
USERSCORE.enum_types = {}
USERSCORE.fields = {USERSCORE_USERID_FIELD, USERSCORE_SCORE_FIELD, USERSCORE_INSURE_FIELD, USERSCORE_GRADE_FIELD, USERSCORE_MEDAL_FIELD, USERSCORE_GIFT_FIELD, USERSCORE_PRESENT_FIELD, USERSCORE_EXPERIENCE_FIELD, USERSCORE_LOVELINESS_FIELD, USERSCORE_WINCOUNT_FIELD, USERSCORE_LOSTCOUNT_FIELD, USERSCORE_DRAWCOUNT_FIELD, USERSCORE_FLEECOUNT_FIELD}
USERSCORE.is_extendable = false
USERSCORE.extensions = {}
PAYMENTNOTIFY_ORDERID_FIELD.name = "orderID"
PAYMENTNOTIFY_ORDERID_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.orderID"
PAYMENTNOTIFY_ORDERID_FIELD.number = 1
PAYMENTNOTIFY_ORDERID_FIELD.index = 0
PAYMENTNOTIFY_ORDERID_FIELD.label = 2
PAYMENTNOTIFY_ORDERID_FIELD.has_default_value = false
PAYMENTNOTIFY_ORDERID_FIELD.default_value = ""
PAYMENTNOTIFY_ORDERID_FIELD.type = 9
PAYMENTNOTIFY_ORDERID_FIELD.cpp_type = 9

PAYMENTNOTIFY_CURRENCYTYPE_FIELD.name = "currencyType"
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.currencyType"
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.number = 2
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.index = 1
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.label = 2
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.has_default_value = false
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.default_value = ""
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.type = 9
PAYMENTNOTIFY_CURRENCYTYPE_FIELD.cpp_type = 9

PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.name = "currencyAmount"
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.currencyAmount"
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.number = 3
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.index = 2
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.label = 2
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.has_default_value = false
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.default_value = 0.0
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.type = 2
PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD.cpp_type = 6

PAYMENTNOTIFY_PAYID_FIELD.name = "payID"
PAYMENTNOTIFY_PAYID_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.payID"
PAYMENTNOTIFY_PAYID_FIELD.number = 4
PAYMENTNOTIFY_PAYID_FIELD.index = 3
PAYMENTNOTIFY_PAYID_FIELD.label = 2
PAYMENTNOTIFY_PAYID_FIELD.has_default_value = false
PAYMENTNOTIFY_PAYID_FIELD.default_value = 0
PAYMENTNOTIFY_PAYID_FIELD.type = 5
PAYMENTNOTIFY_PAYID_FIELD.cpp_type = 1

PAYMENTNOTIFY_SCORE_FIELD.name = "score"
PAYMENTNOTIFY_SCORE_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.score"
PAYMENTNOTIFY_SCORE_FIELD.number = 5
PAYMENTNOTIFY_SCORE_FIELD.index = 4
PAYMENTNOTIFY_SCORE_FIELD.label = 2
PAYMENTNOTIFY_SCORE_FIELD.has_default_value = false
PAYMENTNOTIFY_SCORE_FIELD.default_value = 0
PAYMENTNOTIFY_SCORE_FIELD.type = 5
PAYMENTNOTIFY_SCORE_FIELD.cpp_type = 1

PAYMENTNOTIFY_MEMBERORDER_FIELD.name = "memberOrder"
PAYMENTNOTIFY_MEMBERORDER_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.memberOrder"
PAYMENTNOTIFY_MEMBERORDER_FIELD.number = 6
PAYMENTNOTIFY_MEMBERORDER_FIELD.index = 5
PAYMENTNOTIFY_MEMBERORDER_FIELD.label = 2
PAYMENTNOTIFY_MEMBERORDER_FIELD.has_default_value = false
PAYMENTNOTIFY_MEMBERORDER_FIELD.default_value = 0
PAYMENTNOTIFY_MEMBERORDER_FIELD.type = 5
PAYMENTNOTIFY_MEMBERORDER_FIELD.cpp_type = 1

PAYMENTNOTIFY_USERRIGHT_FIELD.name = "userRight"
PAYMENTNOTIFY_USERRIGHT_FIELD.full_name = ".gameServer.misc.s2c.PaymentNotify.userRight"
PAYMENTNOTIFY_USERRIGHT_FIELD.number = 7
PAYMENTNOTIFY_USERRIGHT_FIELD.index = 6
PAYMENTNOTIFY_USERRIGHT_FIELD.label = 2
PAYMENTNOTIFY_USERRIGHT_FIELD.has_default_value = false
PAYMENTNOTIFY_USERRIGHT_FIELD.default_value = 0
PAYMENTNOTIFY_USERRIGHT_FIELD.type = 13
PAYMENTNOTIFY_USERRIGHT_FIELD.cpp_type = 3

PAYMENTNOTIFY.name = "PaymentNotify"
PAYMENTNOTIFY.full_name = ".gameServer.misc.s2c.PaymentNotify"
PAYMENTNOTIFY.nested_types = {}
PAYMENTNOTIFY.enum_types = {}
PAYMENTNOTIFY.fields = {PAYMENTNOTIFY_ORDERID_FIELD, PAYMENTNOTIFY_CURRENCYTYPE_FIELD, PAYMENTNOTIFY_CURRENCYAMOUNT_FIELD, PAYMENTNOTIFY_PAYID_FIELD, PAYMENTNOTIFY_SCORE_FIELD, PAYMENTNOTIFY_MEMBERORDER_FIELD, PAYMENTNOTIFY_USERRIGHT_FIELD}
PAYMENTNOTIFY.is_extendable = false
PAYMENTNOTIFY.extensions = {}

PaymentNotify = protobuf.Message(PAYMENTNOTIFY)
UserScore = protobuf.Message(USERSCORE)
