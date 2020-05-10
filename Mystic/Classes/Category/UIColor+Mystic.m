//
//  Tiny.m
//  Tiny
//
//  Created by Travis Weerts on 4/2/11.
//  Copyright 2011 Tinymatic. All rights reserved.
//

#import "UIColor+Mystic.h"

#define DEFAULT_VOID_COLOR	nil


// Observer 2°, D65 Illuminant
#define REFX_O2_D65 95.047
#define REFY_O2_D65 100.0
#define REFZ_O2_D65 108.883

// Coordinate bounds for device and whitepoint
#define REFMIN_L 0.0
#define REFMAX_L 100.0
#define REFMIN_A_02_D65 -86.184593
#define REFMAX_A_02_D65 98.254173
#define REFMIN_B_02_D65 -107.863632
#define REFMAX_B_02_D65 94.482437

void HSVtoRGB3(float h, float s, float v, float *r, float *g, float *b)
{
    if (s == 0) {
        *r = *g = *b = v;
    } else {
        float   f,p,q,t;
        int     i;
        
        h *= 360;
        
        if (h == 360.0f) {
            h = 0.0f;
        }
        
        h /= 60;
        i = floor(h);
        
        f = h - i;
        p = v * (1.0 - s);
        q = v * (1.0 - (s*f));
        t = v * (1.0 - (s * (1.0 - f)));
        
        switch (i) {
            case 0: *r = v; *g = t; *b = p; break;
            case 1: *r = q; *g = v; *b = p; break;
            case 2: *r = p; *g = v; *b = t; break;
            case 3: *r = p; *g = q; *b = v; break;
            case 4: *r = t; *g = p; *b = v; break;
            case 5: *r = v; *g = p; *b = q; break;
        }
    }
}

void RGBtoHSV3(float r, float g, float b, float *h, float *s, float *v)
{
    float max = MAX(r, MAX(g, b));
    float min = MIN(r, MIN(g, b));
    float delta = max - min;
    
    *v = max;
    *s = (max != 0.0f) ? (delta / max) : 0.0f;
    
    if (*s == 0.0f) {
        *h = 0.0f;
    } else {
        if (r == max) {
            *h = (g - b) / delta;
        } else if (g == max) {
            *h = 2.0f + (b - r) / delta;
        } else if (b == max) {
            *h = 4.0f + (r - g) / delta;
        }
        
        *h *= 60.0f;
        
        if (*h < 0.0f) {
            *h += 360.0f;
        }
    }
    
    *h /= 360.0f;
}

@implementation UIColor (Mystic)


- (NSArray *)rgbaArray
{
    // Takes a UIColor and returns R,G,B,A values in NSNumber form
    CGFloat r=0,g=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return @[[NSNumber numberWithFloat:r],[NSNumber numberWithFloat:g],[NSNumber numberWithFloat:b],[NSNumber numberWithFloat:a]];
}

- (NSArray *)hsbaArray
{
    // Takes a UIColor and returns Hue,Saturation,Brightness,Alpha values in NSNumber form
    CGFloat h=0,s=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [self getHue:&h saturation:&s brightness:&b alpha:&a];
    }
    
    return @[[NSNumber numberWithFloat:h],[NSNumber numberWithFloat:s],[NSNumber numberWithFloat:b],[NSNumber numberWithFloat:a]];
}
- (UIColor *) colorWithHue:(CGFloat)hue saturation:(CGFloat)sat brightness:(CGFloat)b;
{
    MysticHSB hsb = (MysticHSB){hue,sat,b};
    return [UIColor colorWithHSB:hsb];
}
+ (CGFloat) differenceLAB:(UIColor *)color color2:(UIColor *)color2;
{
    double KL = 1;
    double K1 = 0.045;
    double K2 = 0.015;
    // double KL = 2;
    // double K1 = 0.048;
    // double K2 = 0.014;
    
    CGFloat l, a, b;
    CGFloat l2, a2, b2;
    CGFloat alpha, alpha2;
    
    [color getLightness:&l A:&a B:&b alpha:&alpha];
    [color2 getLightness:&l2 A:&a2 B:&b2 alpha:&alpha2];

    
    
    CGFloat dL = fabs(l - l2);
    CGFloat c1 = sqrtf((powf(a, 2) + powf(b, 2)));
    CGFloat c2 = sqrtf((powf(a2, 2) + powf(b2, 2)));
    CGFloat dC = fabs(c1 - c2);
    CGFloat da = fabs(a - a2);
    CGFloat db = fabs(b - b2);
    CGFloat ddd = powf(da, 2)+powf(db, 2) - powf(dC, 2);
    CGFloat dH = fabs(ddd) < .001 ? 0 : sqrtf(ddd);
    
    CGFloat sec1 = powf((dL / KL), 2);
    CGFloat sec2 = powf((dC / (1 + (K1 * c1))), 2);
    CGFloat sec3 = powf((dH / (1 + (K2 * c1))), 2);
    
    CGFloat sq = sqrtf(sec1 + sec2 + sec3);
    
    sq = sq/100.0;
    if(isnan(sq))
    {
        DLog(@"da: %2.2f  |  %2.2f  |  %2.2f", powf(da, 2), powf(db, 2), powf(dC, 2));
        
        
        int y = 0;
    }
    
    return sq;
}
+ (UIColor *)colorWithLightness:(CGFloat)lightness A:(CGFloat)A B:(CGFloat)B alpha:(CGFloat)alpha
{
    CGFloat x,y,z;
    [UIColor labToXyzL:lightness A:A B:B X:&x Y:&y Z:&z];
    
    CGFloat r,g,b;
    [UIColor xyzToRgbx:x y:y z:z r:&r g:&g b:&b];
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:alpha];
}

- (void)getLightness:(CGFloat *)lightnessOut A:(CGFloat *)aOut B:(CGFloat *)bOut alpha:(CGFloat *)alphaOut
{
    CGFloat R,G,B,alphaIn;
    [self getRed:&R green:&G blue:&B alpha:&alphaIn];
    
    CGFloat x,y,z;
    [UIColor rgbToXYZr:R g:G b:B x:&x y:&y z:&z];
    [UIColor xyzToLabx:x y:y z:z l:lightnessOut a:aOut b:bOut];
    
    // L range is 0 to 100.   a and b range ??? 'independent of colorspace' according to wikipedia.  Looks like 500 for A, 200 for B in these formulas (converting from XYZ)
    
    *alphaOut = alphaIn;
}

