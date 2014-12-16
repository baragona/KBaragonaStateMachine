//
//  StateView.m
//  KBaragonaStateMachine
//
//  Created by Kevin Baragona on 10/26/14.
//  Copyright (c) 2014 Kevin Baragona. All rights reserved.
//

#import "StateView.h"


int getCurrentTimeMS(){
    struct timeval  tv;
    gettimeofday(&tv, NULL);

    int time_in_mill =
         ((int)(((tv.tv_sec) * 1000)) + (tv.tv_usec) / 1000 );
    
    return time_in_mill;
}



@implementation StateView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    return self;
}

-(void)awakeFromNib{
    _displayAngle=0;
    _displayScale=1;
    _displayTranslation=CGPointZero;
    _viewIsCurrentlyBeingTouched=0;
    _selectedStateIndexes=[NSArray array];
    _selectedTransitionIndexes=[NSArray array];
    [self deselectAll];
    _lassoSelectionPolygonPoints=[NSMutableArray array];
    [self updateViewTransformationMatrix];
    
    _activeGestureRecognizers = [NSMutableSet set];
    
    [[CADisplayLink displayLinkWithTarget:self selector: @selector(animationFrameCallback:)] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
float otherscale=1;
-(void)  animationFrameCallback: (CADisplayLink *) sender{
    //NSLog(@"ding\n");
    
    //otherscale=1+((sin(getCurrentTimeMS()/100.0))/100);
    //[self updateViewTransformationMatrix];
    //[self setNeedsDisplay];
}

-(void) setSelectedStateIndexes: (NSArray *) array{
    if([[NSSet setWithArray:array] isEqualToSet:[NSSet setWithArray:_selectedStateIndexes]]){
    
    }else{
        _selectedStateIndexes = array;
        if(_callOnSelectedItemSetChanged){
            _callOnSelectedItemSetChanged();
        }
    }
}
-(NSArray *) getSelectedStateIndexes{
    return _selectedStateIndexes;
}
-(void) setSelectedTransitionIndexes: (NSArray *) array{
    if([[NSSet setWithArray:array] isEqualToSet:[NSSet setWithArray:_selectedTransitionIndexes]]){
    
    }else{
        _selectedTransitionIndexes = array;
        if(_callOnSelectedItemSetChanged){
            _callOnSelectedItemSetChanged();
        }
    }
}
-(NSArray *) getSelectedTransitionIndexes{
    return _selectedTransitionIndexes;
}


- (void)callbackWithPointOnNextTap:(void(^)(CGPoint p)) block{
    _callOnNextTap = block;
}
-(void) neverMindNextTap{
    _callOnNextTap = 0;
}

CGPoint loc;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([touches count]==0){
        _viewIsCurrentlyBeingTouched=0;
    }
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if([touches count]==0){
        _viewIsCurrentlyBeingTouched=0;
    }
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _viewIsCurrentlyBeingTouched=1;
    //printf("touch\n");
    
    //[self drawRect:self.bounds];
    //[self setNeedsDisplay];
    
    _lassoSelectionPolygonPoints=[NSMutableArray array];
    
    id closestTappedState;
    CGFloat minTappedDistance= -1;
    
    int tappedTransitionIndex= -1;
    
    for (UITouch* touch in touches){
        CGPoint p = [touch locationInView:self];

        p=[self convertPointFromScreenSpaceToModelSpace:p];
        
        //p.x -= self.bounds.size.width/2;
        //p.y -= self.bounds.size.height/2;
        
        
        if(_callOnNextTap){
            _callOnNextTap(p);
            _callOnNextTap=0;
            break;
        }
        loc=p;

        //NSLog(@"%f, %f\n" ,p.x,p.y);
        //check if the tap landed on a state
        for (StateObject* state in _currentDiagram.states) {
            CGRect stateSensitiveBox =[self getTapSensitiveRectForState:state];
            
            //if(CGRectContainsPoint(stateBox, p)){
            if([self ellipseInRect: stateSensitiveBox containsPoint:p]){

                
                
                CGFloat distance = [self distanceFromMidpointOfRect:stateSensitiveBox toPoint:p];
                if(distance < minTappedDistance || minTappedDistance<0){
                    minTappedDistance=distance;
                    closestTappedState=state;
                }
            }
        }
        
        for(TransitionObject * transition in _currentDiagram.transitions){
            CGPathRef sensitivepath = [transition sensitivePathForDisplayScale:_displayScale];
            
            if(CGPathContainsPoint(sensitivepath, nil, p, true)){
                tappedTransitionIndex=[_currentDiagram.transitions indexOfObject:transition];
                
            }
            
            CGPathRelease(sensitivepath);
        }
        
        
    }
    NSMutableArray*  tappedStates = [NSMutableArray array];
    if(closestTappedState){
    
        if([_selectedStateIndexes containsObject:@([_currentDiagram.states indexOfObject:closestTappedState])]){
            //tapped part of the current selection...
        }else{
    
            tappedStates = [NSMutableArray arrayWithObject:closestTappedState];
            NSMutableArray * newstates =[NSMutableArray arrayWithArray:_currentDiagram.states];
            [newstates  removeObjectsInArray:tappedStates];
            [newstates  addObjectsFromArray:tappedStates];
            _currentDiagram.states = newstates;
        
            //find the indexes of the objects
            NSMutableArray * selectedIndexes = [NSMutableArray array];
            for(StateObject* state in tappedStates){
                [selectedIndexes addObject:@([_currentDiagram.states indexOfObject:state])];
            }
            [self setSelectedTransitionIndexes:[NSArray array]]; //deselect all transitions
            [self setSelectedStateIndexes: selectedIndexes];
        }
    }else{
    
        if(tappedTransitionIndex>-1){
            [self setSelectedStateIndexes: [NSArray array]];
            [self setSelectedTransitionIndexes:[NSArray arrayWithObject:@(tappedTransitionIndex)]];

        }else{
    
            [self deselectAll]; //tapped empty space Deselect all
        }
    }
    
    [self setNeedsDisplay];


    

}

-(void) deselectAll{
    [self setSelectedStateIndexes: [NSArray array]];
    [self setSelectedTransitionIndexes:[NSArray array]];
}

-(CGPoint) convertPointFromScreenSpaceToModelSpace: (CGPoint) p{
    return CGPointApplyAffineTransform(p,CGAffineTransformInvert(_viewTrans));
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //Do nothing, all movement is handled by gesutre recognizers
}

// Ensure that the all gesture recognizers the view can recognize simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view != self)
        return NO;

    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;

    return YES;
}

