//
//  TransitionObject.m
//  KBaragonatransitionMachine
//
//  Created by Kevin Baragona on 11/24/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import "TransitionObject.h"

@implementation TransitionObject
- (id) init{
    self = [super init];
    
    self.label = @"";
    
    self.fontSize = 10;
    
    return self;
}

+ initWithLabel: (NSString *) label startState: (StateObject*) start endState: (StateObject*) end{
    
    TransitionObject * transition = [[TransitionObject alloc] init];

    transition.startState = start;
    transition.endState = end;
    transition.label = label;

    return transition;

}

- (id) clone{
    TransitionObject * new = [[TransitionObject alloc] init];
    new.startState = self.startState;
    new.endState = self.endState;
    new.label = self.label;
    new.positionWhenMovementStarted = self.positionWhenMovementStarted;
    new.fontSize = self.fontSize;

    return new;
}

-(CGRect) rectCenteredAt: (CGPoint) where width:(CGFloat) w height:(CGFloat) h{
    CGPoint center =CGPointZero;
    return CGRectMake(center.x+where.x-(w/2.0), center.y+where.y-(h/2.0), w, h);
}

-(CGRect) boundingBox{
    CGRect transitionBox =CGRectZero;
    
    return transitionBox;
}

-(CGRect) boundingBoxAtAngle: (float) radians{
    CGRect transitionBox =CGRectZero;
    
    return transitionBox;
}

- (CGPathRef) sensitivePathForDisplayScale: (float) scale{
    CGMutablePathRef line = CGPathCreateMutable();
    CGPoint endpoints[]={[self getEndPoint],[self getStartPoint]};
    CGPathAddLines(line, nil, endpoints, 2);
    CGPathRef sensitivePath = CGPathCreateCopyByStrokingPath(line, NULL, 30.0/scale, kCGLineCapButt, kCGLineJoinMiter, 0);
    CGPathRelease(line);
    return sensitivePath;
}


-(CGPoint) getStartPoint{
    StateObject * startState = self.startState;
    StateObject * endState = self.endState;
    
    CGPoint start = startState.position;
    CGPoint end = endState.position;
    
    float xdir = end.x-start.x;
    float ydir = end.y-start.y;
    
    float dist = sqrtf(xdir*xdir + ydir*ydir);
    if(dist<=0){
        dist = 1;
    }
    xdir /= dist;
    ydir /= dist;
    
    float startRadius = [startState rectWidth]/2;
    
    start.x += xdir*startRadius;
    start.y += ydir*startRadius;
    
    return start;
    
}

-(CGPoint) getEndPoint{
    StateObject * startState = self.startState;
    StateObject * endState = self.endState;
    
    CGPoint start = startState.position;
    CGPoint end = endState.position;
    
    float xdir = end.x-start.x;
    float ydir = end.y-start.y;
    
    float dist = sqrtf(xdir*xdir + ydir*ydir);
    if(dist<=0){
        dist = 1;
    }
    xdir /= dist;
    ydir /= dist;
    
    float endRadius   = [endState rectWidth]/2;

    
    end.x -= xdir*endRadius;
    end.y -= ydir*endRadius;
    
    
    return end;
    
}
-(CGPoint) getMidPoint{
    
    CGPoint a = [self getStartPoint];
    CGPoint b = [self getEndPoint];
    
    a.x += b.x;
    a.y += b.y;
    
    a.x /=2;
    a.y /=2;
    return a;
}


@end