- (UIColor *)offsetWithLightness:(CGFloat)lightnessOffset a:(CGFloat)aOffset b:(CGFloat)bOffset alpha:(CGFloat)alphaOffset
{
    CGFloat l,a,b,alpha;
    [self getLightness:&l A:&a B:&b alpha:&alpha];
    
    l += lightnessOffset;
    a += aOffset;
    b += bOffset;
    alpha += alphaOffset;
    
    return [UIColor colorWithLightness:l A:a B:b alpha:alpha];
}

#pragma mark - Public intermediate XYZ colorspace methods (mostly for tests)
- (void)getX:(CGFloat *)xOut Y:(CGFloat *)yOut Z:(CGFloat *)zOut alpha:(CGFloat *)alphaOut
{
    CGFloat r,g,b,alpha;
    [self getRed:&r green:&g blue:&b alpha:&alpha];
    
    CGFloat x,y,z;
    [UIColor rgbToXYZr:r g:g b:b x:&x y:&y z:&z];
    
    *xOut = x;
    *yOut = y;
    *zOut = z;
    *alphaOut = alpha;
}

#pragma mark - Private: RGB->XYZ->LAB

+ (void) rgbToXYZr:(CGFloat)r g:(CGFloat)g b:(CGFloat)b x:(CGFloat *)outX y:(CGFloat *)outY z:(CGFloat *)outZ
{
    if(r > 0.04045) { r = pow(((r + 0.055) / 1.055),2.4); }
    else { r = r / 12.92; }
    if(g > 0.04045) { g = pow(((g + 0.055) / 1.055),2.4); }
    else { g = g / 12.92; }
    if(b > 0.04045) { b = pow(((b + 0.055) / 1.055),2.4); }
    else { b = b / 12.92; }
    
    r *= 100.0;
    g *= 100.0;
    b *= 100.0;
    
    *outX = (r * 0.4124) + (g * 0.3576) + (b * 0.1805);
    *outY = (r * 0.2126) + (g * 0.7152) + (b * 0.0722);
    *outZ = (r * 0.0193) + (g * 0.1192) + (b * 0.9505);
}

+ (void) xyzToLabx:(CGFloat)x y:(CGFloat)y z:(CGFloat)z l:(CGFloat *)outL a:(CGFloat *)outA b:(CGFloat *)outB
{
    x /= REFX_O2_D65;
    y /= REFY_O2_D65;
    z /= REFZ_O2_D65;
    
    if(x > 0.008856) { x = pow(x, 1.0/3.0);} else {x = (7.787 * x) +(16.0/116.0);}
    if(y > 0.008856) { y = pow(y, 1.0/3.0);} else {y = (7.787 * y) +(16.0/116.0);}
    if(z > 0.008856) { z = pow(z, 1.0/3.0);} else {z = (7.787 * z) +(16.0/116.0);}
    
    *outL = (116.0 * y) - 16.0;
    *outA = 500.0 * (x - y);
    *outB = 200.0 * (y - z);
}

#pragma mark - Private: LAB->XYZ->RGB

+ (void)labToXyzL:(CGFloat)L A:(CGFloat)A B:(CGFloat)B X:(CGFloat *)outX Y:(CGFloat *)outY Z:(CGFloat *)outZ
{
    CGFloat x,y,z;
    y = (L + 16.0) / 116.0;
    x = A / 500.0 + y;
    z = y - B / 200.0;
    
    if(pow(y, 3.0) > 0.008856) { y = pow(y, 3.0); } else { y = (y - 16.0/116.0) / 7.787; }
    if(pow(x, 3.0) > 0.008856) { x = pow(x, 3.0); } else { x = (x - 16.0/116.0) / 7.787; }
    if(pow(z, 3.0) > 0.008856) { z = pow(z, 3.0); } else { z = (z - 16.0/116.0) / 7.787; }
    
    *outX = REFX_O2_D65 * x;
    *outY = REFY_O2_D65 * y;
    *outZ = REFZ_O2_D65 * z;
}

+ (void) xyzToRgbx:(CGFloat)x y:(CGFloat)y z:(CGFloat)z r:(CGFloat *)outR g:(CGFloat *)outG b:(CGFloat *)outB
{
    x /= 100.0;
    y /= 100.0;
    z /= 100.0;
    
    CGFloat r,g,b;
    
    r = x * 3.2406 + y * -1.5372 + z * -0.4986;
    g = x * -0.9689 + y * 1.8758 + z * 0.0415;
    b = x * 0.0557 + y * -0.2040 + z * 1.0570;
    
    if(r > 0.0031308) { r = 1.055 * pow(r, (1 / 2.4)) - 0.055; } else { r = 12.92 * r; }
    if(g > 0.0031308) { g = 1.055 * pow(g, (1 / 2.4)) - 0.055; } else { g = 12.92 * g; }
    if(b > 0.0031308) { b = 1.055 * pow(b, (1 / 2.4)) - 0.055; } else { b = 12.92 * b; }
    
    *outR = r * 255.0;
    *outG = g * 255.0;
    *outB = b * 255.0;
}


- (CIColor *) CIColor;
{
    return [CIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}
+ (UIColor *) colorWithRGB:(MysticRGB)rgb;
{
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];
}

