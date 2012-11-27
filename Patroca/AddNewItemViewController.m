//
//  AddNewItemViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 8/25/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "AddNewItemViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "DatabaseConstants.h"

#define thumbnailSize 65
#define fullImageSize 500
#define thumbnailsAnimationSpeed 0.25f

@interface AddNewItemViewController ()

@end

@implementation AddNewItemViewController
@synthesize itemNameLabel;
@synthesize doneButton;
@synthesize itemNameTextField;
@synthesize picturesTakenView;
@synthesize cameraOverlayView;
@synthesize doneTakingPicturesButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add New Item", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [itemNameTextField setDelegate:self];

    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //setup the views
    [self localizeStrings];
    [self setupCameraOverlayView];
    [self setupImagePicker];
    [self presentCamera];

    //initialize a new blank Item object
    currentItem = [PFObject objectWithClassName:DB_TABLE_ITEMS];
    itemThumbnails = [[NSMutableArray alloc] init];
    itemImages = [[NSMutableArray alloc] init];
    
    xSpacing = 10;
    xPosition = 0 - thumbnailSize;
}


- (void)localizeStrings {
    [itemNameLabel setText:NSLocalizedString(@"Item Name", nil)];
    [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [doneTakingPicturesButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
}

- (void)setupCameraOverlayView {
    [cameraOverlayView setBackgroundColor:[UIColor clearColor]];
}

- (void)setupImagePicker {
    
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	[imagePicker setAllowsEditing:NO];
	[imagePicker setShowsCameraControls:NO];
	[imagePicker setCameraOverlayView:cameraOverlayView];
	[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
	[imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:[imagePicker sourceType]]];
	[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
}

- (void)presentCamera {

//    UINavigationController *navigationController = (UINavigationController *)self.view.window.rootViewController.presentedViewController;
//    [navigationController pushViewController:imagePicker animated:YES];
//    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];

    
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (IBAction)doneButtonPressed:(id)sender {

    //dismiss keyboard
    [self.view endEditing:YES];

	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[HUD setDimBackground:YES];
	[HUD setLabelText: NSLocalizedString(@"Saving", nil)];
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self savePicture:picture];
	return;
}

- (void)savePicture:(UIImage *)picture {

    float imageWidth = picture.size.width;
    float imageHeight = picture.size.height;
    
    float ratio = imageWidth/fullImageSize;
    CGSize fullImageNewSize = CGSizeMake(imageWidth/ratio, imageHeight/ratio);
        
    UIImage *fullSize = [picture resizedImage:fullImageNewSize interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnail = [picture thumbnailImage:thumbnailSize transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
    
    [itemThumbnails addObject:thumbnail];
    [itemImages addObject:fullSize];


    //is the new thumbnail out of bounds on the thumbnail list?
    if( (xPosition + xSpacing + thumbnailSize + thumbnailSize) > cameraOverlayView.frame.size.width ) {

        //New image would be out of bounds, so move each thumbnail to the left
        [UIView beginAnimations:@"Move Out Thumbnails" context:nil];
        [UIView setAnimationDuration:thumbnailsAnimationSpeed];
        
        for(UIView *imageView in picturesTakenView.subviews) {
            if( [imageView isKindOfClass:[UIImageView class]] ) {

                float newX = imageView.frame.origin.x - (xSpacing + imageView.frame.size.width);
                [imageView setFrame:CGRectMake(newX, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
            }
        }
        
        
        [UIView commitAnimations];
        
    } else {
        
        xPosition +=  (xSpacing + thumbnailSize);
    }
    
    //Create the new thumbnail
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:thumbnail];
    float yPosition = (10+picturesTakenView.frame.size.height); //image starts off screen then animates up
    [thumbnailImageView setFrame:CGRectMake(xPosition, yPosition, thumbnailImageView.frame.size.width, thumbnailImageView.frame.size.height)];
    [picturesTakenView addSubview:thumbnailImageView];

    //Animate thumbnail up
    [UIView beginAnimations:@"Show New Thumbnail" context:nil];
    [UIView setAnimationDuration:thumbnailsAnimationSpeed];
    thumbnailImageView.transform = CGAffineTransformMakeTranslation(0, -picturesTakenView.frame.size.height);
    [UIView commitAnimations];
}


- (void)saveItem {
    
    //save item details
    NSLog(@"Saving Item...");
    [currentItem setObject:[itemNameTextField text] forKey:DB_FIELD_ITEM_NAME];
    [currentItem setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
    [currentItem setObject:itemLocationPoint forKey:DB_FIELD_ITEM_LOCATION];

    //save all thumbnails and images
    for(int i=0; i<[itemThumbnails count]; i++) {
        
        NSLog(@"Saving image %d of %d...", i+1, [itemThumbnails count]);
        [HUD setLabelText:[NSString stringWithFormat:NSLocalizedString(@"Saving image %d of %d...", nil), i+1, [itemThumbnails count]]];

        UIImage *thumbnailImage = [itemThumbnails objectAtIndex:i];
        NSData *thumbnailData = UIImagePNGRepresentation(thumbnailImage);
        PFFile *thumbnailImageFile = [PFFile fileWithName:@"thumbnail.png" data:thumbnailData];
        
        UIImage *fullImage = [itemImages objectAtIndex:i];
        NSData *imageData = UIImagePNGRepresentation(fullImage);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        
        PFObject *itemImagesObject = [PFObject objectWithClassName:DB_TABLE_ITEM_IMAGES];
        [itemImagesObject setObject:currentItem forKey:DB_FIELD_ITEM_ID];
        [itemImagesObject setObject:thumbnailImageFile forKey:DB_FIELD_ITEM_THUMBNAIL];
        [itemImagesObject setObject:imageFile forKey:DB_FIELD_ITEM_IMAGE];
        [itemImagesObject save];
        
        if( [currentItem objectForKey:DB_FIELD_ITEM_MAIN_THUMBNAIL] == nil) {
            [currentItem setObject:thumbnailImageFile forKey:DB_FIELD_ITEM_MAIN_THUMBNAIL];
        }
        
        NSLog(@"Images saved!");
    }
    
    [currentItem save];
    NSLog(@"Item saved!");

    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"Saved!", nil);

    [self closeThisScreen];
}

- (void)closeThisScreen {
    sleep(1);
    [self.navigationController popViewControllerAnimated:YES];
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
    [self setItemNameLabel:nil];
    [self setDoneButton:nil];
    [self setItemNameTextField:nil];
    [self setPicturesTakenView:nil];
    [self setCameraOverlayView:nil];
    [self setDoneTakingPicturesButton:nil];
    [super viewDidUnload];
}

@end
