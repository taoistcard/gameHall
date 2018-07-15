-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.gameServer.gameServer.login.c2s_pb')


LOGIN = protobuf.Descriptor();
local LOGIN_SESSION_FIELD = protobuf.FieldDescriptor();
local LOGIN_MACHINEID_FIELD = protobuf.FieldDescriptor();
local LOGIN_BEHAVIORFLAGS_FIELD = protobuf.FieldDescriptor();
local LOGIN_PAGETABLECOUNT_FIELD = protobuf.FieldDescriptor();
ANDROIDLOGIN = protobuf.Descriptor();
local ANDROIDLOGIN_USERID_FIELD = protobuf.FieldDescriptor();
local ANDROIDLOGIN_MACHINEID_FIELD = protobuf.FieldDescriptor();
local ANDROIDLOGIN_BEHAVIORFLAGS_FIELD = protobuf.FieldDescriptor();
local ANDROIDLOGIN_PAGETABLECOUNT_FIELD = protobuf.FieldDescriptor();
LOGOUT = protobuf.Descriptor();

LOGIN_SESSION_FIELD.name = "session"
LOGIN_SESSION_FIELD.full_name = ".gameServer.login.c2s.Login.session"
LOGIN_SESSION_FIELD.number = 1
LOGIN_SESSION_FIELD.index = 0
LOGIN_SESSION_FIELD.label = 2
LOGIN_SESSION_FIELD.has_default_value = false
LOGIN_SESSION_FIELD.default_value = ""
LOGIN_SESSION_FIELD.type = 9
LOGIN_SESSION_FIELD.cpp_type = 9

LOGIN_MACHINEID_FIELD.name = "machineID"
LOGIN_MACHINEID_FIELD.full_name = ".gameServer.login.c2s.Login.machineID"
LOGIN_MACHINEID_FIELD.number = 2
LOGIN_MACHINEID_FIELD.index = 1
LOGIN_MACHINEID_FIELD.label = 2
LOGIN_MACHINEID_FIELD.has_default_value = false
LOGIN_MACHINEID_FIELD.default_value = ""
LOGIN_MACHINEID_FIELD.type = 9
LOGIN_MACHINEID_FIELD.cpp_type = 9

LOGIN_BEHAVIORFLAGS_FIELD.name = "behaviorFlags"
LOGIN_BEHAVIORFLAGS_FIELD.full_name = ".gameServer.login.c2s.Login.behaviorFlags"
LOGIN_BEHAVIORFLAGS_FIELD.number = 3
LOGIN_BEHAVIORFLAGS_FIELD.index = 2
LOGIN_BEHAVIORFLAGS_FIELD.label = 2
LOGIN_BEHAVIORFLAGS_FIELD.has_default_value = false
LOGIN_BEHAVIORFLAGS_FIELD.default_value = 0
LOGIN_BEHAVIORFLAGS_FIELD.type = 13
LOGIN_BEHAVIORFLAGS_FIELD.cpp_type = 3

LOGIN_PAGETABLECOUNT_FIELD.name = "pageTableCount"
LOGIN_PAGETABLECOUNT_FIELD.full_name = ".gameServer.login.c2s.Login.pageTableCount"
LOGIN_PAGETABLECOUNT_FIELD.number = 4
LOGIN_PAGETABLECOUNT_FIELD.index = 3
LOGIN_PAGETABLECOUNT_FIELD.label = 2
LOGIN_PAGETABLECOUNT_FIELD.has_default_value = false
LOGIN_PAGETABLECOUNT_FIELD.default_value = 0
LOGIN_PAGETABLECOUNT_FIELD.type = 13
LOGIN_PAGETABLECOUNT_FIELD.cpp_type = 3

LOGIN.name = "Login"
LOGIN.full_name = ".gameServer.login.c2s.Login"
LOGIN.nested_types = {}
LOGIN.enum_types = {}
LOGIN.fields = {LOGIN_SESSION_FIELD, LOGIN_MACHINEID_FIELD, LOGIN_BEHAVIORFLAGS_FIELD, LOGIN_PAGETABLECOUNT_FIELD}
LOGIN.is_extendable = false
LOGIN.extensions = {}
ANDROIDLOGIN_USERID_FIELD.name = "userID"
ANDROIDLOGIN_USERID_FIELD.full_name = ".gameServer.login.c2s.AndroidLogin.userID"
ANDROIDLOGIN_USERID_FIELD.number = 1
ANDROIDLOGIN_USERID_FIELD.index = 0
ANDROIDLOGIN_USERID_FIELD.label = 2
ANDROIDLOGIN_USERID_FIELD.has_default_value = false
ANDROIDLOGIN_USERID_FIELD.default_value = 0
ANDROIDLOGIN_USERID_FIELD.type = 13
ANDROIDLOGIN_USERID_FIELD.cpp_type = 3

ANDROIDLOGIN_MACHINEID_FIELD.name = "machineID"
ANDROIDLOGIN_MACHINEID_FIELD.full_name = ".gameServer.login.c2s.AndroidLogin.machineID"
ANDROIDLOGIN_MACHINEID_FIELD.number = 2
ANDROIDLOGIN_MACHINEID_FIELD.index = 1
ANDROIDLOGIN_MACHINEID_FIELD.label = 2
ANDROIDLOGIN_MACHINEID_FIELD.has_default_value = false
ANDROIDLOGIN_MACHINEID_FIELD.default_value = ""
ANDROIDLOGIN_MACHINEID_FIELD.type = 9
ANDROIDLOGIN_MACHINEID_FIELD.cpp_type = 9

ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.name = "behaviorFlags"
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.full_name = ".gameServer.login.c2s.AndroidLogin.behaviorFlags"
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.number = 3
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.index = 2
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.label = 2
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.has_default_value = false
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.default_value = 0
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.type = 13
ANDROIDLOGIN_BEHAVIORFLAGS_FIELD.cpp_type = 3

ANDROIDLOGIN_PAGETABLECOUNT_FIELD.name = "pageTableCount"
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.full_name = ".gameServer.login.c2s.AndroidLogin.pageTableCount"
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.number = 4
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.index = 3
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.label = 2
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.has_default_value = false
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.default_value = 0
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.type = 13
ANDROIDLOGIN_PAGETABLECOUNT_FIELD.cpp_type = 3

ANDROIDLOGIN.name = "AndroidLogin"
ANDROIDLOGIN.full_name = ".gameServer.login.c2s.AndroidLogin"
ANDROIDLOGIN.nested_types = {}
ANDROIDLOGIN.enum_types = {}
ANDROIDLOGIN.fields = {ANDROIDLOGIN_USERID_FIELD, ANDROIDLOGIN_MACHINEID_FIELD, ANDROIDLOGIN_BEHAVIORFLAGS_FIELD, ANDROIDLOGIN_PAGETABLECOUNT_FIELD}
ANDROIDLOGIN.is_extendable = false
ANDROIDLOGIN.extensions = {}
LOGOUT.name = "Logout"
LOGOUT.full_name = ".gameServer.login.c2s.Logout"
LOGOUT.nested_types = {}
LOGOUT.enum_types = {}
LOGOUT.fields = {}
LOGOUT.is_extendable = false
LOGOUT.extensions = {}

AndroidLogin = protobuf.Message(ANDROIDLOGIN)
Login = protobuf.Message(LOGIN)
Logout = protobuf.Message(LOGOUT)

