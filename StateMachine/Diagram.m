//
//  Diagram.m
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 11/3/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import "Diagram.h"

@implementation Diagram


- (id)init{
    self = [super init];
    
    self.states = [NSArray array]; // Initialize with an empty list of states
    self.transitions = [NSMutableArray array];
    return self;
}

- (id) clone{
    Diagram * new = [[Diagram alloc] init];
    //new.states = self.states;
    new.states = [NSMutableArray array];
    //new.transitions = [NSMutableArray arrayWithArray:self.transitions];
    new.transitions = [NSMutableArray array];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
    int i=-1;
    for(StateObject * state in self.states){
        i++;
        StateObject * stateCopy = [state clone];
        [((NSMutableArray*)new.states) addObject:stateCopy];
        [dict setValue:stateCopy forKey:[NSString stringWithFormat:@"%d", ((int) state)]];
    }
    
    for(TransitionObject * transition in self.transitions){
        TransitionObject * transitionCopy = [transition clone];
        
        transitionCopy.startState = [dict valueForKey:[NSString stringWithFormat:@"%d", ((int) transitionCopy.startState)]];
        transitionCopy.endState = [dict valueForKey:[NSString stringWithFormat:@"%d", ((int) transitionCopy.endState)]];
        [new.transitions addObject:transitionCopy];
    }
    
    return new;
}

+ (Diagram *) defaultDiagram{
    
    Diagram * d = [[Diagram alloc] init];
    
    StateObject * state1 = [[StateObject alloc] init];
    
    state1.label = @"State 1";
    
    d.states = [NSArray arrayWithObject:state1];
 
    
    StateObject * state2 = [[StateObject alloc] init];
    
    state2.label = @"State 2";
    state2.position = CGPointMake(100,100);
    
    d.states=[d.states  arrayByAddingObject: state2];
    
    [d.transitions addObject:[TransitionObject initWithLabel:@"Transition" startState:state1 endState:state2]];
    
    return d;
}

-(CGRect) rectCenteredAt: (CGPoint) where width:(CGFloat) w height:(CGFloat) h{
    CGPoint center =CGPointZero;
    return CGRectMake(center.x+where.x-(w/2.0), center.y+where.y-(h/2.0), w, h);
}

-(CGRect) boundingBox{
    if(self.states.count>0){
        CGRect bounds =  CGRectNull;
        for(StateObject * state in self.states){
            
            bounds = CGRectUnion(bounds, [state boundingBox]);
            
        }
        return bounds;
    }else{
        return [self rectCenteredAt:CGPointZero width:100 height:100];
    }
}

- (CGRect) boundingBoxAtAngle: (float) radians{
    if(self.states.count>0){
        CGRect bounds =  CGRectNull;
        for(StateObject * state in self.states){
            
            bounds = CGRectUnion(bounds, [state boundingBoxAtAngle:radians]);
            
        }
        return bounds;
    }else{
        return [self rectCenteredAt:CGPointZero width:100 height:100];
    }
}

- (void) recenterDiagramObjects{

    CGRect boundingBox = [self boundingBox];

    float xcenter = boundingBox.origin.x + boundingBox.size.width/2;
    float ycenter = boundingBox.origin.y + boundingBox.size.height/2;



    for(StateObject * state in self.states){;
        state.position = CGPointMake(state.position.x - xcenter, state.position.y - ycenter);
        
    }
}


@end
