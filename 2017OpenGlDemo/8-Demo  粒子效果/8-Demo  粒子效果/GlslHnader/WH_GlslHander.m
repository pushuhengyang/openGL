//
//  WH_GlslHander.m
//  8-Demo  粒子效果
//
//  Created by xuwenhao on 17/4/7.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GlslHander.h"
#import "WH_OpenGlHander.h"




/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
    AGLKMVPMatrix,
    AGLKSamplers2D,
    AGLKElapsedSeconds,
    AGLKGravity,
    AGLKNumUniforms
};


/////////////////////////////////////////////////////////////////
// Attribute identifiers
typedef enum {
    AGLKParticleEmissionPosition = 0,
    AGLKParticleEmissionVelocity,
    AGLKParticleEmissionForce,
    AGLKParticleSize,
    AGLKParticleEmissionTimeAndLife,
} AGLKParticleAttrib;


@interface WH_GlslHander ()
{
    GLuint program;
    GLint uniforms[AGLKNumUniforms];
    GLfloat elapsedSeconds;

}

@property (strong, nonatomic, readwrite)
WH_OpenGlHander *particleAttributeBuffer;

@property (nonatomic, assign, readonly) NSUInteger
numberOfParticles;
@property (nonatomic, strong, readonly) NSMutableData
*particleAttributesData;
@property (nonatomic, assign, readwrite) BOOL
particleDataWasUpdated;

@end

@implementation WH_GlslHander

const GLKVector3 AGLKDefaultGravity = {0.0f, -9.80665f, 0.0f};

-(instancetype)init{
    if (self = [super init]) {
        _gravity = AGLKDefaultGravity;
        _texture2d0 = [[GLKEffectPropertyTexture alloc] init];
        _texture2d0.enabled = YES;
        _texture2d0.name = 0;
        elapsedSeconds = 0;

        _texture2d0.target = GLKTextureTarget2D;
        _particleAttributesData=[[NSMutableData alloc]init];
        _transform = [[GLKEffectPropertyTransform alloc] init];
    }
    return self;
}


- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration{

    AGLKParticleAttributes newParticle;
    newParticle.emissionPosition = aPosition;
    newParticle.emissionVelocity = aVelocity;
    newParticle.emissionForce = aForce;
    newParticle.size = GLKVector2Make(aSize, aDuration);
//    newParticle.emissionTimeAndLife = GLKVector2Make(elapsedSeconds, elapsedSeconds + aSpan);
   

    
    BOOL foundSlot = NO;
//    const long count = self.numberOfParticles;
//    
//    for(int i = 0; i < count && !foundSlot; i++)
//    {
//        AGLKParticleAttributes oldParticle =
//        [self particleAtIndex:i];
//        
//        if(oldParticle.emissionTimeAndLife.y < self.elapsedSeconds)
//        {
//            [self setParticle:newParticle atIndex:i];
//            foundSlot = YES;
//        }
//    }
    
    if(!foundSlot)
    {
        [self.particleAttributesData appendBytes:&newParticle
                                          length:sizeof(newParticle)];
        self.particleDataWasUpdated = YES;
    }
 
}

- (void)setParticle:(AGLKParticleAttributes)aParticle
            atIndex:(NSUInteger)anIndex
{
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    AGLKParticleAttributes *particlesPtr =
    (AGLKParticleAttributes *)[self.particleAttributesData
                               mutableBytes];
    particlesPtr[anIndex] = aParticle;
    
    self.particleDataWasUpdated = YES;
}


- (AGLKParticleAttributes)particleAtIndex:(NSUInteger)anIndex
{
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    const AGLKParticleAttributes *particlesPtr =
    (const AGLKParticleAttributes *)[self.particleAttributesData
                                     bytes];
    
    return particlesPtr[anIndex];
}

- (NSUInteger)numberOfParticles;
{
    static long last;
    long ret = [self.particleAttributesData length] /
    sizeof(AGLKParticleAttributes);
    if (last != ret) {
        last = ret;
        //        NSLog(@"count %ld", ret);
    }
    return ret;
}