+ (UIColor *) color:(MysticColorType)colorType;
{
    return [MysticColor colorWithType:colorType];
}
+ (UIColor *) colorWithType:(MysticColorType)colorType;
{
    return [MysticColor colorWithType:colorType];
}
- (UIColor *) invertedColor;
{
    return [[[UIColor alloc] initWithRed:(1.0 - self.red)
                                             green:(1.0 - self.green)
                                              blue:(1.0 - self.blue)
                                             alpha:self.alpha] autorelease];
}
- (UIColor *) addRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
{
    MysticRGB rgb = self.rgb;
    rgb.red = MAX(MIN(1.0,rgb.red+red), 0.0);
    rgb.green = MAX(MIN(1.0,rgb.green+green), 0.0);
    rgb.blue = MAX(MIN(1.0,rgb.blue+blue), 0.0);
    rgb.alpha = MAX(MIN(1.0,rgb.alpha+alpha), 0.0);
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:rgb.alpha];


}
+ (UIColor *) clear; { return [UIColor clearColor]; }
+ (UIColor *) yellow; { return [UIColor yellowColor]; }
+ (UIColor *) red; { return [UIColor redColor]; }
+ (UIColor *) blue; { return [UIColor blueColor]; }
+ (UIColor *) green; { return [UIColor greenColor]; }
+ (UIColor *) black; { return [UIColor blackColor]; }
+ (UIColor *) white; { return [UIColor whiteColor]; }
+ (UIColor *) orange; { return [UIColor orangeColor]; }
+ (UIColor *) purple; { return [UIColor purpleColor]; }
+ (UIColor *) cyan; { return [UIColor cyanColor]; }
+ (UIColor *) magenta; { return [UIColor magentaColor]; }
- (UIColor *) opaque; { return [self alpha:1]; }
- (UIColor *) displayColor;
{
    return self;
//    return [self isEqualToColor:[UIColor blackColor]] ? [UIColor hex:@"40403e"] : self;
}
- (NSString *) vec4Str;
{
    return [NSString stringWithFormat:@"vec4(%2.1f, %2.1f, %2.1f, %2.1f)", self.red, self.green, self.blue, self.alpha];
}

+ (UIColor *) mysticBackgroundColor;
{
    return [UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
}

+ (UIColor *) mysticBurnoutKhaki;
{
    return [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)232/255 blue:(CGFloat)217/255 alpha:1];
}

+ (UIColor *) mysticGrayBackgroundColor;
{
    return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)216/255 blue:(CGFloat)204/255 alpha:1];
}

+ (UIColor *) mysticDarkGrayBackgroundColor;
{
    return [UIColor colorWithRed:(CGFloat)203/255 green:(CGFloat)199/255 blue:(CGFloat)189/255 alpha:1];
}

+ (UIColor *) mysticWhiteBackgroundColor;
{
    return [UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
}

+ (UIColor *) mysticDarkBackgroundColor;
{
    return [UIColor colorWithRed:(CGFloat)31/255 green:(CGFloat)26/255 blue:(CGFloat)24/255 alpha:1];
}

+ (UIColor *) mysticChocolateColor;
{
    return [UIColor colorWithRed:(CGFloat)71/255 green:(CGFloat)59/255 blue:(CGFloat)55/255 alpha:1];
}

+ (UIColor *) mysticDarkChocolateColor;
{
    return [UIColor colorWithRed:(CGFloat)51/255 green:(CGFloat)43/255 blue:(CGFloat)40/255 alpha:1];
}


+ (UIColor *) mysticRustColor;
{
    return [UIColor colorWithRed:(CGFloat)163/255 green:(CGFloat)83/255 blue:(CGFloat)72/255 alpha:1];
}

+ (UIColor *) mysticReallyLightGrayColor;
{
    return [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)185/255 blue:(CGFloat)180/255 alpha:1];
}
+ (UIColor *) mysticSubGrayColor;
{
    return [UIColor colorWithRed:(CGFloat)111/255 green:(CGFloat)106/255 blue:(CGFloat)106/255 alpha:1];
}
+ (UIColor *) mysticTitleDarkColor;
{
    return [UIColor colorWithRed:(CGFloat)83/255 green:(CGFloat)82/255 blue:(CGFloat)80/255 alpha:1];
}
+ (UIColor *) mysticTitleLightColor;
{
    return [UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)238/255 blue:(CGFloat)227/255 alpha:1];
}
+ (UIColor *) mysticLightTextShadowColor
{
    return [UIColor colorWithRed:0.106 green:0.106 blue:0.106 alpha:1];
}
+ (UIColor *) mysticLightTextColor;
{
    return [UIColor colorWithRed:(CGFloat)251/255 green:(CGFloat)238/255 blue:(CGFloat)227/255 alpha:1];
}
+ (UIColor *) mysticDarkTextColor;
{
    return [UIColor colorWithRed:0.106 green:0.106 blue:0.106 alpha:1];
}
+ (UIColor *) mysticDarkTextShadowColor;
{
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
}
+ (UIColor *) mysticWhiteColor;
{
    return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)233/255 blue:(CGFloat)227/255 alpha:1];
}
+ (UIColor *) mysticGreenColor;
{
    return [UIColor colorWithRed:(CGFloat)120/255 green:(CGFloat)159/255 blue:(CGFloat)45/255 alpha:1];
}
+ (UIColor *) mysticPinkColor;
{
    return [MysticColor colorWithType:MysticColorTypePink];

//    return [UIColor colorWithRed:(CGFloat)214/255 green:(CGFloat)114/255 blue:(CGFloat)110/255 alpha:1];
}
+ (UIColor *) mysticBrownColor
{
    return [UIColor colorWithRed:0.426 green:0.373 blue:0.349 alpha:1];
}
+ (UIColor *) mysticBlackColor
{
    return [UIColor colorWithRed:0.106 green:0.106 blue:0.106 alpha:1];
}
+ (UIColor *) mysticGrayColor
{
    return [UIColor colorWithRed:0.302 green:0.302 blue:0.302 alpha:1];
}
+ (UIColor *) mysticBlueColor
{
    return [UIColor colorWithRed:0.267 green:0.675 blue:0.667 alpha:1];
}
+ (UIColor *) mysticLightBlueColor
{
    return [UIColor colorWithRed:(CGFloat)143/255 green:(CGFloat)217/255 blue:(CGFloat)215/255 alpha:1];
}
+ (UIColor *) mysticRedColor
{
    return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)57/255 blue:(CGFloat)44/255 alpha:1];
}
+ (UIColor *) mysticLightRedColor
{
    return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)57/255 blue:(CGFloat)44/255 alpha:1];
}
+ (UIColor *) mysticDarkRedColor
{
    return [UIColor colorWithRed:(CGFloat)74/255 green:(CGFloat)35/255 blue:(CGFloat)29/255 alpha:1];
}
+ (UIColor *) mysticInactiveIconColor;
{
    return [UIColor colorWithRed:(CGFloat)111/255 green:(CGFloat)106/255 blue:(CGFloat)106/255 alpha:1];
}

