//
//  MysticAlert.m
//  Mystic
//
//  Created by Me on 11/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAlert.h"
#import "AHAlertView.h"
#import "AppDelegate.h"

@implementation MysticAlert

+ (id) notice:(NSString *)title message:(NSString *)msg;
{
    return [MysticAlert notice:title message:msg action:nil options:nil];
}

+ (id) notice:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok;
{
    return [MysticAlert notice:title message:msg action:ok options:nil];

}
+ (id) notice:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok options:(NSDictionary *)opts;
{
    MysticAlert *obj = [[self class] make:title message:msg action:ok cancel:nil options:opts];
   
    obj.style = MysticAlertStyleOk;

    [obj setup];
    [obj show];
    return obj;
}
+ (id) ask:(NSString *)title message:(NSString *)msg yes:(MysticAlertBlock)ok no:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
{
    NSMutableDictionary *o = [NSMutableDictionary dictionaryWithDictionary:opts ? opts : @{}];
    if(!isM(opts[@"button"])) [o setObject:@"YES" forKey:@"button"];
    if(!isM(opts[@"cancelTitle"])) [o setObject:@"NO" forKey:@"cancelTitle"];
    return [self show:title message:msg action:ok cancel:cancel options:o];
    
}
+ (id) show:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
{
    MysticAlert *a = [[self class] alert:title message:msg action:ok cancel:cancel options:opts];
    if(a)
    {
        [a show];
    }
    return a;
}
+ (id) input:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel inputs:(NSArray *)inputs options:(NSDictionary *)opts;
{
    MysticAlert *a = [[self class] make:title message:msg action:ok cancel:cancel options:opts];
    
    if(inputs && inputs.count && a.style!=MysticAlertStyleMultiple)
    {
        a.style = MysticAlertStyleInput;
    }
    
    if(a)
    {
        [a setup];
        a.inputs = inputs;

    }
    return a;
}

