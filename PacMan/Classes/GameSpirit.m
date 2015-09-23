//
//  GameSpirit.m
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameSpirit.h"


@implementation GameSpirit

@synthesize endPoint;
@synthesize speed;
@synthesize moveEnum;
@synthesize isBig;

-(id) initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		speed = 0.1;
		moveEnum = GameMoveNoneEnum;
	}
	return self;
}


-(void)moveToNextPoint{
	CGPoint center = self.center;
	if (endPoint.x != center.x) {
		if (center.x < endPoint.x) {
			center.x += speed;
			if (center.x > endPoint.x) center.x = endPoint.x;
		}
		else {
			center.x -= speed;
			if (center.x < endPoint.x) center.x = endPoint.x;
		}
	}
	
	if (endPoint.y != center.y) {
		if (center.y < endPoint.y) {
			center.y += speed;
			if (center.y > endPoint.y) center.y = endPoint.y;
		}
		else {
			center.y -= speed;
			if (center.y < endPoint.y) center.y = endPoint.y;
		}
	}
	
	[self moveToPoint:center];
}

-(void)moveToPoint:(CGPoint)p{
	self.center = p;
}

// check if movement is possible
-(BOOL)canMove{
	CGPoint center = self.center;
	if (center.x == endPoint.x && center.y == endPoint.y) {
		return NO;
	}
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
