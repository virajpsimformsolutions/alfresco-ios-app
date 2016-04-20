/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile iOS App.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "MainMenuConfigurationBuilder.h"
#import "AlfrescoConfigService.h"
#import "ActivitiesViewController.h"
#import "FileFolderListViewController.h"
#import "DownloadsViewController.h"
#import "SyncViewController.h"
#import "TaskViewController.h"
#import "FilteredTaskViewController.h"
#import "NavigationViewController.h"
#import "AccountsViewController.h"
#import "SettingsViewController.h"
#import "WebBrowserViewController.h"
#import "AppConfigurationManager.h"
#import "AccountManager.h"
#import "FileFolderCollectionViewController.h"
#import "SearchViewController.h"
#import "PersonProfileViewController.h"
#import "SiteMembersViewController.h"
#import "SitesViewController.h"
#import "SyncNavigationViewController.h"
#import "SearchResultsTableViewController.h"

#import "RealmSyncViewController.h"

static NSString * const kMenuIconTypeMappingFileName = @"MenuIconTypeMappings";
static NSString * const kMenuIconIdentifierMappingFileName = @"MenuIconIdentifierMappings";

@interface MainMenuConfigurationBuilder ()
@property (nonatomic, strong) NSDictionary *iconTypeMappings;
@property (nonatomic, strong) NSDictionary *iconIdentifierMappings;
@end

@implementation MainMenuConfigurationBuilder

- (instancetype)initWithAccount:(UserAccount *)account session:(id<AlfrescoSession>)session;
{
    self = [super initWithAccount:account];
    if (self)
    {
        self.configService = [[AppConfigurationManager sharedManager] configurationServiceForAccount:account];
        self.session = session;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:kMenuIconTypeMappingFileName ofType:@"plist"];
        self.iconTypeMappings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        plistPath = [[NSBundle mainBundle] pathForResource:kMenuIconIdentifierMappingFileName ofType:@"plist"];
        self.iconIdentifierMappings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return self;
}

#pragma mark - Public Methods

