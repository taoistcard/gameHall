-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('protocol.loginServer.loginServer.activity.c2s_pb')


QUERYSCOREACTIVITY = protobuf.Descriptor();
ALMS = protobuf.Descriptor();
QUERY = protobuf.Descriptor();

QUERYSCOREACTIVITY.name = "QueryScoreActivity"
QUERYSCOREACTIVITY.full_name = ".loginServer.activity.c2s.QueryScoreActivity"
QUERYSCOREACTIVITY.nested_types = {}
QUERYSCOREACTIVITY.enum_types = {}
QUERYSCOREACTIVITY.fields = {}
QUERYSCOREACTIVITY.is_extendable = false
QUERYSCOREACTIVITY.extensions = {}
ALMS.name = "Alms"
ALMS.full_name = ".loginServer.activity.c2s.Alms"
ALMS.nested_types = {}
ALMS.enum_types = {}
ALMS.fields = {}
ALMS.is_extendable = false
ALMS.extensions = {}
QUERY.name = "Query"
QUERY.full_name = ".loginServer.activity.c2s.Query"
QUERY.nested_types = {}
QUERY.enum_types = {}
QUERY.fields = {}
QUERY.is_extendable = false
QUERY.extensions = {}

Alms = protobuf.Message(ALMS)
Query = protobuf.Message(QUERY)
QueryScoreActivity = protobuf.Message(QUERYSCOREACTIVITY)
