//
//  CRSystemInfoHelper.h
//  CRSystemInfoHelper
//
//  Created by Cătălin Stan on 05/04/16.
//  Copyright © 2016 Cătălin Stan. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double CRSystemInfoHelperVersionNumber;
FOUNDATION_EXPORT const unsigned char CRSystemInfoHelperVersionString[];

NS_ASSUME_NONNULL_BEGIN

/**
 Name of the operating system implementation.
 */
FOUNDATION_EXPORT NSString * const CRSystemInfoSysnameKey;

/**
 Network name of this machine.
 */
FOUNDATION_EXPORT NSString * const CRSystemInfoNodenameKey;

/**
 Release level of the operating system.
 */
FOUNDATION_EXPORT NSString * const CRSystemInfoReleaseKey;

/**
 Version level of the operating system.
 */
FOUNDATION_EXPORT NSString * const CRSystemInfoVersionKey;

/**
 Machine hardware platform.
 */
FOUNDATION_EXPORT NSString * const CRSystemInfoMachineKey;

/**
 The CRSystemInfoHelper class provides easy-access to some useful system
 information that would otherwise require some more elaborate code.
 */
@interface CRSystemInfoHelper : NSObject

/**
 @name Accessing the shared helper instance
 */

/**
 The shared helper instance

 @return A singleton CRSharedHelper object
 */
+ (instancetype)sharedHelper;

/**
 @name Getting IP Addresses
 */

/**
 A dictionary where the keys are interface names and the values are
 the IP addresses associated with those interfaces.
 
 Check the `getifaddrs(3)` manual page for more information.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSString *> * AllIPAddresses;

/**
 The IP Address of "en0".
 
 This is a convenience method for `AllIPAddresses[@"en0"]`.
 */
@property (nonatomic, readonly, strong) NSString * IPAddress;

/**
 @name Getting `uname` System Information
 */

/**
 A dictionary containing the results of the 'uname(3)` call.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSString *> * systemInfo;

/**
 A concatenated string representation of all the values in `systemInfo`, in
 the order listed in the `uname(3)` manual page.
 */
@property (nonatomic, readonly, strong) NSString * systemInfoString;

/**
 A concatenated string representation of the OS version keys from `systemInfo`,
 the following order: `CRSystemInfoSysnameKey`, `CRSystemInfoReleaseKey`,
 `CRSystemInfoMachineKey`
 */
@property (nonatomic, readonly, strong) NSString * systemVersionString;

/**
 @name Getting Memory Usage
 */

/**
 Gets the resident memory size of the binary, as reported by
 [`task_info`](https://www.gnu.org/software/hurd/gnumach-doc/Task-Information.html)
 */
@property (nonatomic, readonly) vm_size_t memoryUsage;

/**
 A human-readable formatted byte count string from the value returned by
 `memoryUsage`
 */
@property (nonatomic, readonly, strong) NSString * memoryUsageString;

@end

NS_ASSUME_NONNULL_END