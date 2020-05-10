#import "MysticVertexConstants.h"
#import "GPUImage.h"



NSString * const MysticVertexOne = SHADER_STRING(

                                                 attribute vec4 position;
                                                 attribute vec4 inputTextureCoordinate;
                                                 varying vec2 textureCoordinate;
                                                 
                                                 void main()
                                                 {
                                                     gl_Position = position;
                                                     textureCoordinate = inputTextureCoordinate.xy;

);


NSString * const MysticVertexTwo = SHADER_STRING(

                                                 attribute vec4 position;
                                                 attribute vec4 inputTextureCoordinate;
                                                 attribute vec4 inputTextureCoordinate2;
                                                 
                                                 varying vec2 textureCoordinate;
                                                 varying vec2 textureCoordinate2;
                                                 
                                                 void main()
                                                 {
                                                     gl_Position = position;
                                                     textureCoordinate = inputTextureCoordinate.xy;
                                                     textureCoordinate2 = inputTextureCoordinate2.xy;

);

NSString * const MysticVertexThree = SHADER_STRING(

                                                   attribute vec4 position;
                                                   attribute vec4 inputTextureCoordinate;
                                                   attribute vec4 inputTextureCoordinate2;
                                                   attribute vec4 inputTextureCoordinate3;
                                                   
                                                   varying vec2 textureCoordinate;
                                                   varying vec2 textureCoordinate2;
                                                   varying vec2 textureCoordinate3;
                                                   
                                                   void main()
                                                   {
                                                       gl_Position = position;
                                                       textureCoordinate = inputTextureCoordinate.xy;
                                                       textureCoordinate2 = inputTextureCoordinate2.xy;
                                                       textureCoordinate3 = inputTextureCoordinate3.xy;

);

NSString * const MysticVertexFour = SHADER_STRING(

                                                  attribute vec4 position;
                                                  attribute vec4 inputTextureCoordinate;
                                                  attribute vec4 inputTextureCoordinate2;
                                                  attribute vec4 inputTextureCoordinate3;
                                                  attribute vec4 inputTextureCoordinate4;
                                                  
                                                  varying vec2 textureCoordinate;
                                                  varying vec2 textureCoordinate2;
                                                  varying vec2 textureCoordinate3;
                                                  varying vec2 textureCoordinate4;
                                                  
                                                  void main()
                                                  {
                                                      gl_Position = position;
                                                      textureCoordinate = inputTextureCoordinate.xy;
                                                      textureCoordinate2 = inputTextureCoordinate2.xy;
                                                      textureCoordinate3 = inputTextureCoordinate3.xy;
                                                      textureCoordinate4 = inputTextureCoordinate4.xy;

);

NSString * const MysticVertexFive = SHADER_STRING(

                                                  attribute vec4 position;
                                                  attribute vec4 inputTextureCoordinate;
                                                  attribute vec4 inputTextureCoordinate2;
                                                  attribute vec4 inputTextureCoordinate3;
                                                  attribute vec4 inputTextureCoordinate4;
                                                  attribute vec4 inputTextureCoordinate5;
                                                  
                                                  varying vec2 textureCoordinate;
                                                  varying vec2 textureCoordinate2;
                                                  varying vec2 textureCoordinate3;
                                                  varying vec2 textureCoordinate4;
                                                  varying vec2 textureCoordinate5;
                                                  
                                                  void main()
                                                  {
                                                      gl_Position = position;
                                                      textureCoordinate = inputTextureCoordinate.xy;
                                                      textureCoordinate2 = inputTextureCoordinate2.xy;
                                                      textureCoordinate3 = inputTextureCoordinate3.xy;
                                                      textureCoordinate4 = inputTextureCoordinate4.xy;
                                                      textureCoordinate5 = inputTextureCoordinate5.xy;

);

NSString * const MysticVertexSix = SHADER_STRING(

                                                 attribute vec4 position;
                                                 attribute vec4 inputTextureCoordinate;
                                                 attribute vec4 inputTextureCoordinate2;
                                                 attribute vec4 inputTextureCoordinate3;
                                                 attribute vec4 inputTextureCoordinate4;
                                                 attribute vec4 inputTextureCoordinate5;
                                                 attribute vec4 inputTextureCoordinate6;

                                                 
                                                 varying vec2 textureCoordinate;
                                                 varying vec2 textureCoordinate2;
                                                 varying vec2 textureCoordinate3;
                                                 varying vec2 textureCoordinate4;
                                                 varying vec2 textureCoordinate5;
                                                 varying vec2 textureCoordinate6;
                                                 
                                                 void main()
                                                 {
                                                     gl_Position = position;
                                                     textureCoordinate = inputTextureCoordinate.xy;
                                                     textureCoordinate2 = inputTextureCoordinate2.xy;
                                                     textureCoordinate3 = inputTextureCoordinate3.xy;
                                                     textureCoordinate4 = inputTextureCoordinate4.xy;
                                                     textureCoordinate5 = inputTextureCoordinate5.xy;
                                                     textureCoordinate6 = inputTextureCoordinate6.xy;

);

NSString * const MysticVertexSeven = SHADER_STRING(

                                                   attribute vec4 position;
                                                   attribute vec4 inputTextureCoordinate;
                                                   attribute vec4 inputTextureCoordinate2;
                                                   attribute vec4 inputTextureCoordinate3;
                                                   attribute vec4 inputTextureCoordinate4;
                                                   attribute vec4 inputTextureCoordinate5;
                                                   attribute vec4 inputTextureCoordinate6;
                                                   attribute vec4 inputTextureCoordinate7;
                                                   
                                                   varying vec2 textureCoordinate;
                                                   varying vec2 textureCoordinate2;
                                                   varying vec2 textureCoordinate3;
                                                   varying vec2 textureCoordinate4;
                                                   varying vec2 textureCoordinate5;
                                                   varying vec2 textureCoordinate6;
                                                   varying vec2 textureCoordinate7;
                                                   
                                                   void main()
                                                   {
                                                       gl_Position = position;
                                                       textureCoordinate = inputTextureCoordinate.xy;
                                                       textureCoordinate2 = inputTextureCoordinate2.xy;
                                                       textureCoordinate3 = inputTextureCoordinate3.xy;
                                                       textureCoordinate4 = inputTextureCoordinate4.xy;
                                                       textureCoordinate5 = inputTextureCoordinate5.xy;
                                                       textureCoordinate6 = inputTextureCoordinate6.xy;
                                                       textureCoordinate7 = inputTextureCoordinate7.xy;

);

NSString * const MysticVertexEight = SHADER_STRING(

                                                   attribute vec4 position;
                                                   attribute vec4 inputTextureCoordinate;
                                                   attribute vec4 inputTextureCoordinate2;
                                                   attribute vec4 inputTextureCoordinate3;
                                                   attribute vec4 inputTextureCoordinate4;
                                                   attribute vec4 inputTextureCoordinate5;
                                                   attribute vec4 inputTextureCoordinate6;
                                                   attribute vec4 inputTextureCoordinate7;
                                                   attribute vec4 inputTextureCoordinate8;
                                                   
                                                   varying vec2 textureCoordinate;
                                                   varying vec2 textureCoordinate2;
                                                   varying vec2 textureCoordinate3;
                                                   varying vec2 textureCoordinate4;
                                                   varying vec2 textureCoordinate5;
                                                   varying vec2 textureCoordinate6;
                                                   varying vec2 textureCoordinate7;
                                                   varying vec2 textureCoordinate8;
                                                   
                                                   void main()
                                                   {
                                                       gl_Position = position;
                                                       textureCoordinate = inputTextureCoordinate.xy;
                                                       textureCoordinate2 = inputTextureCoordinate2.xy;
                                                       textureCoordinate3 = inputTextureCoordinate3.xy;
                                                       textureCoordinate4 = inputTextureCoordinate4.xy;
                                                       textureCoordinate5 = inputTextureCoordinate5.xy;
                                                       textureCoordinate6 = inputTextureCoordinate6.xy;
                                                       textureCoordinate7 = inputTextureCoordinate7.xy;
                                                       textureCoordinate8 = inputTextureCoordinate8.xy;

);



