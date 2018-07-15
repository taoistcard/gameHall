#include "LuaBasicConversions.h"
#include <string>


#include "CCLuaEngine.h"

#include "ZipUtilsLua.h"



using namespace cocos2d;

void uncompressZip(std::map<std::string, std::string> params)
{
    auto src = params["src"];
    auto dest = params["dest"];
    auto filename = params["filename"];
    auto subpath = filename.substr(0, filename.find("."));
    cocos2d::ZipUtils::uncompressDir((char*)(src+filename).c_str(), (char*)(dest+subpath+"/").c_str());
    
    //操蛋的做法，通过userdefault标识filename已经解压
    cocos2d::UserDefault::getInstance()->setBoolForKey(filename.c_str(), true);
    
}

int lua_cocos2dx_ZipUtil_uncompressDir(lua_State* tolua_S)
{
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_istable(tolua_S,1,0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        std::string  installPath = tolua_tocppstring(tolua_S, 2, "");
        std::string  downloadPath = tolua_tocppstring(tolua_S, 3, "");
        std::string  fileName = tolua_tocppstring(tolua_S, 4, "");
        printf("%s\n %s \n %s \n", installPath.c_str(), downloadPath.c_str(), fileName.c_str());

        std::map<std::string,std::string> param;
        param["src"]= installPath;
        param["dest"]= downloadPath;
        param["filename"]= fileName;
        std::thread t1(uncompressZip, param);
        t1.detach();
        
//        std::thread t1(&cocos2d::ZipUtils::uncompressDir, cocos2d::ZipUtils,
//                       (char*)std::string(fileName).c_str(),
//                       (char*)std::string(fileName2).c_str());
//        t1.join();
        
//        Scheduler *sched = Director::getInstance()->getScheduler();
//        sched->performFunctionInCocosThread([=]{
//            
//            cocos2d::ZipUtils::uncompressDir((char*)fileName.c_str(), (char*)fileName2.c_str());
//            
//
//        });

        
//        sched->performFunctionInCocosThread([&](){
//            cocos2d::ZipUtils::uncompressDir((char*)fileName.c_str(), (char*)fileName2.c_str());
//        });

        
//        
//        cocos2d::utils::captureScreen([=](bool succeed, const std::string& name ){
//            
//            tolua_pushboolean(tolua_S, succeed);
//            tolua_pushstring(tolua_S, name.c_str());
//            LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 2);
//            LuaEngine::getInstance()->removeScriptHandler(handler);
//        }, fileName);
        
        return 0;
    }
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_ZipUtil_uncompressDir'.",&tolua_err);
    return 0;
#endif
    /**/
    
    
//    
//    int argc = 0;
//    bool ok  = true;
//#if COCOS2D_DEBUG >= 1
//    tolua_Error tolua_err;
//#endif
//    
//#if COCOS2D_DEBUG >= 1
//    if (!tolua_isusertable(tolua_S,1,"cc.ZipUtils",0,&tolua_err)) goto tolua_lerror;
//#endif
//    
//    argc = lua_gettop(tolua_S)-1;
//    do
//    {
//        if (argc == 2)
//        {
//            const char* arg0;
//            std::string arg0Tmp;
//            ok &= luaval_to_std_string(tolua_S, 2,&arg0Tmp, "cc.ZipUtils:uncompressDir");
//            if (!ok) { break; }
//            arg0 = arg0Tmp.c_str();
//            
//            const char* arg1;
//            std::string arg1Tmp;
//            ok &= luaval_to_std_string(tolua_S, 3, &arg1Tmp, "cc.ZipUtils:uncompressDir");
//            if (!ok) { break; }
//            arg1 = arg1Tmp.c_str();
//            
//            bool ret = cocos2d::ZipUtils::uncompressDir((char*)arg0, (char*)arg1);
//            if (ret == true)
//                return 1;
//        }
//    } while (0);
//    ok  = true;
//    luaL_error(tolua_S, "%s has wrong number of arguments: %s, was expecting %d", "ZipUtils:uncompressDir",argc, 2);
//    return 0;
//#if COCOS2D_DEBUG >= 1
//    tolua_lerror:
//    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_ZipUtil_uncompressDir'.",&tolua_err);
//#endif
//    
    return 0;
}


int TOLUA_API luaTestFun(lua_State *L)
{
    printf("luaTestFun!!!!!!!!!!!");
    return 1;
}

int luaopen_ZipUtils(lua_State* tolua_S)
{
    
    if (nullptr == tolua_S)
        return 0;
    
    tolua_open(tolua_S);
    tolua_module(tolua_S, "cc", 0);
    tolua_beginmodule(tolua_S, "cc");
    tolua_module(tolua_S, "ZipUtils", 0);
        tolua_beginmodule(tolua_S,"ZipUtils");
        tolua_function(tolua_S, "uncompressDir", lua_cocos2dx_ZipUtil_uncompressDir);
        tolua_function(tolua_S, "test", luaTestFun);
        tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
    

    return 1;

}

int tolua_ZipUtils_open(lua_State *L)
{
    luaopen_ZipUtils(L);

	return 1;
}