+ (id) showInput:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel inputs:(NSArray *)inputs options:(NSDictionary *)opts;
{
    MysticAlert *a = [[self class] make:title message:msg action:ok cancel:cancel options:opts];
    
    if(inputs && inputs.count && a.style!=MysticAlertStyleMultiple)
    {
        a.style = MysticAlertStyleInput;
    }
    
    if(a)
    {
        [a setup];
        a.inputs = inputs;
        
        [a show];
    }
    return a;
}
+ (id) alert:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
{
    
    MysticAlert *obj = [[self class] alert:opts];
    if(msg) obj.message = msg;
    if(title) obj.title = title;
    if(ok) obj.action = ok;
    if(cancel) obj.cancel = cancel;
    [obj setup];
    return obj;
    
}
+ (id) alert:(NSDictionary *)options;
{
    MysticAlert *obj = [[self class] alloc];
    obj.options = options;
    int i = (int)obj.retainCount;
    [obj setup];
//    DLog(@"showing alert: %d -> %d", i, (int)obj.retainCount);

    return [obj autorelease];
}
+ (id) make:(NSString *)title message:(NSString *)msg action:(MysticAlertBlock)ok cancel:(MysticAlertBlock)cancel options:(NSDictionary *)opts;
{
    MysticAlert *obj = [[self class] alloc];
    obj.options = opts;
    if(msg) obj.message = msg;
    if(title) obj.title = title;
    if(ok) obj.action = ok;
    if(cancel) obj.cancel = cancel;
    return obj;
    
}
- (void) dealloc;
{
//    DLog(@"dealloc mystic alert");
    [_alert release];
    Block_release(_action);
    Block_release(_cancel);
    [_cancelTitle release];
    [_button release];
    [_title release];
    [_message release];
    [_options release];
    [_buttonActions release];
    _presentingController = nil;
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.style = MysticAlertStyleDefault;
    }
    return self;
}
- (void) setInputs:(NSArray *)inputs;
{
    if(inputs && inputs.count)
    {
        if(usingIOS8())
        {
            for (NSString *input in inputs) {
                
                NSString *placeholder = nil;
                BOOL isSecure = NO;
                NSString *value = nil;
                UIKeyboardType keyType = UIKeyboardTypeDefault;
                UITextFieldViewMode clearMode = UITextFieldViewModeAlways;
                UIKeyboardAppearance appearance =  UIKeyboardAppearanceDark;
                if([input isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *inputO = (id)input;
                    placeholder = inputO[@"placeholder"];
                    keyType = inputO[@"type"] ? [inputO[@"type"] integerValue] : keyType;
                    clearMode = inputO[@"clear"] ? [inputO[@"clear"] integerValue] : clearMode;
                    appearance = inputO[@"appearance"] ? [inputO[@"appearance"] integerValue] : appearance;

                    value = inputO[@"text"] ? inputO[@"text"] : inputO[@"value"];
                    isSecure = inputO[@"secure"] ? [inputO[@"secure"] boolValue] : [placeholder hasPrefix:@"#"];
                }
                else
                {
                    placeholder = input;
                    isSecure = [input hasPrefix:@"#"];
                }
                [(UIAlertController *)self.alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
                 {
                     if(placeholder) textField.placeholder = NSLocalizedString([placeholder stringByReplacingOccurrencesOfString:@"#" withString:@""], nil);
                     if(value) textField.text = value;
                     textField.secureTextEntry = isSecure;
                     textField.keyboardType = keyType;
                     textField.clearButtonMode = clearMode;
                     textField.keyboardAppearance = appearance;
                 }];
            }
        }
        else
        {
            AHAlertView *a = self.alert;
            a.alertViewStyle = AHAlertViewStylePlainTextInput;
            

        }
    }
}
- (void) setOptions:(NSDictionary *)options;
{
    [_options release], _options = nil;
    _options = [options retain];
    if(_options[@"buttons"]) self.style = MysticAlertStyleMultiple;
}
- (void) setup;
{
    __unsafe_unretained __block MysticAlert *weakSelf = self;
    if(!self.presentingController && isM(_options[@"controller"]))
    {
        self.presentingController =_options[@"controller"];
    }
    self.style = isM(_options[@"style"]) ? [_options[@"style"] integerValue] : self.style;
    if(usingIOS8())
    {
        UIAlertController *a = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(self.title, nil)
                                              message:NSLocalizedString(self.message, nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableArray *acs = [NSMutableArray array];
        switch (self.style) {
            case MysticAlertStyleOk: break;
            default:
            {
                if(self.options[@"cancelTitle"] || self.cancel)
                {
                    __unsafe_unretained __block MysticAlert *weakSelf2 = [self retain];
                    UIAlertActionStyle alertActionStyle = UIAlertActionStyleDefault;
                    if(isM(self.options[@"destruct"]) && [self.options[@"destruct"] boolValue])
                    {
                        alertActionStyle = UIAlertActionStyleDestructive;
                    }
                    
                    else if(isM(self.options[@"cancelStyle"]))
                    {
                        if(isMBOOL(self.options[@"cancelStyle"])) alertActionStyle = UIAlertActionStyleCancel;
                        else alertActionStyle = (UIAlertActionStyle)[self.options[@"cancelStyle"] integerValue];
                    }
                    UIAlertAction *acancelAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(self.cancelTitle,  @"Cancel action")
                                                    style:alertActionStyle
                                               handler:^(UIAlertAction *action) {
                                                   if(weakSelf2.cancel)
                                                   {
                                                       weakSelf2.cancel(action, weakSelf2);
                                                       weakSelf2.cancel = nil;
                                                   }
                                                   
                                                   int i = weakSelf2.retainCount;
                                                   while (i >0) {
                                                       [weakSelf2 autorelease];
                                                       i--;
                                                   }
                                               }];
                    
                    [acs addObject:acancelAction];

                }
                break;
            }
        }
        switch (self.style) {
            case MysticAlertStyleCancel: break;
            default:
            {
                if(self.action || self.options[@"button"])
                {
                    __unsafe_unretained __block MysticAlert *weakSelf2 = [self retain];
                    
                    UIAlertActionStyle alertActionStyle = UIAlertActionStyleDefault;
                    if(isM(self.options[@"buttonStyle"]))
                    {
                        alertActionStyle = (UIAlertActionStyle)[self.options[@"buttonStyle"] integerValue];
                    }
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(self.button, @"OK action")
                                               style:alertActionStyle
                                               handler:^(UIAlertAction *action) {
                                                   if(weakSelf2.action){
                                                       weakSelf2.action(action, weakSelf2);
                                                       weakSelf2.action = nil;
                                                   }
                                                   
                                                   int i = weakSelf2.retainCount;
                                                   while (i >0) {
                                                       [weakSelf2 autorelease];
                                                       i--;
                                                   }
                                                   
                                                   
                                               }];
                    
                    [acs addObject:okAction];
                    
                }
            }
        }
        
        
        switch (self.style) {
            case MysticAlertStyleOk: break;
            case MysticAlertStyleCancel: break;
            case MysticAlertStyleMultiple:
            {
                __unsafe_unretained __block MysticAlert *weakSelf2 = [self retain];
                
                [a addAction:acs.lastObject];
                for (NSDictionary *btn in self.options[@"buttons"]) {
                    
                    UIAlertActionStyle alertActionStyle = UIAlertActionStyleDefault;
                    if(isM(btn[@"buttonStyle"])) alertActionStyle = (UIAlertActionStyle)[btn[@"buttonStyle"] integerValue];
                    [self addActionForIndex:btn[@"title"] action:btn[@"action"]];
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(btn[@"title"], nil)
                                               style:alertActionStyle
                                               handler:^(UIAlertAction *action) {
                                                   [weakSelf2 callActionFor:action.title obj:action];
                                                   int i = weakSelf2.retainCount;
                                                   while (i >0) {
                                                       [weakSelf2 autorelease];
                                                       i--;
                                                   }
                                               }];
                    
                    [a addAction:okAction];
                }
                [a addAction:acs.firstObject];
                [acs removeAllObjects];
                break;
            }
                
            default: {
                for (UIAlertAction* act in acs) [a addAction:act];
                [acs removeAllObjects];
                break;
            }
        }
        
        if(acs.count)
        {
            for (UIAlertAction* act in acs) [a addAction:act];
            [acs removeAllObjects];

        }
        
        UIColor *tColor = isM(self.options[@"tint"]) ? self.options[@"tint"] : [[self class] tintColor];
        tColor = tColor ? [MysticColor color:tColor] : nil;
        if(tColor) [a.view setTintColor:tColor];
        
        self.alert = a;

    }
    else
    {
        AHAlertView *a = [[AHAlertView alloc] initWithTitle:NSLocalizedString(self.title, nil) message:NSLocalizedString(self.message, nil)];
        
        switch (self.style) {
            case MysticAlertStyleOk:
                
                break;
                
            default:
            {
                if(self.options[@"cancelTitle"] || self.cancel)
                {
                    __unsafe_unretained __block MysticAlertBlock _b = self.action ? Block_copy(self.action) : nil;
                    __unsafe_unretained __block MysticAlert *weakSelf2 = [self retain];

                    [a setCancelButtonTitle:NSLocalizedString(self.cancelTitle, nil) block:^{
                        if(_b)
                        {
                            _b(@NO, weakSelf2);
                            Block_release(_b);
                        }
                        int i = weakSelf2.retainCount;
                        while (i >0) {
                            [weakSelf2 autorelease];
                            i--;
                        }
                    }];
                }
                break;
            }
        }
        
        switch (self.style) {
            case MysticAlertStyleCancel: break;
            default:
            {
                if(self.action || self.options[@"button"])
                {
                    __unsafe_unretained __block MysticAlertBlock _b = self.action ? Block_copy(self.action) : nil;
                    __unsafe_unretained __block MysticAlert *weakSelf2 = [self retain];

                    [a addButtonWithTitle:NSLocalizedString(self.button, nil) block:^{
                        if(_b)
                        {
                            _b(@YES, weakSelf2);
                            Block_release(_b);
                        }
                        int i = weakSelf2.retainCount;
                        while (i >0) {
                            [weakSelf2 autorelease];
                            i--;
                        }

                    }];
                }
            }
        }
        self.alert = a;
        
    }
}
- (UITextField *) firstInput;
{
    if(usingIOS8())
    {
        UIAlertController *a = self.alert;
        return a.textFields.firstObject;
    }
   
    return [(AHAlertView *)self.alert textFieldAtIndex:0];
    
}
- (UITextField *) inputAtIndex:(NSInteger)index;
{
    if(usingIOS8())
    {
        UIAlertController *a = self.alert;
        return [a.textFields objectAtIndex:index];
    }
    
    NSMutableArray *fields = [NSMutableArray array];
    for (UIView *v in [self.alert subviews]) {
        if([v isKindOfClass:[UITextField class]])
        {
            [fields addObject:v];
        }
    }
    
    return fields.count ? [fields objectAtIndex:index] : nil;
    
}
- (UITextField *) lastInput;
{
    if(usingIOS8())
    {
        UIAlertController *a = self.alert;
        return a.textFields.lastObject;
    }
    
    NSMutableArray *fields = [NSMutableArray array];
    for (UIView *v in [self.alert subviews]) {
        if([v isKindOfClass:[UITextField class]])
        {
            [fields addObject:v];
        }
    }
    
    return fields.count ? fields.lastObject : nil;
    
}
- (NSString *)title;
{
    if(_title) return _title;

    return self.options[@"title"];
}
- (NSString *)message;
{
    if(_message) return _message;

    return self.options[@"message"];
}
- (NSString *)button;
{
    if(_button) return _button;

    return self.options[@"button"] ? self.options[@"button"] : @"Ok";
}
- (NSString *)cancelTitle;
{
    if(_cancelTitle) return _cancelTitle;
    return self.options[@"cancelTitle"] ? self.options[@"cancelTitle"] : @"Cancel";
}
- (MysticAlertBlock) action;
{
    if(_action) return _action;

    id bBlock = self.options[@"action"];
    if(bBlock) return (MysticAlertBlock)bBlock;
    return ^(id o, id o2){};
    
}
- (void) addActionForIndex:(id)key action:(MysticBlockObject)action;
{
    MysticBlockObj *b = [MysticBlockObj objectWithKey:[@"alertbtn-" stringByAppendingFormat:@"%@",key] blockObject:action];
    if(!self.buttonActions) self.buttonActions=[NSMutableDictionary dictionary];
    [self.buttonActions setObject:b forKey:key];
}
- (void) callActionFor:(id)key obj:(id)obj;
{
    if(!self.buttonActions || !self.buttonActions[key]) return;
    MysticBlockObj *b = self.buttonActions[key];
    b.blockObject(@{@"sender":obj,@"alert":self.alert});
}
- (MysticBlockObject) actionBlock;
{
    if(self.action)
    {
        __unsafe_unretained __block MysticAlert *weakSelf = [self retain];

        MysticBlockObject b = ^(id o){
            weakSelf.action(o, weakSelf);
            [weakSelf release];
        };
        return b;
    }
    return ^(id o){};
}
- (MysticAlertBlock) cancel;
{
    if(_cancel) return _cancel;
    id bBlock = self.options[@"cancel"];
    
    
    if(bBlock)
    {
        return (MysticAlertBlock)bBlock;
    }
    return ^(id o, id o2){};
    
}
- (MysticBlockObject) cancelBlock;
{
    if(self.cancel)
    {
        __unsafe_unretained __block MysticAlert *weakSelf = [self retain];

        MysticBlockObject b = ^(id o){
            weakSelf.cancel(o, weakSelf);
            [weakSelf release];
        };
        return b;
    }
    return ^(id o){};
}
- (void) dismiss;
{
    [self dismiss:nil];
}
- (void) dismiss:(MysticBlock)finished;
{
    [self dismissAnimated:YES complete:finished];
}
- (void) dismissAnimated:(BOOL)a complete:(MysticBlock)finished;
{
    if(usingIOS8())
    {
        UIViewController *c = self.presentingController ? self.presentingController : [AppDelegate instance].window.rootViewController;
        [c dismissViewControllerAnimated:a completion:finished];
    }
    else if(self.alert && [self.alert respondsToSelector:@selector(show)])
    {
        [(AHAlertView *)self.alert setDismissalStyle:a ? AHAlertViewDismissalStyleDefault : AHAlertViewDismissalStyleNone];
        [(AHAlertView *)self.alert dismiss];
        if(finished)
        {
            finished();
        }
    }
}
- (void) show;
{
    [self show:nil];
}
- (void) show:(MysticBlock)finished;
{
    [self showAnimated:YES complete:finished];
}
- (void) showAnimated:(BOOL)a complete:(MysticBlock)finished;
{
    if(usingIOS8())
    {
        UIViewController *c = self.presentingController ? self.presentingController : [UIApplication sharedApplication].windows.lastObject.rootViewController;
        [c presentViewController:self.alert animated:a completion:finished];
    }
    else if(self.alert && [self.alert respondsToSelector:@selector(show)])
    {
        [self.alert show];
        if(finished) finished();
    }
}

