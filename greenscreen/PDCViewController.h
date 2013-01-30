//
//  PDCViewController.h
//  greenscreen
//
//  Created by koba on 1/30/13.
//  Copyright (c) 2013 Pas de Chocolat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDCGreenScreener.h"

@interface PDCViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *hueCenterSlider;
@property (weak, nonatomic) IBOutlet UISlider *hueRangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *hueCenterLabel;
@property (weak, nonatomic) IBOutlet UILabel *hueRangeLabel;

@property (nonatomic, strong) PDCGreenScreener *greenScreener;
@property (nonatomic, strong) UIImage *originalImage;

- (IBAction)handleSelectPhotoPressed:(UIButton *)sender;
- (IBAction)hueCenterValueChanged:(UISlider *)sender;
- (IBAction)hueRangeValueChanged:(UISlider *)sender;

@end
