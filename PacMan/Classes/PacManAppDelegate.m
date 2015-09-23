//
//  PacManAppDelegate.m
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PacManAppDelegate.h"

@implementation PacManAppDelegate

@synthesize window;
@synthesize game;
@synthesize lbScore;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [window makeKeyAndVisible];
	
	[game setDelegate:self];
	
	NSString *levelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"level1.map"];
	[game setMap:[NSString stringWithContentsOfFile:levelPath encoding:NSUTF8StringEncoding error:nil]];
    
	[game performSelector:@selector(startGame) withObject:nil afterDelay:1];
    return YES;
}

-(IBAction)restartClick:(id)sender{
	[game restartGame];
}



-(void) gameView:(GameView *)gameView isWin:(BOOL)win{
	isWin = win;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:(win)?@"You Win":@"You Lost" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leve1",@"Level2",nil];
	[alert show];
	[alert release];
}

-(void)gameView:(GameView*)gameView gameScore:(int)score{
	NSString *gameScore = [[NSString stringWithFormat:@"%6d",score] stringByReplacingOccurrencesOfString:@" " withString:@"0"];
	[lbScore setText:gameScore];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSString *levelPath = nil;
	switch (buttonIndex) {
		case 1:
			levelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"level1.map"];
			break;
		case 2:
			levelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"level2.map"];
			break;
	}
	
	if (levelPath) {
		[game setMap:[NSString stringWithContentsOfFile:levelPath encoding:NSUTF8StringEncoding error:nil]];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
