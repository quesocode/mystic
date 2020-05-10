//
//  MysticControlObject.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "MysticConstants.h"

@class EffectControl, MysticControlObject;

@protocol MysticControlObjectDelegate

@optional
- (UIColor *) controlCurrentBackgroundColor:(EffectControl *)effectControl;
- (void) thumbnail:(EffectControl *)control effect:(MysticControlObject *)effect;
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control;
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;

- (void) enableControl:(EffectControl *)control;
- (void) updateControl:(EffectControl *)control;
- (void) controlBecameActive:(EffectControl *)control;
- (void) controlBecameInactive:(EffectControl *)control;

- (void) updateControl:(EffectControl *)control selected:(BOOL)makeSelected;
- (void) cancelEffect:(EffectControl *)control;
- (void) controlTouched:(EffectControl *)control;
- (void) prepareControlForReuse:(EffectControl *)control;
- (BOOL) controlShouldShowCancel:(EffectControl *)control;


@end

@interface MysticControlObject : NSObject <MysticControlObjectDelegate>

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *controlImageName, *controlImageURL, *defaultControlImageName;
@property (nonatomic, readonly) NSString *imageURLString, *previewURLString, *thumbURLString, *originalImageURLString;

@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, readonly) NSString *groupName;

@property (nonatomic, assign) UIImage *controlImage;
@property (nonatomic, assign) MysticObjectType type, groupType;
@property (nonatomic, readonly) BOOL hasAdjustableSettings;

@property (nonatomic, assign) BOOL cancelsEffect, hasBeenDisplayed;
@property (nonatomic, assign) BOOL selected, showLabel, alwaysShowLabel;
@property (nonatomic, assign) BOOL deselectable;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL updatesPhoto;
@property (nonatomic, assign) BOOL showsSubControls, allowsMultipleSelections, showAllActiveControls;
@property (nonatomic, assign) MysticControlObject* parentControl;
@property (nonatomic, assign) BOOL enabled, updatesSiblingsOnChange;
@property (nonatomic, assign) BOOL allowsLocking;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) UIImage *lockedOverlayImage, *selectedOverlayImage, *defaultControlImage, *selectedControlImage;
@property (nonatomic, retain) NSDictionary *coreData;
@property (nonatomic, retain) NSDictionary *info;
@property (nonatomic, copy) EffectContolAction action, cancelAction;
@property (nonatomic, copy) MysticBlockReturnsBOOL isActiveAction;

+ (MysticObjectType) classObjectType;
+ (id) optionWithName:(NSString *)name info:(NSDictionary *)info;
+ (Class) classForType:(MysticObjectType)optionType;
+ (MysticObjectType) objectTypeForClass:(Class)theClass;
- (void) setObject:(id)object forKey:(id<NSCopying>)aKey;
- (id) setUserChoice;
- (BOOL) hasCustomRender;
- (NSString *) controlImageNamePath;
- (NSInteger) integerValue;
- (void) commonInit;
- (id) objectForKey:(id)key;
@end





