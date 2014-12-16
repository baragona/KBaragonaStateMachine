//
//  Diagram.h
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 11/3/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StateObject.h"
#import "TransitionObject.h"

@interface Diagram : NSObject


    @property NSArray * states; // array of StateObject

    @property NSMutableArray * transitions;

    + (Diagram *) defaultDiagram;
    - (id) clone;

    - (CGRect) boundingBox;
    - (CGRect) boundingBoxAtAngle: (float) radians;

    - (void) recenterDiagramObjects;

@end
