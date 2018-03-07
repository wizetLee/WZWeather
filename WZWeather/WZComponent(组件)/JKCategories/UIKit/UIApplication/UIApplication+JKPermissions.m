//
//  UIApplication-Permissions.m
//  UIApplication-Permissions Sample
//
//  Created by Jack Rostron on 12/01/2014.
//  Copyright (c) 2014 Rostron. All rights reserved.
//

#import "UIApplication+JKPermissions.h"
#import <objc/runtime.h>

//Import required frameworks
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <EventKit/EventKit.h>

typedef void (^JKLocationSuccessCallback)();
typedef void (^JKLocationFailureCallback)();

static char JKPermissionsLocationManagerPropertyKey;
static char JKPermissionsLocationBlockSuccessPropertyKey;
static char JKPermissionsLocationBlockFailurePropertyKey;

@interface UIApplication () <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *jk_permissionsLocationManager;
@property (nonatomic, copy) JKLocationSuccessCallback jk_locationSuccessCallbackProperty;
@property (nonatomic, copy) JKLocationFailureCallback jk_locationFailureCallbackProperty;
@end


@implementation UIApplication (Permissions)


#pragma mark - Check permissions
-(JKPermissionAccess)hasAccessToBluetoothLE {
    switch ([[[CBCentralManager alloc] init] state]) {
        case CBCentralManagerStateUnsupported:
            return JKPermissionAccessUnsupported;
            break;
            
        case CBCentralManagerStateUnauthorized:
            return JKPermissionAccessDenied;
            break;
            
        default:
            return JKPermissionAccessGranted;
            break;
    }
}

-(JKPermissionAccess)hasAccessToCalendar {
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
        case EKAuthorizationStatusAuthorized:
            return JKPermissionAccessGranted;
            break;
            
        case EKAuthorizationStatusDenied:
            return JKPermissionAccessDenied;
            break;
            
        case EKAuthorizationStatusRestricted:
            return JKPermissionAccessRestricted;
            break;
            
        default:
            return JKPermissionAccessUnknown;
            break;
    }
}

-(JKPermissionAccess)hasAccessToContacts {
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            return JKPermissionAccessGranted;
            break;
            
        case kABAuthorizationStatusDenied:
            return JKPermissionAccessDenied;
            break;
            
        case kABAuthorizationStatusRestricted:
            return JKPermissionAccessRestricted;
            break;
            
        default:
            return JKPermissionAccessUnknown;
            break;
    }
}

-(JKPermissionAccess)hasAccessToLocation {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorized:
            return JKPermissionAccessGranted;
            break;
            
        case kCLAuthorizationStatusDenied:
            return JKPermissionAccessDenied;
            break;
            
        case kCLAuthorizationStatusRestricted:
            return JKPermissionAccessRestricted;
            break;
            
        default:
            return JKPermissionAccessUnknown;
            break;
    }
    return JKPermissionAccessUnknown;
}

-(JKPermissionAccess)hasAccessToPhotos {
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized:
            return JKPermissionAccessGranted;
            break;
            
        case ALAuthorizationStatusDenied:
            return JKPermissionAccessDenied;
            break;
            
        case ALAuthorizationStatusRestricted:
            return JKPermissionAccessRestricted;
            break;
            
        default:
            return JKPermissionAccessUnknown;
            break;
    }
}

-(JKPermissionAccess)hasAccessToReminders {
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusAuthorized:
            return JKPermissionAccessGranted;
            break;
            
        case EKAuthorizationStatusDenied:
            return JKPermissionAccessDenied;
            break;
            
        case EKAuthorizationStatusRestricted:
            return JKPermissionAccessRestricted;
            break;
            
        default:
            return JKPermissionAccessUnknown;
            break;
    }
    return JKPermissionAccessUnknown;
}


#pragma mark - Request permissions
/**
 *  日历
 *
 *  @param accessGranted <#accessGranted description#>
 *  @param accessDenied  <#accessDenied description#>
 */
-(void)jk_requestAccessToCalendarWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}

/**
 *  通讯录
 *
 *  @param accessGranted <#accessGranted description#>
 *  @param accessDenied  <#accessDenied description#>
 */
-(void)jk_requestAccessToContactsWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if(addressBook) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    accessGranted();
                } else {
                    accessDenied();
                }
            });
        });
    }
}

/**
 *  麦克风
 *
 *  @param accessGranted <#accessGranted description#>
 *  @param accessDenied  <#accessDenied description#>
 */
-(void)jk_requestAccessToMicrophoneWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    AVAudioSession *session = [[AVAudioSession alloc] init];
    [session requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}

/**
 *  Core Motion可以让开发者从各个内置传感器那里获取未经修改的传感数据，并观测或响应设备各种运动和角度变化。这些传感器包括陀螺仪、加速器和磁力仪(罗盘)。
 *
 *  @param accessGranted <#accessGranted description#>
 */
-(void)jk_requestAccessToMotionWithSuccess:(void(^)())accessGranted {
    CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [motionManager startActivityUpdatesToQueue:motionQueue withHandler:^(CMMotionActivity *activity) {
        accessGranted();
        [motionManager stopActivityUpdates];
    }];
}

/**
 *  ALAssetsLibrary
 *
 *  @param accessGranted <#accessGranted description#>
 *  @param accessDenied  <#accessDenied description#>
 */
-(void)jk_requestAccessToPhotosWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        accessGranted();
    } failureBlock:^(NSError *error) {
        accessDenied();
    }];
}

/**
 *  事件提醒开发包（EventKit）由事件库、事件源、日历和事件/提醒组成，他们的关系是：事件库用于直接操作日历数据库，日历数据库中的数据按事件源、日历和事件/提醒三级进行分类组织。每个事件源对应一个准帐户，该帐户下可以有多个日历，日历分两类，一类是用于存储事件的日历，一类是用于存储提醒的日历。这里所说的存储，实际就是分类，反过来的，根据子项对父项进行分类。就如两口缸，一口装水，一口沙子一样，这个缸就是上面提及的日历，水相当于事件，沙子相当于提醒。一户人家的院子里可以摆好多口缸，这个院子就相当于帐户，有两个默认帐户，一个是Local，一个是Other。帐户的类型，还可能有iCloud或Gmail帐号等，一般是邮箱附带的，所以就默认对应着该邮箱地址了。就像 大户人家的总管，管好每户的院子，还有每个院子里的缸一样，事件库直接管理所有的帐户和日历，还有日历下的事件或提醒。管理包括增加、修改、查询、删除（CURD）。
 *
 *  @param accessGranted <#accessGranted description#>
 *  @param accessDenied  <#accessDenied description#>
 */
-(void)jk_requestAccessToRemindersWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}


#pragma mark - Needs investigating
/*
 -(void)requestAccessToBluetoothLEWithSuccess:(void(^)())accessGranted {
 //REQUIRES DELEGATE - NEEDS RETHINKING
 }
 */

-(void)jk_requestAccessToLocationWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied {
    self.jk_permissionsLocationManager = [[CLLocationManager alloc] init];
    self.jk_permissionsLocationManager.delegate = self;
    
    self.jk_locationSuccessCallbackProperty = accessGranted;
    self.jk_locationFailureCallbackProperty = accessDenied;
    [self.jk_permissionsLocationManager startUpdatingLocation];
}


#pragma mark - Location manager injection
-(CLLocationManager *)jk_permissionsLocationManager {
    return objc_getAssociatedObject(self, &JKPermissionsLocationManagerPropertyKey);
}

-(void)setJk_permissionsLocationManager:(CLLocationManager *)manager {
    objc_setAssociatedObject(self, &JKPermissionsLocationManagerPropertyKey, manager, OBJC_ASSOCIATION_RETAIN);
}

-(JKLocationSuccessCallback)locationSuccessCallbackProperty {
    return objc_getAssociatedObject(self, &JKPermissionsLocationBlockSuccessPropertyKey);
}

-(void)setJk_locationSuccessCallbackProperty:(JKLocationSuccessCallback)locationCallbackProperty {
    objc_setAssociatedObject(self, &JKPermissionsLocationBlockSuccessPropertyKey, locationCallbackProperty, OBJC_ASSOCIATION_COPY);
}

-(JKLocationFailureCallback)locationFailureCallbackProperty {
    return objc_getAssociatedObject(self, &JKPermissionsLocationBlockFailurePropertyKey);
}

-(void)setJk_locationFailureCallbackProperty:(JKLocationFailureCallback)locationFailureCallbackProperty {
    objc_setAssociatedObject(self, &JKPermissionsLocationBlockFailurePropertyKey, locationFailureCallbackProperty, OBJC_ASSOCIATION_COPY);
}


#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        self.locationSuccessCallbackProperty();
    } else if (status != kCLAuthorizationStatusNotDetermined) {
        self.locationFailureCallbackProperty();
    }
}

@end
