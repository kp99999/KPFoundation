#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KPFoundation.h"
#import "DBToParser.h"
#import "JsonToParser.h"
#import "ShareTable.h"
#import "AnimTimeManege.h"
#import "TimingTask.h"
#import "FileToUse.h"
#import "FileUse+FMDB.h"
#import "FileUse+Manager.h"
#import "FileUse+Other.h"
#import "FileUse.h"
#import "FileUseOther.h"
#import "GeneralUIUse+Image.h"
#import "GeneralUIUse.h"
#import "KPPublicDefine.h"
#import "LocationManager.h"
#import "CheckNetwork.h"
#import "NetWorkErrer.h"
#import "NetWorkManage.h"
#import "NetWorkPublic.h"
#import "NetworkRequest.h"
#import "TCPLinkManage.h"
#import "DeviceBaseData.h"
#import "GeneralUse+Compress.h"
#import "GeneralUse+StrengthPassword.h"
#import "GeneralUse+Time.h"
#import "GeneralUse.h"
#import "MultiLanguage.h"
#import "CatchBugRecord.h"
#import "FileToControll.h"
#import "BridgeClientSDK.h"
#import "ASMUInt128.h"
#import "Base64.h"
#import "LCMD5Tool.h"
#import "MF_Base64Additions.h"
#import "NSData+ASMCityHash.h"
#import "NSData+BMCrypto.h"
#import "NSString+ASMCityHash.h"
#import "NSString+BMCrypto.h"
#import "SecurityPolicy.h"
#import "TouchID.h"
#import "NSStream+NSStreamAddition.h"
#import "StreamHandle.h"
#import "KeychainItemWrapper.h"
#import "NSObjectSafe.h"

FOUNDATION_EXPORT double KPFoundationVersionNumber;
FOUNDATION_EXPORT const unsigned char KPFoundationVersionString[];

