//
//  MG_Detect_EXT.hpp
//  MGBeauty
//
//  Created by 张英堂 on 2017/2/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#ifndef MG_Detect_EXT_hpp
#define MG_Detect_EXT_hpp


#include "MG_Facepp.h"
#include "MG_Common.h"
#include "MG_Detector.h"

#ifdef __cplusplus
extern "C"{
#endif
    
    class MG_DETECT_HANDLE_EXT
    {
    private:
        int image_width;
        int image_height;
        
        MG_FPP_APIHANDLE fppAPIHandle;
        MG_FPP_IMAGEHANDLE fppImageHandle;
                
    public:
        
        MG_DETECT_HANDLE_EXT(const MG_BYTE *model_data, int32_t model_length, MG_RETCODE *error_code);
        ~MG_DETECT_HANDLE_EXT();
        


        MG_RETCODE set_image_data(int width, int height, const MG_BYTE *image_data, MG_IMAGEMODE image_mode);
        
        MG_RETCODE detect_face(MG_FACE faceArray[KMGDETECTMAXFACE], int *face_count);

        MG_RETCODE set_config(const MG_FPP_APICONFIG config);
        MG_RETCODE get_config(MG_FPP_APICONFIG *config);
        
        
    };
    
    
    
#ifdef __cplusplus
}
#endif



#endif /* MG_Detect_EXT_hpp */
