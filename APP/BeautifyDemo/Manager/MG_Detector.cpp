//
//  faceDetector.c
//  FaceppDemo
//
//  Created by 张英堂 on 2017/2/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#include "MG_Detector.h"
#include "MG_Detect_EXT.h"

MG_RETCODE MGF_CreateHandle(const MG_BYTE *model_data,
                                      int model_length,
                                      MG_FACE_ALGORITHM_HANDLE *detect_handle)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;

    MG_DETECT_HANDLE_EXT *ptr = new MG_DETECT_HANDLE_EXT(model_data, model_length, &returnCode);
    *detect_handle = reinterpret_cast<_MG_FACE_ALGORITHM*>(ptr);
    
    return returnCode;
}

MG_RETCODE MGF_DetectFace(MG_FACE_ALGORITHM_HANDLE detect_handle,
                                    int image_width,
                                    int image_height,
                                    const unsigned char *image_data,
                                    MG_FACE face_array[KMGDETECTMAXFACE],
                                    int *face_count)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;

    MG_DETECT_HANDLE_EXT *ptr = (MG_DETECT_HANDLE_EXT *)detect_handle;

    if (ptr == NULL) {
        returnCode = MG_RETCODE_INVALID_HANDLE;
    } else {
        returnCode = ptr->set_image_data(image_width, image_height, image_data, MG_IMAGEMODE_RGBA);
        
        returnCode = ptr->detect_face(face_array, face_count);
        // TODO: smooth
    }
    
    return returnCode;
}

MG_RETCODE MGF_Release(MG_FACE_ALGORITHM_HANDLE detect_handle)
{
    if (NULL != detect_handle) {
        delete reinterpret_cast<MG_DETECT_HANDLE_EXT*>(detect_handle);
        detect_handle = NULL;
    }
    return MG_RETCODE_OK;
}


MG_RETCODE MGF_SetConfig(MG_FACE_ALGORITHM_HANDLE detect_handle, const MG_FPP_APICONFIG config)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;
    MG_DETECT_HANDLE_EXT *ptr = (MG_DETECT_HANDLE_EXT *)detect_handle;
    
    if (ptr == NULL) {
        returnCode = MG_RETCODE_INVALID_HANDLE;
    }else{
        returnCode =  ptr->set_config(config);
    }
    return returnCode;
}

MG_RETCODE MGF_GetConfig(MG_FACE_ALGORITHM_HANDLE detect_handle, MG_FPP_APICONFIG *config)
{
    MG_RETCODE returnCode = MG_RETCODE_OK;
    MG_DETECT_HANDLE_EXT *ptr = (MG_DETECT_HANDLE_EXT *)detect_handle;

    if (ptr == NULL) {
        returnCode = MG_RETCODE_INVALID_HANDLE;
    }else{
        returnCode =  ptr->get_config(config);
    }
    return returnCode;
}

MG_RETCODE MGF_SetNormalConfig(MG_FACE_ALGORITHM_HANDLE detect_handle){
    MG_RETCODE returnCode = MG_RETCODE_OK;
    MG_DETECT_HANDLE_EXT *ptr = (MG_DETECT_HANDLE_EXT *)detect_handle;

    if (ptr == NULL) {
        returnCode = MG_RETCODE_INVALID_HANDLE;
    }else{
        MG_FPP_APICONFIG config;
        config.min_face_size = 50;
        config.interval = 10;
        config.detection_mode = MG_FPP_DETECTIONMODE_NORMAL;
        config.rotation = MG_ROTATION_0;
        config.one_face_tracking = false;
        
        returnCode =  ptr->set_config(config);
    }
    return returnCode;
}

MG_DETECTOR_WRAPPER_FUNCTIONS_TYPE mg_detector = {
    MGF_CreateHandle,
    MGF_DetectFace,
    MGF_Release,
    MGF_SetConfig,
    MGF_GetConfig,
    MGF_SetNormalConfig,
};
