//
//  GameView.h
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSpirit.h"

@protocol GameViewDelegate;


typedef enum{
	GameRoleNoneEnum,
	GameRoleSmallPeaEnum,
	GameRoleBigPeaEnum,
	GameRoleManEnum,
	GameRoleGhostEnum,
	GameRoleWallEnum
}GameRoleEnum;


@interface GameView : UIView <UIAccelerometerDelegate> {
	CGFloat gridWidth;
	CGFloat gridHeight;
	char *map;
	NSMutableArray *arrayPlayer;
	NSMutableArray *arrayGhost;
	NSMutableArray *arrayPea;
	
	NSTimer *gameTimer;
	GameMoveEnum manMoveEnum;
	BOOL isPlaying;
	int manScore;
	CGFloat manEatGhostTime;
	
	id<GameViewDelegate> delegate;
	
	UIImage *ghostBlue;
	UIImage *ghostRed;
}

@property (nonatomic,retain) NSMutableArray *arrayPlayer;
@property (nonatomic,retain) NSMutableArray *arrayGhost;
@property (nonatomic,retain) NSMutableArray *arrayPea;
@property (nonatomic,retain) UIImage *ghostBlue;
@property (nonatomic,retain) UIImage *ghostRed;

@property (nonatomic,assign) id<GameViewDelegate> delegate;

-(void) setMap:(NSString *)m;

-(void)startGame;
-(void)restartGame;
-(void)stopGame;

@end


@protocol GameViewDelegate
-(void)gameView:(GameView*)gameView isWin:(BOOL)win;
-(void)gameView:(GameView*)gameView gameScore:(int)score;
@end