+ (UIColor *) mysticDarkGrayColor;
{
    return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)80/255 blue:(CGFloat)80/255 alpha:1];
}
- (UIColor *) lighterThan:(UIColor *)color;
{
    if(!color || [self isLighterThan:color]) return self;
    
    MysticColorHSB _hsb = self.hsb;
    MysticColorHSB _hsb2 = color.hsb;
    if(1-_hsb2.brightness<=0) return self;
    return [self colorWithBrightness:MIN(1,MAX(0, (1-(0.9*(1-_hsb2.brightness)))+(_hsb.brightness*(0.9*(1-_hsb2.brightness)))))];
}
- (UIColor *) darkerThan:(UIColor *)color;
{
    if(!color || [self isDarkerThan:color]) return self;
    MysticColorHSB _hsb = self.hsb;
    MysticColorHSB _hsb2 = color.hsb;
    if(_hsb2.brightness<=0) return self;
    float p = ((_hsb2.brightness-_hsb.brightness)/_hsb2.brightness)*(0.9*_hsb2.brightness);
    return [self colorWithBrightness:MIN(1,MAX(0, (0.9*_hsb2.brightness)-p))];
}
- (BOOL) isDarkerThan:(UIColor *)color;
{
    MysticColorHSB _hsb = self.hsb;
    return !color ? NO : _hsb.brightness < color.hsb.brightness;
}
- (BOOL) isLighterThan:(UIColor *)color;
{
    MysticColorHSB _hsb = self.hsb;
    return !color ? NO : _hsb.brightness > color.hsb.brightness;
}

- (UIColor *) darker:(CGFloat)percent;
{
    
    MysticColorHSB _hsb = self.hsb;
    float b = MAX(0, _hsb.brightness - ((_hsb.brightness)*percent));
    return [self colorWithBrightness:b];
//
}

- (UIColor *) lighter:(CGFloat)percent;
{
    MysticColorHSB _hsb = self.hsb;
    float b = MIN(1, ((1 - _hsb.brightness)*percent) + _hsb.brightness);
    _hsb.brightness = b;
    if(b - _hsb.brightness < percent)
    {
        _hsb.saturation = MAX(0, _hsb.saturation - (( _hsb.saturation)*percent));
    }
    
    return [self colorWithHSB:(MysticColorHSB)_hsb];
;
    
}

- (NSString *) hexString; { return [self hexValue]; }


- (NSString *) hexValue
{
    if([self isEqualToColor:UIColor.clearColor]) return @"CLEAR";
    NSArray *rgb = [self rgbaArray];
    CGFloat am = MAX([[rgb objectAtIndex:3] floatValue], 0);
    CGFloat rm = MAX([[rgb objectAtIndex:0] floatValue], 0);
    CGFloat gm = MAX([[rgb objectAtIndex:1] floatValue], 0);
    CGFloat bm = MAX([[rgb objectAtIndex:2] floatValue], 0);
    
    CGFloat a = MIN(am, 1);
    CGFloat r = MIN(rm, 1);
    CGFloat g = MIN(gm, 1);
    CGFloat b = MIN(bm, 1);
    
//    DLog(@"hex value:  %@", RGBStr(rm, gm, bm));
    // Convert to hex string between 0x00 and 0xFF
    NSString *s = [NSString stringWithFormat:@"%02lX%02lX%02lX",
            (long)(r * 255), (long)(g * 255), (long)(b * 255)];
    if(a <= 0) s = [s stringByAppendingString:@" 0.0%"];
    return s;
//    return [NSString stringWithFormat:@"0x%02lX%02lX%02lX%02lX",
//            (long)(a * 255), (long)(r * 255), (long)(g * 255), (long)(b * 255)];
    
}

+ (UIColor *) randomColor {
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    id color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    return color;
}

