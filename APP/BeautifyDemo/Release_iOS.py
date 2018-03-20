#!/usr/bin/env python
# -*- coding: utf-8 -*-
__author__ = 'seven'

import os, sys, commands, shutil

#检查命令输入
def check_argv(path):
    if len(path) == 3:
        haspath = os.path.exists(path[1]) & os.path.isdir(path[1])
        if haspath == True:
            return True
    return False

#检查cmd命令行
def check_cmd(status, str='命令执行失败，请重试！'):
    if status == 0:
        return True
    else:
        print(str)
        return False

#检查目录是否存在，不存在并创建
def check_file(path):
    if not os.path.exists(path):os.mkdir(path)


#打包完成，创建 IPA
def creatIPA(appPath, savePath, exportPlistPath):
    print '*******'
    print appPath
    print '*******'
    print savePath
    print '*******'
    print exportPlistPath
    print '*******'
    
    comStr = 'xcodebuild -exportArchive -exportOptionsPlist %s  -archivePath %s -exportPath %s CODE_SIGN_IDENTITY="iPhone Distribution: Beijing Megvii Co., Ltd"'%(exportPlistPath, appPath, savePath)
    #xcodebuild  -exportArchive -exportFormat IPA -archivePath <archivePath> -exportPath <exportPath>

    (r_status, output) = commands.getstatusoutput(comStr)
    print output
    
    return r_status

#移动文件
def move_file(nowPath, scourePath):
#    print nowPath +'\r'
#    print scourePath
#    os.chdir(scourePath)
#
    removeFileInFirstDir(scourePath)
    os.chdir(nowPath)
    shutil.copytree(nowPath, scourePath)

#删除目录下指定文件
def removeFileInFirstDir(filePaht):
    os.remove(filePaht)

#启动
if __name__ == '__main__':

#    saveIpaPath = os.path.expanduser('~') + '/Desktop/FaceIDApp'
    print '\r'
    print('********** 生成 IPA 包中，请等待 **********')
#    print 'ipa文件保存目录: ' + saveIpaPath

    import os
    if check_argv(sys.argv):
        print '参数检查完成'
        #        if  os.path.exists(saveIpaPath):
        #            shutil.rmtree(saveIpaPath)
#
        #        os.mkdir(saveIpaPath)

#        xcode 文件目录
    else:
        print 'argv invalid'
        sys.exit()

    path = sys.argv
    xcodePath = path[1]
    saveIpaPath = path[2]

    os.chdir(xcodePath)
#Xcode 清理
    (c_status, output) = commands.getstatusoutput('xcodebuild clean -workspace Beautify.xcworkspace -scheme BeautifyDemo')
    if check_cmd(c_status, 'xcode clean error!'):
        print 'xcodebuild clean finish'

    ipaName = 'BeautifyDemo.ipa'

    (b_status, output) = commands.getstatusoutput('xcodebuild -workspace Beautify.xcworkspace -scheme BeautifyDemo -configuration Release -sdk iphoneos CODE_SIGN_IDENTITY="iPhone Distribution: Beijing Megvii Co., Ltd"')
    print b_status
    print output
    if check_cmd(b_status, 'xcodebuild error!'):
        print 'xcodebuild to .app finish'
        
        commdstr = output.split()
#        print commdstr
        appPath = commdstr[-6]

#        print appPath + '\r'
#.dSYM
        finish = creatIPA(appPath, saveIpaPath + '/' + ipaName, xcodePath+'/BeautifyDemo/exportPlist.plist')
        if check_cmd(finish, '打包失败'):
            print 'xcrun to .ipa finish'
            
            #dSYMPath = appPath + '.dSYM'
#move_file(dSYMPath, saveIpaPath + '/' + os.path.basename(dSYMPath))

    print('\r' + '********** IPA打包结束 **********' + '\r')