- (void)sectionsForHeaderGroupWithCompletionBlock:(void (^)(NSArray *))completionBlock
{
    // Accounts Menu Item
    AccountsViewController *accountsController = [[AccountsViewController alloc] initWithConfiguration:self.managedAccountConfiguration session:self.session];
    NavigationViewController *accountsNavigationController = [[NavigationViewController alloc] initWithRootViewController:accountsController];
    MainMenuItem *accountsItem = [MainMenuItem itemWithIdentifier:kAlfrescoMainMenuItemAccountsIdentifier
                                                            title:NSLocalizedString(@"accounts.title", @"Accounts")
                                                            image:[[UIImage imageNamed:@"mainmenu-alfresco.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                      description:nil
                                                  displayType:MainMenuDisplayTypeMaster
                                                 associatedObject:accountsNavigationController];
    
    // Create the accounts section
    MainMenuSection *accountsSection = [MainMenuSection sectionItemWithTitle:nil sectionItems:@[accountsItem]];
    
    completionBlock(@[accountsSection]);
}

- (void)sectionsForContentGroupWithCompletionBlock:(void (^)(NSArray *))completionBlock
{
    AppConfigurationManager *configManager = [AppConfigurationManager sharedManager];
    self.configService = [[AppConfigurationManager sharedManager] configurationServiceForCurrentAccount];

    void (^buildItemsForProfile)(AlfrescoProfileConfig *profile) = ^(AlfrescoProfileConfig *profile) {
        [self.configService retrieveViewGroupConfigWithIdentifier:profile.rootViewId completionBlock:^(AlfrescoViewGroupConfig *rootViewConfig, NSError *rootViewError) {
            if (rootViewError)
            {
                AlfrescoLogError(@"Could not retrieve root config for profile %@", profile.rootViewId);
            }
            else
            {
                AlfrescoLogDebug(@"ViewGroupConfig: %@", rootViewConfig.identifier);
                
                [self buildSectionsForRootView:rootViewConfig completionBlock:completionBlock];
            }
        }];
    };
    
    if(self.account)
    {
        if (self.account == [AccountManager sharedManager].selectedAccount)
        {
            buildItemsForProfile(configManager.selectedProfile);
        }
        else
        {
            [self.configService retrieveDefaultProfileWithCompletionBlock:^(AlfrescoProfileConfig *defaultConfig, NSError *defaultConfigError) {
                if (defaultConfigError)
                {
                    AlfrescoLogError(@"Could not retrieve root config for profile %@", defaultConfig.rootViewId);
                }
                else
                {
                    buildItemsForProfile(defaultConfig);
                }
            }];
        }
    }
    else
    {
        self.configService = [[AppConfigurationManager sharedManager] configurationServiceForNoAccountConfiguration];
        [self.configService retrieveDefaultProfileWithCompletionBlock:^(AlfrescoProfileConfig *defaultConfig, NSError *defaultConfigError) {
            if (defaultConfigError)
            {
                AlfrescoLogError(@"Could not retrieve root config for profile %@", defaultConfig.rootViewId);
            }
            else
            {
                buildItemsForProfile(defaultConfig);
            }
        }];
    }
}

- (void)sectionsForFooterGroupWithCompletionBlock:(void (^)(NSArray *))completionBlock
{
    // Settings Menu Item
    SettingsViewController *settingsController = [[SettingsViewController alloc] initWithSession:self.session];
    NavigationViewController *settingNavigationController = [[NavigationViewController alloc] initWithRootViewController:settingsController];
    MainMenuItem *settingsItem = [MainMenuItem itemWithIdentifier:kAlfrescoMainMenuItemSettingsIdentifier
                                                            title:NSLocalizedString(@"settings.title", @"Settings")
                                                            image:[[UIImage imageNamed:@"mainmenu-settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                      description:nil
                                                      displayType:MainMenuDisplayTypeModal
                                                 associatedObject:settingNavigationController];
    
    // Help Menu Item
    NSString *helpURLString = [NSString stringWithFormat:kAlfrescoHelpURLString, [Utility helpURLLocaleIdentifierForAppLocale]];
    NSString *fallbackURLString = [NSString stringWithFormat:kAlfrescoHelpURLString, [Utility helpURLLocaleIdentifierForLocale:kAlfrescoISO6391EnglishCode]];
    WebBrowserViewController *helpViewController = [[WebBrowserViewController alloc] initWithURLString:helpURLString
                                                                              initialFallbackURLString:fallbackURLString
                                                                                          initialTitle:NSLocalizedString(@"help.title", @"Help Title")
                                                                                 errorLoadingURLString:nil];
    NavigationViewController *helpNavigationController = [[NavigationViewController alloc] initWithRootViewController:helpViewController];
    MainMenuItem *helpItem = [MainMenuItem itemWithIdentifier:kAlfrescoMainMenuItemHelpIdentifier
                                                        title:NSLocalizedString(@"help.title", @"Help")
                                                        image:[[UIImage imageNamed:@"mainmenu-help.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                  description:nil
                                                  displayType:MainMenuDisplayTypeModal
                                             associatedObject:helpNavigationController];
    
    // Create the section
    MainMenuSection *footerSection = [MainMenuSection sectionItemWithTitle:nil sectionItems:@[settingsItem, helpItem]];
    
    completionBlock(@[footerSection]);
}

#pragma mark - Private Methods

- (void)buildSectionsForRootView:(AlfrescoViewGroupConfig *)rootView completionBlock:(void (^)(NSArray *sections))completionBlock
{
    NSMutableArray *sections = [NSMutableArray array];
    [self buildSectionsForRootView:rootView section:nil sectionArray:sections completionBlock:completionBlock];
}

- (void)buildSectionsForRootView:(AlfrescoViewGroupConfig *)rootView
                         section:(MainMenuSection *)section
                    sectionArray:(NSMutableArray *)sectionArray
                 completionBlock:(void (^)(NSArray *sections))completionBlock
{
    for (AlfrescoItemConfig *subItem in rootView.items)
    {
        if ([subItem isKindOfClass:[AlfrescoViewGroupConfig class]])
        {
            // Recursively build the views from the view groups
            [self.configService retrieveViewGroupConfigWithIdentifier:subItem.identifier completionBlock:^(AlfrescoViewGroupConfig *groupConfig, NSError *groupConfigError) {
                if (groupConfigError)
                {
                    AlfrescoLogError(@"Unable to retrieve view group for identifier: %@. Error: %@", subItem.identifier, groupConfigError.localizedDescription);
                }
                else
                {
                    MainMenuSection *newSection = [[MainMenuSection alloc] initWithTitle:groupConfig.label sectionItems:nil];
                    [self buildSectionsForRootView:groupConfig section:newSection sectionArray:sectionArray completionBlock:completionBlock];
                }
            }];
        }
        else if ([subItem isKindOfClass:[AlfrescoViewConfig class]])
        {
            if (!section)
            {
                section = [[MainMenuSection alloc] initWithTitle:subItem.label sectionItems:nil];
            }
            
            // define a block
            void (^createMenuItem)(AlfrescoViewConfig *subItem) = ^(AlfrescoViewConfig *subItem) {
                NSString *bundledIconName = [self imageFileNameForAlfrescoViewConfig:subItem];
                
                id associatedObject = [self associatedObjectForAlfrescoViewConfig:(AlfrescoViewConfig *)subItem];
                // Do not render the view if it's not supported
                if (associatedObject)
                {
                    MainMenuItem *item = [[MainMenuItem alloc] initWithIdentifier:subItem.identifier
                                                                            title:(subItem.label) ?: NSLocalizedString(subItem.identifier, @"Item Title")
                                                                            image:[[UIImage imageNamed:bundledIconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                      description:nil
                                                                      displayType:[self displayTypeForAlfrescoViewConfig:subItem]
                                                                 associatedObject:associatedObject];
                    [section addMainMenuItem:item];
                }
            };
            
            // For some reason there seems to be inline view definition in the embeded JSON configuration file
            // Not sure if this is documented behaviour?
            // Determine if a view retrieval is required
            if (![subItem.type isEqualToString:@"view-id"])
            {
                createMenuItem((AlfrescoViewConfig *)subItem);
            }
            else
            {
                // Retrieve the view using the view identifier
                [self.configService retrieveViewConfigWithIdentifier:subItem.identifier completionBlock:^(AlfrescoViewConfig *viewConfig, NSError *viewConfigError) {
                    if (viewConfigError)
                    {
                        AlfrescoLogError(@"Unable to retrieve view for identifier: %@. Error: %@", subItem.identifier, viewConfigError.localizedDescription);
                    }
                    else
                    {
                        createMenuItem((AlfrescoViewConfig *)subItem);
                    }
                }];
            }
        }
        
    }
    
    // Add the section to the sections array
    if (section)
    {
        [sectionArray addObject:section];
    }
    
    if (completionBlock != NULL)
    {
        completionBlock(sectionArray);
    }
}

- (MainMenuDisplayType)displayTypeForAlfrescoViewConfig:(AlfrescoViewConfig *)viewConfig
{
    MainMenuDisplayType returnDisplayType = MainMenuDisplayTypeMaster;
    
    return returnDisplayType;
}

- (id)associatedObjectForAlfrescoViewConfig:(AlfrescoViewConfig *)viewConfig
{
    NavigationViewController *navigationController = nil;
    id associatedObject = nil;
    
    if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeActivities])
    {
        // Activities
        NSString *siteShortName = viewConfig.parameters[kAlfrescoConfigViewParameterSiteShortNameKey];
        ActivitiesViewController *activityListViewController = [[ActivitiesViewController alloc] initWithSiteShortName:siteShortName session:self.session];
        associatedObject = activityListViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeRepository])
    {
        // File Folder
        NSArray *parameterKeys = viewConfig.parameters.allKeys;
        FileFolderCollectionViewController *fileFolderCollectionViewController = nil;
        
        if ([parameterKeys containsObject:kAlfrescoConfigViewParameterSiteShortNameKey])
        {
            NSString *siteShortName = viewConfig.parameters[kAlfrescoConfigViewParameterSiteShortNameKey];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithSiteShortname:siteShortName sitePermissions:nil siteDisplayName:viewConfig.label session:self.session];
        }
        else if ([parameterKeys containsObject:kAlfrescoConfigViewParameterPathKey])
        {
            NSString *folderPath = viewConfig.parameters[kAlfrescoConfigViewParameterPathKey];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithFolderPath:folderPath folderPermissions:nil folderDisplayName:viewConfig.label session:self.session];
        }
        else if ([parameterKeys containsObject:kAlfrescoConfigViewParameterFolderTypeKey])
        {
            NSString *folderTypeId = viewConfig.parameters[kAlfrescoConfigViewParameterFolderTypeKey];
            NSString *displayName = viewConfig.label;
            
            if ([folderTypeId isEqualToString:kAlfrescoConfigViewParameterFolderTypeMyFiles])
            {
                displayName = displayName ?: NSLocalizedString(@"myFiles.title", @"My Files");
                fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithCustomFolderType:CustomFolderServiceFolderTypeMyFiles folderDisplayName:displayName session:self.session];
            }
            else if ([folderTypeId isEqualToString:kAlfrescoConfigViewParameterFolderTypeShared])
            {
                displayName = displayName ?: NSLocalizedString(@"sharedFiles.title", @"Shared Files");
                fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithCustomFolderType:CustomFolderServiceFolderTypeSharedFiles folderDisplayName:displayName session:self.session];
            }
        }
        else if ([parameterKeys containsObject:kAlfrescoConfigViewParameterNodeRefKey])
        {
            NSString *nodeRef = viewConfig.parameters[kAlfrescoConfigViewParameterNodeRefKey];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithNodeRef:nodeRef folderPermissions:nil folderDisplayName:viewConfig.label session:self.session];
        }
        else
        {
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithFolder:nil folderDisplayName:nil session:self.session];
        }
        
        associatedObject = fileFolderCollectionViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSiteBrowser])
    {
        // Sites
        SitesViewController *sitesListViewController = [[SitesViewController alloc] initWithSession:self.session];
        associatedObject = sitesListViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeTasks])
    {
        // Tasks
        NSDictionary *taskFilters = viewConfig.parameters[kAlfrescoConfigViewParameterTaskFiltersKey];
        if (taskFilters.count > 0)
        {
            TaskViewFilter *filter = [[TaskViewFilter alloc] initWithDictionary:taskFilters];
            FilteredTaskViewController *filteredTaskViewController = [[FilteredTaskViewController alloc] initWithFilter:filter session:self.session];
            associatedObject = filteredTaskViewController;
        }
        else
        {
            TaskViewController *taskListViewController = [[TaskViewController alloc] initWithSession:self.session];
            associatedObject = taskListViewController;
        }
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeFavourites])
    {
        // Favorites
        FileFolderCollectionViewController *favoritesViewController = [[FileFolderCollectionViewController alloc] initForFavoritesWithSession:self.session];
        associatedObject = favoritesViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSync])
    {
        // Sync
        RealmSyncViewController *syncViewController = [[RealmSyncViewController alloc] initWithParentNode:nil andSession:self.session];
        SyncNavigationViewController *syncNavigationController = [[SyncNavigationViewController alloc] initWithRootViewController:syncViewController];
        associatedObject = syncNavigationController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeLocal])
    {
        // Local
        DownloadsViewController *localFilesViewController = [[DownloadsViewController alloc] initWithSession:self.session];
        localFilesViewController.screenNameTrackingEnabled = YES;
        associatedObject = localFilesViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypePersonProfile])
    {
        // Person
        NSString *username = viewConfig.parameters[kAlfrescoConfigViewParameterUsernameKey];
        if (!username)
        {
            username = self.session.personIdentifier;
        }
        
        SiteMembersViewController *personViewController = [[SiteMembersViewController alloc] initWithUsername:username session:self.session];
        associatedObject = personViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypePeople])
    {
        // Site membership
        UIViewController *membersViewController = nil;
        NSString *siteShortName = viewConfig.parameters[kAlfrescoConfigViewParameterSiteShortNameKey];
        if(siteShortName)
        {
            membersViewController = [[SiteMembersViewController alloc] initWithSiteShortName:siteShortName session:self.session displayName:nil];
        }
        else
        {
            NSString *keywords = viewConfig.parameters[kAlfrescoConfigViewParameterKeywordsKey];
            SearchResultsTableViewController *resultsController = [[SearchResultsTableViewController alloc] initWithDataType:SearchViewControllerDataSourceTypeSearchUsers session:self.session pushesSelection:NO];
            [resultsController loadViewWithKeyword:keywords];
            membersViewController = resultsController;
        }
        
        associatedObject = membersViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeGallery])
    {
        // Gallery (Grid)
        NSArray *parameterKeys = viewConfig.parameters.allKeys;
        FileFolderCollectionViewController *galleryViewController = nil;
        
        if ([parameterKeys containsObject:kAlfrescoConfigViewParameterNodeRefKey])
        {
            NSString *nodeRef = viewConfig.parameters[kAlfrescoConfigViewParameterNodeRefKey];
            galleryViewController = [[FileFolderCollectionViewController alloc] initWithNodeRef:nodeRef folderPermissions:nil folderDisplayName:viewConfig.label session:self.session];
            galleryViewController.style = CollectionViewStyleGrid;
        }
        
        associatedObject = galleryViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeDocumentDetails])
    {
        // Document
        NSArray *parameterKeys = viewConfig.parameters.allKeys;
        FileFolderCollectionViewController *fileFolderCollectionViewController = nil;
        
        if([parameterKeys containsObject:kAlfrescoConfigViewParameterPathKey])
        {
            NSString *documentPath = viewConfig.parameters[kAlfrescoConfigViewParameterPathKey];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithDocumentPath:documentPath session:self.session];
        }
        else if ([parameterKeys containsObject:kAlfrescoConfigViewParameterNodeRefKey])
        {
            NSString *documentNodeRef = viewConfig.parameters[kAlfrescoConfigViewParameterNodeRefKey];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithDocumentNodeRef:documentNodeRef session:self.session];
        }
        
        associatedObject = fileFolderCollectionViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSearchRepository])
    {
        // Search repository
        NSArray *parameterKeys = viewConfig.parameters.allKeys;
        FileFolderCollectionViewController *fileFolderCollectionViewController = nil;
        if([parameterKeys containsObject:kAlfrescoConfigViewParameterKeywordsKey])
        {
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:[viewConfig.parameters[kAlfrescoConfigViewParameterIsExactKey] boolValue] includeContent:[viewConfig.parameters[kAlfrescoConfigViewParameterFullTextKey] boolValue]];
            searchOptions.includeDescendants = [viewConfig.parameters[kAlfrescoConfigViewParameterSearchFolderOnlyKey] boolValue];
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithSearchString:viewConfig.parameters[kAlfrescoConfigViewParameterKeywordsKey] searchOptions:searchOptions emptyMessage:nil session:self.session];
        }
        else if ([parameterKeys containsObject:kAlfrescoConfigViewParameterStatementKey])
        {
            fileFolderCollectionViewController = [[FileFolderCollectionViewController alloc] initWithSearchStatement:viewConfig.parameters[kAlfrescoConfigViewParameterStatementKey] session:self.session];
        }
        associatedObject = fileFolderCollectionViewController;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSearch])
    {
        // Search
        SearchViewController *controller = [[SearchViewController alloc] initWithDataSourceType:SearchViewControllerDataSourceTypeLandingPage session:self.session];
        associatedObject = controller;
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSearchAdvanced])
    {
        // TODO: Currently place an empty view controller
        associatedObject = [[UIViewController alloc] init];
    }
    else if ([viewConfig.type isEqualToString:kAlfrescoConfigViewTypeSite])
    {
        // Sites
        NSArray *parameterKeys = viewConfig.parameters.allKeys;
        SitesViewController *sitesListViewController = nil;
        
        if ([parameterKeys containsObject:kAlfrescoConfigViewParameterShowKey])
        {
            SitesListViewFilter filter;
            NSString *showValue = viewConfig.parameters[kAlfrescoConfigViewParameterShowKey];
            if ([showValue isEqualToString:kAlfrescoConfigViewParameterMySitesValue])
            {
                filter = SitesListViewFilterMySites;
            }
            else if ([showValue isEqualToString:kAlfrescoConfigViewParameterFavouriteSitesValue])
            {
                filter = SitesListViewFilterFavouriteSites;
            }
            else if ([showValue isEqualToString:kAlfrescoConfigViewParameterAllSitesValue])
            {
                filter = SitesListViewFilterAllSites;
            }
            else
            {
                filter = SitesListViewFilterNoFilter;
            }
            
            sitesListViewController = [[SitesViewController alloc] initWithSitesListFilter:filter title:viewConfig.label session:self.session];
        }
        else
        {
            sitesListViewController = [[SitesViewController alloc] initWithSession:self.session];
        }
        
        associatedObject = sitesListViewController;
    }
    
    // If the view is supported, wrap it with a NavigationViewController
    if ((associatedObject) && (![associatedObject isKindOfClass:[NavigationViewController class]]))
    {
         navigationController = [[NavigationViewController alloc] initWithRootViewController:associatedObject];
    }
    else if ([associatedObject isKindOfClass:[NavigationViewController class]])
    {
        navigationController = associatedObject;
    }
    
    return navigationController;
}

- (NSString *)imageFileNameForAlfrescoViewConfig:(AlfrescoViewConfig *)viewConfig
{
    NSString *bundledIconName = nil;
    
    if (viewConfig.iconIdentifier)
    {
        bundledIconName = self.iconIdentifierMappings[viewConfig.iconIdentifier];
    }
    else
    {
        bundledIconName = self.iconTypeMappings[viewConfig.type];
    }
    
    if (!bundledIconName)
    {
        bundledIconName = @"mainmenu-help.png";
    }
    
    return bundledIconName;
}

@end
