//
//  AddNewItemViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 8/25/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@class PFObject;
@class PFGeoPoint;

@interface AddNewItemViewController : BaseViewController <UITextFieldDelegate,
                                                          UIImagePickerControllerDelegate,
                                                          UINavigationControllerDelegate,
                                                          CLLocationManagerDelegate> {

    //the item and its images (thumbs and full sizes)
    PFObject *currentItem;
    NSMutableArray *itemThumbnails;
    NSMutableArray *itemImages;
    
    float xPosition; //the pictures taken are put side by side in thumbnails endlessly at xPosition
    float xSpacing;  //the spacing between the thumbnails
    float thumbnailSize;
    
 	UIImagePickerController *imagePicker;
                                                              
    CLLocationManager *locationManager;
    PFGeoPoint *itemLocationPoint;

}

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet UIView *picturesTakenView;
@property (strong, nonatomic) IBOutlet UIView *cameraOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *doneTakingPicturesButton;
@property (weak, nonatomic) IBOutlet UITextView *itemDescriptionTextView;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)takePictureButtonPressed:(id)sender;
- (IBAction)doneTakingPicturesButtonPressed:(id)sender;

- (void)saveItem;
- (void)setupCameraOverlayView;
- (void)setupImagePicker;
- (void)presentCamera;
- (void)closeThisScreen;

@end
