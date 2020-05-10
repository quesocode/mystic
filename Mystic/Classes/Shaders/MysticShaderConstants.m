
#import "MysticShaderConstants.h"

#import "GPUImage.h"
#import "GPUImageLevelsFilter.h"

#define MControlOutputColor(color, minOutput, maxOutput) 			min(max(color, minOutput), maxOutput)

#define MGammaCorrection(color, gamma)								pow(color, 1.0 / gamma)

#define MLevelsControlInputRange(color, minInput, maxInput)				min(max(color - minInput, vec3(0.0)) / (maxInput - minInput), vec3(1.0))
#define MLevelsControlInput(color, minInput, gamma, maxInput)				MGammaCorrection(MLevelsControlInputRange(color, minInput, maxInput), gamma)
#define MLevelsControlOutputRange(color, minOutput, maxOutput) 			mix(minOutput, maxOutput, color)
#define MLevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput) 	MLevelsControlOutputRange(MLevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)

#define GammaCorrection(color, gamma)								pow(color, 1.0 / gamma)

#define LevelsControlInputRange(color, minInput, maxInput)				min(max(color - minInput, vec3(0.0)) / (maxInput - minInput), vec3(1.0))
#define LevelsControlInput(color, minInput, gamma, maxInput)				GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput) 			mix(minOutput, maxOutput, color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput) 	LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)




NSString * const kMysticShaderOutputColor = @"outputColor";


#pragma mark -
#pragma mark Colors

NSString * const MysticShaderColorWhite = @" mediump vec4 whiteColor = vec4(1.0);";
NSString * const MysticShaderColorBlack = @" mediump vec4 blackColor = vec4(0.0);";
NSString * const MysticShaderColorGreen = @" mediump vec4 greenColor = vec4(0.0, 1.0, 0.0, 1.0);";
NSString * const MysticShaderColorMagenta = @" mediump vec4 magentaColor = vec4(1.0, 0.0, 1.0, 1.0);";
NSString * const MysticShaderColorBlue = @" mediump vec4 blueColor = vec4(0.0, 0.0, 1.0, 1.0);";
NSString * const MysticShaderColorYellow = @" mediump vec4 yellowColor = vec4(1.0, 1.0, 0.0, 1.0);";
NSString * const MysticShaderColorRed = @" mediump vec4 redColor = vec4(1.0, 0.0, 0.0, 1.0);";
NSString * const MysticShaderColorCyan = @" mediump vec4 cyanColor = vec4(0.0, 1.0, 1.0, 1.0);";
NSString * const MysticShaderColorW = @" const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);";
#pragma mark -
#pragma mark Header

NSString *const MysticShaderHeader = SHADER_STRING(

   lowp float nearColor(lowp vec4 col, lowp vec4 tcol, lowp float error) {
       if( abs(col.r-tcol.r) < error )
       {
           if(abs(col.g-tcol.g) < error)
           {
                if(abs(col.b-tcol.b) < error)
                {
                    return 1.0;
                }
           }
       }
       return 0.0;
       
       
   }


);

#pragma mark -
#pragma mark Filters
NSString * const MysticShaderControlOutput = SHADER_STRING(
     mediump vec4 controlOutput(mediump vec4 c)
   {
    return vec4(MControlOutputColor(c.rgb, vec3(0.0),  vec3(1.0)), c.a);
    }


);


NSString * const MysticShaderColorBalance = SHADER_STRING(
                                                           
                                                           outColor = vec4(inColor.r * %2.3f, inColor.g * %2.3f, inColor.b * %2.3f, inColor.a);
                                                           );

NSString * const MysticShaderBrightness = @" outColor = vec4((inColor.rgb + vec3(%2.3f)), inColor.w); ";

NSString * const MysticShaderExposure = @" outColor = vec4(inColor.rgb * pow(2.0, %2.2f), inColor.w); ";
NSString * const MysticShaderContrast = SHADER_STRING(
                                                      
                                                      
                                                      
                                                      outColor = vec4(((inColor.rgb - vec3(0.5)) * %2.2f + vec3(0.5)), inColor.w);
                                                      
                                                      
                                                      );
NSString * const MysticShaderGamma = @" outColor = vec4(pow(inColor.rgb, vec3(%2.2f)), inColor.w); ";


