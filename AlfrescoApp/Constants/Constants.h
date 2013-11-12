//
//  Constants.h
//  AlfrescoApp
//
//  Created by Tauseef Mughal on 29/07/2013
//  Copyright (c) 2013 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kMaxItemsPerListingRetrieve;

extern NSString * const kLicenseDictionaries;

extern NSString * const kImageMappingPlist;

extern NSString * const kProtocolHTTP;
extern NSString * const kProtocolHTTPS;

// Notificiations
extern NSString * const kAlfrescoSessionReceivedNotification;
extern NSString * const kAlfrescoAccessDeniedNotification;
extern NSString * const kAlfrescoApplicationPolicyUpdatedNotification;
extern NSString * const kAlfrescoDocumentDownloadedNotification;
extern NSString * const kAlfrescoConnectivityChangedNotification;
extern NSString * const kAlfrescoDocumentUpdatedOnServerNotification;
extern NSString * const kAlfrescoDocumentUpdatedLocallyNotification;
// parameter keys used in the dictionary of notification object
extern NSString * const kAlfrescoDocumentUpdatedDocumentParameterKey;
extern NSString * const kAlfrescoDocumentUpdatedFilenameParameterKey;
extern NSString * const kAlfrescoDocumentDownloadedIdentifierKey;

// Accounts
extern NSString * const kAlfrescoAccountAddedNotification;
extern NSString * const kAlfrescoAccountRemovedNotification;

// Application policy constants
extern NSString * const kApplicationPolicySettings;
extern NSString * const kApplicationPolicyAudioVideo;
extern NSString * const kApplicationPolicyServer;
extern NSString * const kApplicationPolicyUsernameGenerationFormat;
extern NSString * const kApplicationPolicyServerDisplayName;
extern NSString * const kApplicationPolicySettingAudioEnabled;
extern NSString * const kApplicationPolicySettingVideoEnabled;

// Sync
extern NSString * const kSyncObstaclesKey;
extern NSInteger const kDefaultMaximumAllowedDownloadSize;
extern NSString * const kSyncPreference;
extern NSString * const kSyncOnCellular;

// Sync notification constants
extern NSString * const kSyncStatusChangeNotification;
extern NSString * const kSyncObstaclesNotification;

// Confirmation Options
extern NSUInteger const kConfirmationOptionYes;
extern NSUInteger const kConfirmationOptionNo;

// User settings keychain constants
extern NSString * const kApplicationRepositoryUsername;
extern NSString * const kApplicationRepositoryPassword;

// The maximum number of file suffixes that are attempted to avoid file overwrites
extern NSUInteger const kFileSuffixMaxAttempts;

// Custom NSError codes (use Bundle Identifier for error domain)
extern NSInteger const kErrorFileSuffixMaxAttempts;

// Upload image quality setting
extern CGFloat const kUploadJPEGCompressionQuality;

// MultiSelect Actions
extern NSString * const kMultiSelectDelete;

// Thumbnail mappings folder
extern NSString * const kThumbnailMappingFolder;

// Favourites notifications
extern NSString * const kFavouritesDidAddNodeNotification;
extern NSString * const kFavouritesDidRemoveNodeNotification;

// Cache
extern NSInteger const kNumberOfDaysToKeepCachedData;

// Good Services
extern NSString * const kFileTransferServiceName;
extern NSString * const kFileTransferServiceVersion;
extern NSString * const kFileTransferServiceMethod;
extern NSString * const kEditFileServiceName;
extern NSString * const kEditFileServiceVersion;
extern NSString * const kEditFileServiceMethod;
extern NSString * const kSaveEditFileServiceName;
extern NSString * const kSaveEditFileServiceVersion;
extern NSString * const kSaveEditFileServiceSaveEditMethod;
extern NSString * const kSaveEditFileServiceReleaseEditMethod;
// keys to parameters passed to the editFile service
extern NSString * const kEditFileServiceParameterKey; // defined by Good Service - DO NOT CHANGE VALUE
extern NSString * const kEditFileServiceParameterAlfrescoDocument;
extern NSString * const kEditFileServiceParameterAlfrescoDocumentIsDownloaded;
extern NSString * const kEditFileServiceParameterDocumentFileName;

extern NSString * const kAlfrescoOnPremiseServerURLTemplate;

// Cloud Sign Up
extern NSString * const kAlfrescoCloudTermOfServiceUrl;
extern NSString * const kAlfrescoCloudPrivacyPolicyUrl;
extern NSString * const kAlfrescoCloudCustomerCareUrl;
