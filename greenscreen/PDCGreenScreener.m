//
//  PDCGreenScreener.m
//  greenscreen
//
//  Created by koba on 1/30/13.
//  Copyright (c) 2013 Pas de Chocolat. All rights reserved.
//

#import "PDCGreenScreener.h"

@implementation PDCGreenScreener

- (id)init
{
    return [self initWithReusableContext:nil];
}

- (id)initWithReusableContext:(CIContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        _hueCenterDegrees = 120.0f;
        _hueRangeDegrees = 60.0f;
    }
    return self;
}

- (CIContext *)context
{
    if (_context != nil) return _context;
    
    _context = [CIContext contextWithOptions:nil];
    return _context;
}

- (void)hueCenterDegrees:(CGFloat)degrees
{
    _hueCenterDegrees = MIN(360.0f, MAX(0.0f, degrees));
}

- (void)hueRangeDegrees:(CGFloat)degrees
{
    _hueRangeDegrees = MIN(360.0f, MAX(0.0f, degrees));
}


#pragma mark - Green Screen Filtering


void rgbToHSV(float rgb[3], float hsv[3]) {
    float rgbMax, rgbMin, rgbSpan;
    float r = rgb[0];
    float g = rgb[1];
    float b = rgb[2];
    
    // Initialize HSV:
    hsv[0] = hsv[1] = 0;
    
    // Compute Value
    rgbMax = fmaxf(r, fmaxf(g, b));
    hsv[2] = rgbMax;
    if (rgbMax == 0) {
        return;
    }
    
    // Normalize Value to 1
    r /= rgbMax;
    g /= rgbMax;
    b /= rgbMax;
    rgbMin = fminf(r, fminf(g, b));
    rgbMax = fmaxf(r, fmaxf(g, b));
    
    // Compute Saturation
    rgbSpan = rgbMax - rgbMin;
    hsv[1] = rgbSpan;
    if (rgbSpan == 0) {
        return;
    }
    
    // Normalize Saturation to 1
    r = (r - rgbMin) / rgbSpan;
    g = (g - rgbMin) / rgbSpan;
    b = (b - rgbMin) / rgbSpan;
    rgbMax = fmaxf(r, fmaxf(g, b));
    
    // Compute Hue
    if (rgbMax == r) {
        // max is RED
        hsv[0] = 0.0 + 60.0*(g - b);
        if (hsv[0] < 0.0) {
            hsv[0] += 360.0;
        }
        
    } else if (rgbMax == g) {
        // max is GREEN
        hsv[0] = 120.0 + 60.0*(b - r);
        
    } else {
        // max is BLUE
        hsv[0] = 240.0 + 60.0*(r - g);
    }
}

- (UIImage *)backgroundlessImageFromInputImage:(UIImage *)inputImage
{
    float minHueAngle = self.hueCenterDegrees - self.hueRangeDegrees/2.0f;
    float maxHueAngle = self.hueCenterDegrees + self.hueRangeDegrees/2.0f;
    
    const unsigned int size = 64;
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float *cubeData = (float *) malloc ( cubeDataSize );
    float rgb[3], hsv[3];
    
    size_t offset = 0;
    for (int z = 0; z < size; z++) {
        rgb[2] = ( (double)z ) / ( size - 1 ); // blue value
        for (int y = 0; y < size; y++) {
            rgb[1] = ( (double)y ) / ( size - 1 ); // green value
            for (int x = 0; x < size; x++) {
                rgb[0] = ( (double)x ) / ( size - 1 ); // red value
                
                rgbToHSV( rgb, hsv );
                float alpha = ( hsv[0] > minHueAngle && hsv[0] < maxHueAngle ) ? 0.0f : 1.0f;
                cubeData[offset]   = rgb[0] * alpha;
                cubeData[offset+1] = rgb[1] * alpha;
                cubeData[offset+2] = rgb[2] * alpha;
                cubeData[offset+3] = alpha;
                
                offset += 4;
            }
        }
    }
    
    // Create memory with the cube data
    NSData *data = [NSData dataWithBytesNoCopy:cubeData
                                        length:cubeDataSize
                                  freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    // Set data for cube
    [colorCube setValue:data forKey:@"inputCubeData"];
    // Input image
    [colorCube setValue:[[CIImage alloc] initWithCGImage:inputImage.CGImage]
                 forKey:kCIInputImageKey];
    
    CIImage *outputImage =  colorCube.outputImage;
    CGImageRef cgimg = [self.context createCGImage:outputImage
                                          fromRect:[outputImage extent]];
    
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    
    // Release it:
    CGImageRelease(cgimg);
    
    return newImage;
}


@end
