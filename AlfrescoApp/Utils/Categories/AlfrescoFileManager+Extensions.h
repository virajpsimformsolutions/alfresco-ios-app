//
//  AlfrescoFileManager+Extensions.h
//  AlfrescoApp
//
//  Created by Tauseef Mughal on 12/12/2013.
//  Copyright (c) 2013 Alfresco. All rights reserved.
//

#import "AlfrescoFileManager.h"

@interface AlfrescoFileManager (Extensions)

// preview documents
- (NSString *)documentPreviewDocumentFolderPath;

// thumbnails
- (NSString *)thumbnailsFolderPath;
- (NSString *)thumbnailsMappingFolderPath;
- (NSString *)thumbnailsDocLibFolderPath;
- (NSString *)thumbnailsImgPreviewFolderPath;

// sync
- (NSString *)syncFolderPath;

// downloads
- (NSString *)downloadsFolderPath;
- (NSString *)downloadsInfoContentPath;
- (NSString *)downloadsContentFolderPath;

@end