NSString * const MysticShaderTiltShift = SHADER_STRING(
                                                       
                                                       lowp float blurIntensity = 1.0 - smoothstep(topFocusLevel - focusFallOffRate, topFocusLevel, outputCoordinate.y);
                                                       blurIntensity += smoothstep(bottomFocusLevel, bottomFocusLevel + focusFallOffRate, textureCoordinate2.y);
                                                       
                                                       gl_FragColor = mix(sharpImageColor, blurredImageColor, blurIntensity);
);
NSString * const MysticShaderHaze = SHADER_STRING(

                                                  highp vec4 hazecolor = vec4(1.0);
                                                  
                                                  highp float  hazed = outputCoordinate.y * %2.2f  +  %2.2f;
                                                  
                                                  
                                                  
                                                  outColor = (inColor - hazed * hazecolor) / (1.0 -hazed);


);

NSString * const MysticShaderShadows = SHADER_STRING(

                                                     mediump float hsluminance = dot(inColor.rgb, hsluminanceWeighting);
                                                     mediump float shadows = %2.2f;
                                                     mediump float highlights = %2.2f;
                                                     mediump float shadow = clamp((pow(hsluminance, 1.0/(shadows+1.0)) + (-0.76)*pow(hsluminance, 2.0/(shadows+1.0))) - hsluminance, 0.0, 1.0);
                                                     mediump float highlight = clamp((1.0 - (pow(1.0-hsluminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-hsluminance, 2.0/(2.0-highlights)))) - hsluminance, -1.0, 0.0);
                                                     lowp vec3 hsresult = vec3(0.0, 0.0, 0.0) + ((hsluminance + shadow + highlight) - 0.0) * ((inColor.rgb - vec3(0.0, 0.0, 0.0))/(hsluminance - 0.0));
                                                     
                                                     outColor = vec4(hsresult.rgb, inColor.a);

);




NSString * const MysticShaderLevels = SHADER_STRING(
                                                    mediump vec4 setLevels(mediump vec4 c, mediump vec3 lvlmin, mediump vec3 lvlmid, mediump vec3 lvlmax, mediump vec3 lvlminOut, mediump vec3 lvlmaxOut)
                                                    {
                                                        return thresholdColor(vec4(LevelsControl(c.rgb, lvlmin, lvlmid, lvlmax, lvlminOut, lvlmaxOut), c.a), blackColor, whiteColor);

                                                    }
                                                    );

NSString * const MysticShaderTemperature = SHADER_STRING(
                                                         yiq = RGBtoYIQ * inColor.rgb;
                                                         yiq.b = clamp(yiq.b + %2.2f*0.5226*0.1, -0.5226, 0.5226);
                                                         rgb = YIQtoRGB * yiq;
                                                         
                                                         processed = vec3(
                                                                          (rgb.r < 0.5 ? (2.0 * rgb.r * warmFilter.r) : (1.0 - 2.0 * (1.0 - rgb.r) * (1.0 - warmFilter.r))),
                                                                          (rgb.g < 0.5 ? (2.0 * rgb.g * warmFilter.g) : (1.0 - 2.0 * (1.0 - rgb.g) * (1.0 - warmFilter.g))),
                                                                          (rgb.b < 0.5 ? (2.0 * rgb.b * warmFilter.b) : (1.0 - 2.0 * (1.0 - rgb.b) * (1.0 - warmFilter.b))));
                                                         
                                                         outColor = vec4(mix(rgb, processed, %2.2f), inColor.a);
                                                         
);

NSString * const MysticShaderUnsharpMask = @"";
NSString * const MysticShaderVignette = SHADER_STRING(
                                                      
                                                      
                                                      
                                                      vignetteCenter = vec2(%2.2f, %2.2f);
                                                      vignetteColor = vec3(%2.1f, %2.1f, %2.1f);
                                                      vignetteStart = %2.2f;
                                                      vignetteEnd = %2.2f;
                                                      
                                                      lowp float vigd = distance(outputCoordinate, vec2(vignetteCenter.x, vignetteCenter.y));
                                                      lowp float vigpercent = smoothstep(vignetteStart, vignetteEnd, vigd);
                                                      outColor = vec4(mix(inColor.x, vignetteColor.x, vigpercent), mix(inColor.y, vignetteColor.y, vigpercent), mix(inColor.z, vignetteColor.z, vigpercent), 1.0);
);
NSString * const MysticShaderSharpness = @"";



NSString * const MysticShaderSaturation = @" outColor = vec4(mix(satgreyScaleColor, inColor.rgb, %2.2f), inColor.w); ";


#pragma mark -
#pragma mark Prefixes



#pragma mark -
#pragma mark Blends




#pragma mark -
#pragma mark Functions