- (NSString *) rgbaString;
{
    return [NSString stringWithFormat:@"rgba(%2.4f,%2.4f,%2.4f,%2.4f)", [(UIColor *)self red], [(UIColor *)self green], [(UIColor *)self blue], [(UIColor *)self alpha]];
    
}
- (NSString *) fgString;
{
    return [NSString stringWithFormat:@"fg%d,%d,%d;", self.red255, self.green255, self.blue255];
}
- (NSString *) bgString;
{
    return [NSString stringWithFormat:@"bg%d,%d,%d;", self.red255, self.green255, self.blue255];
}
- (NSString *) rgb255;
{
    return [NSString stringWithFormat:@"%d,%d,%d", self.red255, self.green255, self.blue255];
}
+ (UIColor *) string: (NSString *) str
{
    CGFloat alpha = 1.0;
    
    NSString *cs = nil;
    if(str)
    {
        if([str hasPrefix:@"fg"])
        {
            NSArray *c = [[str substringFromIndex:2] componentsSeparatedByString:@","];
            return [UIColor colorWithRed:[(NSNumber *)c[0] floatValue]/255.f green:[(NSNumber *)c[1] floatValue]/255.f blue:[(NSNumber *)c[2] floatValue]/255.f alpha:1];
            
        }
        else if([str hasPrefix:@"bg"])
        {
            NSArray *c = [[str substringFromIndex:2] componentsSeparatedByString:@","];
            return [UIColor colorWithRed:[(NSNumber *)c[0] floatValue]/255.f green:[(NSNumber *)c[1] floatValue]/255.f blue:[(NSNumber *)c[2] floatValue]/255.f alpha:1];
        }
        else if([str hasPrefix:@"rgba("])
        {
            NSString *rgbaStr = [str substringWithRange:(NSRange){5, str.length-6}];
            NSArray *rgbaArray = [rgbaStr componentsSeparatedByString:@","];
            
            UIColor *c2 = rgbaArray.count == 4 ? [UIColor colorWithRed:[[rgbaArray objectAtIndex:0] floatValue] green:[[rgbaArray objectAtIndex:1] floatValue] blue:[[rgbaArray objectAtIndex:2] floatValue] alpha:[[rgbaArray objectAtIndex:3] floatValue]] : nil;
            
            return c2;
        }
        NSString *colorString = [str isKindOfClass:[NSString class]] ? str : [NSString stringWithFormat:@"%@", str];
        NSArray *c = [colorString componentsSeparatedByString:@","];
        if([c count] == 3)
        {
            CGFloat d = 1;
            for (NSString *s in c) {
                
                if(s.floatValue > 1) { d = 255.f; break; }
            }
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            
            CGFloat r, g, b = 0;
            r = [numberFormatter numberFromString:c[0]].floatValue/d;
            g = [numberFormatter numberFromString:c[1]].floatValue/d;
            b = [numberFormatter numberFromString:c[2]].floatValue/d;

//            NSLog(@"color from string: d: %2.2f   r:  %2.2f   g:  %2.2f  b:  %2.2f  %@", d, [(NSNumber *)c[0] floatValue]/d, [(NSNumber *)c[1] floatValue]/d, [(NSNumber *)c[2] floatValue]/d,  [c componentsJoinedByString:@", "]);
            [numberFormatter release];
            return [UIColor colorWithRed:r green:g blue:b alpha:1];
        }
        c = [colorString componentsSeparatedByString:@"@"];
        if(c.count > 1)
        {
            alpha = (CGFloat)[c[1] floatValue];
            c = c[0];
        }
        cs = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    }
    
    
    UIColor *r = nil;
    if([cs isEqualToString:@"RANDOM"] || [cs equals:@"#RANDOM"]) r = [UIColor randomColor];
    else if([cs isEqualToString:@"TEXTURED"]) r = [UIColor scrollViewTexturedBackgroundColor];
    else if([cs isEqualToString:@"FLIPSIDE"]) r = [UIColor viewFlipsideBackgroundColor];
    else if([cs isEqualToString:@"GROUP"]) r = [UIColor groupTableViewBackgroundColor];
    else if([cs isEqualToString:@"STRIPES"]) r = [UIColor groupTableViewBackgroundColor];
    else if([cs isEqualToString:@"TABLE"]) r = [UIColor groupTableViewBackgroundColor];
    else if([cs isEqualToString:@"PINSTRIPES"]) r = [UIColor groupTableViewBackgroundColor];
    else if([cs isEqualToString:@"BLACK"]) r = [UIColor blackColor];
    else if([cs isEqualToString:@"RED"]) r = [UIColor redColor];
    else if([cs isEqualToString:@"WHITE"]) r = [UIColor whiteColor];
    else if([cs isEqualToString:@"YELLOW"]) r = [UIColor yellowColor];
    else if([cs isEqualToString:@"BLUE"]) r = [UIColor blueColor];
    else if([cs isEqualToString:@"PURPLE"]) r = [UIColor purpleColor];
    else if([cs isEqualToString:@"GRAY"]) r = [UIColor grayColor];
    else if([cs isEqualToString:@"GREEN"]) r = [UIColor greenColor];
    else if([cs isEqualToString:@"ORANGE"]) r = [UIColor orangeColor];
    else if([cs isEqualToString:@"BROWN"]) r = [UIColor brownColor];
    else if([cs isEqualToString:@"CLEAR"]) r = [UIColor clearColor];
    else if([cs isEqualToString:@"LIGHTGRAY"]) r = [UIColor lightGrayColor];
    else if([cs isEqualToString:@"MAGENTA"]) r = [UIColor magentaColor];
    else if([cs equals:@"#GREEN"]) r = [UIColor string:COLOR_GREEN];
    else if([cs equals:@"#GREEN_BRIGHT"]) r = [UIColor string:COLOR_GREEN_BRIGHT];
    else if([cs equals:@"#RED"]) r = [UIColor string:COLOR_RED];
    else if([cs equals:@"#CYAN"]) r = [UIColor cyanColor];
    else if([cs equals:@"#MAGENTA"]) r = [UIColor magentaColor];
    else if([cs equals:@"#WHITE"]) r = [UIColor string:COLOR_WHITE];
    else if([cs equals:@"#BLUE"]) r = [UIColor string:COLOR_BLUE];
    else if([cs equals:@"#YELLOW"]) r = [UIColor string:COLOR_YELLOW];
    else if([cs equals:@"#BG"]) r = [UIColor string:COLOR_BG];
    else if([cs equals:@"#PURPLE"]) r = [UIColor string:COLOR_PURPLE];
    else if([cs equals:@"#DATE"]) r = [UIColor string:COLOR_DATE];
    else if([cs equals:@"#DOTS"]) r = [UIColor string:COLOR_DOTS];
    else if([cs equals:@"#BLOCK"]) r = [UIColor string:COLOR_BLOCK];
    else if([cs equals:@"#DULL"]) r = [UIColor string:COLOR_DULL];
    else if([cs equals:@"#COLOR_GREEN"]) r = [UIColor string:COLOR_GREEN];
    else if([cs equals:@"#COLOR_GREEN_BRIGHT"]) r = [UIColor string:COLOR_GREEN_BRIGHT];
    else if([cs equals:@"#COLOR_RED"]) r = [UIColor string:COLOR_RED];
    else if([cs equals:@"#COLOR_WHITE"]) r = [UIColor string:COLOR_WHITE];
    else if([cs equals:@"#COLOR_BLUE"]) r = [UIColor string:COLOR_BLUE];
    else if([cs equals:@"#COLOR_YELLOW"]) r = [UIColor string:COLOR_YELLOW];
    else if([cs equals:@"#COLOR_PURPLE"]) r = [UIColor string:COLOR_PURPLE];
    else if([cs equals:@"#COLOR_DATE"]) r = [UIColor string:COLOR_DATE];
    else if([cs equals:@"#COLOR_DOTS"]) r = [UIColor string:COLOR_DOTS];
    else if([cs equals:@"#COLOR_BLOCK"]) r = [UIColor string:COLOR_BLOCK];
    else if([cs equals:@"#COLOR_DULL"]) r = [UIColor string:COLOR_DULL];
    else if([cs equals:@"#COLOR_BG"]) r = [UIColor string:COLOR_BG];
    else if(cs) r = [UIColor colorWithHexString:cs];
	if(alpha < 1.0) r = [r colorWithAlphaComponent:alpha];
    return r;
}
+ (UIColor *) fromHex: (NSString *) stringToConvert{
	return [UIColor colorWithHexString:stringToConvert];
}
+ (UIColor *) hex: (NSString *) hex{
    return [self fromHex:hex];
}
+ (UIColor *) fromString: (NSString *) string;
{
    return [self string:string];
}


