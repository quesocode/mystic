//
//  MysticPermissionView.m
//  Mystic
//
//  Created by Travis A. Weerts on 6/2/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticPermissionView.h"

#define kMysticPermissionFadeTime  0.25
#define kMysticPermissionFadeOutTime  0.25

@implementation MysticPermissionView


- (instancetype) commonInit;
{
    [super commonInit];
    self.backgroundColorAlpha = 0.65;
    self.backgroundColor = UIColor.blackColor;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] autorelease];
    self.gestureRecognizers = @[tap];
    
    MysticButton *closeBtn = [MysticButton buttonWithImage:[UIImage imageNamed:@"arrow_dark_down.png"] target:self sel:@selector(hideButton:)];
    closeBtn.alpha = 0;
    closeBtn.center = CGPointMake(MCenterOfRect(self.bounds).x, self.bounds.size.height - CGRectGetHeight(closeBtn.frame) - 6);
    closeBtn.hitInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [self addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    return self;
}


+ (instancetype) showInView:(UIView *)view type:(MysticPermissionType)type animated:(BOOL)animated complete:(MysticBlockObjObjBOOL)finished;
{
    MysticPermissionView *pv = [[[[self class] alloc] initWithFrame:view.bounds] autorelease];
    __unsafe_unretained __block MysticPermissionView *_pv = [pv retain];
    __unsafe_unretained __block UIView *_view = view ? [view retain] : nil;
    pv.container = view;
    pv.onComplete = finished;
    [pv setType:type complete:^(id obj, BOOL success) {
        
        if(!success)
        {
            BOOL alreadyAdded = [_pv.container.subviews containsObject:_pv];
            if(!alreadyAdded) [_pv.container addSubview:_pv];
            if(animated)
            {
                if(!alreadyAdded) _pv.alpha = 0;
                _pv.titleLabel.alpha = 0;
                _pv.descriptionLabel.alpha = 0;
                _pv.imageView.alpha = 0;
                _pv.button.alpha = 0;
                _pv.closeBtn.alpha = 1;
                
                _pv.titleLabel.transform = CGAffineTransformMakeTranslation(0, -15);
                _pv.descriptionLabel.transform = CGAffineTransformMakeTranslation(0, 15);
                _pv.imageView.transform = CGAffineTransformMakeTranslation(0, -30);
                _pv.button.transform = CGAffineTransformMakeTranslation(0, 30);
                _pv.closeBtn.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pv.bounds)-_pv.closeBtn.frame.origin.y);

                [_pv fadeIn:kMysticPermissionFadeTime completion:^(BOOL finished) {
                    
                    [MysticUIView animateKeyframesWithDuration:0.4 delay:0 options:nil animations:^{
                        [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                            _pv.imageView.alpha = 1;
                            _pv.imageView.transform = CGAffineTransformIdentity;
                        }];
                        [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                            _pv.titleLabel.alpha = 1;
                            _pv.titleLabel.transform = CGAffineTransformIdentity;
                        }];
                        [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                            _pv.descriptionLabel.alpha = 1;
                            _pv.descriptionLabel.transform = CGAffineTransformIdentity;
                        }];
                        [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                            _pv.button.alpha = 1;
                            _pv.button.transform = CGAffineTransformIdentity;
                        }];

                    } completion:^(BOOL finished) {
                        [MysticUIView animateQuickSpringWithDuration:0.4 delay:0.3 options:nil animations:^{
                            _pv.closeBtn.transform = CGAffineTransformIdentity;
                        }];
                    }];
                    if(_pv.hasConfirmed && _pv.onComplete) { _pv.onComplete(_pv, obj, success); _pv.onComplete=nil; }
                    [_pv autorelease];
                }];
                return;
            }
            
        }
        
        if(_pv.onComplete) { _pv.onComplete(_pv, obj, success); _pv.onComplete=nil; }
        [_pv autorelease];
    }];
    return pv;
}