NSString * const MysticShaderLum = SHADER_STRING(
                                                 
                                                 highp float lum(mediump vec3 c) {
                                                 return dot(c, vec3(0.3, 0.59, 0.11));
                                                
                                                 }
                                                 
                                                 );




NSString * const MysticShaderClipColor = SHADER_STRING(
                                                 
                                                 mediump vec3 clipcolor(mediump vec3 c) {
                                                    highp float l = lum(c);
                                                    mediump float n = min(min(c.r, c.g), c.b);
                                                    mediump float x = max(max(c.r, c.g), c.b);
                                                    
                                                    if (n < 0.0) {
                                                        c.r = l + ((c.r - l) * l) / (l - n);
                                                        c.g = l + ((c.g - l) * l) / (l - n);
                                                        c.b = l + ((c.b - l) * l) / (l - n);
                                                    }
                                                    if (x > 1.0) {
                                                        c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
                                                        c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
                                                        c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
                                                    }
                                                    
                                                    return c;
                                                }
                                                 
                                                 );




NSString * const MysticShaderSetLum = SHADER_STRING(
                                                    mediump vec3 setlum(mediump vec3 c, highp float l) {
                                                        highp float d = l - lum(c);
                                                        c = c + vec3(d);
                                                        return clipcolor(c);
                                                    }
                                                       
                                                       );



NSString * const MysticShaderSat = SHADER_STRING(
                                                       
                                                 highp float sat(mediump vec3 c) {
                                                     mediump float n = min(min(c.r, c.g), c.b);
                                                     mediump float x = max(max(c.r, c.g), c.b);
                                                     return x - n;
                                                 }
                                                       );




NSString * const MysticShaderMid = SHADER_STRING(
                                                 mediump float mid(mediump float cmin, mediump float cmid, mediump float cmax, highp float s) {
                                                     return ((cmid - cmin) * s) / (cmax - cmin);
                                                 }
                                                 );




NSString * const MysticShaderSetSat = SHADER_STRING(

                                                    mediump vec3 setsat(mediump vec3 c, highp float s) {
                                                        if (c.r > c.g) {
                                                            if (c.r > c.b) {
                                                                if (c.g > c.b) {
                                                                    /* g is mid, b is min */
                                                                    c.g = mid(c.b, c.g, c.r, s);
                                                                    c.b = 0.0;
                                                                } else {
                                                                    /* b is mid, g is min */
                                                                    c.b = mid(c.g, c.b, c.r, s);
                                                                    c.g = 0.0;
                                                                }
                                                                c.r = s;
                                                            } else {
                                                                /* b is max, r is mid, g is min */
                                                                c.r = mid(c.g, c.r, c.b, s);
                                                                c.b = s;
                                                                c.r = 0.0;
                                                            }
                                                        } else if (c.r > c.b) {
                                                            /* g is max, r is mid, b is min */
                                                            c.r = mid(c.b, c.r, c.g, s);
                                                            c.g = s;
                                                            c.b = 0.0;
                                                        } else if (c.g > c.b) {
                                                            /* g is max, b is mid, r is min */
                                                            c.b = mid(c.r, c.b, c.g, s);
                                                            c.g = s;
                                                            c.r = 0.0;
                                                        } else if (c.b > c.g) {
                                                            /* b is max, g is mid, r is min */
                                                            c.g = mid(c.r, c.g, c.b, s);
                                                            c.b = s;
                                                            c.r = 0.0;
                                                        } else {
                                                            c = vec3(0.0);
                                                        }
                                                        return c;
                                                    }
                                                       
                                                    );

NSString * const MysticShaderMainsTemplate = SHADER_STRING(
    mediump vec4 %%textureColor%% = texture2D(%%inputTexture%%, %%textureCoordinate%%);
                                                           );
NSString * const MysticShaderMainsTextureTemplatePreviousCoord = SHADER_STRING(
                                                                               mediump vec4 %%textureColor%% = texture2D(%%inputTexture%%, %%stackTexturePreviousCoordinate%%);

);
NSString * const MysticShaderMainsTextureTemplate = SHADER_STRING(
                                                           mediump vec4 %%textureColor%% = texture2D(%%inputTexture%%, %%stackTextureCoordinate%%);
                                                           );