- (BOOL)isEqualToColor:(UIColor *)color;
{
    UIColor *c = [color retain];
    if(self.red != c.red || self.blue != c.blue || self.green != c.green || self.alpha != c.alpha) { [c autorelease]; return NO; }
    [c autorelease];
    return YES;
}



// Return a UIColor's color space model
- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *) colorSpaceString
{
	switch ([self colorSpaceModel])
	{
		case kCGColorSpaceModelUnknown:
			return @"kCGColorSpaceModelUnknown";
		case kCGColorSpaceModelMonochrome:
			return @"kCGColorSpaceModelMonochrome";
		case kCGColorSpaceModelRGB:
			return @"kCGColorSpaceModelRGB";
		case kCGColorSpaceModelCMYK:
			return @"kCGColorSpaceModelCMYK";
		case kCGColorSpaceModelLab:
			return @"kCGColorSpaceModelLab";
		case kCGColorSpaceModelDeviceN:
			return @"kCGColorSpaceModelDeviceN";
		case kCGColorSpaceModelIndexed:
			return @"kCGColorSpaceModelIndexed";
		case kCGColorSpaceModelPattern:
			return @"kCGColorSpaceModelPattern";
		default:
			return @"Not a valid color space";
	}
}

- (BOOL) canProvideRGBComponents
{
	return (([self colorSpaceModel] == kCGColorSpaceModelRGB) || 
			([self colorSpaceModel] == kCGColorSpaceModelMonochrome));
}
- (MysticRGB) rgb;
{
    return (MysticRGB){self.red,self.green,self.blue,self.alpha};
}
// Return a UIColor's components
- (NSArray *) arrayFromRGBAComponents
{
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	
	// RGB
	if ([self colorSpaceModel] == kCGColorSpaceModelRGB)
		return [NSArray arrayWithObjects:
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[1]],
				[NSNumber numberWithFloat:c[2]],
				[NSNumber numberWithFloat:c[3]],
				nil];
	
	// Monochrome
	if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome)
		return [NSArray arrayWithObjects:
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[1]],
				nil];
	
	// No support at this time for other color spaces yet
	return nil;
}
- (BOOL) isHueDifferentThan:(UIColor *)color;
{
    return [self isHueDifferentThan:color threshold:0.1];
}
- (BOOL) isHueDifferentThan:(UIColor *)color threshold:(float)threshold;
{
    if([self isEqualToColor:color]) return NO;
    if(!color) return YES;
    float hue = self.hue;
    float hue2 = color.hue;
    return fabsf(hue-hue2) > threshold;
}
- (float) hueDifference:(UIColor *)color;
{
    if([self isEqualToColor:color]) return 0;
    if(!color) return 1;
    float hue = self.hue;
    float hue2 = color.hue;
    return fabsf(hue-hue2);
}
- (BOOL) isDifferentThan:(UIColor *)color;
{
    return [self isDifferentThan:color threshold:0.09];
}
- (BOOL) isDifferentThan:(UIColor *)color threshold:(float)t;
{
    if([self isEqualToColor:color]) return NO;
    if(!color) return YES;
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    CGFloat r = c[0];
    CGFloat g,b;
    const CGFloat *c2 = CGColorGetComponents(color.CGColor);
    CGFloat r2 = c2[0];
    CGFloat g2,b2;
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome)
    {
        g = c[0];
        b = c[0];
        g2 = c2[0];
        b2 = c2[0];
    }
    else
    {
        g = c[1];
        b = c[2];
        g2 = c2[1];
        b2 = c2[2];
    }
    float d = fabsf((float)(r - r2));
    d = d > t ? d : MAX(d,fabsf((float)(g - g2)));
    d = d > t ? d : MAX(d,fabsf((float)(b - b2)));
    return d > t;
}
- (MysticRGB) differenceThan:(UIColor *)color;
{
    MysticRGB diff = (MysticRGB){0,0,0};
    if([self isEqualToColor:color]) return diff;
    if(!color) return (MysticRGB){1,1,1};
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    CGFloat r = c[0];
    CGFloat g,b;
    const CGFloat *c2 = CGColorGetComponents(color.CGColor);
    CGFloat r2 = c2[0];
    CGFloat g2,b2;
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome)
    {
        g = c[0];
        b = c[0];
        g2 = c2[0];
        b2 = c2[0];
    }
    else
    {
        g = c[1];
        b = c[2];
        g2 = c2[1];
        b2 = c2[2];
    }
    diff.red = fabsf((float)(r-r2));
    diff.green = fabsf((float)(g-g2));
    diff.blue = fabsf((float)(b-b2));
    return diff;
}

//- (CGFloat) red
//{
//	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
//	const CGFloat *c = CGColorGetComponents(self.CGColor);
//	return c[0];
//}
//
//- (CGFloat) green
//{
//	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
//	const CGFloat *c = CGColorGetComponents(self.CGColor);
//	if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
//	return c[1];
//}
//
//- (CGFloat) blue
//{
//	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
//	const CGFloat *c = CGColorGetComponents(self.CGColor);
//	if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
//	return c[2];
//}

- (CGFloat) red
{
    NSArray *rgb = [self rgbaArray];
    return [rgb.firstObject floatValue];
//    CGFloat red, green, blue, alpha;
//    
//    [self getRed:&red green:&green blue:&blue alpha:&alpha];
//
    
    
//    return red;
}