-(float) idealDisplayScale{
    CGPoint topLeft = [self getTopLeftDiagramBoundAtCurrentAngle];
    CGPoint botRight = [self getBottomRightDiagramBoundAtCurrentAngle];


    float width = botRight.x - topLeft.x;

    float height = botRight.y - topLeft.y;
    
    float xscale = self.bounds.size.width / width;
    float yscale = self.bounds.size.height / height;

    float fitScale = MIN(xscale, yscale)*.7*_displayScale;
    NSLog(@"Current scale: %f\tscale that fits: %f",_displayScale,fitScale);
    float maxscale = 2;
    float minscale = MIN(fitScale,maxscale);
    float chosen;
    if(_displayScale>maxscale){
        chosen = maxscale;
    }else if(_displayScale<minscale){
        chosen = minscale;
    }else{
        chosen = _displayScale;
    }
    NSLog(@"chose new scale: %f",chosen);
    return chosen;
}

-(CGPoint) idealDisplayTranslation{
    CGPoint topLeft = [self getTopLeftDiagramBoundAtCurrentAngle];
    CGPoint botRight = [self getBottomRightDiagramBoundAtCurrentAngle];
    
    float xcenter = (topLeft.x+botRight.x)/2;
    float ycenter = (topLeft.y+botRight.y)/2;

    CGPoint screenCenter = [self getCenter];

    CGPoint diff = CGPointMake(screenCenter.x-xcenter, screenCenter.y-ycenter);
    
    diff = CGPointMake(_displayTranslation.x + diff.x, _displayTranslation.y + diff.y);
    
    return diff;
}

