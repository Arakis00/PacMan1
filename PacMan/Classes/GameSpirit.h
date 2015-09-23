//
//  GameSpirit.h
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	GameMoveNoneEnum,
	GameMoveLeftEnum,
	GameMoveTopEnum,
	GameMoveRightEnum,
	GameMoveBottomEnum
}GameMoveEnum;

@interface GameSpirit : UIImageView {
	CGPoint endPoint;
	CGFloat speed;
	GameMoveEnum moveEnum;
	
	BOOL isBig;
}

@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGFloat speed;
@property (nonatomic) GameMoveEnum moveEnum;
@property (nonatomic) BOOL isBig;

-(void)moveToNextPoint;
-(void)moveToPoint:(CGPoint)p;
-(BOOL)canMove;

@end
