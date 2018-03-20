//
//  faceDetector.h
//  FaceppDemo
//
//  Created by 张英堂 on 2017/2/9.
//  Copyright © 2017年 megvii. All rights reserved.
//

#ifndef MG_Detector_h
#define MG_Detector_h

#include <stdio.h>
#include "MG_Common.h"
#include "MG_Facepp.h"

#ifdef __cplusplus
extern "C"{
#endif
    
#define KMGDETECTMAXFACE 5
#define KMGDETECTMODELNAME @"megviifacepp_0_4_7_model"

    
struct _MG_FACE_ALGORITHM;
typedef struct _MG_FACE_ALGORITHM* MG_FACE_ALGORITHM_HANDLE;

typedef struct {
    MG_RETCODE (*CreateHandle)(const unsigned char *model_data,
                                int model_length,
                                MG_FACE_ALGORITHM_HANDLE  *detect_handle);
    
    MG_RETCODE (*DetectFace)(MG_FACE_ALGORITHM_HANDLE detect_handle,
                             int image_width,
                             int image_height,
                             const unsigned char *image_data,
                             MG_FACE face_array[KMGDETECTMAXFACE],
                             int *face_count);

    
    MG_RETCODE (*Release)(MG_FACE_ALGORITHM_HANDLE detect_handle);
    
    MG_RETCODE (*SetConfig)(MG_FACE_ALGORITHM_HANDLE detect_handle, const MG_FPP_APICONFIG config);
    MG_RETCODE (*GetConfig)(MG_FACE_ALGORITHM_HANDLE detect_handle, MG_FPP_APICONFIG *config);
    MG_RETCODE (*SetNormalConfig)(MG_FACE_ALGORITHM_HANDLE detect_handle);

} MG_DETECTOR_WRAPPER_FUNCTIONS_TYPE;
    
extern MG_EXPORT MG_DETECTOR_WRAPPER_FUNCTIONS_TYPE mg_detector;

    
#ifdef __cplusplus
}
#endif

#endif /* faceDetector_h */
