//
//  GameView.m
//  PacMan
//
//  Created by dashiell gough on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"

#define Grid_Num_H 9
#define Grid_Num_V 13


#define Accelerometer_Interval 1.0/10.0
#define Update_Interval 1.0/30.0

#define Man_Speed 60*Update_Interval
#define Ghost_Speed 30*Update_Interval
#define Eat_GhostTime 6.0

#define OnePea_Score 200


@interface GameView()
-(void)initGame;
-(void)addWallPath:(CGContextRef)context pointX:(CGFloat)px pointY:(CGFloat)py;
-(void)addGhostWithPoint:(CGFloat)px pointY:(CGFloat)py;
-(void)addPeaWithPoint:(CGFloat)px pointY:(CGFloat)py isBig:(BOOL)big;
-(void)addManWithPoint:(CGFloat)px pointY:(CGFloat)py;
-(GameRoleEnum)getRoleEnum:(char)role;

-(void)updateInterval;
-(CGPoint)getCenterWithPoint:(CGFloat)px pointY:(CGFloat)py;
-(GameSpirit*)addSpiritWithPoint:(CGFloat)px pointY:(CGFloat)py spiritSize:(CGSize)size;
-(CGPoint)getGridPointWithPoint:(CGPoint)p;
-(BOOL)moveSpiritWidthOrientation:(GameSpirit*)spirit moveEnum:(GameMoveEnum)move setTransform:(BOOL)trans;
@end


@implementation GameView

@synthesize arrayPlayer;
@synthesize arrayGhost;
@synthesize arrayPea;
@synthesize delegate;
@synthesize ghostBlue;
@synthesize ghostRed;

// Initialize the game
-(void)initGame{
	map = NULL;
	[self setBackgroundColor:[UIColor blackColor]];
	arrayPea = [[NSMutableArray alloc] init];
	arrayPlayer = [[NSMutableArray alloc] init];
	arrayGhost = [[NSMutableArray alloc] init];
	
	ghostBlue = [[UIImage imageNamed:@"blue_enemy.png"] retain];
	ghostRed = [[UIImage imageNamed:@"red_enemy.png"] retain];
	
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = self;
	accelerometer.updateInterval = Accelerometer_Interval;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initGame];
	}
    return self;
}

- (void) awakeFromNib{
	[super awakeFromNib];
	[self initGame];
}

// According to the map data, determine what object is at the position
-(GameRoleEnum)getRoleEnum:(char)role{
	if ("#"[0] == role) {
		return GameRoleWallEnum;
	}
	if("X"[0] == role){
		return GameRoleGhostEnum;
	}
	if("M"[0] == role){
		return GameRoleManEnum;
	}
	if ("o"[0] == role) {
		return GameRoleSmallPeaEnum;
	}
	if("O"[0] == role){
		return GameRoleBigPeaEnum;
	}
	return GameRoleNoneEnum;
}


-(GameRoleEnum)getRoleEnumByPoint:(CGFloat)px pointY:(CGFloat)py{
	if (px < 0 || px >= Grid_Num_H) {
		return GameRoleWallEnum;
	}
	
	if (py < 0 || py >= Grid_Num_V) {
		return GameRoleWallEnum;
	}
	
	int num = px + (py * Grid_Num_H);
	return [self getRoleEnum:map[num]];
}

// Set up the map
-(void) setMap:(NSString *)m{
	NSArray *array = [m componentsSeparatedByString:@"\n"];
	int count = [array count];
	if (count == Grid_Num_V) {
		char *mapTemp = new char[Grid_Num_H*Grid_Num_V];
		for (int i=0; i<count; i++) {
			NSString *s = [array objectAtIndex:i];
			if ([s length] == Grid_Num_H) {
				const char *uu = [s UTF8String];
				if (i == 0) strcpy(mapTemp, uu);
				else strcat(mapTemp,uu);
			}
			else {
				delete mapTemp;
				return;
			}
		}
		if (map) delete map;
		map = mapTemp;
	}
	[self restartGame];
}

// Set the grid size
-(void) layoutSubviews{
	[super layoutSubviews];
	gridWidth = self.bounds.size.width / Grid_Num_H;
	gridHeight = self.bounds.size.height / Grid_Num_V;
}

// draw the level
-(void) drawRect:(CGRect)rect{
	while ([[self subviews] count]) {
		[[[self subviews] lastObject] removeFromSuperview];
	}
	
	if (map) {
		[arrayGhost removeAllObjects];
		[arrayPea removeAllObjects];
		[arrayPlayer removeAllObjects];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
		
		for (int i=0; i<Grid_Num_H * Grid_Num_V; i++) {
			char s = map[i];
			GameRoleEnum roleEnum = [self getRoleEnum:s];
			int x = i%Grid_Num_H;
			int y = i/Grid_Num_H;
			switch (roleEnum) {
				case GameRoleWallEnum:
					[self addWallPath:context pointX:x pointY:y];
					break;
				case GameRoleManEnum:
					[self addManWithPoint:x pointY:y];
					break;
				case GameRoleGhostEnum:
					[self addGhostWithPoint:x pointY:y];
					break;
				case GameRoleSmallPeaEnum:
					[self addPeaWithPoint:x pointY:y isBig:NO];
					break;
				case GameRoleBigPeaEnum:
					[self addPeaWithPoint:x pointY:y isBig:YES];
					break;
				default:
					break;
			}
		}
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
		CGContextFillPath(context);
		
		for (GameSpirit *spirit in arrayGhost) {
			[self bringSubviewToFront:spirit];
		}
		for (GameSpirit *spirit in arrayPlayer) {
			[self bringSubviewToFront:spirit];
		}
	}
}