- (void)prepareToDraw{
    if(0 == program)
    {
        [self loadShaders];
    }
    
    if (program!=0) {
        glUseProgram(program);
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
                                                                  self.transform.projectionMatrix,
                                                                  self.transform.modelviewMatrix);
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix], 1, 0,
                           modelViewProjectionMatrix.m);
        glUniform1i(uniforms[AGLKSamplers2D], 0);
        glUniform3fv(uniforms[AGLKGravity], 1, self.gravity.v);
        glUniform1fv(uniforms[AGLKElapsedSeconds], 1, &elapsedSeconds);
        
        
        
    }
    
    
    
}
- (void)draw{
    if(self.particleDataWasUpdated)
    {
        if(nil == self.particleAttributeBuffer &&
           0 < [self.particleAttributesData length])
        {  // vertex attiributes haven't been sent to GPU yet
            self.particleAttributeBuffer =
            [[WH_OpenGlHander alloc]
             initWithAttribStride:sizeof(AGLKParticleAttributes)
             numberOfVertices:
             (int)[self.particleAttributesData length] /
             sizeof(AGLKParticleAttributes)
             bytes:[self.particleAttributesData bytes]
             usage:GL_DYNAMIC_DRAW];
        }
        else
        {
            [self.particleAttributeBuffer
             reinitWithAttribStride:
             sizeof(AGLKParticleAttributes)
             numberOfVertices:
             (int)[self.particleAttributesData length] /
             sizeof(AGLKParticleAttributes)
             bytes:[self.particleAttributesData bytes]];
        }
        
        self.particleDataWasUpdated = NO;
    }

    //位置
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:AGLKParticleEmissionPosition
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, emissionPosition)
     shouldEnable:YES];
   //大小
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:AGLKParticleSize
     numberOfCoordinates:2
     attribOffset:
     offsetof(AGLKParticleAttributes, size)
     shouldEnable:YES];
    //方向
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:AGLKParticleEmissionVelocity
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, emissionVelocity)
     shouldEnable:YES];
    //加速度方向
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:AGLKParticleEmissionForce
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, emissionForce)
     shouldEnable:YES];
    
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:AGLKParticleEmissionTimeAndLife
     numberOfCoordinates:2
     attribOffset:
     offsetof(AGLKParticleAttributes, emissionTimeAndLife)
     shouldEnable:YES];
    
    glActiveTexture(GL_TEXTURE0);
    if(0 != self.texture2d0.name && self.texture2d0.enabled)
    {
        glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
    }
    else
    {
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    
    glDepthMask(GL_FALSE);  // Disable depth buffer writes
    [self.particleAttributeBuffer
     drawArrayWithMode:GL_POINTS
     startVertexIndex:0
     numberOfVertices:1];
    glDepthMask(GL_TRUE);
}

-(BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    program = glCreateProgram();
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Ver" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Color" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    
    
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    
    glBindAttribLocation(program, AGLKParticleEmissionPosition,
                         "a_emissionPosition");
    glBindAttribLocation(program, AGLKParticleEmissionVelocity,
                         "a_emissionVelocity");
    glBindAttribLocation(program, AGLKParticleEmissionForce,
                         "a_emissionForce");
    glBindAttribLocation(program, AGLKParticleSize,
                         "a_size");
    glBindAttribLocation(program, AGLKParticleEmissionTimeAndLife,
                         "a_emissionAndDeathTimes");
    

    uniforms[AGLKMVPMatrix] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[AGLKSamplers2D] = glGetUniformLocation(program,
                                                    "u_samplers2D");
    uniforms[AGLKGravity] = glGetUniformLocation(program,
                                                 "u_gravity");
    uniforms[AGLKElapsedSeconds] = glGetUniformLocation(program,
                                                        "u_elapsedSeconds");

    
    if (vertShader)
    {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}



@end