-(BOOL) isUserInteracting{
    return [_activeGestureRecognizers count] != 0;
}

-(void) rescaleAndTranslateToFit{
        _displayScale = [self idealDisplayScale];
        [self updateViewTransformationMatrix];
        _displayTranslation = [self idealDisplayTranslation];
        [self updateViewTransformationMatrix];
        [self setNeedsDisplay];
        NSLog(@"Rescaling and moving");
}

-(void) gestureEventCommon:(UIGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan ) {
        [_activeGestureRecognizers addObject:sender];
    }
    if ([sender state] == UIGestureRecognizerStateEnded ) {
        [_activeGestureRecognizers removeObject:sender];
    }
    if ([sender state] == UIGestureRecognizerStateCancelled ) {
        [_activeGestureRecognizers removeObject:sender];
    }
    
    if(![self isUserInteracting]){
        [self rescaleAndTranslateToFit];
    }
    
}

- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender {
    
    float scale = ((UIPinchGestureRecognizer *)sender).scale;

    if ([sender state] == UIGestureRecognizerStateBegan ) {
        _scaleWhenPinchStarted=_displayScale;
    }
    if ([sender state] == UIGestureRecognizerStateChanged ) {
        NSLog(@"scale g. %f\n", scale);
        _displayScale = _scaleWhenPinchStarted*scale;
        [self updateViewTransformationMatrix];
        [self setNeedsDisplay];
    }
    [self gestureEventCommon:sender];
}

