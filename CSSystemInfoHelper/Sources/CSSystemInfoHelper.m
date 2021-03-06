//
//  CSSystemInfoHelper.m
//  CSSystemInfoHelper
//
//  Created by Cătălin Stan on 05/04/16.
//  Copyright © 2016 Cătălin Stan. All rights reserved.
//

#import <CSSystemInfoHelper/CSSystemInfoHelper.h>
#import "CSSystemInfoHelper+Internal.h"

#import "CSSystemInfoProvider.h"
#import "Errors.h"

__attribute__((objc_direct_members))
@interface CSSystemInfoHelper ()

@property (nonatomic, readonly, strong, nullable) id<CSSystemInfoProviderProtocol> systemInfoProvider;

@end

@implementation CSSystemInfoHelper

+ (instancetype)sharedHelper {
    static CSSystemInfoHelper* sharedHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[CSSystemInfoHelper alloc] initWithSystemInfoProvider:CSSystemInfoProvider.sharedProvider];
    });
    return sharedHelper;
}

- (instancetype)initWithSystemInfoProvider:(id<CSSystemInfoProviderProtocol>)systemInfoProvider {
    self = [super init];
    if (self != nil) {
        _systemInfoProvider = systemInfoProvider;
    }
    return self;
}

- (NSArray<CSNetworkInterface *> *)networkInterfaces {
    NSError *error;
    NSArray<CSNetworkInterface *> *networkInterfaces;
    if (!(networkInterfaces = [self.systemInfoProvider queryNetworkInterfaces:&error])) {
        NSLog(@"Error loading network interfaces: %@. %@.", error.localizedDescription, error.localizedFailureReason);
        return nil;
    }
    return networkInterfaces;
}

- (CSSystemInfo *)systemInfo {
    NSError *error;
    CSSystemInfo *systemInfo;
    if (!(systemInfo = [self.systemInfoProvider querySystemInfo:&error])) {
        NSLog(@"Error loading system info: %@. %@.", error.localizedDescription, error.localizedFailureReason);
        return nil;
    }
    return systemInfo;
}

- (vm_size_t)memoryUsage {
    NSError *error;
    vm_size_t memoryUsage = 0;
    if (![self.systemInfoProvider getResidentSize:&memoryUsage error:&error]) {
        NSLog(@"Error getting resident size: %@. %@.", error.localizedDescription, error.localizedFailureReason);
        return 0;
    }
    return memoryUsage;
}

- (NSString *)memoryUsageString {
    return [self formatByteCount:self.memoryUsage];
}

- (vm_size_t)memoryPhysicalFootprint {
    NSError *error;
    vm_size_t memoryPhysicalFootprint = 0;
    if (![self.systemInfoProvider getPhysFootprint:&memoryPhysicalFootprint error:&error]) {
        NSLog(@"Error getting physical memory footprint: %@. %@.", error.localizedDescription, error.localizedFailureReason);
        return 0;
    }
    return memoryPhysicalFootprint;
}

- (NSString *)memoryPhysicalFootprintString {
    return [self formatByteCount:self.memoryPhysicalFootprint];
}

#if TARGET_OS_OSX
- (NSString *)platformUUID {
    static NSString* platformUUID;
    if (!platformUUID) {
        io_registry_entry_t ioRegistryRoot = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/");
        CFStringRef uuidCf = (CFStringRef) IORegistryEntryCreateCFProperty(ioRegistryRoot, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
        IOObjectRelease(ioRegistryRoot);
        platformUUID = CFBridgingRelease(uuidCf);
    }
    return platformUUID;
}
#endif

#pragma mark - Private Helpers

- (NSString *)formatByteCount:(long long)byteCount {
    return [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleMemory];
}

#pragma mark - Deprecated

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

- (NSDictionary<NSString *, NSString *> *)AllIPAddresses {
    NSArray<CSNetworkInterface *> *networkInterfaces = self.networkInterfaces;
    NSMutableDictionary<NSString *, NSString *> *allIPAddresses = [NSMutableDictionary dictionaryWithCapacity:networkInterfaces.count];
    for (CSNetworkInterface *interface in networkInterfaces) {
        if (interface.family != AF_INET) {
            continue;
        }
        allIPAddresses[interface.name] = interface.address;
    }
    return allIPAddresses;
}

- (NSString *)IPAddress {
    NSString *firstInterfaceAddress;
    NSArray<CSNetworkInterface *> *networkInterfaces = self.networkInterfaces;
    for (CSNetworkInterface *interface in networkInterfaces) {
        if (interface.family != AF_INET) {
            continue;
        }
        if ([interface.name isEqualToString:CSSystemInfoHelperDefaultInterface]) {
            return interface.address;
            break;
        }
        if (!firstInterfaceAddress) {
            firstInterfaceAddress = interface.address;
        }
    }
    
    NSString *IPAddress;
    if (!(IPAddress = firstInterfaceAddress)) {
        IPAddress = CSSystemInfoHelperIPAddressNone;
    }
    return IPAddress;
}

#pragma clang diagnostic pop

@end

NSString * const CSSystemInfoHelperIPAddressNone = @"(none)";
NSString * const CSSystemInfoHelperDefaultInterface = @"en0";

