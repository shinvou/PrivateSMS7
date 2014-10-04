//
//  Tweak.xm
//  PrivateSMS7
//
//  Created by Timm Kandziora on 26.07.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

@interface CKConversationListController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_table;
}
- (id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)composeButtonClicked:(id)clicked;
@end

@interface CKConversationSearcher : NSObject
- (BOOL)searchBarShouldBeginEditing:(id)arg1;
@end

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.privatesms7.plist"

static BOOL hidden = YES;
static BOOL saveState = NO;
static UIBarButtonItem *switchButton = nil;
static UIBarButtonItem *composeButton = nil;

%hook CKConversationListController

%new - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hidden) {
        return 0.0;
    } else {
        return 76.0;
    }
}

- (id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath
{
    if (hidden) {
        UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    } else {
        return %orig;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    %orig;

    if (editing) {
        if (switchButton) {
            switchButton.title = (hidden) ? @"Unhide" : @"Hide";
        } else {
            composeButton = [[self navigationItem].rightBarButtonItem retain];

            switchButton = [[UIBarButtonItem alloc] initWithTitle:@"Unhide" style:UIBarButtonItemStylePlain target:self action:@selector(switch)];
        }

        [[self navigationItem] setRightBarButtonItem:switchButton animated:YES];
    } else {
        [[self navigationItem] setRightBarButtonItem:composeButton animated:YES];
    }
}

- (void)composeButtonClicked:(id)clicked
{
    if (hidden) {
        return;
    } else {
        %orig;
    }
}

%new - (void)switch
{
    hidden = !hidden;

    if (saveState) {
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
        [settings setObject:[NSNumber numberWithBool:hidden] forKey:@"isHidden"];
        [settings writeToFile:settingsPath atomically:YES];
        [settings release];
    }

    [self setEditing:NO animated:YES];
    UITableView *tableView = MSHookIvar<UITableView *>(self, "_table");
    [tableView reloadData];
}

%end

%hook CKConversationSearcher

- (BOOL)searchBarShouldBeginEditing:(id)arg1
{
    if (hidden) {
        return NO;
    } else {
        return %orig;
    }
}

%end

static void ReloadSettings()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"saveState"]) {
            system("killall -9 MobileSMS");

            saveState = [[settings objectForKey:@"saveState"] boolValue];

            if (saveState) {
                if ([settings objectForKey:@"isHidden"]) {
                    hidden = [[settings objectForKey:@"isHidden"] boolValue];
                } else {
                    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"isHidden"];
                    [settings writeToFile:settingsPath atomically:YES];
                }
            }
        }
    }

    [settings release];
}

static void ReloadSettingsOnStartup()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"saveState"]) {
            saveState = [[settings objectForKey:@"saveState"] boolValue];

            if (saveState) {
                if ([settings objectForKey:@"isHidden"]) {
                    hidden = [[settings objectForKey:@"isHidden"] boolValue];
                } else {
                    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"isHidden"];
                    [settings writeToFile:settingsPath atomically:YES];
                }
            }
        }
    }

    [settings release];
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.privatesms7/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettingsOnStartup();
	}
}