- (void) showWithKeyboard:(MysticBlock)finished;
{
    if(usingIOS8())
    {
        UIViewController *c = [UIApplication sharedApplication].windows.lastObject.rootViewController;
        [c presentViewController:self.alert animated:YES completion:finished];
    }
    else if(self.alert && [self.alert respondsToSelector:@selector(show)])
    {
        [self.alert show];
        if(finished) finished();
    }
}

+ (void) featureDisabled;
{
    [MysticAlert notice:@"Feature Disabled" message:@"This feature is disabled for the Beta version. For now, you can only save your photo to your device." action:^(id obj1, id obj2) {
        
    } options:nil];
}

+ (void) comingSoon;
{
    [MysticAlert notice:@"Coming Soon" message:@"More info on this coming soon..." action:^(id obj1, id obj2) {
        
    } options:nil];
}


#pragma mark - Appearance


+ (UIColor *) tintColor;
{
    if(usingIOS8())
    {
        return [UIColor hex:@"70706b"];
    }
    return nil;
}
+ (void) setupAppearance;
{
    if(usingIOS8())
    {
        
    }
    else
    {
        [[AHAlertView appearance] setContentInsets:UIEdgeInsetsMake(12, 18, 12, 18)];
        [[AHAlertView appearance] setBackgroundImage:[UIImage imageNamed:@"custom-dialog-background"]];
        
        UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(20, 8, 20, 8);
        UIImage *cancelButtonImage = [[UIImage imageNamed:@"custom-cancel-normal"]
                                      resizableImageWithCapInsets:buttonEdgeInsets];
        UIImage *normalButtonImage = [[UIImage imageNamed:@"custom-button-normal"]
                                      resizableImageWithCapInsets:buttonEdgeInsets];
        
        [[AHAlertView appearance] setCancelButtonBackgroundImage:cancelButtonImage
                                                        forState:UIControlStateNormal];
        [[AHAlertView appearance] setButtonBackgroundImage:normalButtonImage
                                                  forState:UIControlStateNormal];
        [[AHAlertView appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MysticUI gothamLight:19], UITextAttributeFont,
                                                          [UIColor hex:@"212121"], UITextAttributeTextColor,
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          nil]];
        [[AHAlertView appearance] setMessageTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [MysticUI gotham:13], UITextAttributeFont,
                                                            [UIColor hex:@"6b6b6b"], UITextAttributeTextColor,
                                                            [UIColor clearColor], UITextAttributeTextShadowColor,
                                                            [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                            nil]];
        [[AHAlertView appearance] setButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [MysticUI gothamBold:15], UITextAttributeFont,
                                                                [UIColor hex:@"fcfbf0"], UITextAttributeTextColor,
                                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                nil]];
    }
}
@end
