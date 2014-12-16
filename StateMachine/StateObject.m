//
//  StateObject.m
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 11/3/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import "StateObject.h"

@implementation StateObject

- (id) init{
    self = [super init];
    
    
    self.position = CGPointMake(0,0);
    
    self.rectWidth = 100;
    
    self.label = @"";
    
    self.fontSize = 10;
    self.didCalculateFontSize = 0;
    
    return self;
}

+ initWithLabel: (NSString *) label position:(CGPoint) p{
    
    StateObject * state = [[StateObject alloc] init];

    
    state.position = p;
    state.label = label;

    return state;

}

- (id) clone{
    StateObject * new = [[StateObject alloc] init];

    new.position = self.position;
    new.rectWidth = self.rectWidth;
    new.label = self.label;
    new.positionWhenMovementStarted = self.positionWhenMovementStarted;
    new.fontSize = self.fontSize;
    new.didCalculateFontSize = self.didCalculateFontSize;

    return new;
}

-(CGRect) rectCenteredAt: (CGPoint) where width:(CGFloat) w height:(CGFloat) h{
    CGPoint center =CGPointZero;
    return CGRectMake(center.x+where.x-(w/2.0), center.y+where.y-(h/2.0), w, h);
}

-(CGRect) boundingBox{
    CGRect stateBox =[self rectCenteredAt: self.position  width:[self rectWidth] height:[self rectWidth]];
    
    return stateBox;
}

-(CGRect) boundingBoxAtAngle: (float) radians{
    CGRect stateBox =[self rectCenteredAt: CGPointApplyAffineTransform(self.position, CGAffineTransformMakeRotation(radians)) width:[self rectWidth] height:[self rectWidth]];
    
    return stateBox;
}

@end
