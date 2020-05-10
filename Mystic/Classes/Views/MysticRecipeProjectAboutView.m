//
//  MysticRecipeProjectAboutView.m
//  Mystic
//
//  Created by travis weerts on 8/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticRecipeProjectAboutView.h"
#import "UIColor+Mystic.h"
#import "UIImageView+WebCache.h"
#import "PackPotionOptionRecipe.h"
//#import <Slash/Slash.h>
#import <QuartzCore/QuartzCore.h>

@implementation MysticRecipeProjectAboutView
@synthesize imageView;

static CGFloat const kLabelVMargin = 10;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect rframe = CGRectMake(0, 6, 250, 250);
        rframe.origin.x = self.bounds.size.width/2 - rframe.size.width/2;
        self.clipsToBounds = YES;

        UIImageView *recipeImageView = [[UIImageView alloc] initWithFrame:rframe];
        recipeImageView.contentMode = UIViewContentModeScaleAspectFill;
        recipeImageView.backgroundColor = [UIColor mysticGrayBackgroundColor];
        self.imageView = recipeImageView;
        [self addSubview:recipeImageView];
        rframe.size.width = 280;
        rframe.size.height = self.bounds.size.height - rframe.size.height- 30;
        rframe.origin.x = 20;
        rframe.origin.y = recipeImageView.frame.origin.y + recipeImageView.frame.size.height + 10;
        
        [[OHAttributedLabel appearance] setLinkColor:[UIColor mysticBlueColor]];
        
        self.textView = [[OHAttributedLabel alloc] initWithFrame:rframe];
        
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.userInteractionEnabled = YES;
        self.textView.textAlignment = NSTextAlignmentCenter;
        
        
        [self addSubview:self.textView];
    }
    return self;
}
- (void) setRecipe:(PackPotionOptionRecipe *)recipe;
{
    [self setImageURL:recipe.previewURLString];
    NSString *desc = [NSString stringWithFormat:@"<h6>%@</h6>\r\n<div>%@</div>", [recipe.project.name capitalizedString], recipe.project.details ? recipe.project.details : @"Details coming soon..."];
    [self setDescription:desc];
}
- (void) setDescription:(NSString *)str;
{
    NSDictionary *style = @{
                            @"$default" :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue" size:14]},
                            @"strong"   :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]},
                            @"em"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Italic" size:14]},
                            @"h1"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:48]},
                            @"h2"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:36]},
                            @"h3"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:32]},
                            @"h4"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:24]},
                            @"h5"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]},
                            @"h6"       :
                                @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]},
                            @"div"        :
                                @{NSForegroundColorAttributeName : [UIColor grayColor],
                                  NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue" size:12]}
                            };

    
   // NSAttributedString *attributedString = [SLSMarkupParser attributedStringWithMarkup:str style:style error:NULL];
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithString:str];
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithAttributedString:attributedString];
    
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTCenterTextAlignment;
    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle.firstLineHeadIndent = 0; // indentation for first line
    paragraphStyle.lineSpacing = 3.f; // increase space between lines by 3 points
    [attrStr setParagraphStyle:paragraphStyle];
    
    self.textView.attributedText = attrStr;
    CGFloat width = self.textView.frame.size.width; // whatever your desired width is
//    CGRect rect = [self.textView.attributedText boundingRectWithSize:CGSizeMake(width, 10000) options: NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading context:nil];
    
    //CGSize size = rect.size;
    CGSize sz = [attrStr sizeConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    sz.height = sz.height + 2*kLabelVMargin;
    
    CGRect f = self.textView.frame;
    f.size.height = sz.height;
    self.textView.frame = f;
    
    self.contentSize = CGSizeMake(self.frame.size.width, self.textView.frame.origin.y + self.textView.frame.size.height);

    
}
- (void) setImageURL:(NSString *)url;
{
    self.imageView.alpha = 0;
    __weak typeof(self) weakSelf = self;
    [self.imageView cancelCurrentImageLoad];
    [self.imageView setImageWithURL:[NSURL URLWithString:url]
                   placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                       
                       [MysticUIView animateWithDuration:0.5 animations:^{
                           weakSelf.imageView.alpha = 1;
                       } completion:^(BOOL finished) {

                       }];
                       
                   }];
    

}


-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    DLog(@"link: %@", linkInfo);
	if ([[linkInfo.URL scheme] isEqualToString:@"user"])
    {
		// We use this arbitrary URL scheme to handle custom actions
		// So URLs like "user:xxx" will be handled here instead of opening in Safari.
		// Note: in the above example, "xxx" is the 'resourceSpecifier' part of the URL
//		NSString* user = [linkInfo.URL resourceSpecifier];
        
        // Display some message according to the user name clicked
//        NSString* title = [NSString stringWithFormat:@"Tap on user %@", user];
//        NSString* message = [NSString stringWithFormat:@"Here you may display the profile of user %@ on a new screen for example.", user];
		
		// Prevent the URL from opening in Safari, as we handled it here manually instead
		return NO;
	}
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
        {
            // Execute the default behavior, which is opening the URL in Safari for URLs, starting a call for phone numbers, ...
            return YES;
        }
        else
        {
            return NO;
        }
	}
}



@end