// add a wall
-(void)addWallPath:(CGContextRef)context pointX:(CGFloat)px pointY:(CGFloat)py{
	CGRect rect = CGRectMake(px*gridWidth, py*gridHeight, gridWidth, gridHeight);
	CGContextAddRect(context, rect);
}

// add a spirit
-(void)addGhostWithPoint:(CGFloat)px pointY:(CGFloat)py{
	GameSpirit *spirit = [self addSpiritWithPoint:px pointY:py spiritSize:CGSizeMake(27,27)];
	[spirit setImage:ghostBlue];
	[spirit setSpeed:Ghost_Speed];
	[arrayGhost addObject:spirit];
}

//add a pea
-(void)addPeaWithPoint:(CGFloat)px pointY:(CGFloat)py isBig:(BOOL)big{	
	GameSpirit *spirit = [self addSpiritWithPoint:px pointY:py spiritSize:CGSizeMake((big)?25:15, (big)?25:15)];
	spirit.isBig = big;
	[spirit setImage:[UIImage imageNamed:@"item_pickup.png"]];
	[arrayPea addObject:spirit];
}

//add the hero
-(void)addManWithPoint:(CGFloat)px pointY:(CGFloat)py{
	GameSpirit *spirit = [self addSpiritWithPoint:px pointY:py spiritSize:CGSizeMake(27, 27)];
	[spirit setImage:[UIImage imageNamed:@"player.png"]];
	[spirit setSpeed:Man_Speed];
	[arrayPlayer addObject:spirit];
}

// get a spririt at a point
-(GameSpirit*)addSpiritWithPoint:(CGFloat)px pointY:(CGFloat)py spiritSize:(CGSize)size{
	CGPoint centerP = [self getCenterWithPoint:px pointY:py];
	GameSpirit *spirite = [[GameSpirit alloc] initWithFrame:CGRectMake(0, 0, size.width,size.height)];
	[spirite setEndPoint:centerP];
	[spirite moveToPoint:centerP];
	[self addSubview:spirite];
	return spirite;
}


-(CGPoint)getCenterWithPoint:(CGFloat)px pointY:(CGFloat)py{
	return CGPointMake(px*gridWidth + gridWidth/2, py*gridHeight + gridHeight/2);
}


-(CGPoint)getGridPointWithPoint:(CGPoint)p{
	return CGPointMake((int)((p.x - gridWidth/2)/gridWidth), (int)((p.y - gridHeight/2)/gridHeight));
}


-(void)startGame{
	[self stopGame];
	
	gameTimer = [NSTimer scheduledTimerWithTimeInterval:Update_Interval target:self selector:@selector(updateInterval) userInfo:nil repeats:YES];
	isPlaying = YES;
}


-(void)restartGame{
	[self setNeedsDisplay];
	manScore = 0;
	if (delegate) 
		[delegate gameView:self gameScore:manScore];
	[self startGame];
}


-(void)stopGame{
	if (gameTimer) {
		[gameTimer invalidate];
		gameTimer = nil;
		isPlaying = NO;
		manEatGhostTime = 0;
		manMoveEnum = GameMoveNoneEnum;
	}
}

// move the spirit left/right/up/down
-(BOOL)moveSpiritWidthOrientation:(GameSpirit*)spirit moveEnum:(GameMoveEnum)move setTransform:(BOOL)trans{
	CGPoint gridPoint = [self getGridPointWithPoint:spirit.endPoint];
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch (move) {
		case GameMoveTopEnum:
			gridPoint.y -= 1;
			transform = CGAffineTransformMakeRotation(-M_PI/2);
			break;
		case GameMoveBottomEnum:
			gridPoint.y += 1;
			transform = CGAffineTransformMakeRotation(M_PI/2);
			break;
		case GameMoveLeftEnum:
			gridPoint.x -= 1;
			transform = CGAffineTransformMakeScale(-1, 1);
			break;
		case GameMoveRightEnum:
			gridPoint.x += 1;
			break;
	}
	
	GameRoleEnum roleEnum = [self getRoleEnumByPoint:gridPoint.x pointY:gridPoint.y];
	if (roleEnum != GameRoleWallEnum) {
		spirit.moveEnum = manMoveEnum;//move;
		[spirit setEndPoint:[self getCenterWithPoint:gridPoint.x pointY:gridPoint.y]];
		
		if (trans) {
//			[UIView beginAnimations:nil context:nil];
//			[UIView setAnimationDuration:0.1];
			[spirit setTransform:transform];
//			[UIView commitAnimations];
		}
		
		return YES;
	}
	else {
		if (gridPoint.x == -1 || gridPoint.x == Grid_Num_H) {
			gridPoint.x = (gridPoint.x == Grid_Num_H)?0:Grid_Num_H - 1;
			GameRoleEnum roleEnum = [self getRoleEnumByPoint:gridPoint.x pointY:gridPoint.y];
			if (roleEnum != GameRoleWallEnum){
				CGPoint center = [self getCenterWithPoint:gridPoint.x pointY:gridPoint.y];
				[spirit setEndPoint:center];
				[spirit moveToPoint:center];
			}
			return YES;
		}
	}
	
	return NO;
}

