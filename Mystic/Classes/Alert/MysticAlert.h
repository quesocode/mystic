//
//  MysticAlert.h
//  Mystic
//
//  Created by Me on 11/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"


@interface MysticAlert : NSObject

@property (nonatomic, retain) id alert;
@property (nonatomic, retain) NSDictionary *options;
@property (nonatomic, retain) NSMutableDictionary *buttonActions;

@property (nonatomic, copy) MysticAlertBlock cancel, action;
@property (nonatomic, retain) NSString *title, *message, *button, *cancelTitle;
@property (nonatomic, readonly) UITextField *firstInput, *lastInput;
@property (nonatomic, assign) NSArray *inputs;
@property (nonatomic, readonly) MysticBlockObject cancelBlock, actionBlock;
@property (nonatomic, assign) MysticAlertStyle style;
@property (nonatomic, assign) UIViewController *presentingController;
+ (id) alert:(NSDictionary *)options;
+ (id) notice:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok;
+ (id) notice:(NSString *)title message:(NSString *)msg;
+ (id) alert:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
+ (id) show:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
+ (id) ask:(NSString *)title message:(NSString *)msg yes:(MysticAlertBlock)ok no:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
+ (id) notice:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok options:(NSDictionary *)opts;
+ (id) make:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
+ (id) input:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel inputs:(NSArray *)inputs options:(NSDictionary *)opts;
+ (id) showInput:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel inputs:(NSArray *)inputs options:(NSDictionary *)opts;

+ (void) setupAppearance;

- (void) setup;
- (UITextField *) inputAtIndex:(NSInteger)index;
- (void) addActionForIndex:(id)key action:(MysticBlockObject)action;

- (void) show;
- (void) show:(MysticBlock)finished;
- (void) showAnimated:(BOOL)a complete:(MysticBlock)finished;
- (void) showWithKeyboard:(MysticBlock)finished;

- (void) dismiss;
- (void) dismiss:(MysticBlock)finished;
- (void) dismissAnimated:(BOOL)a complete:(MysticBlock)finished;
+ (void) featureDisabled;
+ (void) comingSoon;

@end
