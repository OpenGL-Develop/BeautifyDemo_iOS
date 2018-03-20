
/**
 * @file MG_Beautify.h
 * @brief 美颜算法的头文件
 *
 * 包含 Face++ 的美颜算法
 */

#ifndef mg_beautify_h
#define mg_beautify_h

#include "MG_Common.h"

#ifdef __cplusplus
extern "C"{
#endif
    
#define MGB_ATTR_BEAUTIFY 0x01             ///< 磨皮美白标识位
#define MGB_ATTR_TRANS 0x02          ///< 大眼瘦脸标识位
#define MGB_ATTR_FILTER 0x04        ///< 滤镜标识位
#define MGB_ATTR_STICKER 0x08           ///< 贴纸标识位
#define MGB_ATTR_BUDY 0x10           ///< 魔法背景标识位
#define MGB_ATTR_SKIN 0x20         ///< 人脸换肤标识位
    
    /**
     * @brief 美颜美型参数
     *
     * 以下参数区间均为 [0， 20]，0为没有效果，20为效果最高
     */
    typedef enum {
        MG_BEAUTIFY_ENLARGE_EYE = 1,            ///< 眼镜变大
        MG_BEAUTIFY_SHRINK_FACE = 2,            ///< 瘦脸
        MG_BEAUTIFY_BRIGHTNESS = 3,             ///< 亮度
        MG_BEAUTIFY_DENOISE = 4,                ///< 磨皮程度
        MG_BEAUTIFY_PINK = 5                    ///< 粉嫩程度
    }MG_BEAUTIFY_TYPE;
    
    
    struct _MG_BEAUTIFY;
    /**
     * @brief 美颜美型算法句柄
     */
    typedef struct _MG_BEAUTIFY* MG_BEAUTIFY_HANDLE;
    
    typedef struct {
        
        /**
         * @brief 获取算法版本信息
         *
         * @return 返回一个字符串，表示算法版本号及相关信息
         */
        const char* (*GetApiVersion)();
        
        
        /**
         * @brief 创建美颜美型算法句柄（handle）
         *
         * 传入算法模型数据，创建一个算法句柄。
         *
         * @param[in] env               Android jni 的环境变量，仅在 Android SDK 中使用
         * @param[in] jobj              Android 调用的上下文，仅在 Android SDK 中使用
         * @param[in] model_data        算法模型的二进制数据
         * @param[in] model_length      算法模型的字节长度
         * @param[in] image_width       要处理图像的高度
         * @param[in] image_height      要处理图像的宽度
         * @param[in] orientation       输入图像顺时针旋转 rotation 度之后为正常的重力方向。
         *
         * @param[out] handle   算法句柄的指针，成功创建后会修改其值
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*CreateHandle)(
#if MGAPI_BUILD_ON_ANDROID
                                   JNIEnv*,jobject context,
#endif
                                   const unsigned char* model_data, int model_length,
                                   int image_width, int image_height, MG_ROTATION orientation,
                                   MG_BEAUTIFY_HANDLE *handle);
        
        /**
         * @brief 在输入的 图像texture 宽度/高度 要改变时，请调用该方法重置
         *
         * @param[in] handle            美颜美型句柄
         * @param[in] image_width       图像的高度
         * @param[in] image_height      图像的的宽度
         * @param[in] orientation       输入图像顺时针旋转 rotation 度之后为正常的重力方向
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*ResetHandle)(MG_BEAUTIFY_HANDLE handle,
                                  int image_width, int image_height,
                                  MG_ROTATION orientation);

        
        
        /**
         * @brief 释放美颜美型句柄（handle）
         *
         * @param[in] handle 美颜美型句柄
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*ReleaseHandle)(MG_BEAUTIFY_HANDLE handle);
        
        
        /**
         * @brief 设置美颜美型的参数
         *
         * @param[in] handle 美颜美型句柄
         * @param[in] MG_BEAUTIFY_TYPE 设置参数的类型
         * @param[in] value 设置数值 【0 - 20】之间
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*SetParamProperty)(MG_BEAUTIFY_HANDLE handle,
                                       MG_BEAUTIFY_TYPE type, float value);
        
        /**
         * @brief 对图像按照设置的参数进行渲染
         *
         * @param[in] handle 美颜美型句柄
         * @param[in] oldTextureIndex 原始图像 texture
         * @param[in] newTextureIndex 渲染后的图像 texture
         * @param[in] faces 人脸信息数组
         * @param[in] facesCount 人脸数量
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*ProcessTexture)(MG_BEAUTIFY_HANDLE handle,
                                     unsigned int oldTextureIndex,
                                     unsigned int newTextureIndex,
                                     MG_FACE *faces,
                                     int facesCount);
        
        /**
         * @brief 图像添加滤镜效果
         *
         * @param[in] handle 美颜美型句柄
         * @param[in] filterLocation 滤镜数据路径
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*SetFilter)(MG_BEAUTIFY_HANDLE handle,
                                const char* filterLocation);
        
        /**
         * @brief  图像移除滤镜效果
         *
         * @param[in] handle 美颜美型句柄
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*RemoveFilter)(MG_BEAUTIFY_HANDLE handle);
        
        /**
         * @brief  使用加速的磨皮方法
         *
         * @param[in] handle 美颜美型句柄
         * @param[in] value 是否使用加速的磨皮方法
         *
         * @return 成功则返回 MG_RETCODE_OK
         */
        MG_RETCODE (*UseFastFilter)(MG_BEAUTIFY_HANDLE handle, bool value);
        
    } MG_BEAUTIFY_API_FUNCTIONS_TYPE;
    
    /**
     * @brief 美颜美型算法域
     *
     * Example:
     *      mg_beautify.CreateHandle(...
     *      mg_beautify.ResetHandle(...
     */
    extern MG_EXPORT MG_BEAUTIFY_API_FUNCTIONS_TYPE mg_beautify;
    
#ifdef __cplusplus
}
#endif

#endif /* mg_beautify_h */
