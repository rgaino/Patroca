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
#import "FacebookUtilsCache.h"

#define thumbnailSize 53
#define fullImageSize 640
#define croppedSquareImageSize 596
#define imageCornerRadius 0
#define thumbnailsAnimationSpeed 0.25f
#define maxPictures 4
#define fadeOutCameraMessageDelay 4.0f

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
    [doneButton setEnabled:NO];
    
    [_itemNameTextField setDelegate:self];
    [_itemNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_itemNameTextField setPlaceholder:NSLocalizedString(@"what is this?", nil)];

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
    [self performSelector:@selector(fadeOutCameraMessageLabel) withObject:nil afterDelay:fadeOutCameraMessageDelay];
}

- (void)fadeOutCameraMessageLabel {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [_cameraMessageLabel setAlpha:0];
    [_cameraMessageBackgroundImageView setAlpha:0];
    [UIView commitAnimations];
}

- (void)textFieldDidChange:(id)sender {
    [doneButton setEnabled: (_itemNameTextField.text.length > 0) ];
}

- (IBAction)takePictureButtonPressed:(id)sender {
	
    [imagePicker takePicture];
}

- (IBAction)doneTakingPicturesButtonPressed:(id)sender {

	[self dismissViewControllerAnimated:YES completion:nil];
    [locationManager startUpdatingLocation];
    [_itemNameTextField becomeFirstResponder];
}

- (IBAction)backButtonPressed {
    
    if(itemImages.count == 0) {
        //user didn't take any pictures yet, so just pop out
        [self dismissViewControllerAnimated:NO completion:nil];
        [super backButtonPressed];

    } else {
        //ask before popping out

        UIActionSheet *discardItemActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"sure_discard_item_question", nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"no", nil)
                                                             destructiveButtonTitle:NSLocalizedString(@"yes", nil)
                                                                  otherButtonTitles:nil];
        
        [discardItemActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [discardItemActionSheet showInView:self.view];
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(buttonIndex == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [super backButtonPressed];
    }
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
    [imagePicker presentViewController:galleryImagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    if( picker == galleryImagePicker ) {
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
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
    [_picturePreviewImageView setImage:croppedSquareImage];

    
    
/*
Commenting out the next section because I only want one picture taken (it was 4 before)
To bring that back, simply uncomment these lines and:
  1) unhide the pic thumbs that are hidden on the XIB file.
  2) unhide the cameraMessage label and backgroundMessageView
 
The only line left is the one that dismissess the camera/gallery
 */
    
    [self performSelector:@selector(doneTakingPicturesButtonPressed:) withObject:nil];

    /*
    [_doneTakingPicturesButton setHidden:NO];

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
        [self performSelector:@selector(doneTakingPicturesButtonPressed:) withObject:nil afterDelay:thumbnailsAnimationSpeed];
    } else {
        
        //show camera message
        NSString *cameraMessageString = [NSString stringWithFormat:@"camera_message_%d", (int)(itemImages.count+1)];
        [_cameraMessageLabel setText:NSLocalizedString(cameraMessageString, nil)];
        [_cameraMessageLabel setAlpha:1.0f];
        [_cameraMessageBackgroundImageView setAlpha:1.0f];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutCameraMessageLabel) object:nil];
        [self performSelector:@selector(fadeOutCameraMessageLabel) withObject:nil afterDelay:fadeOutCameraMessageDelay];
    }
    
    */
}


- (void)doneButtonPressed {
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [HUD setMode:MBProgressHUDModeDeterminate];
	[HUD setDimBackground:YES];
	[HUD setLabelText: NSLocalizedString(@"saving", nil)];
    [HUD setDelegate:self];
    [self.navigationController.view addSubview:HUD];
    
    [HUD show:YES];
    [self saveItem];
}

- (void)saveItem {
    
    //save item details
    NSLog(@"saving item...");
    [currentItem setObject:[_itemNameTextField text] forKey:DB_FIELD_ITEM_NAME];
    [currentItem setObject:[_itemDescriptionTextView text] forKey:DB_FIELD_ITEM_DESCRIPTION];
    [currentItem setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
    [currentItem setObject:itemLocationPoint forKey:DB_FIELD_ITEM_LOCATION];
    [currentItem setObject:[NSNumber numberWithBool:NO] forKey:DB_FIELD_ITEM_TRADED];
    [currentItem setObject:[NSNumber numberWithBool:NO] forKey:DB_FIELD_ITEM_DELETED];

    imageNumber=0;
    [self saveNextItemImage]; //start with the first one, then this method will check and upload others.
}

- (void)saveNextItemImage {
    
    NSString *hudString = [NSString stringWithFormat:NSLocalizedString(@"saving image %d of %d...", nil), imageNumber+1, [itemThumbnails count]];
    [HUD setProgress:0.0f];
    [HUD setLabelText:hudString];
    NSLog(@"%@", hudString);
    
    UIImage *fullImage = [itemImages objectAtIndex:imageNumber];
    NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.6f);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    NSLog(@"Begin upload at %@", [NSDate date]);
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"Finished upload at %@", [NSDate date]);
        PFObject *itemImagesObject = [PFObject objectWithClassName:DB_TABLE_ITEM_IMAGES];
        [itemImagesObject setObject:currentItem forKey:DB_FIELD_ITEM_ID];
        [itemImagesObject setObject:imageFile forKey:DB_FIELD_ITEM_IMAGE];
        [itemImagesObject saveInBackground];
        
        if(imageNumber == itemImages.count-1) {
            
            //last image, save and we're done.
            dispatch_async(dispatch_get_main_queue(), ^{
                // This block will be executed asynchronously on the main thread.
                //because UI elements must be updated on the main thread
                [HUD setMode:MBProgressHUDModeIndeterminate];
                [HUD setLabelText:NSLocalizedString(@"wrapping_up", nil)];
            });
            [currentItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                //subscribe the user for push notifications on this item
                NSString *subscribeChannel = [NSString stringWithFormat:NOTIFICATIONS_COMMENTS_ON_ITEM, currentItem.objectId];
                [PFPush subscribeToChannelInBackground:subscribeChannel];
                NSLog(@"Item saved!");
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.labelText = NSLocalizedString(@"saved!", nil);
                
                //notify the user's friends of the new item
                [self sendNewItemPushNotifications];
                [self performSelector:@selector(closeThisScreen) withObject:nil afterDelay:1.0f];
            }];
            
            
        } else {
            
            //there's more images to save, so call this method again
            imageNumber++;
            [self saveNextItemImage];
        }


    } progressBlock:^(int percentDone) {
        float perc = percentDone/100.0f;
        [HUD setProgress:perc];
    }];


    if(imageNumber == 0) {
        
        //first image, use it as poster image for the item
        [currentItem setObject:imageFile forKey:DB_FIELD_ITEM_MAIN_IMAGE];
    }
}

