//
//  NewSocketData.cpp
//  cocos2d_libs
//
//  Created by sayuokdgd on 14-12-17.
//
//

#include "NewSocketData.h"
#import  "zlib.h"
#include "RSA.h"

//#ifndef _WIN32
//#import  "zlib.h"
//#else
////压缩文件
//#include "Compress\ZLib.h"

////链接文件
//#ifndef _DEBUG
//#pragma comment(lib,"Version")
//#pragma comment(lib,"Compress\\ZLib.lib")
//#else
//#pragma comment(lib,"Version")
//#pragma comment(lib,"Compress\\ZLibD.lib")
//#endif
//#endif



//RSA public key
//int e[] = {1,4,3,4,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5};
//int n[] = {3,1,6,0,2,8,2,4,7,3,7,8,0,6,0,3,4,7,8,9,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21};
typedef unsigned int uii;
typedef unsigned char bt;

uii bts2ui(bt* in_pBts) {
    if (!in_pBts) {
        printf("NULL == in_pBts\n");
        return 0;
    }
    uii t_uiResult = (uii)in_pBts[0] & 0xff;
    t_uiResult |= (((uii)in_pBts[1] << 8) & 0xff00);
    t_uiResult |= (((uii)in_pBts[2] << 16) & 0xff0000);
    t_uiResult |= (((uii)in_pBts[3] << 24) & 0xff000000);
    return t_uiResult;
}


//////////////////////////////////////////////////////////////////////////////////

//构造函数
NewCTCPSocketData::NewCTCPSocketData()
{
    //设置变量
    m_cbDataFlag = DK_MAPPED|DK_NEW_VERSION_EX|DK_COMPRESS|DK_ENCRYPT;
    m_wBufferSize = 0;
    m_dwSendXorKey_TCP=0x60798607;
    m_dwRecvXorKey_TCP=0x60798607;
    m_dwSendPacketCount_TCP = 0;
    m_dwRecvPacketCount_TCP = 0;
    memset(m_cbDataBuffer,0,sizeof(m_cbDataBuffer));
    return;
}

//析构函数
NewCTCPSocketData::~NewCTCPSocketData()
{
}

bool NewCTCPSocketData::init()
{
    retain();
    return true;
}

void NewCTCPSocketData::clearSocketData()
{
    //设置变量
    m_cbDataFlag = DK_MAPPED|DK_NEW_VERSION_EX|DK_COMPRESS|DK_ENCRYPT;
    m_wBufferSize = 0;
    m_dwSendXorKey_TCP=0x60798607;
    m_dwRecvXorKey_TCP=0x60798607;
    m_dwSendPacketCount_TCP = 0;
    m_dwRecvPacketCount_TCP = 0;
    memset(m_cbDataBuffer,0,sizeof(m_cbDataBuffer));
}

//设置数据
#if CC_LUA_ENGINE_ENABLED > 0
bool NewCTCPSocketData::SetBufferDataLua(LUA_FUNCTION listener,unsigned char * pcbBuffer, unsigned short wBufferSize)
{
    m_wBufferSize = wBufferSize;
    memcpy(m_cbDataBuffer, pcbBuffer, wBufferSize);
    
    //映射数据
    if (UnMappedBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }

    // 解析头
    Byte b1Temp = m_cbDataBuffer[3];
    unsigned int b1Temp32 = (unsigned int)b1Temp;
    unsigned int b1TempMove = (unsigned int)(b1Temp32 << 16);
    unsigned int bt1 =(unsigned int) (b1TempMove & 0x00FF0000);
    
    Byte b2Temp = m_cbDataBuffer[4];
    unsigned int b2Temp32 = (unsigned int)b2Temp;
    unsigned int b2TempMove = (unsigned int)(b2Temp32 << 8);
    unsigned short bt2 =(unsigned short) (b2TempMove & 0xFF00);
    
    Byte bt3 = m_cbDataBuffer[5];
    unsigned int cmd = bt1+bt2+bt3;
    
    //    unsigned int cmd = (unsigned int)pcbBuffer[5] & 0xff;
    //    cmd |= (((unsigned int)pcbBuffer[4] << 8) & 0xff00);
    //    cmd |= (((unsigned int)pcbBuffer[3] << 16) & 0xff0000);
    
    //    unsigned int cmd = (unsigned int)pcbBuffer[3] << 16 & 0x00ff0000;
    //    cmd |= (((unsigned int)pcbBuffer[4] << 8) & 0xff00);
    //    cmd |= (((unsigned int)pcbBuffer[5]) & 0xff);
    
    //设置数据
    if (listener)
    {
        void *buff = m_cbDataBuffer + 6;
        
        LuaStack *stack = LuaEngine::getInstance()->getLuaStack();
        stack->clean();
        stack->pushInt(cmd);
        stack->pushInt(0);
        stack->pushString((const char *)buff, m_wBufferSize - 6);
        stack->executeFunctionByHandler(listener, 3);
    }
    return true;
}
#endif


