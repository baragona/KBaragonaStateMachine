//
//  StateView.h
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 10/26/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>

#import "Diagram.h"

#import <CoreText/CoreText.h>

@interface StateView : UIView <UIGestureRecognizerDelegate>

    @property Diagram * currentDiagram;

    - (void)callbackWithPointOnNextTap:(void(^)(CGPoint p)) block;
    @property (copy) void(^callOnNextTap)(CGPoint p);

    @property (copy) void(^callOnViewWillModifyDiagramSoSaveUndoState)();
    @property (copy) void(^callOnSelectedItemSetChanged)();


    -(void) neverMindNextTap;

    @property (nonatomic)  NSArray * selectedStateIndexes;
    @property (nonatomic)  NSArray * selectedTransitionIndexes;


    -(void) deselectAll;

    -(BOOL) isUserInteracting;

    -(void) rescaleAndTranslateToFit;

    @property CGAffineTransform viewTrans;

    @property float displayAngle;
    @property float displayScale;
    @property CGPoint displayTranslation;

    @property float scaleWhenPinchStarted;
    @property float rotationWhenRotationStarted;
    @property CGPoint displacementWhenPanStarted;

    @property NSMutableArray * lassoSelectionPolygonPoints;
    @property CGPoint moveGestureInitialPoint;
    @property BOOL moveGestureIsLasso;

    @property BOOL viewIsCurrentlyBeingTouched;

    @property NSMutableSet * activeGestureRecognizers;

@end
