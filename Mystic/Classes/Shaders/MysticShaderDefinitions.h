//
//  MysticShaderDefinitions.h
//  Mystic
//
//  Created by Me on 10/23/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

//#ifndef Mystic_MysticShaderDefinitions_h
//#define Mystic_MysticShaderDefinitions_h


#define sMysticColorBalance(c, r, g, b)     vec4(c.r * r, c.g * g, c.b * b, c.a)

#define sMysticBrightness(c, b)             vec4((c.rgb + vec3(b)), c.w)

//#endif