- (CGFloat) green
{
//    CGFloat red, green, blue, alpha;
//    
//    [self getRed:&red green:&green blue:&blue alpha:&alpha];
//    
//    return green;
    
    NSArray *rgb = [self rgbaArray];
    return [[rgb objectAtIndex:1] floatValue];
}

- (CGFloat) blue
{
//    CGFloat red, green, blue, alpha;
//    
//    [self getRed:&red green:&green blue:&blue alpha:&alpha];
//    
//    return blue;
    NSArray *rgb = [self rgbaArray];
    return [[rgb objectAtIndex:2] floatValue];
}

- (CGFloat) alpha
{
    return CGColorGetAlpha([self CGColor]);
}

- (UIColor *) colorOpaque; { return [self alpha:1]; }
- (UIColor *) colorTransparent; { return [self alpha:0]; }

//- (CGFloat) alpha
//{
//	const CGFloat *c = CGColorGetComponents(self.CGColor);
//    NSInteger num = CGColorGetNumberOfComponents(self.CGColor);
//    
//    if(num == 2) return c[1];
//	return num > 3 ? c[num-1] : 1.0;
//}
- (UIColor *) clear; { return [UIColor clearColor]; }
- (UIColor *)alpha:(CGFloat)a;
{
    return a == 0 ? [UIColor clearColor] : [self colorWithAlphaComponent:a];
}
- (int) red255;
{
    CGFloat red, green, blue, alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    float c = red;
    int v = [@(c * 255.0) intValue];

    return v;
}
- (int) blue255;
{
    CGFloat red, green, blue, alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    
    float c = blue;
    int v = [@(c * 255.0) intValue];

    return v;

}
- (int) green255;
{
    CGFloat red, green, blue, alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    float c = green;
    int v = [@(c * 255.0) intValue];

    return v;

}
- (void) componentsDescription;
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    NSInteger num = CGColorGetNumberOfComponents(self.CGColor);
    
    NSString *str = @"Components: ";
    for (int i = 0; i < num; i++) {
        str = [str stringByAppendingFormat:@"%d: %2.1f |  ", i, c[i]];
        
    }
    DLog(@"Color: %@  |  %@", self.hexStringWithoutHash, str );
}

/*
 *
 * String Utilities
 *
 */

- (NSString *) stringFromColor
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use stringFromColor");
	return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
}

- (NSString *) hexStringFromColor
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use hexStringFromColor");
    
	CGFloat r, g, b;
	r = self.red;
	g = self.green;
	b = self.blue;
	
	// Fix range if needed
	if (r < 0.0f) r = 0.0f;
	if (g < 0.0f) g = 0.0f;
	if (b < 0.0f) b = 0.0f;
	
	if (r > 1.0f) r = 1.0f;
	if (g > 1.0f) g = 1.0f;
	if (b > 1.0f) b = 1.0f;
	
	// Convert to hex string between 0x00 and 0xFF
	return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

+ (UIColor *) colorWithString: (NSString *) stringToConvert
{
	NSString *cString = [stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Proper color strings are denoted with braces
	if (![cString hasPrefix:@"{"]) return DEFAULT_VOID_COLOR;
	if (![cString hasSuffix:@"}"]) return DEFAULT_VOID_COLOR;
	
	// Remove braces	
	cString = [cString substringFromIndex:1];
	cString = [cString substringToIndex:([cString length] - 1)];
	CFShow(cString);
	
	// Separate into components by removing commas and spaces
	NSArray *components = [cString componentsSeparatedByString:@", "];
	if ([components count] != 4) return DEFAULT_VOID_COLOR;
	
	// Create the color
	return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
						   green:[[components objectAtIndex:1] floatValue] 
							blue:[[components objectAtIndex:2] floatValue]
						   alpha:[[components objectAtIndex:3] floatValue]];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if([cString length] == 3) cString = [NSString stringWithFormat:@"%@%@", cString, cString];
    
	// String should be 6 or 8 characters
	if ([cString length] < 6) return DEFAULT_VOID_COLOR;
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	
    unsigned int a = 255;
    NSRange range;
    if ([cString length] == 8)
    {
        range.location = 0;
        range.length = 2;
        NSString *aString = [cString substringWithRange:range];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        cString = [cString substringFromIndex:2];
    }
	if ([cString length] != 6) return DEFAULT_VOID_COLOR;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:(float) a / 255.0f];
}

/**
 * Returns a UIColor that is offset from the current UIColor instance.
 *
 * @param {CGFloat} Hue offset (-1.0 to 1.0)
 * @param {CGFloat} Saturation offset (-1.0 to 1.0)
 * @param {CGFloat} Brightness offset (-1.0 to 1.0)
 * @param {CGFloat} Alpha offset (-1.0 to 1.0)
 *
 * @return {UIColor}
 */
- (UIColor *)offsetWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    // Current values
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    // Calculate offsets
    hue         = fmodf(hue + h, 1.0f);
    saturation  = [self clamp:(saturation + s)];
    brightness  = [self clamp:(brightness + b)];
    alpha       = [self clamp:(alpha + a)];
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (BOOL) isInGraySpace;
{
    MysticColorHSB h = self.hsb;
    return (h.saturation == 0 && h.hue == 0);
        
}

