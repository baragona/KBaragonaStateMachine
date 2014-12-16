//
//  TransitionObject.h
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 11/24/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StateObject.h"

@interface TransitionObject : NSObject
    + initWithLabel: (NSString *) label startState: (StateObject*) start endState: (StateObject*) end;

    @property NSString * label;

    @property float fontSize;


    @property CGPoint positionWhenMovementStarted;


    @property StateObject* startState;
    @property StateObject* endState;

    - (id) clone;

    - (CGRect) boundingBox;
    - (CGRect) boundingBoxAtAngle: (float) radians;

    - (CGPoint) getStartPoint;
    - (CGPoint) getEndPoint;
    - (CGPoint) getMidPoint;
    - (CGPathRef) sensitivePathForDisplayScale: (float) scale;

@end