- (void) setType:(MysticPermissionType)type complete:(MysticBlockObjBOOL)block;
{
    self.type = type;
    __unsafe_unretained __block MysticBlockObjBOOL _block = block ? Block_copy(block) : nil;
    __unsafe_unretained __block MysticPermissionView *_pv = [self retain];
    [self requestPermissions:self.hasConfirmed complete:^(id permissionStatusObj, BOOL success) {
        BOOL wasDenied = NO;
        BOOL wasRestricted = NO;
        if(permissionStatusObj) {
            switch ([permissionStatusObj intValue]) {
                case MysticAuthorizationStatusDenied: wasDenied = YES; break;
                case MysticAuthorizationStatusRestricted: wasRestricted = YES; break;
                case MysticAuthorizationStatusNotDetermined: success = NO; break;
                case MysticAuthorizationStatusAuthorized:
                default: break; }
        }
        
                
        if(wasDenied || wasRestricted)
        {
            NSString *title, *description, *buttonTitle;
            UIColor *iconColor = [UIColor colorWithRed:0.87 green:0.56 blue:0.22 alpha:1.00];
            MysticBlockSender buttonAction = ^(id sender){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            };
            id iconType = @(MysticIconTypeAlert);
            buttonTitle = @"OPEN SETTINGS";
            switch (_pv.type) {
                case MysticPermissionTypeCamera:
                {
                    iconType = @(MysticIconTypeCamera);
                    title =  wasDenied ? @"ACCESS DENIED" : @"CAMERA IS RESTRICTED";
                    description = wasDenied ? @"Bummer...\n\nYou need to allow Mystic access\nto your photos before you can\nchoose one to edit. \n\nTap OPEN SETTINGS below\nand turn Photos on." : @"Hmm... for some weird reason access to your photo library is restricted?\n\nTap OPEN SETTINGS below\nand turn Photos on.";
                    
                    break;
                }
                default:
                {
                    title =  wasDenied ? @"ACCESS DENIED" : @"PHOTOS ARE RESTRICTED";
                    description = wasDenied ? @"Bummer...\n\nYou need to allow Mystic access\nto your photos before you can\nchoose one to edit. \n\nTap OPEN SETTINGS below\nand turn Photos on." : @"Hmm... for some weird reason access to your photo library is restricted?\n\nTap OPEN SETTINGS below\nand turn Photos on.";
                    break;
                }
            }
            
            [_pv showTitle:title description:description icon:iconType iconColor:iconColor button:buttonTitle action:buttonAction];
            
        }
        else if([permissionStatusObj intValue] == MysticAuthorizationStatusNotDetermined)
        {
            NSString *title, *description, *buttonTitle;
            UIColor *iconColor = [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00];
            MysticBlockSender buttonAction = ^(MysticButton *sender){
                ((MysticPermissionView *)sender.superview).hasConfirmed = YES;
                [((MysticPermissionView *)sender.superview) requestAgain];
            };
            id iconType = @"mystic_logo_clean.png";
            buttonTitle = @"CONTINUE";
            switch (_pv.type) {
                case MysticPermissionTypeCamera:
                {
//                    iconType = MysticIconTypeCamera;
                    title =  @"MYSTIC NEEDS ACCESS";
                    description = @"Before you can take a photo\nyou must allow Mystic to use your camera";
                    break;
                }
                default:
                {
//                    iconType = MysticIconTypePhotoLibrary;
                    title =  @"MYSTIC NEEDS ACCESS";
                    description = @"Before you can edit your photos\nyou must allow Mystic access\nto your photos";
                    break;
                }
            }
            
            [_pv showTitle:title description:description icon:iconType iconColor:iconColor button:buttonTitle action:buttonAction];
        }
        
        if(_block) { _block(permissionStatusObj, success); Block_release(_block); }
        [_pv autorelease];
    }];
}