bool NewCTCPSocketData::InitSocketData(unsigned int wMainCmdID, unsigned int wSubCmdID, unsigned char * pData, unsigned short wDataSize)
{
    //效验大小
    ASSERT(wDataSize<=SOCKET_TCP_PACKET);
    if (wDataSize>(SOCKET_TCP_BUFFER-6)) return false; //超出缓冲上限
    
    Byte b1 = (Byte)((unsigned short)(wDataSize+4) >> 8 & 0X00FF);
    Byte b2 = (Byte)((unsigned short)(wDataSize+4) & 0X00FF);
    Byte b3 = (Byte)(wMainCmdID >> 16 & 0X00FF);
    Byte b4 = (Byte)(wMainCmdID >>8  & 0X00FF);
    Byte b5 = (Byte)(wMainCmdID & 0X00FF);
    
    m_cbDataBuffer[0] = b1;
    m_cbDataBuffer[1] = b2;
    m_cbDataBuffer[2] = 0;
    m_cbDataBuffer[3] = b3;
    m_cbDataBuffer[4] = b4;
    m_cbDataBuffer[5] = b5;
    
    //设置数据
    if (wDataSize > 0)
    {
        m_wBufferSize = 6 + wDataSize;
        memcpy(m_cbDataBuffer + 6, pData , wDataSize);
    }
    else
    {
        m_wBufferSize = 6;
    }
    
    //映射数据
    if (MappedBuffer() == false)
    {
        ASSERT(FALSE);
        return false;
    }

    return true;
}

unsigned char *NewCTCPSocketData::GetDataBuffer()
{
    unsigned char *buff = (unsigned char *)malloc(m_wBufferSize);
    memcpy(buff, m_cbDataBuffer, m_wBufferSize);
    return buff;
}

#if CC_LUA_ENGINE_ENABLED > 0
LUA_STRING NewCTCPSocketData::GetDataBufferLua()
{
    LuaStack *stack = LuaEngine::getInstance()->getLuaStack();
    stack->clean();
    stack->pushString((char *)m_cbDataBuffer, (int)m_wBufferSize);
    
//    unsigned char* ret = cobj->GetDataBuffer();
//    unsigned short size = cobj->GetBufferSize();
//    lua_settop(tolua_S, 0);
//    lua_pushlstring(tolua_S, (const char *)ret, size);
    return 1;
}
#endif

unsigned short NewCTCPSocketData::GetBufferSize()
{
    return m_wBufferSize;
}

//映射数据
bool NewCTCPSocketData::MappedBuffer()
{
    // 变量定义
    short cbCheckCode = 0;
    // 字节映射
    for (unsigned short i = 3; i < m_wBufferSize; i++) {
        short data = m_cbDataBuffer[i];
        data &= 0x00FF;
        cbCheckCode += data;
        cbCheckCode &= 0x00FF;
        m_cbDataBuffer[i] = g_NewSendByteMap[data];
    }

    m_cbDataBuffer[2] = ((Byte)cbCheckCode);
    return true;

}

//映射数据
bool NewCTCPSocketData::UnMappedBuffer()
{
    // 效验参数
    if (m_wBufferSize < 6) {
        return false;
    }
    // 变量定义
    short cbCheckCode = 0;
    // 字节映射
    for (int i = 3; i < m_wBufferSize; i++) {
        short data = m_cbDataBuffer[i];
        data &= 0x00FF;
        m_cbDataBuffer[i] = g_NewRecvByteMap[data];
        data = m_cbDataBuffer[i];
        cbCheckCode += data;
        cbCheckCode &= 0x00FF;
        
    }
    Byte code = m_cbDataBuffer[2];
    if(code!=cbCheckCode)
    {
        return false;
    }
    return true;

}