NSString * const MysticShaderMain = SHADER_STRING(
      void main()
      {
);
          
          
NSString * const MysticShaderOneUniform = SHADER_STRING(
     varying highp vec2 textureCoordinate;
     
     uniform sampler2D inputImageTexture;
);
          

NSString * const MysticShaderTwoUniform = SHADER_STRING(
  varying highp vec2 textureCoordinate;
  varying highp vec2 textureCoordinate2;
  
  uniform sampler2D inputImageTexture;
  uniform sampler2D inputImageTexture2;
  );
          
NSString * const MysticShaderThreeUniform = SHADER_STRING(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;
    
    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    
    
    );
NSString * const MysticShaderFourUniform = SHADER_STRING(
   varying highp vec2 textureCoordinate;
   varying highp vec2 textureCoordinate2;
   varying highp vec2 textureCoordinate3;
   varying highp vec2 textureCoordinate4;
   
   uniform sampler2D inputImageTexture;
   uniform sampler2D inputImageTexture2;
   uniform sampler2D inputImageTexture3;
   uniform sampler2D inputImageTexture4;
   
   );
NSString * const MysticShaderFiveUniform = SHADER_STRING(
   varying highp vec2 textureCoordinate;
   varying highp vec2 textureCoordinate2;
   varying highp vec2 textureCoordinate3;
   varying highp vec2 textureCoordinate4;
   varying highp vec2 textureCoordinate5;
   
   uniform sampler2D inputImageTexture;
   uniform sampler2D inputImageTexture2;
   uniform sampler2D inputImageTexture3;
   uniform sampler2D inputImageTexture4;
   uniform sampler2D inputImageTexture5;
   
   );
NSString * const MysticShaderSixUniform = SHADER_STRING(
  varying highp vec2 textureCoordinate;
  varying highp vec2 textureCoordinate2;
  varying highp vec2 textureCoordinate3;
  varying highp vec2 textureCoordinate4;
  varying highp vec2 textureCoordinate5;
  varying highp vec2 textureCoordinate6;
  
  uniform sampler2D inputImageTexture;
  uniform sampler2D inputImageTexture2;
  uniform sampler2D inputImageTexture3;
  uniform sampler2D inputImageTexture4;
  uniform sampler2D inputImageTexture5;
  uniform sampler2D inputImageTexture6;
  
  );
NSString * const MysticShaderSevenUniform = SHADER_STRING(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;
    varying highp vec2 textureCoordinate4;
    varying highp vec2 textureCoordinate5;
    varying highp vec2 textureCoordinate6;
    varying highp vec2 textureCoordinate7;
    
    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    uniform sampler2D inputImageTexture4;
    uniform sampler2D inputImageTexture5;
    uniform sampler2D inputImageTexture6;
    uniform sampler2D inputImageTexture7;
    );
NSString * const MysticShaderEightUniform = SHADER_STRING(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;
    varying highp vec2 textureCoordinate4;
    varying highp vec2 textureCoordinate5;
    varying highp vec2 textureCoordinate6;
    varying highp vec2 textureCoordinate7;
    varying highp vec2 textureCoordinate8;
    
    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    uniform sampler2D inputImageTexture4;
    uniform sampler2D inputImageTexture5;
    uniform sampler2D inputImageTexture6;
    uniform sampler2D inputImageTexture7;
    uniform sampler2D inputImageTexture8;
    
    );
          
NSString * const MysticShaderOne = SHADER_STRING(

         mediump vec4 maskColor;

         
         mediump vec4 inputColor = outputColor;
         mediump vec4 previousOutputColor = outputColor;

);

NSString * const MysticShaderTwo = SHADER_STRING(
     
         mediump vec4 maskColor;
         mediump vec4 inputColor;

         mediump vec4 previousOutputColor = outputColor;

);

NSString * const MysticShaderThree = SHADER_STRING(
           mediump vec4 maskColor;
mediump vec4 inputColor;
                                                   mediump vec4 previousOutputColor = outputColor;

);

NSString * const MysticShaderFour = SHADER_STRING(
          mediump vec4 maskColor;

mediump vec4 inputColor;          mediump vec4 previousOutputColor = outputColor;

);

          
NSString * const MysticShaderFive = SHADER_STRING(
          mediump vec4 maskColor;


          mediump vec4 previousOutputColor = outputColor;

mediump vec4 inputColor;
                                                  
                                                  );
          
          

          
          
NSString * const MysticShaderSix = SHADER_STRING(
         mediump vec4 maskColor;

mediump vec4 inputColor;         mediump vec4 previousOutputColor = outputColor;

);

NSString * const MysticShaderSeven = SHADER_STRING(
       mediump vec4 maskColor;


mediump vec4 inputColor;       mediump vec4 previousOutputColor = outputColor;

);

NSString * const MysticShaderEight = SHADER_STRING(
       mediump vec4 maskColor;


mediump vec4 inputColor;       mediump vec4 previousOutputColor = outputColor;

);