- (IBAction)handleRotationGesture:(UIGestureRecognizer *)sender {
    
    float rotation = ((UIRotationGestureRecognizer *)sender).rotation;
    if ([sender state] == UIGestureRecognizerStateBegan ) {
        _rotationWhenRotationStarted=_displayAngle;
    }
    if ([sender state] == UIGestureRecognizerStateChanged ) {
        NSLog(@"rotation g. %f\n", rotation);
        _displayAngle = _rotationWhenRotationStarted+rotation;
        [self updateViewTransformationMatrix];
        [self setNeedsDisplay];
    }
    [self gestureEventCommon:sender];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {

    CGPoint displacement = [sender translationInView:self];
    if ([sender state] == UIGestureRecognizerStateBegan ) {
        _displacementWhenPanStarted=_displayTranslation;
    }
    if ([sender state] == UIGestureRecognizerStateChanged ) {
        NSLog(@"panning g. %f, %f\n", displacement.x, displacement.y);
        _displayTranslation =CGPointMake(_displacementWhenPanStarted.x+displacement.x, _displacementWhenPanStarted.y+displacement.y);
        [self updateViewTransformationMatrix];
        [self setNeedsDisplay];
    }
    [self gestureEventCommon:sender];
}

- (IBAction)handleMoveStatesGesture:(UIPanGestureRecognizer *)sender {
    
    CGPoint displacement = [sender translationInView:self];
    CGPoint position = [sender locationInView:self];
    //displacement.x -= self.bounds.size.width/2;
    //displacement.y -= self.bounds.size.height/2;
    
    position = [self convertPointFromScreenSpaceToModelSpace:position];
    

    
    if ([sender state] == UIGestureRecognizerStateBegan ) {
        _moveGestureInitialPoint = position;
        if([_selectedStateIndexes count]>0){
            _moveGestureIsLasso=false;
            _callOnViewWillModifyDiagramSoSaveUndoState();
            for(NSNumber *stateIndex in _selectedStateIndexes){
                StateObject* state = [_currentDiagram.states objectAtIndex:[stateIndex integerValue] ];
                state.positionWhenMovementStarted=state.position;
            }
        }else{
            _moveGestureIsLasso=true;
            _lassoSelectionPolygonPoints=[NSMutableArray array];
        }
        
    }
    if ([sender state] == UIGestureRecognizerStateChanged ) {
        if(_moveGestureIsLasso){
            [_lassoSelectionPolygonPoints addObject:[NSValue valueWithCGPoint:position]];
            
            CGPathRef lassoPath = [self getLassoPath];
            
            NSMutableArray * selectedStateIndexes=[NSMutableArray array];
            NSMutableArray * selectedTransitionIndexes=[NSMutableArray array];

            int i=-1;
            for (StateObject * state in _currentDiagram.states){
                i++;
                
                if(CGPathContainsPoint(lassoPath, nil, state.position, true)){
                    [selectedStateIndexes addObject:@(i)];
                }
                
            }
            i=-1;
            for (TransitionObject * transition in _currentDiagram.transitions){
                i++;
                
                if(CGPathContainsPoint(lassoPath, nil, [transition getStartPoint], true) && CGPathContainsPoint(lassoPath, nil, [transition getEndPoint], true)){
                    [selectedTransitionIndexes addObject:@(i)];
                }
                
            }
            CGPathRelease(lassoPath);
            [self setSelectedTransitionIndexes:selectedTransitionIndexes];
            [self setSelectedStateIndexes: selectedStateIndexes];
            
        }else{
            displacement = CGPointApplyAffineTransform(displacement,
                
                CGAffineTransformInvert(
                    CGAffineTransformConcat(
                        CGAffineTransformMakeRotation(_displayAngle),
                        CGAffineTransformMakeScale(_displayScale, _displayScale)
                    )
                )
            );
            
            NSLog(@"move g. %f, %f\n", displacement.x, displacement.y);
            
            for(NSNumber *stateIndex in _selectedStateIndexes){
                StateObject* state = [_currentDiagram.states objectAtIndex:[stateIndex integerValue] ];
                state.position = CGPointMake(state.positionWhenMovementStarted.x+displacement.x, state.positionWhenMovementStarted.y+displacement.y);
                [self setNeedsDisplay];
            }
        }
        [self setNeedsDisplay];
    }
    if ([sender state] == UIGestureRecognizerStateEnded ) {
        if(_moveGestureIsLasso){

            
            _lassoSelectionPolygonPoints=[NSMutableArray array];
            [self setNeedsDisplay];
        }else{
            [_currentDiagram recenterDiagramObjects];
            [self setNeedsDisplay];
        }
    }
    
    [self gestureEventCommon:sender];
}


-(void) layoutSubviews{
    [super layoutSubviews];
    [self updateViewTransformationMatrix];
    [self setNeedsDisplay];
}


-(CGRect) rectCenteredAt: (CGPoint) where width:(CGFloat) w height:(CGFloat) h{
    CGPoint center =CGPointZero;
    return CGRectMake(center.x+where.x-(w/2.0), center.y+where.y-(h/2.0), w, h);
}


// test if a point is in an ellipse
-(BOOL) ellipseInRect: (CGRect) rect containsPoint: (CGPoint) p{
    
    CGPoint rectCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    double a = rect.size.width/2;
    double b = rect.size.height/2;
    
    
    double dx = (rectCenter.x - p.x)/a;
    double dy = (rectCenter.y - p.y)/b;
    if(dx*dx + dy*dy < 1){
        return true;
    }else{
        return false;
    }
    
}
/* return how far from center of a rect a point is */
-(CGFloat) distanceFromMidpointOfRect: (CGRect) rect toPoint: (CGPoint) p{
    
    CGPoint rectCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

    
    double dx = (rectCenter.x - p.x);
    double dy = (rectCenter.y - p.y);
    return sqrt(dx*dx + dy*dy);
}


-(void) updateViewTransformationMatrix{
    _viewTrans = CGAffineTransformConcat(
                                    CGAffineTransformConcat(
                                    CGAffineTransformConcat(
                                      CGAffineTransformConcat(
                                          CGAffineTransformMakeTranslation(self.bounds.size.width/2,self.bounds.size.height/2)
                                          ,
                                          CGAffineTransformMakeTranslation(-self.bounds.size.width/2,-self.bounds.size.height/2)
                                         ),
                                          CGAffineTransformMakeRotation(_displayAngle)
                                         ),
                                          CGAffineTransformMakeScale(_displayScale*otherscale, _displayScale*otherscale)
                                         ),
                                          CGAffineTransformMakeTranslation(self.bounds.size.width/2 + _displayTranslation.x, self.bounds.size.height/2 + _displayTranslation.y)
                                         );
    
}

-(CGAffineTransform) getVerticalFlipTransform{
    return CGAffineTransformConcat(
                                  CGAffineTransformConcat(
                                  CGAffineTransformMakeScale(1,-1)
                                  ,
                                  CGAffineTransformMakeTranslation(0, self.bounds.size.height)
                                  ),
                                  CGAffineTransformIdentity) ;
}

-(CGAffineTransform) rotationTransformAroundPoint:(CGPoint) p angle: (CGFloat) angle{
    return CGAffineTransformConcat(
                                        CGAffineTransformConcat(
                                              CGAffineTransformMakeTranslation(-p.x,-p.y)
                                             ,
                                              CGAffineTransformMakeRotation(angle)
                                             ),
                                              CGAffineTransformMakeTranslation(p.x, p.y)
                                         );
};

-(CGPoint) getCenter{
    return CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

-(CGRect) getRectLargerThanRect: (CGRect) rect by:(double) amount{
    
    float widen=amount/_displayScale;
    rect.origin.x -=widen;
    rect.origin.y -=widen;
    
    rect.size.width  +=widen*2;
    rect.size.height +=widen*2;
    
    return rect;
}

-(CGRect) getTapSensitiveRectForState: (StateObject*) state{
    CGRect stateBox =[state boundingBox];
    
    return [self getRectLargerThanRect:stateBox by:20];
}

-(CTFrameRef) getFrameForForString: (NSString * )string  withFontSize: (float) fontSize withContext:(CGContextRef) context inPath: (CGPathRef) path{
        NSMutableAttributedString* attString = [[NSMutableAttributedString alloc]
                                          initWithString: string];

        CTFontRef helveticaBold;
        helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), fontSize, NULL);
         //    create paragraph style and assign text

        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting _settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
         };

        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
    
    
        [attString addAttribute:(id)kCTFontAttributeName
                       value:(id)CFBridgingRelease(helveticaBold)
                       range:NSMakeRange(0, [attString length])];
        [attString addAttribute:(id)kCTForegroundColorAttributeName
                       value:(id)[UIColor blackColor].CGColor
                       range:NSMakeRange(0, [attString length])];

        [attString addAttribute:(id)kCTParagraphStyleAttributeName
                        value:CFBridgingRelease(paragraphStyle)
                         range:NSMakeRange(0, [attString length])];

        NSDictionary *optionsDict = [[NSDictionary alloc] init];
    
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                 CFRangeMake(0, [attString length]), path, (__bridge CFDictionaryRef) optionsDict );
    
        CFRelease(framesetter);
        return frame;
    
}

