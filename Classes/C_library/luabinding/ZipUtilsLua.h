
#ifndef __LUA_ZIPUTIL_H_
#define __LUA_ZIPUTIL_H_

extern "C" {
#include "lua.h"
#include "tolua++.h"
}
#include "tolua_fix.h"

int tolua_ZipUtils_open(lua_State *L);

#endif