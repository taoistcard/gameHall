//
//  SocketData.cpp
//  cocos2d_libs
//
//  Created by sayuokdgd on 14-12-17.
//
//

#include "SocketData.h"
#import  "zlib.h"
#include "RSA.h"

#ifndef _WIN32
#import  "zlib.h"
#else
//压缩文件
#include "Compress\ZLib.h"

//链接文件
#ifndef _DEBUG
#pragma comment(lib,"Version")
#pragma comment(lib,"Compress\\ZLib.lib")
#else
#pragma comment(lib,"Version")
#pragma comment(lib,"Compress\\ZLibD.lib")
#endif
#endif



//RSA public key
int e[] = {1,4,3,4,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5};
int n[] = {3,1,6,0,2,8,2,4,7,3,7,8,0,6,0,3,4,7,8,9,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21};

//////////////////////////////////////////////////////////////////////////////////

//构造函数
CTCPSocketData::CTCPSocketData()
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
CTCPSocketData::~CTCPSocketData()
{
}

bool CTCPSocketData::init()
{
    retain();
    return true;
}

void CTCPSocketData::clearSocketData()
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
bool CTCPSocketData::SetBufferData(unsigned char * pcbBuffer, unsigned short wBufferSize, tagTCPData & TCPData)
{
    //数据效验
    ASSERT(wBufferSize>sizeof(TCP_Info)&&(wBufferSize<=SOCKET_TCP_BUFFER));
    if (wBufferSize<=sizeof(TCP_Info)||(wBufferSize>SOCKET_TCP_BUFFER)) return false;
    
    //设置数据
    m_wBufferSize=wBufferSize;
    memcpy(m_cbDataBuffer,pcbBuffer,wBufferSize);
    
    //效验数据
    ASSERT(((TCP_Info *)m_cbDataBuffer)->wPacketSize==wBufferSize);
    if (((TCP_Info *)m_cbDataBuffer)->wPacketSize!=wBufferSize) return false;
    
    //标志设置
    if (m_cbDataFlag==0)
    {
        //设置标志
        TCP_Info * pInfo=(TCP_Info *)m_cbDataBuffer;
        if ((pInfo->cbDataKind&DK_MAPPED)!=0) m_cbDataFlag|=DK_MAPPED;
        if ((pInfo->cbDataKind&DK_ENCRYPT)!=0) m_cbDataFlag|=DK_ENCRYPT;
        if ((pInfo->cbDataKind&DK_COMPRESS)!=0) m_cbDataFlag|=DK_COMPRESS;
        if ((pInfo->cbDataKind&DK_NEW_VERSION)!=0) m_cbDataFlag|=DK_NEW_VERSION;
        
        //效验标志
        ASSERT(m_cbDataFlag!=0);
        if (m_cbDataFlag==0) return false;
    }
    
    //解压数据
    if (UnCompressBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //解密数据
    if (CrevasseBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //映射数据
    if (UnMappedBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //变量定义
    TCP_Head * pHead=(TCP_Head *)m_cbDataBuffer;
    
    //设置数据
    TCPData.Command=pHead->CommandInfo;
    TCPData.wDataSize=m_wBufferSize-sizeof(TCP_Head);
    TCPData.pDataBuffer=m_cbDataBuffer+sizeof(TCP_Head);
    
    return true;
}

//设置数据
#if CC_LUA_ENGINE_ENABLED > 0
bool CTCPSocketData::SetBufferDataLua(LUA_FUNCTION listener,unsigned char * pcbBuffer, unsigned short wBufferSize)
{
    //数据效验
    ASSERT(wBufferSize>sizeof(TCP_Info)&&(wBufferSize<=SOCKET_TCP_BUFFER));
    if (wBufferSize<=sizeof(TCP_Info)||(wBufferSize>SOCKET_TCP_BUFFER)) return false;
    
    //设置数据
    m_wBufferSize=wBufferSize;
    memcpy(m_cbDataBuffer,pcbBuffer,wBufferSize);
    
    //效验数据
    ASSERT(((TCP_Info *)m_cbDataBuffer)->wPacketSize==wBufferSize);
    if (((TCP_Info *)m_cbDataBuffer)->wPacketSize!=wBufferSize) return false;
    
    //标志设置
    if (m_cbDataFlag==0)
    {
        //设置标志
        TCP_Info * pInfo=(TCP_Info *)m_cbDataBuffer;
        if ((pInfo->cbDataKind&DK_MAPPED)!=0) m_cbDataFlag|=DK_MAPPED;
        if ((pInfo->cbDataKind&DK_ENCRYPT)!=0) m_cbDataFlag|=DK_ENCRYPT;
        if ((pInfo->cbDataKind&DK_COMPRESS)!=0) m_cbDataFlag|=DK_COMPRESS;
        if ((pInfo->cbDataKind&DK_NEW_VERSION)!=0) m_cbDataFlag|=DK_NEW_VERSION;
        if ((pInfo->cbDataKind&DK_NEW_VERSION_EX)!=0) m_cbDataFlag|=DK_NEW_VERSION_EX;
        
        //效验标志
        ASSERT(m_cbDataFlag!=0);
        if (m_cbDataFlag==0) return false;
    }
    
    //解压数据
    if (UnCompressBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //解密数据
    if (CrevasseBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //映射数据
    if (UnMappedBuffer()==false)
    {
        ASSERT(FALSE);
        return false;
    }
    
    //变量定义
    TCP_Head * pHead=(TCP_Head *)m_cbDataBuffer;
    
    //设置数据
    if (listener)
    {
        void *buff = m_cbDataBuffer+sizeof(TCP_Head);
        
        LuaStack *stack = LuaEngine::getInstance()->getLuaStack();
        stack->clean();
        stack->pushInt(pHead->CommandInfo.wMainCmdID);
        stack->pushInt(pHead->CommandInfo.wSubCmdID);
        stack->pushString((const char *)buff,m_wBufferSize - sizeof(TCP_Head));
        stack->executeFunctionByHandler(listener, 3);
    }
    return true;
}
#endif


bool CTCPSocketData::InitSocketData(unsigned short wMainCmdID, unsigned short wSubCmdID, unsigned char * pData, unsigned short wDataSize)
{
    //效验大小
    ASSERT(wDataSize<=SOCKET_TCP_PACKET);
    if (wDataSize>SOCKET_TCP_PACKET) return false;
    
    //变量定义
    TCP_Head * pHead = (TCP_Head *)m_cbDataBuffer;
    
    //设置命令
    pHead->CommandInfo.wSubCmdID = wSubCmdID;
    pHead->CommandInfo.wMainCmdID = wMainCmdID;
    
    //设置包头
    pHead->TCPInfo.cbDataKind = 0;
    pHead->TCPInfo.cbCheckCode = 0;
    pHead->TCPInfo.wPacketSize = sizeof(TCP_Head)+wDataSize;
    
    //设置数据
    if (wDataSize > 0)
    {
        m_wBufferSize=sizeof(TCP_Head)+wDataSize;
        memcpy(m_cbDataBuffer+sizeof(TCP_Head),pData,wDataSize);
    }
    else
    {
        m_wBufferSize=sizeof(TCP_Head);
    }
    
    
    //映射数据
    if (((m_cbDataFlag&DK_MAPPED)!=0)&&(MappedBuffer()==false))
    {
        ASSERT(FALSE);
        return false;
    }
    
    //加密数据
    if (((m_cbDataFlag&DK_ENCRYPT)!=0)&&(EncryptBuffer()==false))
    {
        ASSERT(FALSE);
        return false;
    }
    
    //压缩数据
    if (((m_cbDataFlag&DK_COMPRESS)!=0)&&(CompressBuffer()==false))
    {
        ASSERT(FALSE);
        return false;
    }
    
    //新版本标志
    if ((m_cbDataFlag&DK_NEW_VERSION_EX)!=0)
    {
        pHead->TCPInfo.cbDataKind|=DK_NEW_VERSION_EX;
    }
    
    return true;
}

unsigned char *CTCPSocketData::GetDataBuffer()
{
    unsigned char *buff = (unsigned char *)malloc(m_wBufferSize);
    memcpy(buff, m_cbDataBuffer, m_wBufferSize);
    return buff;
}

#if CC_LUA_ENGINE_ENABLED > 0
LUA_STRING CTCPSocketData::GetDataBufferLua()
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

unsigned short CTCPSocketData::GetBufferSize()
{
    return m_wBufferSize;
}

//映射数据
bool CTCPSocketData::MappedBuffer()
{
    //变量定义
    unsigned char cbCheckCode=0;
    TCP_Info * pInfo=(TCP_Info *)m_cbDataBuffer;
    
    //字节映射
    for (unsigned short i=sizeof(TCP_Info);i<m_wBufferSize;i++)
    {
        cbCheckCode+=m_cbDataBuffer[i];
        m_cbDataBuffer[i]=g_SendByteMap[m_cbDataBuffer[i]];
    }
    
    //设置包头
    pInfo->cbDataKind|=DK_MAPPED;
    pInfo->cbCheckCode=~cbCheckCode+1;
    
    return true;
}

//映射数据
bool CTCPSocketData::UnMappedBuffer()
{
    //效验参数
    ASSERT(m_wBufferSize>=sizeof(TCP_Head));
    ASSERT(((TCP_Head *)m_cbDataBuffer)->TCPInfo.wPacketSize==m_wBufferSize);
    
    //效验参数
    if (m_wBufferSize<sizeof(TCP_Head)) return false;
    if (((TCP_Head *)m_cbDataBuffer)->TCPInfo.wPacketSize!=m_wBufferSize) return false;
    
    //变量定义
    TCP_Info * pInfo=(TCP_Info *)m_cbDataBuffer;
    
    //映射数据
    if ((pInfo->cbDataKind&DK_MAPPED)!=0)
    {
        //变量定义
        unsigned char cbCheckCode=pInfo->cbCheckCode;
        
        //效验字节
        for (int i=sizeof(TCP_Info);i<m_wBufferSize;i++)
        {
            cbCheckCode+=g_RecvByteMap[m_cbDataBuffer[i]];
            m_cbDataBuffer[i]=g_RecvByteMap[m_cbDataBuffer[i]];
        }
        
        //结果判断
        ASSERT(cbCheckCode==0);
        if (cbCheckCode!=0) return false;
    }
    
    return true;
}

//加密数据
bool CTCPSocketData::EncryptBuffer()
{
    //调整长度
    unsigned short wEncryptSize = m_wBufferSize - sizeof(TCP_Info), wSnapCount = 0;
    if ((wEncryptSize % sizeof(unsigned int)) != 0)
    {
        wSnapCount = sizeof(unsigned int) - wEncryptSize % sizeof(unsigned int);
        memset(m_cbDataBuffer + sizeof(TCP_Info) + wEncryptSize, 0, wSnapCount);
    }
    
    //信息头
    TCP_Head *pHead = (TCP_Head*)m_cbDataBuffer;
     
    //创建密钥
    unsigned int dwXorKey = m_dwSendXorKey_TCP;

    //加密数据
    unsigned short * pwSeed = (unsigned short *)(m_cbDataBuffer + sizeof(TCP_Info));
    unsigned int * pdwXor = (unsigned int *)(m_cbDataBuffer + sizeof(TCP_Info));
    unsigned short wEncrypCount = (wEncryptSize + wSnapCount) / sizeof(unsigned int);
    for (unsigned short i = 0; i < wEncrypCount; i++)
    {
        *pdwXor++ ^= dwXorKey;
        dwXorKey = SeedRandMap(*pwSeed++);
        dwXorKey |= ((unsigned int)SeedRandMap(*pwSeed++)) << 16;
        dwXorKey ^= g_dwPacketKey;
    }
    
    //插入密钥
    if (m_dwSendPacketCount_TCP == 0)
    {
        RSA *testRSA = new RSA();
        char key[32];
        sprintf(key, "%x",m_dwSendXorKey_TCP);
        string encryptoStr = testRSA->tencrypto(e, n, key);
        int keyLen = encryptoStr.length();
        
        memmove(m_cbDataBuffer + sizeof(TCP_Head) + sizeof(unsigned int) + keyLen, m_cbDataBuffer + sizeof(TCP_Head), m_wBufferSize);
        * ((unsigned int *)(m_cbDataBuffer + sizeof(TCP_Head))) = keyLen;
        memcpy(m_cbDataBuffer + sizeof(TCP_Head) + sizeof(unsigned int), encryptoStr.c_str(), keyLen);
        pHead->TCPInfo.wPacketSize += sizeof(unsigned int) + keyLen;
        m_wBufferSize += sizeof(unsigned int) + keyLen;
        
        delete testRSA;
    }
     
    //设置变量
    pHead->TCPInfo.cbDataKind |= DK_ENCRYPT;
    m_dwSendPacketCount_TCP++;
    m_dwSendXorKey_TCP = dwXorKey;
    return true;
}

//解密数据
bool CTCPSocketData::CrevasseBuffer()
{
    unsigned int dwRecvServerKey;
    unsigned short i = 0;
    //效验参数
    ASSERT(m_wBufferSize >= sizeof(TCP_Head));
    ASSERT(((TCP_Head *)m_cbDataBuffer)->TCPInfo.wPacketSize == m_wBufferSize);
     
    //调整长度
    unsigned short wSnapCount = 0;
    if ((m_wBufferSize % sizeof(unsigned int)) != 0)
    {
        wSnapCount = sizeof(unsigned int) - m_wBufferSize % sizeof(unsigned int);
        memset(m_cbDataBuffer + m_wBufferSize, 0, wSnapCount);
    }
     
    //提取密钥
    if (m_dwRecvPacketCount_TCP == 0)
    {
        ASSERT(m_wBufferSize >= (sizeof(TCP_Head) + sizeof(unsigned int)));
        if (m_wBufferSize < (sizeof(TCP_Head) + sizeof(unsigned int)))
        {
            //数据包解密长度错误
            return false;
        }
        //直接提取
        dwRecvServerKey = *(unsigned int *)(m_cbDataBuffer + sizeof(TCP_Head));
        memmove(m_cbDataBuffer + sizeof(TCP_Head), m_cbDataBuffer + sizeof(TCP_Head) + sizeof(unsigned int),
                m_wBufferSize - sizeof(TCP_Head) - sizeof(unsigned int));
        m_wBufferSize -= sizeof(unsigned int);
        ((TCP_Head *)m_cbDataBuffer)->TCPInfo.wPacketSize -= sizeof(unsigned int);
    }
     
    //解密数据
    unsigned int dwXorKey = m_dwRecvXorKey_TCP;
    
    
    unsigned int * pdwXor = (unsigned int *)(m_cbDataBuffer + sizeof(TCP_Info));
    unsigned short  * pwSeed = (unsigned short *)(m_cbDataBuffer + sizeof(TCP_Info));
    unsigned short wEncrypCount = (m_wBufferSize + wSnapCount - sizeof(TCP_Info)) / 4;
    for (i = 0; i < wEncrypCount; i++)
    {
        if ((i == (wEncrypCount - 1)) && (wSnapCount > 0))
        {
            unsigned char * pcbKey = ((unsigned char *) & m_dwRecvXorKey_TCP) + sizeof(unsigned int) - wSnapCount;
            memcpy(m_cbDataBuffer + m_wBufferSize, pcbKey, wSnapCount);
        }
        dwXorKey = SeedRandMap(*pwSeed++);
        dwXorKey |= ((unsigned int)SeedRandMap(*pwSeed++)) << 16;
        dwXorKey ^= g_dwPacketKey;
        *pdwXor++ ^= m_dwRecvXorKey_TCP;
        m_dwRecvXorKey_TCP = dwXorKey;
    }
    
    //重新生成key
    if (m_dwRecvPacketCount_TCP == 0)
    {
        m_dwRecvXorKey_TCP |= dwRecvServerKey;
        m_dwSendXorKey_TCP |= dwRecvServerKey;
    }
    
    m_dwRecvPacketCount_TCP++;
    return true;
}

//随机映射
unsigned short CTCPSocketData::SeedRandMap(unsigned short wSeed)
{
    unsigned int dwHold = wSeed;
    return (unsigned short)((dwHold = dwHold * 241103L + 2533101L) >> 16);
}

//压缩数据
bool CTCPSocketData::CompressBuffer()
{
    //效验参数
    ASSERT(m_wBufferSize>=sizeof(TCP_Head));
    if (m_wBufferSize<sizeof(TCP_Head)) return false;
    
    //起始数据
    unsigned short wSourceSize = m_wBufferSize-sizeof(TCP_Info);
    unsigned char* pcbSourceData = m_cbDataBuffer+sizeof(TCP_Info);
    
    //压缩数据
    unsigned char cbResultData[SOCKET_TCP_BUFFER];
    
    unsigned long length = SOCKET_TCP_BUFFER;
    int z_return = compress(cbResultData,&length,pcbSourceData,wSourceSize);
    if (z_return)
    {
        printf("compressedData fail");
        return false;
    }
    
    if (length < wSourceSize && length > 0) //需要压缩
    {
        //变量定义
        TCP_Info * pInfo = (TCP_Info *)m_cbDataBuffer;
        
        //设置包头
        pInfo->cbDataKind |= DK_COMPRESS;
        pInfo->wPacketSize = (unsigned short)(length)+sizeof(TCP_Info);
        
        //设置数据
        m_wBufferSize = pInfo->wPacketSize;
        memcpy(m_cbDataBuffer+sizeof(TCP_Info),cbResultData,length);
        
    }
    
    return true;
}

//解压数据
bool CTCPSocketData::UnCompressBuffer()
{
    //效验参数
    ASSERT(m_wBufferSize>=sizeof(TCP_Info));
    ASSERT(((TCP_Info *)m_cbDataBuffer)->wPacketSize==m_wBufferSize);
    
    //变量定义
    TCP_Info * pInfo=(TCP_Info *)m_cbDataBuffer;
    
    //解压判断
    if ((pInfo->cbDataKind&DK_COMPRESS) != 0)
    {
        //起始数据
        unsigned short wSourceSize = m_wBufferSize-sizeof(TCP_Info);
        unsigned char* pcbSourceData = m_cbDataBuffer+sizeof(TCP_Info);
        
        //解压数据
        unsigned char cbResultData[SOCKET_TCP_BUFFER];
        
        unsigned long length = SOCKET_TCP_BUFFER;
        int z_return = uncompress(cbResultData,&length,pcbSourceData,wSourceSize);
        if (z_return)
        {
            printf("DecompressedData fail");
            return false;
        }
        
        unsigned long lResultSize = length;
        
        //效验结果
        ASSERT((lResultSize>wSourceSize)&&((lResultSize+sizeof(TCP_Info))<=SOCKET_TCP_BUFFER));
        if ((lResultSize<=wSourceSize)||((lResultSize+sizeof(TCP_Info))>SOCKET_TCP_BUFFER)) return false;
        
        //设置包头
        pInfo->cbDataKind&=~DK_COMPRESS;
        pInfo->wPacketSize=(unsigned short)(lResultSize)+sizeof(TCP_Info);
        
        //设置数据
        m_wBufferSize=pInfo->wPacketSize;
        memcpy(m_cbDataBuffer+sizeof(TCP_Info),cbResultData,lResultSize);
    }
    
    return true;
}