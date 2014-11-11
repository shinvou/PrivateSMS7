#import <Preferences/Preferences.h>

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.privatesms7.plist"

@interface PSMS7SettingsListController: PSListController { }
@end

@implementation PSMS7SettingsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        [self setTitle:@"PrivateSMS7"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Save hidden/unhidden state"];
        [firstGroup setProperty:@"Save hidden/unhidden state across resprings, reboots and so on.\n\nIf this is not enabled, MobileSMS will automatically launch with a hidden chat history after a respring/reboot or when not running in background." forKey:@"footerText"];
        
        PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                                 target:self
                                                                    set:@selector(setValue:forSpecifier:)
                                                                    get:@selector(getValueForSpecifier:)
                                                                 detail:Nil
                                                                   cell:PSSwitchCell
                                                                   edit:Nil];
        [enabled setIdentifier:@"enabled"];
        [enabled setProperty:@(YES) forKey:@"enabled"];
        
        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"contact developer"];
        [secondGroup setProperty:@"Feel free to follow me on twitter for any updates on my apps and tweaks or contact me for support questions.\n \nThis tweak is Open-Source, so make sure to check out my GitHub." forKey:@"footerText"];
        
        PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"twitter"
                                                              target:self
                                                                 set:nil
                                                                 get:nil
                                                              detail:Nil
                                                                cell:PSLinkCell
                                                                edit:Nil];
        twitter.name = @"@biscoditch";
        twitter->action = @selector(openTwitter);
        [twitter setIdentifier:@"twitter"];
        [twitter setProperty:@(YES) forKey:@"enabled"];
        [twitter setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/PSMS7Settings.bundle/twitter.png"] forKey:@"iconImage"];
        
        PSSpecifier *github = [PSSpecifier preferenceSpecifierNamed:@"github"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:Nil
                                                               cell:PSLinkCell
                                                               edit:Nil];
        github.name = @"https://github.com/shinvou";
        github->action = @selector(openGithub);
        [github setIdentifier:@"github"];
        [github setProperty:@(YES) forKey:@"enabled"];
        [github setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/PSMS7Settings.bundle/github.png"] forKey:@"iconImage"];
        
        [specifiers addObject:firstGroup];
        [specifiers addObject:enabled];
        [specifiers addObject:secondGroup];
        [specifiers addObject:twitter];
        [specifiers addObject:github];
        
        _specifiers = specifiers;
    }
    
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    
    if (settings) {
        if ([settings objectForKey:@"saveState"]) {
            if ([[settings objectForKey:@"saveState"] boolValue]) {
                return [NSNumber numberWithBool:YES];
            }
        }
    }
    
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    [defaults setObject:value forKey:@"saveState"];
    [defaults writeToFile:settingsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.privatesms7/reloadSettings"), NULL, NULL, TRUE);
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=biscoditch"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/biscoditch"]];
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/shinvou"]];
}

@end