- (void)requestPermissions:(BOOL)shouldRequest complete:(MysticBlockObjBOOL)block
{
    switch (self.type) {
        case MysticPermissionTypeCamera:
        {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (status)
            {
                case AVAuthorizationStatusAuthorized:
                {
                    block(@(status), YES);
                    break;
                }
                case AVAuthorizationStatusNotDetermined:
                {
                    if(!shouldRequest && block != nil) { block(@(status), NO); return; } else if(!block) { return; }
                    
                    __unsafe_unretained __block MysticBlockObjBOOL _block = block ? Block_copy(block) : nil;
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        mdispatch(^{
                            if(granted)
                            {
                                _block(@(AVAuthorizationStatusAuthorized), granted);
                            }
                            else
                            {
                                _block(@([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]), granted);
                            }
                            Block_release(_block);
                        });
                     }];
                    break;
                }
                default: block(@(status), NO); break;
            }
            return;
        }
        default: break;
    }
    
    // only called if requesting photo library
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusAuthorized: block(@(status), YES); break;
        case PHAuthorizationStatusNotDetermined:
        {
            if(!shouldRequest) {
                block(@(status), NO);
                return;
            }
            if(!block) return;
            __unsafe_unretained __block MysticBlockObjBOOL _block = block ? Block_copy(block) : nil;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
             {
                 mdispatch(^{
                     if (status == PHAuthorizationStatusAuthorized) _block(@(status), YES);
                    else _block(@(status), NO);
                     Block_release(_block);
                 });
             }];
            break;
        }
        default: block(@(status), NO); break;
    }
}



- (void) requestAgain;
{
    __unsafe_unretained __block MysticPermissionView *_pv = [self retain];
    [self fadeOutViews:YES complete:^(BOOL active) {
        [_pv setType:_pv.type complete:^(id obj, BOOL success) {
            if(!success) return [_pv fadeInViews:YES complete:^(BOOL active) { [_pv autorelease]; }];
            if(_pv.hasConfirmed && _pv.onComplete) { _pv.onComplete(_pv, obj, success); _pv.onComplete=nil; }
            [_pv autorelease];
        }];
    }];
    
}




- (void) showTitle:(NSString *)title description:(NSString *)description icon:(id)iconType iconColor:(UIColor *)iconColor button:(NSString *)buttonTitle action:(MysticBlockSender)action;
{
    CGFloat spacing = 20;
    UIImageView *iconView = self.imageView;
    UILabel *titleLabel = self.titleLabel;
    UILabel *msgLabel = self.descriptionLabel;
    MysticButton *btn = self.button;
    if(!self.titleLabel)
    {
        iconView = [[[UIImageView alloc] initWithFrame:(CGRect){0,0,85,85}] autorelease];
        titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)] autorelease];
        msgLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 60, 200)] autorelease];
        iconView.contentMode = UIViewContentModeCenter;
        msgLabel.numberOfLines = 0;
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        [self addSubview:msgLabel];
        self.titleLabel = titleLabel;
        self.descriptionLabel = msgLabel;
        self.imageView = iconView;
    }
    else {
        self.imageView.frame = (CGRect){0,0,70,70};
        self.titleLabel.frame = (CGRect){0,0,200,60};
        self.descriptionLabel.frame = CGRectMake(0, 0, self.bounds.size.width - 60, 200);
        if(btn) [btn removeFromSuperview];
        self.button = nil;
    }
    btn = [MysticButton button:[[MysticAttrString string:buttonTitle style:MysticStringStyleAccessButton] attrString] action:action];
    self.button = btn;
    [self addSubview:btn];
    self.button = btn;
    iconView.image = [iconType isKindOfClass:NSString.class] ? [UIImage imageNamed:iconType] : [MysticImage image:iconType size:iconView.frame.size color:iconColor];
    titleLabel.attributedText = [[MysticAttrString string:title style:MysticStringStyleAccessTitle] attrString];
    msgLabel.attributedText = [[MysticAttrString string:description style:MysticStringStyleAccessDescription] attrString];
    [titleLabel sizeToFit];
    [msgLabel sizeToFit];
    [btn sizeToFit];
    
    CGSize accessSize = titleLabel.frame.size;
    accessSize.width = MAX(MAX(CGRectGetWidth(titleLabel.frame), CGRectGetWidth(msgLabel.frame)), CGRectGetWidth(btn.frame));
    accessSize.height += (spacing*self.subviews.count) + CGRectGetHeight(iconView.frame) + CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(msgLabel.frame) + CGRectGetHeight(btn.frame);
    iconView.center = CGPointAddY(MCenterOfRect(self.bounds), -accessSize.height/2);
    titleLabel.frame = CGRectOffset(titleLabel.frame, 0,CGRectGetMaxY(iconView.frame) + spacing*2.5);
    CGRect messageFrame = CGRectOffset(msgLabel.frame, 0,CGRectGetMaxY(titleLabel.frame) + spacing);
    msgLabel.frame = CGRectWH(messageFrame, MIN(CGRectGetWidth(messageFrame), CGRectInset(self.bounds, spacing*2, 0).size.width), CGRectGetHeight(messageFrame));
    btn.frame = CGRectOffset(CGRectInset(btn.frame, -spacing/1.5,-spacing/3), 0, CGRectGetMaxY(msgLabel.frame) + spacing*3);
    MBorder(btn, [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00], 1.5);
    btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
    titleLabel.center = CGPointX(titleLabel.center, iconView.center.x);
    msgLabel.center = CGPointX(msgLabel.center, iconView.center.x);
    btn.center = CGPointX(btn.center, iconView.center.x);
}


