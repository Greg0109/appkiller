#line 1 "Tweak.x"
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
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     
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


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; @class SBApplicationController; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SpringBoard$frontDisplayDidChange$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, SBApplication *); static void _logos_method$_ungrouped$SpringBoard$frontDisplayDidChange$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, SBApplication *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBApplicationController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBApplicationController"); } return _klass; }
#line 47 "Tweak.x"
void killapp() {
	if (currentRunningAppID != nil) {
		SBApplication *app = [[_logos_static_class_lookup$SBApplicationController() sharedInstance] applicationWithBundleIdentifier:currentRunningAppID];
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

		SBApplication *app = [[_logos_static_class_lookup$SBApplicationController() sharedInstance] applicationWithBundleIdentifier:appID];
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


static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.appkiller/singleapp" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      killapp();
  }];
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.appkiller/multipleapps" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
	  NSString *array = notification.userInfo[@"appArray"];
      killapps(array);
  }];
  _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
}

static void _logos_method$_ungrouped$SpringBoard$frontDisplayDidChange$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBApplication * arg1) {
	if (![[NSString stringWithFormat:@"%@",arg1] containsString:@"Overlay"]) {
		if ((arg1.displayName != nil) && (arg1.bundleIdentifier != nil)) {
			currentRunningAppID = arg1.bundleIdentifier;
		}
	}
	_logos_orig$_ungrouped$SpringBoard$frontDisplayDidChange$(self, _cmd, arg1);
}


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
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);}{ MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(frontDisplayDidChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$frontDisplayDidChange$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$frontDisplayDidChange$);}} }
#line 135 "Tweak.x"
