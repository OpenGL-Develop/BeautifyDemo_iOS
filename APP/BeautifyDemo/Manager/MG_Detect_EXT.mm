//
//  MG_Detect_EXT.cpp
//  MGBeauty
//
//  Created by 张英堂 on 2017/2/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#include "MG_Detect_EXT.h"
#include "MG_Common.h"
#include "string.h"
#include "math.h"

MG_DETECT_HANDLE_EXT::MG_DETECT_HANDLE_EXT(
        const MG_BYTE *model_data, int32_t model_length, MG_RETCODE *error_code)
{
    this->fppImageHandle = NULL;
    this->fppAPIHandle = NULL;
    this->image_width = 0;
    this->image_height = 0;
    
    MG_RETCODE returnCode = MG_RETCODE_OK;
    
    MG_RETCODE initCode = mg_facepp.CreateApiHandle((MG_BYTE *)model_data, (MG_INT32)model_length, &this->fppAPIHandle);
    
    if (initCode != MG_RETCODE_OK) {
        returnCode = MG_RETCODE_FAILED;
        printf("[CreateApiHandle] 初始化失败，modelData 与 SDK 不匹配！，请检查后重试！errorCode:%d", initCode);
    }else{
        
        MG_FPP_APICONFIG config;
        mg_facepp.GetDetectConfig(this->fppAPIHandle, &config);
        
        config.min_face_size = 50;
        config.interval = 20;
        config.detection_mode = MG_FPP_DETECTIONMODE_TRACKING_FAST;
        config.rotation = MG_ROTATION_0;
        config.one_face_tracking = false;
        
        initCode = mg_facepp.SetDetectConfig(this->fppAPIHandle, &config);
    }
    
    *error_code = returnCode;
}

MG_DETECT_HANDLE_EXT::~MG_DETECT_HANDLE_EXT()
{
    if (fppAPIHandle != NULL) {
        mg_facepp.ReleaseApiHandle(fppAPIHandle);
        fppAPIHandle = NULL;
        printf("release fppAPIHandle\n");
        mg_facepp.Shutdown();
    }
    
    if (fppImageHandle != NULL) {
        mg_facepp.ReleaseImageHandle(fppImageHandle);
        fppImageHandle = NULL;
        printf("release fppImageHandle\n");
    }
}

MG_RETCODE MG_DETECT_HANDLE_EXT::set_image_data(int width, int height, const MG_BYTE *image_data, MG_IMAGEMODE image_mode)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;

    if (width == 0 || height == 0) {
        returnCode = MG_RETCODE_INVALID_ARGUMENT;
        return returnCode;
    }

    if (NULL == this->fppImageHandle) {
        mg_facepp.CreateImageHandle(width, height, &this->fppImageHandle);

        this->image_width = width;
        this->image_height = height;
        
    }else{
        if (width != this->image_width || height != this->image_height) {
        
            mg_facepp.ReleaseImageHandle(this->fppImageHandle);
            mg_facepp.CreateImageHandle(width, height, &this->fppImageHandle);
        }
        
        this->image_width = width;
        this->image_height = height;
    }
    
    MG_RETCODE initCode = mg_facepp.SetImageData(this->fppImageHandle ,image_data, image_mode);
    if (initCode != MG_RETCODE_OK) {
        returnCode = MG_RETCODE_FAILED;
    }

    return returnCode;
}

MG_RETCODE MG_DETECT_HANDLE_EXT::set_config(const MG_FPP_APICONFIG config)
{
    MG_RETCODE returnCode = mg_facepp.SetDetectConfig(this->fppAPIHandle, &config);
    
    return returnCode;
}

MG_RETCODE MG_DETECT_HANDLE_EXT::get_config(MG_FPP_APICONFIG *config)
{
    MG_RETCODE returnCode = mg_facepp.GetDetectConfig(this->fppAPIHandle, config);
    return returnCode;
}

MG_RETCODE MG_DETECT_HANDLE_EXT::detect_face(MG_FACE faceArray[KMGDETECTMAXFACE], int *face_count)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;

    *face_count = 0;
    MG_RETCODE detectCode = mg_facepp.Detect(this->fppAPIHandle, this->fppImageHandle, face_count);
    
    if (detectCode == MG_RETCODE_OK) {
    
        int minCount = *face_count < KMGDETECTMAXFACE ? *face_count : KMGDETECTMAXFACE;
        *face_count = minCount;

        for(int i = 0 ; i < minCount; i++){
            MG_FACE face;
            mg_facepp.GetFaceInfo(this->fppAPIHandle, i, &face);
            mg_facepp.GetLandmark(this->fppAPIHandle, i, true, MG_FPP_GET_LANDMARK81, face.points.point);
            
            memcpy(&faceArray[i], &face, sizeof(face));
        }
    }
    return returnCode;
}

