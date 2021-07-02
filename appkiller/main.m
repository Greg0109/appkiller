#include <stdio.h>
#import <Foundation/Foundation.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
		if (argc > 1) {
			printf("Killing multiple apps!\n");
			NSString *appArray = [NSString stringWithUTF8String:argv[1]];
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.appkiller/multipleapps" object:nil userInfo:@{@"appArray" : appArray}];
		} else {
			printf("Killing app!\n");
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.appkiller/singleapp" object:nil userInfo:nil];
		}
		return 0;
	}
	
}
