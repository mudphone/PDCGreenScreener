//
//  PDCViewController.m
//  greenscreen
//
//  Created by koba on 1/30/13.
//  Copyright (c) 2013 Pas de Chocolat. All rights reserved.
//

#import "PDCViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface PDCViewController ()
- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation PDCViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _greenScreener = [[PDCGreenScreener alloc] initWithReusableContext:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.greenScreener.context = nil;  // Dump context if Elf Needs Food, Badly.
}


#pragma mark - Image Picker

- (IBAction)handleSelectPhotoPressed:(UIButton *)sender {
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        
        // Camera photos only, no movies:
        NSMutableArray *mediaTypes = [NSMutableArray arrayWithArray:[UIImagePickerController availableMediaTypesForSourceType:sourceType]];
        [mediaTypes removeObject:(NSString *)kUTTypeMovie];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;

        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing media"
                                                        message:@"This device doesn't support that media source."
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *chosenMediaType = info[UIImagePickerControllerMediaType];
    if ([chosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        self.originalImage = info[UIImagePickerControllerEditedImage];
        
        UIImage *newImage = [self.greenScreener backgroundlessImageFromInputImage:self.originalImage];
        self.imageView.image = newImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end
