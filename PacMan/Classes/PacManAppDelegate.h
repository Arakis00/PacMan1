//
//  PacManAppDelegate.h
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameView.h"

@interface PacManAppDelegate : NSObject <UIApplicationDelegate,GameViewDelegate,UIAlertViewDelegate> {
    UIWindow *window;
	
	GameView *game;
	UILabel *lbScore;
	BOOL isWin;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GameView *game;
@property (nonatomic, retain) IBOutlet UILabel *lbScore;

-(IBAction)restartClick:(id)sender;

@end

