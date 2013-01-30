//
//  PDCGreenScreener.h
//  greenscreen
//
//  Created by koba on 1/30/13.
//  Copyright (c) 2013 Pas de Chocolat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface PDCGreenScreener : NSObject

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, assign) CGFloat hueCenterDegrees;
@property (nonatomic, assign) CGFloat hueRangeDegrees;


- (id)initWithReusableContext:(CIContext *)context;

- (UIImage *)backgroundlessImageFromInputImage:(UIImage *)inputImage;

@end
