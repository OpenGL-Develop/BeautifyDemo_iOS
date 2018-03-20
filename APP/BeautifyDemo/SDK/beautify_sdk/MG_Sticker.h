/**
 * @file MG_Sticker.h
 * @brief 贴图算法的头文件
 *
 * 包含 Face++ 的贴图算法
 */

#ifndef mg_sticker_h
#define mg_sticker_h

#include "MG_Beautify.h"

#ifdef __cplusplus
extern "C"{
#endif
    
    /**
     * @brief 贴纸参数
     *
     */
    typedef enum {
        MG_STICKER_OVERTURN = 0,            ///< 贴纸资源进行左右翻转，0.0 表示不翻转，1.0 表示翻转。
    }MG_STICKER_TYPE;
    
    struct _MG_STICKER;
    /**
     * @brief 贴纸算法句柄
     */
    typedef struct _MG_STICKER* MG_STICKER_HANDLE;
    
    typedef struct {
        
        /**
         * @brief 创建贴纸算法句柄（handle）
         *
         * @param[in] mgbHandle        美颜美型算法句柄，必须输入。如果输入为空，会导致初始化失败
         *
         * @return 成功则返回 初始化句柄
         */
        MG_STICKER_HANDLE (*CreateHandle)(MG_BEAUTIFY_HANDLE mgbHandle);
        
        /**
         * @brief 释放贴纸算法句柄（handle）
         *
         * @param[in] handle 贴纸算法句柄
         *
         */
        MG_RETCODE (*ReleaseHandle)(MG_STICKER_HANDLE handle);
        
        /**
         * @brief 设置贴纸的参数
         *
         * @param[in] handle 贴纸算法句柄
         * @param[in] type 设置参数的类型
         * @param[in] value 设置数值
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*SetParamProperty)(MG_STICKER_HANDLE handle,
                                       MG_STICKER_TYPE type, float value);
        
        /**
         * @brief 对图像按照设置进行贴纸
         *
         * @param[in] handle 贴纸句柄
         * @param[in] oldTextureIndex 原始图像 texture
         * @param[in] newTextureIndex 渲染后的图像 texture
         * @param[in] faces 人脸信息数组
         * @param[in] facesCount 人脸数量
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*ProcessTexture)(MG_STICKER_HANDLE handle,
                                     unsigned int oldTextureIndex,
                                     unsigned int newTextureIndex,
                                     MG_FACE *faces,
                                     int facesCount);
        
        /**
         * @brief 更新贴纸资源
         *
         * @param[in] handle 贴纸句柄
         * @param[in] packageLocation 贴纸资源路径，必须为压缩包路径
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*ChangePackage)(MG_STICKER_HANDLE handle, const char* packageLocation, const char **outpackage);
        
        /**
         * @brief 预载贴图资源
         *
         * @param[in] handle 贴纸句柄
         * @param[in] packageLocation 贴纸资源路径，必须为压缩包路径
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*PreparePackage)(MG_STICKER_HANDLE handle, const char* packageLocation);
        
        /**
         * @brief 禁用贴图资源
         *
         * @param[in] handle 贴纸句柄
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*DisablePackage)(MG_STICKER_HANDLE handle);
        
    } MG_STICKER_API_FUNCTIONS_TYPE;
    
    /**
     * @brief 贴纸算法域
     *
     * Example:
     *      mg_sticker.CreateHandle(...
     *      mg_sticker.ProcessTexture(...
     */
    extern MG_EXPORT MG_STICKER_API_FUNCTIONS_TYPE mg_sticker;
    
#ifdef __cplusplus
}
#endif

#endif /* mg_sticker_h */
