//
//  ViewController.h
//  StateMachine
//
//  Created by Kevin Baragona on 10/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Diagram.h"
#import "StateView.h"
#import "StateObject.h"


@interface ViewController : UIViewController

    @property IBOutlet StateView * stateView;

    @property IBOutlet UIBarButtonItem * undoButton;
    @property IBOutlet UIBarButtonItem * redoButton;
    @property IBOutlet UIBarButtonItem * addStateButton;
    @property IBOutlet UIBarButtonItem * renameButton;
    @property IBOutlet UIBarButtonItem * deleteButton;
    @property IBOutlet UIBarButtonItem * addTransitionButton;
    @property IBOutlet UIBarButtonItem * flipTransitionButton;


    @property IBOutlet UIToolbar * toolbar;

    @property IBOutlet UILabel * messageLabel;

    @property NSMutableArray * undoStack;
    @property NSMutableArray * redoStack;

    

@end
