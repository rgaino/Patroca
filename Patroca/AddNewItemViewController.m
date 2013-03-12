//
//  AddNewItemViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 8/25/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewItemViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "DatabaseConstants.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DoneShareViewController.h"

#define thumbnailSize 53
#define fullImageSize 640
#define croppedSquareImageSize 596
#define imageCornerRadius 0
#define thumbnailsAnimationSpeed 0.25f
#define maxPictures 4

@interface AddNewItemViewController ()

@end

@implementation AddNewItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupHeaderWithBackButton:YES doneButton:YES addItemButton:NO];

    [_itemNameTextField setDelegate:self];

    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    galleryImagePicker = nil;
    
    //setup the views
    [self localizeStrings];
    [self setupCameraOverlayView];
    [self setupImagePicker];
    [self presentCamera];

    //initialize a new blank Item object
    currentItem = [PFObject objectWithClassName:DB_TABLE_ITEMS];
    itemThumbnails = [[NSMutableArray alloc] init];
    itemImages = [[NSMutableArray alloc] init];
    
    xSpacing = 24;
    xPosition = 18;

    
    [_itemDescriptionTextView.layer setCornerRadius:10.0f];
}


- (void)localizeStrings {
    [_cameraMessageLabel setText:NSLocalizedString(@"camera_message_1", nil)];
}

- (void)setupCameraOverlayView {
    [_cameraOverlayView setBackgroundColor:[UIColor clearColor]];
    [_flashButton setHidden:![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]];

}

