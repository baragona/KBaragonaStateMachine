//
//  ViewController.m
//  StateMachine
//
//  Created by Kevin Baragona on 10/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _undoStack = [NSMutableArray array];
    _redoStack = [NSMutableArray array];
    
    
    _messageLabel.alpha = 0;
    

    
    _stateView.currentDiagram = [Diagram defaultDiagram];
    [_stateView setNeedsDisplay];
    __weak id otherself = self;
    _stateView.callOnViewWillModifyDiagramSoSaveUndoState= ^{
        [otherself saveUndoState];
    };
    _stateView.callOnSelectedItemSetChanged = ^{
        [otherself refreshToolbar];
    };
    
    _renameButton = [[UIBarButtonItem alloc]
             initWithTitle:@"Rename" style:UIBarButtonItemStylePlain
                target:self
           action:@selector(renamePressed)];
    _deleteButton =[[UIBarButtonItem alloc]
             initWithTitle:@"Delete" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(deletePressed)];
    _addStateButton = [[UIBarButtonItem alloc]
             initWithTitle:@"New State" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(newStatePressed)];
    
   _undoButton = [[UIBarButtonItem alloc]
             initWithTitle:@"Undo" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(undoPressed)];
   
   _redoButton = [[UIBarButtonItem alloc]
             initWithTitle:@"Redo" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(redoPressed)];
    _addTransitionButton= [[UIBarButtonItem alloc]
             initWithTitle:@"Add Transition" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(addTransitionPressed)];
   
   _flipTransitionButton = [[UIBarButtonItem alloc]
             initWithTitle:@"Reverse" style:UIBarButtonItemStylePlain
        target:self 
   action:@selector(flipTransitionPressed)];
   
    [self refreshUndoRedoButtons];
    [self refreshToolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismissMessage{
    [UIView animateWithDuration:.5
                     animations:^{_messageLabel.alpha = 0;}
                     completion:^(BOOL finished){
                        
                     }];
}

-(void) showMessage: (NSString *) str{
    _messageLabel.text=str;
    _messageLabel.shadowColor = [UIColor blackColor];
    _messageLabel.shadowOffset = CGSizeMake(1.5,1.5);
    /*
    _messageLabel.layer.shouldRasterize = YES;
    _messageLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    _messageLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    _messageLabel.layer.shadowRadius = 3.0;
    _messageLabel.layer.shadowOpacity = 1.0;
    */
    
    
    [UIView animateWithDuration:.1
                     animations:^{_messageLabel.alpha = 1;}
                     completion:^(BOOL finished){
                        //[self dismissMessage];
                     }];
}

-(void) refreshToolbar{

    NSMutableArray * items = [NSMutableArray array];
    
    if(_stateView.selectedStateIndexes.count>0){

    }
    if( _stateView.selectedStateIndexes.count>0 || _stateView.selectedTransitionIndexes.count>0 ){
        //at least one thing selected
        [items addObject:_deleteButton];
        if(_stateView.selectedStateIndexes.count==1 && _stateView.selectedTransitionIndexes.count==0){
            //just one state and nothing else selected
            [items addObject:_renameButton];
        }
        if(_stateView.selectedStateIndexes.count==0 && _stateView.selectedTransitionIndexes.count==1){
            //just one transition and nothing else selected
            [items addObject:_renameButton];
        }
        if(_stateView.selectedStateIndexes.count==2 && _stateView.selectedTransitionIndexes.count==0){
            //just two states and nothing else selected
            [items addObject:_addTransitionButton];
        }
        if(_stateView.selectedStateIndexes.count==0 && _stateView.selectedTransitionIndexes.count==1){
            //just one state and nothing else selected
            [items addObject:_flipTransitionButton];
        }
    }else{
        [items addObject:_addStateButton];
    }
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    [items addObject:_undoButton];
    [items addObject:_redoButton];
    
    /*
    if([_undoStack count]!=0){
        [items addObject:_undoButton];
    }
    if([_redoStack count]!=0){
        [items addObject:_redoButton];
    }
    */
    
    [_toolbar setItems:items];
    
    //[_toolbar setItems:[NSArray arrayWithObjects:_addStateButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _undoButton,_redoButton, nil]];
}

-(void) refreshUndoRedoButtons{
    [_undoButton setEnabled:([_undoStack count]!=0)];
    [_redoButton setEnabled:([_redoStack count]!=0)];

}

-(void)saveUndoState{
    [_undoStack addObject:[_stateView.currentDiagram clone]];
    _redoStack = [NSMutableArray array];
    [self refreshUndoRedoButtons];
}
-(void)saveRedoState{
    [_redoStack addObject:[_stateView.currentDiagram clone]];
    [self refreshUndoRedoButtons];
}

-(IBAction) newStatePressed{
    //[[[UIAlertView alloc] initWithTitle:@"" message:@"New State Pressed" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];

    [self showMessage: @"Tap to place new state"];
    
    [_stateView callbackWithPointOnNextTap: ^(CGPoint p){
        [self dismissMessage];
        
        [self saveUndoState];
        _stateView.currentDiagram = [_stateView.currentDiagram clone];

        NSMutableArray * newStates = [NSMutableArray arrayWithArray:_stateView.currentDiagram.states];
        
        [newStates addObject:[StateObject initWithLabel: @"New State" position:p]];


        _stateView.currentDiagram.states = [ NSArray arrayWithArray:newStates];
        [_stateView rescaleAndTranslateToFit];
        [_stateView setNeedsDisplay];
        
        
        
    }];
    

    
}

-(IBAction)deletePressed{
    [self saveUndoState];
    _stateView.currentDiagram = [_stateView.currentDiagram clone];
    
    NSMutableArray * newStates = [NSMutableArray array];
    int i=-1;
    for (StateObject * state in _stateView.currentDiagram.states){
        i++;
        if([_stateView.selectedStateIndexes containsObject:@(i)]){
            
        }else{
            [newStates addObject:state];
        }
    }
    NSMutableArray * newTransitions = [NSMutableArray array];
    i=-1;
    for (TransitionObject * transition in _stateView.currentDiagram.transitions){
        i++;
        int startStateIndex = [_stateView.currentDiagram.states indexOfObject:[transition startState]];
        int endStateIndex = [_stateView.currentDiagram.states indexOfObject:[transition endState]];

        if(
            [_stateView.selectedTransitionIndexes containsObject:@(i)]
            || [_stateView.selectedStateIndexes containsObject:@(startStateIndex)]
            || [_stateView.selectedStateIndexes containsObject:@(endStateIndex)]
        ){
            //dont add any of the transitions that are selected for deletion
            // Or if either the start or end state are selected for deletion
        }else{
            [newTransitions addObject:transition];
        }
    }
    _stateView.currentDiagram.states = [ NSArray arrayWithArray:newStates];
    _stateView.currentDiagram.transitions = [ NSMutableArray arrayWithArray:newTransitions ];
    [_stateView deselectAll];
    [_stateView rescaleAndTranslateToFit];
    [_stateView setNeedsDisplay];
    
    [self refreshToolbar];

}

-(IBAction)renamePressed{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter New Name" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    [self saveUndoState];
    _stateView.currentDiagram = [_stateView.currentDiagram clone];
    
    NSString * newtext =[[alertView textFieldAtIndex:0] text];
    if([_stateView.selectedStateIndexes count]>0){
        StateObject * stateToRename = [_stateView.currentDiagram.states objectAtIndex:[[_stateView.selectedStateIndexes firstObject] integerValue]];
        
        stateToRename.label = newtext;
        
        stateToRename.didCalculateFontSize=false;
    }
    if([_stateView.selectedTransitionIndexes count]>0){
        TransitionObject * transition = [_stateView.currentDiagram.transitions objectAtIndex:[[_stateView.selectedTransitionIndexes firstObject] integerValue]];
        
        transition.label = newtext;
        
    }
    
    
    [_stateView setNeedsDisplay];

    //[[alertView textFieldAtIndex:0];
}

-(IBAction) undoPressed{
    //[[[UIAlertView alloc] initWithTitle:@"" message:@"Undo Pressed" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    [_redoStack addObject:_stateView.currentDiagram];
    
    _stateView.currentDiagram = [_undoStack lastObject];
    
    [_undoStack removeLastObject];
    
    [_stateView deselectAll];

    [self refreshUndoRedoButtons];


    [_stateView setNeedsDisplay];
    
    [self refreshToolbar];

}

-(IBAction) redoPressed{
    //[[[UIAlertView alloc] initWithTitle:@"" message:@"Redo Pressed" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    [_undoStack addObject:_stateView.currentDiagram];
    
    _stateView.currentDiagram = [_redoStack lastObject];
    
    [_redoStack removeLastObject];
    
    [_stateView deselectAll];

    
    [self refreshUndoRedoButtons];



    [_stateView setNeedsDisplay];
    [self refreshToolbar];

}

-(IBAction)addTransitionPressed{
    [self saveUndoState];
    _stateView.currentDiagram = [_stateView.currentDiagram clone];
    
    [_stateView.currentDiagram.transitions addObject:
        [TransitionObject initWithLabel: @"Transition"
            startState:  [_stateView.currentDiagram.states objectAtIndex: [_stateView.selectedStateIndexes[0] integerValue]]
            endState:    [_stateView.currentDiagram.states objectAtIndex: [_stateView.selectedStateIndexes[1] integerValue]]
        ]
    ];
    [_stateView setNeedsDisplay];
}

-(IBAction)flipTransitionPressed{
    [self saveUndoState];
    _stateView.currentDiagram = [_stateView.currentDiagram clone];
    

    TransitionObject * transition = [_stateView.currentDiagram.transitions objectAtIndex: [_stateView.selectedTransitionIndexes[0] integerValue]];

    StateObject * temp = transition.startState;
    transition.startState = transition.endState;
    transition.endState = temp;

    [_stateView setNeedsDisplay];
}


@end