// update & refresh
-(void)updateInterval{
	manEatGhostTime -= Update_Interval;
	if (manEatGhostTime < 0) manEatGhostTime = 0;
	
	for (GameSpirit *player in arrayPlayer) {
		if ([player canMove]) {
			if (player.moveEnum == manMoveEnum) {
				[player moveToNextPoint];
			}
			else {
				BOOL playIsH = player.moveEnum == GameMoveLeftEnum || player.moveEnum == GameMoveRightEnum;
				BOOL moveIsH = manMoveEnum == GameMoveLeftEnum || manMoveEnum == GameMoveRightEnum;
				BOOL playIsV = player.moveEnum == GameMoveTopEnum || player.moveEnum == GameMoveBottomEnum;
				BOOL moveIsV = manMoveEnum == GameMoveTopEnum || manMoveEnum == GameMoveBottomEnum;
				
				if (playIsH && moveIsH)
					[self moveSpiritWidthOrientation:player moveEnum:manMoveEnum setTransform:YES];
				else if(playIsV && moveIsV)
					[self moveSpiritWidthOrientation:player moveEnum:manMoveEnum setTransform:YES];
				else [player moveToNextPoint];
			}
		}
		else [self moveSpiritWidthOrientation:player moveEnum:manMoveEnum setTransform:YES];
		
		CGRect rectPlayer = player.frame;
		
		for (GameSpirit *pea in arrayPea) {
			CGRect rectPea = pea.frame;
			CGFloat intersect = rectPea.size.width/3*2;
			CGRect rect = CGRectIntersection(rectPlayer, rectPea);
			
			if(MIN(rect.size.width,rect.size.height) > intersect){
				[pea removeFromSuperview];
				[arrayPea removeObject:pea];
				manScore += OnePea_Score;
				
				if(pea.isBig) 
					manEatGhostTime = Eat_GhostTime;
				
				if (delegate) 
					[delegate gameView:self gameScore:manScore];
				
				if (![arrayPea count]) {
					[self stopGame];
					if (self.delegate) {
						[self.delegate gameView:self isWin:YES];
					}
				}
				
				break;
			}
		}
	}
	
	
	for (GameSpirit *ghost in arrayGhost) {
		if (manEatGhostTime){
			if (ghost.image != ghostRed) {
				ghost.image  = ghostRed;
			}
		}
		else {
			if (ghost.image != ghostBlue) {
				ghost.image = ghostBlue;
			}
		}
		
		if (ghost.alpha != 1.0) continue;
		
		if ([ghost canMove]) {
			[ghost moveToNextPoint];
		}
		else {
			GameMoveEnum e = ghost.moveEnum;
			while (true) {
				if (e != GameMoveNoneEnum) {
					if ([self moveSpiritWidthOrientation:ghost moveEnum:e setTransform:NO]) {
						break;
					}
				}
				e = (GameMoveEnum)(arc4random()%4);
			}
		}
		
		CGRect rectGhost = ghost.frame;
		for (GameSpirit *player in arrayPlayer) {
			CGRect rectPlayer = player.frame;
			CGFloat intersect = rectPlayer.size.width/3;
			CGRect rect = CGRectIntersection(rectPlayer, rectGhost);
			if(MIN(rect.size.width,rect.size.height) > intersect){
				if (manEatGhostTime) {
					[ghost setAlpha:0];
					[self performSelector:@selector(recoverGhost) withObject:nil afterDelay:2.0];
				}
				else {
					[self stopGame];
					if (self.delegate) {
						[self.delegate gameView:self isWin:NO];
					}
				}
				break;
			}
		}
	}
}

// respawn/recover a spirit
-(void)recoverGhost{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.8f];
	for (GameSpirit *ghost in arrayGhost){
		if (ghost.alpha != 1) {
			ghost.alpha = 1.0;
		}
	}
	[UIView commitAnimations];
}

// get direction from accelerometer
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	if (isPlaying) {
		if (fabsf(acceleration.x) > fabsf(acceleration.y))
			manMoveEnum = (acceleration.x > 0)?GameMoveRightEnum:GameMoveLeftEnum;
		else
			manMoveEnum = (acceleration.y > 0)?GameMoveTopEnum:GameMoveBottomEnum;
	}
}


- (void)dealloc {
	[self stopGame];
	delete map;
	
	[ghostRed release];
	[ghostBlue release];
	[arrayPlayer release];
	[arrayGhost release];
	[arrayPea release];
	[self setDelegate:nil];
    [super dealloc];
}


@end
