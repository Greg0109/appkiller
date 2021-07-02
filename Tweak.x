#import <libactivator/libactivator.h>
#import "BackBoardServices.h"
#include "NSTask.h"

@interface AppKillerActivateActivatorListener : NSObject <LAListener>
@end

@interface SBApplicationProcessState : NSObject
-(int)pid;
-(BOOL)isRunning;
@end

@interface SBApplication
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@property (nonatomic,readonly) NSString * iconIdentifier;
@property (nonatomic,readonly) NSString * displayName;
@property (setter=_setInternalProcessState:,getter=_internalProcessState,retain) SBApplicationProcessState * internalProcessState;
-(id)_internalProcessState;
@end

@interface SBApplicationController : NSObject
-(id)applicationWithBundleIdentifier:(id)arg1 ;
@end

@interface SBLockStateAggregator : NSObject
+(id)sharedInstance;
-(id)init;
-(void)dealloc;
-(id)description;
-(unsigned long long)lockState;
-(void)_updateLockState;
-(BOOL)hasAnyLockState;
-(id)_descriptionForLockState:(unsigned long long)arg1 ;
@end

@interface SpringBoard : UIApplication
- (UIApplication *)_accessibilityFrontMostApplication;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end

NSString *currentRunningAppID;

void killapp() {
	if (currentRunningAppID != nil) {
		SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:currentRunningAppID];
		SBApplicationProcessState *state = [app _internalProcessState];
		int apppid = [state pid];
		NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/kill"];
		[task setArguments:@[[NSString stringWithFormat:@"%i",apppid]]];
		[task launch];

		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

		dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
			NSTask *opentask = [[NSTask alloc] init];
			[opentask setLaunchPath:@"/usr/bin/open"];
			[opentask setArguments:@[currentRunningAppID]];
			[opentask launch];
		});
	}
}

void killapps(NSString *appIDs) {
	NSArray *appArray = [appIDs componentsSeparatedByString:@","];
	for (NSString *appIDNoFix in appArray) {
		NSString *appID = [appIDNoFix stringByReplacingOccurrencesOfString:@" " withString:@""];

		SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appID];
		SBApplicationProcessState *state = [app _internalProcessState];
		int apppid = [state pid];
		NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/kill"];
		[task setArguments:@[[NSString stringWithFormat:@"%i",apppid]]];
		[task launch];

		NSTask *opentask = [[NSTask alloc] init];
		[opentask setLaunchPath:@"/usr/bin/open"];
		[opentask setArguments:@[appID]];
		[opentask launch];
	}
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.appkiller/singleapp" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      killapp();
  }];
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.appkiller/multipleapps" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
	  NSString *array = notification.userInfo[@"appArray"];
      killapps(array);
  }];
  %orig;
}

-(void)frontDisplayDidChange:(SBApplication *)arg1 {
	if (![[NSString stringWithFormat:@"%@",arg1] containsString:@"Overlay"]) {
		if ((arg1.displayName != nil) && (arg1.bundleIdentifier != nil)) {
			currentRunningAppID = arg1.bundleIdentifier;
		}
	}
	%orig;
}
%end

@implementation AppKillerActivateActivatorListener
-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	killapp();
}

+(void)load {
  @autoreleasepool {
    [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.greg0109.appKiller.activate"];
  }
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Activate AppKiller";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Kills current running app";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
    return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"AppKiller";
}
@end