- (void) hideButton:(MysticButton *)sender;
{
    [self hide:YES complete:nil];
}
- (void) tapped:(UITapGestureRecognizer *)sender;
{
    [self hide:YES complete:nil];
    
}
- (void) hide:(BOOL)animated complete:(MysticBlockBOOL)hide;
{
    if(animated)
    {
        __unsafe_unretained __block MysticPermissionView *_pv = [self retain];
        __unsafe_unretained __block MysticBlockBOOL _hide = hide ? Block_copy(hide) : nil;
        
        _pv.alpha = 1;
        _pv.titleLabel.alpha = 1;
        _pv.descriptionLabel.alpha = 1;
        _pv.imageView.alpha = 1;
        _pv.button.alpha = 1;
        _pv.closeBtn.alpha = 1;
        
        _pv.titleLabel.transform = CGAffineTransformIdentity;
        _pv.descriptionLabel.transform = CGAffineTransformIdentity;
        _pv.imageView.transform = CGAffineTransformIdentity;
        _pv.button.transform = CGAffineTransformIdentity;
        _pv.closeBtn.transform = CGAffineTransformIdentity;
        
        return [_pv fadeOut:kMysticPermissionFadeOutTime completion:^(BOOL finished1) {
            
            [MysticUIView animateKeyframesWithDuration:0.4 delay:0 options:nil animations:^{
                [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                    _pv.imageView.alpha = 0;
                    _pv.imageView.transform = CGAffineTransformMakeTranslation(0, -30);
                }];
                [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                    _pv.titleLabel.alpha = 0;
                    _pv.titleLabel.transform = CGAffineTransformMakeTranslation(0, -15);
                }];
                [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                    _pv.descriptionLabel.alpha = 0;
                    _pv.descriptionLabel.transform = CGAffineTransformMakeTranslation(0, 15);
                }];
                [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                    _pv.button.alpha = 0;
                    _pv.button.transform = CGAffineTransformMakeTranslation(0, 30);
                    _pv.closeBtn.alpha = 0;
                    _pv.closeBtn.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pv.bounds)-_pv.closeBtn.frame.origin.y);
                }];
                
            } completion:^(BOOL finished) {
                [_pv removeFromSuperview];
                if(_hide) { _hide(finished); Block_release(_hide); }
                [_pv release];
            }];
        }];
    }
    [self removeFromSuperview];
    if(hide) hide(YES);
}
- (void) fadeOutViews:(BOOL)animated complete:(MysticBlockBOOL)hide;
{
    if(animated)
    {
        __unsafe_unretained __block MysticPermissionView *_pv = [self retain];
        __unsafe_unretained __block MysticBlockBOOL _hide = hide ? Block_copy(hide) : nil;
        _pv.titleLabel.alpha = 1;
        _pv.descriptionLabel.alpha = 1;
        _pv.imageView.alpha = 1;
        _pv.button.alpha = 1;
        _pv.closeBtn.alpha = 1;
        
        _pv.titleLabel.transform = CGAffineTransformIdentity;
        _pv.descriptionLabel.transform = CGAffineTransformIdentity;
        _pv.imageView.transform = CGAffineTransformIdentity;
        _pv.button.transform = CGAffineTransformIdentity;
        _pv.closeBtn.transform = CGAffineTransformIdentity;
        
        [MysticUIView animateKeyframesWithDuration:0.4 delay:0 options:nil animations:^{
            
            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                _pv.imageView.alpha = 0;
                _pv.imageView.transform = CGAffineTransformMakeTranslation(0, -30);
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                _pv.titleLabel.alpha = 0;
                _pv.titleLabel.transform = CGAffineTransformMakeTranslation(0, -15);
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                _pv.descriptionLabel.alpha = 0;
                _pv.descriptionLabel.transform = CGAffineTransformMakeTranslation(0, 15);
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                _pv.button.alpha = 0;
                _pv.button.transform = CGAffineTransformMakeTranslation(0, 30);
                _pv.closeBtn.alpha = 0;
                _pv.closeBtn.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pv.bounds)-_pv.closeBtn.frame.origin.y);
            }];
            
        } completion:^(BOOL finished) {
            if(_hide) { _hide(finished); Block_release(_hide); }
            [_pv release];
        }];
        return;
    }
    if(hide) hide(YES);
}
- (void) fadeInViews:(BOOL)animated complete:(MysticBlockBOOL)complete;
{
    if(animated)
    {
        __unsafe_unretained __block MysticPermissionView *_pv = [self retain];
        __unsafe_unretained __block MysticBlockBOOL _complete = complete ? Block_copy(complete) : nil;
        _pv.titleLabel.alpha = 0;
        _pv.descriptionLabel.alpha = 0;
        _pv.imageView.alpha = 0;
        _pv.button.alpha = 0;
        _pv.closeBtn.alpha = 1;
        
        _pv.titleLabel.transform = CGAffineTransformMakeTranslation(0, -15);
        _pv.descriptionLabel.transform = CGAffineTransformMakeTranslation(0, 15);
        _pv.imageView.transform = CGAffineTransformMakeTranslation(0, -30);
        _pv.button.transform = CGAffineTransformMakeTranslation(0, 30);
        _pv.closeBtn.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_pv.bounds)-_pv.closeBtn.frame.origin.y);
        
        return [MysticUIView animateKeyframesWithDuration:0.4 delay:0 options:nil animations:^{
            
            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                _pv.imageView.alpha = 1;
                _pv.imageView.transform = CGAffineTransformIdentity;
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                _pv.titleLabel.alpha = 1;
                _pv.titleLabel.transform = CGAffineTransformIdentity;
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                _pv.descriptionLabel.alpha = 1;
                _pv.descriptionLabel.transform = CGAffineTransformIdentity;
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                _pv.button.alpha = 1;
                _pv.button.transform = CGAffineTransformIdentity;
            }];
            
        } completion:^(BOOL finished) {
            [MysticUIView animateQuickSpringWithDuration:0.4 delay:0.3 options:nil animations:^{
                _pv.closeBtn.transform = CGAffineTransformIdentity;
                [_pv release];
            }];
            if(_complete) { _complete(finished); Block_release(_complete); }
        }];
        
    }
    if(complete) complete(YES);
}
@end
