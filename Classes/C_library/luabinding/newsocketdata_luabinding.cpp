/*
** Lua binding: socketdata_luabinding
** Generated automatically by tolua++-1.0.92 on Wed Jan 14 10:18:06 2015.
*/

#include "newsocketdata_luabinding.h"
#include "CCLuaEngine.h"

using namespace cocos2d;




#include "NewSocketData.h"

/* function to release collected object via destructor */
#ifdef __cplusplus


#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"NewCTCPSocketData");
 tolua_usertype(tolua_S,"Ref");
 
 
}

/* method: create of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_create00
static int tolua_socketdata_luabinding_NewCTCPSocketData_create00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   NewCTCPSocketData* tolua_ret = (NewCTCPSocketData*)  NewCTCPSocketData::create();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"NewCTCPSocketData");
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetDataFlag of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_GetDataFlag00
static int tolua_socketdata_luabinding_NewCTCPSocketData_GetDataFlag00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetDataFlag'", NULL);
#endif
  {
   unsigned char tolua_ret = (unsigned char)  self->GetDataFlag();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetDataFlag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: SetDataFlag of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_SetDataFlag00
static int tolua_socketdata_luabinding_NewCTCPSocketData_SetDataFlag00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
  unsigned char cbDataFlag = ((unsigned char)  tolua_tonumber(tolua_S,2,0));
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'SetDataFlag'", NULL);
#endif
  {
   self->SetDataFlag(cbDataFlag);
  }
 }
 return 0;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'SetDataFlag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetDataBufferLua of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_GetDataBuffer00
static int tolua_socketdata_luabinding_NewCTCPSocketData_GetDataBuffer00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetDataBufferLua'", NULL);
#endif
  {
     self->GetDataBufferLua();
   
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetDataBuffer'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetBufferSize of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_GetBufferSize00
static int tolua_socketdata_luabinding_NewCTCPSocketData_GetBufferSize00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetBufferSize'", NULL);
#endif
  {
   unsigned short tolua_ret = (unsigned short)  self->GetBufferSize();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetBufferSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: clearSocketData of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_clearSocketData00
static int tolua_socketdata_luabinding_NewCTCPSocketData_clearSocketData00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'clearSocketData'", NULL);
#endif
  {
   self->clearSocketData();
  }
 }
 return 0;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'clearSocketData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: SetBufferDataLua of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_SetBufferData00
static int tolua_socketdata_luabinding_NewCTCPSocketData_SetBufferData00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION listener = (  toluafix_ref_function(tolua_S,2,0));
  unsigned char* pcbBuffer = ((unsigned char*)  tolua_tostring(tolua_S,3,0));
  unsigned short wBufferSize = ((unsigned short)  tolua_tonumber(tolua_S,4,0));
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'SetBufferDataLua'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->SetBufferDataLua(listener,pcbBuffer,wBufferSize);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'SetBufferData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: InitSocketData of class  NewCTCPSocketData */
#ifndef TOLUA_DISABLE_tolua_socketdata_luabinding_NewCTCPSocketData_InitSocketData00
static int tolua_socketdata_luabinding_NewCTCPSocketData_InitSocketData00(lua_State* tolua_S)
{
#if COCOS2D_DEBUG >= 1
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"NewCTCPSocketData",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  NewCTCPSocketData* self = (NewCTCPSocketData*)  tolua_tousertype(tolua_S,1,0);
  unsigned int wMainCmdID = ((unsigned int)  tolua_tonumber(tolua_S,2,0));
  unsigned int wSubCmdID = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
  unsigned char* pData = ((unsigned char*)  tolua_tostring(tolua_S,4,0));
  unsigned short wDataSize = ((unsigned short)  tolua_tonumber(tolua_S,5,0));
#if COCOS2D_DEBUG >= 1
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'InitSocketData'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->InitSocketData(wMainCmdID,wSubCmdID,pData,wDataSize);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#if COCOS2D_DEBUG >= 1
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'InitSocketData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_newsocketdata_luabinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"NewCTCPSocketData","NewCTCPSocketData","Ref",NULL);
  tolua_beginmodule(tolua_S,"NewCTCPSocketData");
   tolua_function(tolua_S,"create",tolua_socketdata_luabinding_NewCTCPSocketData_create00);
   tolua_function(tolua_S,"GetDataFlag",tolua_socketdata_luabinding_NewCTCPSocketData_GetDataFlag00);
   tolua_function(tolua_S,"SetDataFlag",tolua_socketdata_luabinding_NewCTCPSocketData_SetDataFlag00);
   tolua_function(tolua_S,"GetDataBuffer",tolua_socketdata_luabinding_NewCTCPSocketData_GetDataBuffer00);
   tolua_function(tolua_S,"GetBufferSize",tolua_socketdata_luabinding_NewCTCPSocketData_GetBufferSize00);
   tolua_function(tolua_S,"clearSocketData",tolua_socketdata_luabinding_NewCTCPSocketData_clearSocketData00);
   tolua_function(tolua_S,"SetBufferData",tolua_socketdata_luabinding_NewCTCPSocketData_SetBufferData00);
   tolua_function(tolua_S,"InitSocketData",tolua_socketdata_luabinding_NewCTCPSocketData_InitSocketData00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_newsocketdata_luabinding (lua_State* tolua_S) {
 return tolua_newsocketdata_luabinding_open(tolua_S);
};
#endif

