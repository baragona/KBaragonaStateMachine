//
//  StateObject.h
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 11/3/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateObject : NSObject

    + initWithLabel: (NSString *) label position:(CGPoint) p;

    @property CGPoint position;
    @property NSString * label;

    @property float fontSize;

    @property BOOL didCalculateFontSize;

    @property CGPoint positionWhenMovementStarted;

    @property float rectWidth;

    - (id) clone;

    - (CGRect) boundingBox;
    - (CGRect) boundingBoxAtAngle: (float) radians;
@end