-(void) drawStateLabelForState: (StateObject * )state  withContext:(CGContextRef) context inPath: (CGPathRef) path{


        if(state.didCalculateFontSize){
            CTFrameRef frame = [self getFrameForForString:state.label withFontSize: state.fontSize withContext:context inPath:path];
            CTFrameDraw(frame, context);
            CFRelease(frame);
        }else{
            for(float i=200;i >= 5; i /= 1.1){
                CTFrameRef frame = [self getFrameForForString:state.label withFontSize: i withContext:context inPath:path];


                CFRange actualRange = CTFrameGetVisibleStringRange(frame);
                CFRelease(frame);
                //check if the drawn text fits
                if(actualRange.length >= [state.label length]){
                    //NSLog(@"fits");
                    state.didCalculateFontSize=true;
                    state.fontSize = i;
                    [self drawStateLabelForState:state withContext:context inPath:path];
                    
                    
                    
                    return;
                    
                }else{
                    //NSLog(@"bad fit");
                }
            }
            
            state.didCalculateFontSize=true;
            state.fontSize = 5;
            [self drawStateLabelForState:state withContext:context inPath:path];
        }
    
}

-(CGPathRef) getLassoPath{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint firstPoint = [[_lassoSelectionPolygonPoints  firstObject] CGPointValue];
    CGPathMoveToPoint(path, nil, firstPoint.x, firstPoint.y);

    for(NSValue* val in _lassoSelectionPolygonPoints){
        CGPoint p = [val CGPointValue];
        
        CGPathAddLineToPoint(path, nil, p.x, p.y);
        
    }
    CGPathCloseSubpath(path);
    return path;
}