- (void)closeThisScreen {
    
    [HUD removeFromSuperview];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendNewItemPushNotifications {
    
    if([PFUser currentUser] == nil) {
        NSLog(@"Can't get current user on sendNewUserPushNotifications");
    }
    
    FacebookUtilsCache *facebookUtilsCache = [FacebookUtilsCache getInstance];
    [facebookUtilsCache getFacebookFriendIDsInBackgroundWithCallback:^(NSArray *friendIdsArray, NSError *error) {
        
        if(!error) {
            
            NSString *newItemMessage = [NSString stringWithFormat:NSLocalizedString(@"new_item_message", nil), [[PFUser currentUser] objectForKey:DB_FIELD_USER_NAME]];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:friendIdsArray, @"friend_ids_array",
                                                                              newItemMessage, @"new_item_message",
                                                                              nil];
            
            [PFCloud callFunctionInBackground:@"notifyFriendsOfNewItem" withParameters:params block:^(id object, NSError *error) {
                
                if(!error) {
                    NSLog(@"notifyFriendsOfNewItem called with success");
                } else {
                    NSLog(@"Error calling notifyFriendsOfNewItem: %@ %@", error, [error userInfo]);
                }
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

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
    [self setItemNameTextField:nil];
    [self setPicturesTakenView:nil];
    [self setCameraOverlayView:nil];
    [self setDoneTakingPicturesButton:nil];
    [super viewDidUnload];
}

@end
