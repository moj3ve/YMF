#import <Foundation/Foundation.h>
#import <dlfcn.h>

BOOL pipEnabled, MessEnabled, YTNoAdEnabled, YTBGEnabled, FBEnabled, TWEnabled, RedEnabled, InstaEnabled;

//Messenger No Ads
%group Messenger
//Messenger
@interface MSGThreadListDataSource : NSObject
- (NSArray *)inboxRows;
@end
%hook MSGThreadListDataSource
- (NSArray *)inboxRows {  
  NSMutableArray *orig = [%orig mutableCopy];
  NSMutableIndexSet *adsIndexes = [[NSMutableIndexSet alloc] init];
  for (int i = 1; i < [orig count]; i++) {
    NSArray *row = orig[i];
    NSNumber *type = row[1];
    if ([type intValue] == 2) {
      [adsIndexes addIndex:i];
    }
  }

  [orig removeObjectsAtIndexes:adsIndexes];

  return orig;
}
%end
%end

//Facebook No Ads
%group Facebook
// Facebook Interfaces
@interface FBMemModelObject : NSObject
- (id)initWithFBTree:(void *)arg1;
@end

@interface FBMemNewsFeedEdge : FBMemModelObject
- (id)category;
@end;

@interface FBMemFeedStory : FBMemModelObject
- (id)sponsoredData;
@end

@interface FBVideoChannelPlaylistItem : NSObject
- (id)Bi:(id)arg1 :(id)arg2 :(id)arg3 :(id)arg4 :(id)arg5 :(id)arg6 :(id)arg7;
- (bool)isSponsored;
@end

%hook FBMemNewsFeedEdge

- (id)initWithFBTree:(void *)arg1 {
    id orig = %orig;
    id category = [orig category];
    return category ? [category isEqual:@"ORGANIC"] ? orig : nil : orig;
}

%end

%hook FBMemFeedStory

- (id)initWithFBTree:(void *)arg1 {
    id orig = %orig;
    return [orig sponsoredData] == nil ? orig : nil;
}

%end

%hook FBVideoChannelPlaylistItem

- (id)Bi:(id)arg1 :(id)arg2 :(id)arg3 :(id)arg4 :(id)arg5 :(id)arg6 :(id)arg7 {
    id orig = %orig;
    return [orig isSponsored] ? nil : orig;
}

%end

%end

//Remove Ads Youtube
%group YouTubeNoAds

%hook YTIPlayerResponse
-(bool)isMonetized {
  return 0;
}
%end

%end

//Play Audio In Background Youtube
%group YouTubeBackgroundPlay

%hook YTSingleVideoMediaData

-(bool)isPlayableInBackground {
  return 1;
}

-(bool)isCurrentlyBackgroundable {
  return 1;
}

%end

%hook YTPlaybackData

-(bool)isPlayableInBackground {
  return 1;
}

%end

%hook YTLocalPlaybackController

-(bool)isPlaybackBackgroundable {
  return 1;
}

%end

%end

//Reddit
%group Reddit
@interface Post : NSObject
@end
%hook Post

- (bool)isHidden {  
  if([NSStringFromClass([self classForCoder]) isEqual:@"AdPost"]){
    return 1;
  }
  return %orig;
}

%end

%end
//Twitter
%group Twitter
@interface TFNItemsDataViewController : NSObject
- (id)itemAtIndexPath:(id)arg1;
@end

%hook TFNItemsDataViewController
- (id)tableViewCellForItem:(id)arg1 atIndexPath:(id)arg2 {
  UITableViewCell *tbvCell = %orig;
  id item = [self itemAtIndexPath: arg2];
  if ([item respondsToSelector: @selector(isPromoted)] && [item performSelector:@selector(isPromoted)]) {
    [tbvCell setHidden: YES];
  }
  return tbvCell;  
}

- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2 {
  id item = [self itemAtIndexPath: arg2];
  if ([item respondsToSelector: @selector(isPromoted)] && [item performSelector:@selector(isPromoted)]) {
    return 0;
  }
  return %orig;
}
%end

%end

//Instagram
%group Instagram
@interface IGFeedItem : NSObject
- (BOOL)isSponsored;
- (BOOL)isSponsoredApp;
@end

%hook IGMainFeedListAdapterDataSource
- (NSArray *)objectsForListAdapter:(id)arg1 {
  NSArray *orig = %orig;
  NSMutableArray *objectsNoAds = [@[] mutableCopy];
  for (id object in orig) {
    if ([object isKindOfClass:(NSClassFromString(@"IGFeedItem"))]) {
      if ([object isSponsored] || [object isSponsoredApp]) {
        continue;
      }
    }
    [objectsNoAds addObject:object];
  }
  return objectsNoAds;
}
%end

%hook IGStoryAdPool
- (id)initWithUserSession:(id)arg1 {
  %orig(nil);
  return nil;
}
%end
%end


void loadPrefs() {
    NSString *path = @"/User/Library/Preferences/com.hius.ymfprefs.plist";
    NSString *pathDefault = @"/Library/PreferenceBundles/ymfprefs.bundle/defaults.plist";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
    }
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hius.ymfprefs.plist"];
    if(prefs){
      YTBGEnabled = [[prefs objectForKey:@"ytBgEnabled"] boolValue];
	    YTNoAdEnabled = [[prefs objectForKey:@"ytNadEnabled"] boolValue];
	    FBEnabled = [[prefs objectForKey:@"fbEnabled"] boolValue];
	    MessEnabled = [[prefs objectForKey:@"mEnabled"] boolValue];
	    TWEnabled = [[prefs objectForKey:@"twEnabled"] boolValue];
      RedEnabled = [[prefs objectForKey:@"redEnabled"] boolValue];
      InstaEnabled = [[prefs objectForKey:@"instaEnabled"] boolValue];
    }
}
void request_prefs_update(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo){
     loadPrefs();
}
%ctor {
    @autoreleasepool{
      loadPrefs();
      CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &request_prefs_update, CFSTR("com.hius.ymfprefs/request_prefs_update"), NULL, 0);
      if (YTBGEnabled) %init(YouTubeBackgroundPlay);
	    if (YTNoAdEnabled) %init(YouTubeNoAds);
	    if (FBEnabled) %init(Facebook);
	    if (MessEnabled) %init(Messenger);
      if (TWEnabled) %init(Twitter);
      if (RedEnabled) %init(Reddit);
      if(InstaEnabled){
        dlopen([[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/InstagramAppCoreFramework.framework/InstagramAppCoreFramework"] UTF8String], RTLD_NOW);
        %init(Instagram);
      }
        %init();
    }
}