- (void)setupImagePicker {
    
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	[imagePicker setAllowsEditing:NO];
	[imagePicker setShowsCameraControls:NO];
	[imagePicker setCameraOverlayView:_cameraOverlayView];
	[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
	[imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:[imagePicker sourceType]]];
	[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
}

- (void)presentCamera {
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    [self performSelector:@selector(fadeOutCameraMessageLabel) withObject:nil afterDelay:4.0f];
}

- (void)fadeOutCameraMessageLabel {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [_cameraMessageLabel setAlpha:0];
    [_cameraMessageBackgroundImageView setAlpha:0];
    [UIView commitAnimations];
}

- (void)doneButtonPressed {

    //dismiss keyboard
    [self.view endEditing:YES];

	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[HUD setDimBackground:YES];
	[HUD setLabelText: NSLocalizedString(@"saving", nil)];
    [HUD setDelegate:self];
    [self.navigationController.view addSubview:HUD];

	[HUD showWhileExecuting:@selector(saveItem) onTarget:self withObject:nil animated:YES];
}



- (IBAction)takePictureButtonPressed:(id)sender {
	
    [imagePicker takePicture];
}

- (IBAction)doneTakingPicturesButtonPressed:(id)sender {

	[self dismissViewControllerAnimated:YES completion:nil];
    [locationManager startUpdatingLocation];
}

- (IBAction)backButtonPressed:(id)sender {
	[self dismissViewControllerAnimated:NO completion:nil];
    [super backButtonPressed];
}

- (IBAction)flashButtonPressed:(id)sender {
    
	if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOff ) {
		[_flashButton setImage:[UIImage imageNamed:@"flash_button_auto.png"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
	}
	else if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeAuto ) {
		[_flashButton setImage:[UIImage imageNamed:@"flash_button_on.png"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
	}
	else if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOn ) {
		[_flashButton setImage:[UIImage imageNamed:@"flash_button_off.png"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
	}
}

- (IBAction)galleryButtonPressed:(id)sender {

    galleryImagePicker = [[UIImagePickerController alloc] init];
	[galleryImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[galleryImagePicker setDelegate:self];
	[galleryImagePicker setAllowsEditing:NO];
    [galleryImagePicker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
    [self presentViewController:galleryImagePicker animated:YES completion:nil];

    
    
//	[galleryImagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:[imagePicker sourceType]]];
    
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    if( galleryImagePicker!=nil ) {
        [self dismissViewControllerAnimated:NO completion:nil];
        galleryImagePicker = nil;
    }

    
	UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self savePicture:picture];
	return;
}

- (void)savePicture:(UIImage *)picture {


    float imageWidth = picture.size.width;
    float imageHeight = picture.size.height;
    
    float ratio = imageWidth/fullImageSize;
    CGSize fullImageNewSize = CGSizeMake(imageWidth/ratio, imageHeight/ratio);
        
    UIImage *resizedImage = [picture resizedImage:fullImageNewSize interpolationQuality:kCGInterpolationHigh];
    
    CGRect cropSquare = CGRectMake(fullImageSize - croppedSquareImageSize, fullImageSize - croppedSquareImageSize, croppedSquareImageSize, croppedSquareImageSize);
    UIImage *croppedSquareImage = [resizedImage croppedImage:cropSquare];

    UIImage *thumbnail = [croppedSquareImage thumbnailImage:thumbnailSize transparentBorder:0 cornerRadius:imageCornerRadius interpolationQuality:kCGInterpolationHigh];
    
    [itemThumbnails addObject:thumbnail];
    [itemImages addObject:croppedSquareImage];

    float thumbnailXPosition = xPosition + (xSpacing * (itemThumbnails.count-1) + (thumbnailSize * (itemThumbnails.count-1)) );
    
    //Create the new thumbnail imageView
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:thumbnail];
    float yPosition = _picturesTakenView.frame.size.height; //image starts off screen then animates up
    [thumbnailImageView setFrame:CGRectMake(thumbnailXPosition, yPosition, thumbnailImageView.frame.size.width, thumbnailImageView.frame.size.height)];
    [_picturesTakenView addSubview:thumbnailImageView];

    //Animate thumbnail up
    [UIView beginAnimations:@"Show New Thumbnail" context:nil];
    [UIView setAnimationDuration:thumbnailsAnimationSpeed];
    thumbnailImageView.transform = CGAffineTransformMakeTranslation(0, -_picturesTakenView.frame.size.height);
    [UIView commitAnimations];
    
    if( itemImages.count >= maxPictures ) {
//        [self doneTakingPicturesButtonPressed:nil];
        [self performSelector:@selector(doneTakingPicturesButtonPressed:) withObject:nil afterDelay:thumbnailsAnimationSpeed];
    }
}


- (void)saveItem {
    
    //save item details
    NSLog(@"saving item...");
    [currentItem setObject:[_itemNameTextField text] forKey:DB_FIELD_ITEM_NAME];
    [currentItem setObject:[_itemDescriptionTextView text] forKey:DB_FIELD_ITEM_DESCRIPTION];
    [currentItem setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
    [currentItem setObject:itemLocationPoint forKey:DB_FIELD_ITEM_LOCATION];

    //save all thumbnails and images
    for(int i=0; i<[itemThumbnails count]; i++) {
        
        [HUD setLabelText:[NSString stringWithFormat:NSLocalizedString(@"saving image %d of %d...", nil), i+1, [itemThumbnails count]]];
        
        UIImage *fullImage = [itemImages objectAtIndex:i];
        NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.6f);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        
        PFObject *itemImagesObject = [PFObject objectWithClassName:DB_TABLE_ITEM_IMAGES];
        [itemImagesObject setObject:currentItem forKey:DB_FIELD_ITEM_ID];
        [itemImagesObject setObject:imageFile forKey:DB_FIELD_ITEM_IMAGE];
        [itemImagesObject save];
        
        if(i==0) {
            [currentItem setObject:imageFile forKey:DB_FIELD_ITEM_MAIN_IMAGE];
        }
    }
    
    [currentItem save];
    NSLog(@"Item saved!");

    //subscribe the user for push notifications on this item
    NSString *subscribeChannel = [NSString stringWithFormat:NOTIFICATIONS_COMMENTS_ON_ITEM, currentItem.objectId];
    [PFPush subscribeToChannelInBackground:subscribeChannel];
    

    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"saved!", nil);

    [self closeThisScreen];
}

- (void)closeThisScreen {
    sleep(1);
    
    DoneShareViewController *doneShareViewController = [[DoneShareViewController alloc] initWithNibName:@"DoneShareViewController" bundle:nil];
    [doneShareViewController setItemObject:currentItem];
    [self.navigationController pushViewController:doneShareViewController animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    itemLocationPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
}

- (void)viewDidUnload {
    [self setDoneButton:nil];
    [self setItemNameTextField:nil];
    [self setPicturesTakenView:nil];
    [self setCameraOverlayView:nil];
    [self setDoneTakingPicturesButton:nil];
    [super viewDidUnload];
}

@end