- (UIColor*)blendWithColor:(UIColor*)color2 alpha:(CGFloat)alpha2
{
    alpha2 = MIN( 1.0, MAX( 0.0, alpha2 ) );
    CGFloat beta = 1.0 - alpha2;
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat red     = r1 * beta + r2 * alpha2;
    CGFloat green   = g1 * beta + g2 * alpha2;
    CGFloat blue    = b1 * beta + b2 * alpha2;
    CGFloat alpha   = a1 * beta + a2 * alpha2;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - getHSB

- (MysticColorHSB) hsb;
{
    float hue = 0;
    float saturation = 0;
    float brightness = 0;
    BOOL success = NO;
    int i = 0;
//    success = [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    NSArray *rgb = [self rgbaArray];
    CGFloat alpha = [[rgb objectAtIndex:3] floatValue];
    CGFloat red = [[rgb objectAtIndex:0] floatValue];
    CGFloat green = [[rgb objectAtIndex:1] floatValue];
    CGFloat blue = [[rgb objectAtIndex:2] floatValue];

    
    NSArray *hsba = [self hsbaArray];
    
//    RGBtoHSV3(red, green, blue, &hue, &saturation, &brightness);
    hue = [[hsba objectAtIndex:0] floatValue];
    saturation = [[hsba objectAtIndex:1] floatValue];
    brightness = [[hsba objectAtIndex:2] floatValue];

    success = YES;
//
//    if(!success)
//    {
//        DLogError(@"couldnt convert color to hsb: %@", self);
//        UIColor *c = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
//        success = [c getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
//        i = 1;
//
//    }
//    if(!success)
//    {
//        CGFloat red = self.red;
//        CGFloat green = self.green;
//        CGFloat blue = self.blue;
//
//        
//        CGFloat hue = 0;
//        CGFloat saturation = 0;
//        CGFloat brightness = 0;
//        
//        CGFloat minRGB = MIN(red, MIN(green,blue));
//        CGFloat maxRGB = MAX(red, MAX(green,blue));
//        
//        if (minRGB==maxRGB) {
//            hue = 0;
//            saturation = 0;
//            brightness = minRGB;
//        } else {
//            CGFloat d = (red==minRGB) ? green-blue : ((blue==minRGB) ? red-green : blue-red);
//            CGFloat h = (red==minRGB) ? 3 : ((blue==minRGB) ? 1 : 5);
//            hue = (h - d/(maxRGB - minRGB)) / 6.0;
//            saturation = (maxRGB - minRGB)/maxRGB;
//            brightness = maxRGB;
//        }
//        i = 2;
//    }
//    DLog(@"hsb success: %d  %@    %2.2f ,  %2.2f  ,  %2.2f", i, b(success), hue, saturation, brightness);

    if(success) return (MysticColorHSB){hue,saturation,brightness,alpha};
    
    return (MysticColorHSB){0,0,0,0};
    
}
+ (UIColor *) colorWithHSB:(MysticHSB)hsb;
{
    return [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:hsb.brightness alpha:1];
}
+ (UIColor *) colorWithHSBA:(MysticColorHSB)hsb;
{
    return [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:hsb.brightness alpha:hsb.alpha];
}
+ (UIColor *) colorWithRGB:(MysticRGB)rgb alpha:(CGFloat)alpha;
{
    return [UIColor colorWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:alpha];
}
+ (UIColor *) colorWithHSB:(MysticHSB)hsb alpha:(CGFloat)alpha;
{
    return [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:hsb.brightness alpha:alpha];
}
- (UIColor *) colorWithMinBrightness:(CGFloat)b;
{
    NSArray *hsba = [self hsbaArray];
    CGFloat b2 = [[hsba objectAtIndex:2] floatValue];
    
    return b2<b ? [self colorWithBrightness:b] : self;
}
- (UIColor *) colorWithMinSaturation:(CGFloat)b;
{
    NSArray *hsba = [self hsbaArray];
    CGFloat b2 = [[hsba objectAtIndex:1] floatValue];
    
    return b2<b ? [self colorWithSaturation:b] : self;
}
- (UIColor *) colorWithHue:(CGFloat)hue;
{
    NSArray *hsba = [self hsbaArray];
    float h = [[hsba objectAtIndex:0] floatValue];
    float s = [[hsba objectAtIndex:1] floatValue];
    float b = [[hsba objectAtIndex:2] floatValue];
    float a = [[hsba objectAtIndex:3] floatValue];
    return [UIColor colorWithHue:hue saturation:s brightness:b alpha:a];
//    MysticColorHSB __hsb = self.hsb;
//    return [UIColor colorWithHue:hue saturation:__hsb.saturation brightness:__hsb.brightness alpha:__hsb.alpha];
}

- (UIColor *) colorWithSaturation:(CGFloat)sat;
{
//    MysticColorHSB __hsb = self.hsb;
    NSArray *hsba = [self hsbaArray];
    float h = [[hsba objectAtIndex:0] floatValue];
    float s = [[hsba objectAtIndex:1] floatValue];
    float b = [[hsba objectAtIndex:2] floatValue];
    float a = [[hsba objectAtIndex:3] floatValue];
    return [UIColor colorWithHue:h saturation:sat brightness:b alpha:a];
}

- (UIColor *) colorWithBrightness:(CGFloat)value;
{
//    MysticColorHSB __hsb = self.hsb;
    NSArray *hsba = [self hsbaArray];
    float h = [[hsba objectAtIndex:0] floatValue];
    float s = [[hsba objectAtIndex:1] floatValue];
    float b = [[hsba objectAtIndex:2] floatValue];
    float a = [[hsba objectAtIndex:3] floatValue];
    value = MIN(1, value);
    value = MAX(0, value);
    return [UIColor colorWithHue:h saturation:s brightness:value alpha:a];
}
- (UIColor *) colorWithHSB:(MysticColorHSB)__hsb;
{
    return [UIColor colorWithHue:(CGFloat)__hsb.hue saturation:(CGFloat)__hsb.saturation brightness:(CGFloat)__hsb.brightness alpha:(CGFloat)__hsb.alpha];

}


- (CGFloat) hue;
{
    NSArray *hsba = [self hsbaArray];
    return [[hsba objectAtIndex:0] floatValue];
//    return self.hsb.hue;
}

- (CGFloat) saturation;
{
    NSArray *hsba = [self hsbaArray];
    return [[hsba objectAtIndex:1] floatValue];
//    return self.hsb.saturation;
}

- (CGFloat) brightness;
{
    NSArray *hsba = [self hsbaArray];
    return [[hsba objectAtIndex:2] floatValue];
//    return self.hsb.brightness;
}


#pragma mark - Private

/**
 * Ternary clamp (0.0f to 1.0f)
 *
 * @param {CGFloat} Input
 *
 * @return {CGFloat}
 */
- (CGFloat)clamp:(CGFloat)a
{
    static const CGFloat min = 0.0f;
    static const CGFloat max = 1.0f;
    
    return (a > max) ? max : ((a < min) ? min : a);
}
@end


