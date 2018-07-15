//
//  NewSocketData.h
//  cocos2d_libs
//
//  Created by sayuokdgd on 14-12-17.
//
//

#ifndef __cocos2d_libs__NewSocketData__
#define __cocos2d_libs__NewSocketData__

#pragma pack(1)
#define CC_LUA_ENGINE_ENABLED  1
#if CC_LUA_ENGINE_ENABLED > 0
#include "CCLuaEngine.h"
#endif

#include "Packet.h"
#include "cocos2d.h"

using namespace cocos2d;


//////////////////////////////////////////////////////////////////////////////////
class NewCTCPSocketData : public Ref
{
    //变量定义
public:
    unsigned char							m_cbDataFlag;						//数据标志
    unsigned short							m_wBufferSize;						//数据长度
    unsigned char							m_cbDataBuffer[SOCKET_TCP_BUFFER];	//数据缓存
    unsigned int						    m_dwSendXorKey_TCP;					//发送密钥
    unsigned int							m_dwRecvXorKey_TCP;					//接收密钥
    unsigned int                            m_dwSendPacketCount_TCP;            //发送计数
    unsigned int                            m_dwRecvPacketCount_TCP;            //接受计数
    
    //函数定义
public:
    NewCTCPSocketData();
    ~NewCTCPSocketData();
    bool init();
    CREATE_FUNC(NewCTCPSocketData);
    
    //配置函数
public:
    //获取标志
    unsigned char GetDataFlag() { return m_cbDataFlag; }
    //设置标志
    void SetDataFlag(unsigned char cbDataFlag) { m_cbDataFlag=cbDataFlag; }
    //获取数据
    unsigned char *GetDataBuffer();
#if CC_LUA_ENGINE_ENABLED > 0
    LUA_STRING GetDataBufferLua();
#endif
    //获取数据长度
    unsigned short GetBufferSize();
    
    //数据设置
public:
    void clearSocketData();

#if CC_LUA_ENGINE_ENABLED > 0
    bool SetBufferDataLua(LUA_FUNCTION listener,unsigned char * pcbBuffer, unsigned short wBufferSize);
#endif
    //设置数据
    bool InitSocketData(unsigned int wMainCmdID, unsigned int wSubCmdID, unsigned char * pData, unsigned short wDataSize);
    
    
    //映射数据
private:
    //映射数据
    bool MappedBuffer();
    //映射数据
    bool UnMappedBuffer();
    

    
};

//////////////////////////////////////////////////////////////////////////////////

#pragma pack()

#endif /* defined(__cocos2d_libs__NewSocketData__) */
