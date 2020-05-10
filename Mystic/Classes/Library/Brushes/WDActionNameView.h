//
//  WDActionNameView.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import <UIKit/UIKit.h>

@protocol WDActionNameViewDelegate;

@interface WDActionNameView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) id<WDActionNameViewDelegate> delegate;

- (void) setUndoActionName:(NSString *)undoActionName;
- (void) setRedoActionName:(NSString *)redoActionName;
- (void) setTitle:(NSString *)title message:(NSString *)message;

- (void) setConnectedDeviceName:(NSString *)deviceName;
- (void) setDisconnectedDeviceName:(NSString *)deviceName;

@end

@protocol WDActionNameViewDelegate <NSObject>
- (void) fadingOutActionNameView:(WDActionNameView *)actionNameView;
- (void) fadedOutActionNameView:(WDActionNameView *)actionNameView;

@end