-(CGRect) getDiagramSpaceBoundsAtCurrentAngle{
    return [_currentDiagram boundingBoxAtAngle:_displayAngle];
}

-(CGPoint) getTopLeftDiagramBoundAtCurrentAngle{
    return CGPointApplyAffineTransform([self getDiagramSpaceBoundsAtCurrentAngle].origin,
        CGAffineTransformConcat(
            
            CGAffineTransformMakeRotation(-_displayAngle),
                                _viewTrans
        )
    ) ;
}
-(CGPoint) getBottomRightDiagramBoundAtCurrentAngle{
    CGRect bound = [self getDiagramSpaceBoundsAtCurrentAngle];
    CGPoint origin = bound.origin;
    CGPoint bottomRight = CGPointMake(origin.x+bound.size.width, origin.y+bound.size.height);
    return CGPointApplyAffineTransform(bottomRight,
                                       CGAffineTransformConcat(
                                                               
                                                               CGAffineTransformMakeRotation(-_displayAngle),
                                                               _viewTrans
                                                               )
                                       ) ;
    
}

-(void) drawRect:(CGRect)rect{
    
    
    
    CGContextRef context =  UIGraphicsGetCurrentContext( );
    CGContextSaveGState(context);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIColor * redColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    UIColor * blueColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];

    if([self isUserInteracting]){
    
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    }else{
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);

    }
    CGContextFillRect(context, self.bounds);
    
    //Draw a dot in the bottom left corner.
    /*
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, [self rectCenteredAt:[self getBottomRightDiagramBoundAtCurrentAngle] width:5 height:5]);
    */
    
    CGContextConcatCTM(context, _viewTrans);
    
    CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
    float strokeWidth=10;
    CGContextSetLineWidth(context, strokeWidth);
    
    
    //Draw the diagram's bounding box
    /*
    CGContextSaveGState(context);
        CGContextRotateCTM(context, -_displayAngle);
        CGContextStrokeRect(context, [_currentDiagram boundingBoxAtAngle:_displayAngle]);
    CGContextRestoreGState(context);
    */
    
    
    
    CGAffineTransform verticalFlipTransform = [self getVerticalFlipTransform];
    
    //Set States Style
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2);
    
    

    //Draw All State objects
    int stateIndex=-1;
    for (StateObject* state in _currentDiagram.states) {
        stateIndex++;
        BOOL is_selected = [_selectedStateIndexes containsObject:@(stateIndex)];
        
        
    
        CGContextSaveGState(context);
        CGRect stateBox = [state boundingBox];
        

        
         // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        // Create a path to render text in
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path,&verticalFlipTransform, stateBox);

        CGPoint boxCenter = CGPointMake(CGRectGetMidX(stateBox), CGRectGetMidY(stateBox));
        boxCenter = CGPointApplyAffineTransform(boxCenter, verticalFlipTransform);
        
        
        
        if(0){
            // Draw the tap sensitive area around the state
            CGRect sensitiveBox = [self getTapSensitiveRectForState:state];

            CGContextSaveGState(context);
                CGContextSetRGBFillColor(context, 0, 0, 0, .5);
                CGContextFillEllipseInRect(context, sensitiveBox);
            CGContextRestoreGState(context);
        }
        if(is_selected){
            CGContextSaveGState(context);
                CGContextSetRGBFillColor(context, 0, 0, 1, 1);

                CGFloat locations[] = {0.0, 1.0};

                UIColor *highlightColor =[UIColor colorWithRed:50/255.0 green:132/255.0 blue:1 alpha:1];
            
                NSArray *colors = [NSArray arrayWithObjects:(id)(highlightColor.CGColor), [highlightColor colorWithAlphaComponent:0].CGColor, nil];
                CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);

                CGPoint stateBoxCenter = CGPointMake(CGRectGetMidX(stateBox), CGRectGetMidY(stateBox));

            
                float ID = (([state rectWidth]+strokeWidth/2)/2);
                float OD = ID+(20/_displayScale);
            
                CGContextDrawRadialGradient(context, gradient, stateBoxCenter, ID, stateBoxCenter, OD, kCGGradientDrawsBeforeStartLocation);

                CGGradientRelease(gradient);
            
                CGContextRestoreGState(context);
        }
        
        CGContextConcatCTM(context, verticalFlipTransform);
        
        CGContextSaveGState(context);
            if(is_selected){
                CGContextSetShadowWithColor(context, CGSizeMake(5, 5), 10,[UIColor blackColor].CGColor);
            }else{
                CGContextSetShadowWithColor(context, CGSizeMake(5, 5), 5,[UIColor blackColor].CGColor);
            }
            CGContextAddPath(context, path);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillPath(context);
        CGContextRestoreGState(context);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
        
        
        
        CGContextConcatCTM(context, [self rotationTransformAroundPoint: boxCenter angle:_displayAngle]);

        [self drawStateLabelForState:state withContext:context inPath:path];
        CFRelease(path);

        
        
        CGContextRestoreGState(context);
    }
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

    int transitionIndex=-1;
    for (TransitionObject * transition in _currentDiagram.transitions){
        transitionIndex++;
        BOOL is_selected = [_selectedTransitionIndexes containsObject:@(transitionIndex)];

        CGContextSaveGState(context);
        
        CGPoint start = [transition getStartPoint];
        CGPoint end = [transition getEndPoint];
        
        float xdir = end.x-start.x;
        float ydir = end.y-start.y;
        
        float dist = sqrtf(xdir*xdir + ydir*ydir);
        if(dist<=0){
            dist = 1;
        }
        xdir /= dist;
        ydir /= dist;

        CGPoint arrowPt1=end;
        CGPoint arrowPt2=end;
        

        
        CGPoint leftArrowVecPoint = CGPointApplyAffineTransform(CGPointMake(xdir,ydir), CGAffineTransformMakeRotation(M_PI_4));
        CGPoint rightArrowVecPoint = CGPointApplyAffineTransform(CGPointMake(xdir,ydir), CGAffineTransformMakeRotation(-M_PI_4));

        float leftxdir =leftArrowVecPoint.x;
        float leftydir =leftArrowVecPoint.y;
        float rightxdir =rightArrowVecPoint.x;
        float rightydir =rightArrowVecPoint.y;
        
        arrowPt1.x -= leftxdir*20;
        arrowPt1.y -= leftydir*20;
        arrowPt2.x -= rightxdir*20;
        arrowPt2.y -= rightydir*20;
        
        CGMutablePathRef transitionPath = CGPathCreateMutable();
        CGPoint points[] = {start, end,arrowPt1,end,arrowPt2};
        CGPathAddLines(transitionPath, NULL, points, 5);
        
        
        if(is_selected){
            CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetLineWidth(context, 4);
        }else{
            CGContextSetLineWidth(context, 2);
        }
        
        CGContextAddPath(context, transitionPath);
        CGContextStrokePath(context);
        
        CGPathRelease(transitionPath);
        CGMutablePathRef arrowHeadPath = CGPathCreateMutable();
        CGPoint points2[] = {arrowPt1,end,arrowPt2,arrowPt1};
        CGPathAddLines(arrowHeadPath, NULL, points2, 4);
        
        CGContextAddPath(context, arrowHeadPath);
        CGContextFillPath(context);
        
        CGPathRelease(arrowHeadPath);
        
        //Draw the tap sensitive area around the arrow
        /*
        CGPathRef sensitivePath = [transition sensitivePathForDisplayScale:_displayScale];
        CGContextAddPath(context, sensitivePath);
        CGContextFillPath(context);
        CGPathRelease(sensitivePath);
        */
        
        
        
        //DRAW TRANSITION TEXT
        
        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity); // has no visible effect
        // Create a path to render text in
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint transCenter = [transition getMidPoint];
        CGRect transLabelRect = [self rectCenteredAt:transCenter width:300 height:30];
        CGPathAddRect(path,&verticalFlipTransform, transLabelRect);

        transCenter = CGPointApplyAffineTransform(transCenter, verticalFlipTransform);
        CGContextConcatCTM(context, verticalFlipTransform);
        CGContextConcatCTM(context, [self rotationTransformAroundPoint: transCenter angle:_displayAngle]);
    
        CTFrameRef frame = [self getFrameForForString:transition.label withFontSize: 20 withContext:context inPath:path];
        CFArrayRef  lines = CTFrameGetLines(frame);
        
        
        CGRect labelBounds = CGRectZero;
        CGRect pathBoundingBox = CGPathGetPathBoundingBox(path);
        for(int i=0;i<CFArrayGetCount(lines);i++){
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CGPoint origin;
            CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin);
            
            
            
            CGRect lineBounds = CTLineGetImageBounds(line, context);
            lineBounds.origin.x += pathBoundingBox.origin.x;
            lineBounds.origin.y += pathBoundingBox.origin.y;
            lineBounds.origin.x += origin.x;
            lineBounds.origin.y += origin.y;
            if(i>0){
                labelBounds = CGRectUnion(labelBounds, lineBounds);}
            else{
                labelBounds = lineBounds;
            }
        }
        
        CGContextSaveGState(context);
            //Draw background for the text..
            CGContextSetShadowWithColor(context, CGSizeMake(3, 3), 5,[UIColor blackColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            labelBounds = [self getRectLargerThanRect:labelBounds by:5*_displayScale];
            CGContextFillRect(context, labelBounds);
        CGContextRestoreGState(context);
        CGContextStrokeRect(context, labelBounds);
        

        CTFrameDraw(frame, context);
        
        CFRelease(frame);
        
        if(0){
            //draw the border around transition label
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
        }
        CGPathRelease(path);
        
        CGContextRestoreGState(context);
    }
    
    CGContextSetRGBFillColor(context, 0, 0, 0, .5);
    
    
    
    //Draw last tapped location.
    //CGContextFillEllipseInRect(context, [self rectCenteredAt: loc  width:30/_displayScale height:30/_displayScale]);
    
    
    

    
    
    CGPathRef lassoPath = [self getLassoPath];
    
    CGContextAddPath(context, lassoPath);
    CGContextFillPath(context);
    
    CGPathRelease(lassoPath);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);
}



@end


