//
//  MysticPath.m
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticPath.h"
#import "MysticShapesKit.h"
#import "MysticChoice.h"
#import "UIBezierPath+TextPaths.h"
#import "MysticAttrString.h"
#import "BezierUtils.h"

@implementation MysticPath

- (void) dealloc;
{
    [super dealloc];
    _choice = nil;
    [_path release];
}
- (instancetype) init;
{
    self = [super init];
    if(self)
    {
        _frame = CGRectUnknown;
        _geometryFlipped = NO;
    }
    return self;
}
- (void) setChoice:(MysticChoice *)choice;
{
    [self setChoice:choice maxWidth:_maxWidth];
}
- (void) setChoice:(MysticChoice *)choice maxWidth:(CGFloat)max;
{
    _choice = choice;
    _maxWidth = max;
    
    if(choice.attributedString)
    {
        if([choice.attributedString numberOfLines] <= 1)
        {
            UIBezierPath *p = [UIBezierPath pathForAttributedString:choice.attributedString.attrString];
            if(_path) [_path release];
            _path = [MovePathToPoint(FlipPathVertically(p), CGPointZero) retain];
        }
        else
        {
            UIBezierPath *p = [UIBezierPath pathForMultilineAttributedString:choice.attributedString.attrString maxWidth:max];
            if(_path) [_path release];
            _path = [MovePathToPoint(FlipPathVertically(p), CGPointZero) retain];
        }
        self.frame = _path ? PathBoundingBox(_path) : CGRectZero;
    }
    else if(choice.type!=MysticObjectTypeFont)
    {
        NSDictionary *p = [MysticShapesKit pathBounds:choice];
        self.frame = p[@"frame"] ? [p[@"frame"] CGRectValue] : CGRectUnknown;
        if(_path) [_path release];
        _path = p[@"path"] && !isNull(p[@"path"]) ? [p[@"path"] retain] : nil;
        
    }
    
//    if(_path) {
//        CGRect pb = PathBoundingBox(_path);
//        self.frame = CGRectIsUnknownOrZero(self.frame) ||  !CGRectEqual(self.frame, pb) ? pb : self.frame;
//    }

}
- (UIBezierPath *) path;
{
    if(_path) return _path;
    if(_choice) self.choice = _choice;
    return _path;
}
- (CGRect) frame;
{
    if(!CGRectUnknownOrZero(_frame)) return _frame;
    if(_choice) self.choice = _choice;
    return _frame;
}
@end
