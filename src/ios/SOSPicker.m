//
//  SOSPicker.m
//  SyncOnSet
//
//  Created by Christopher Sullivan on 10/25/13.
//
//

#import "SOSPicker.h"


#import "GMImagePickerController.h"
#import "GMFetchItem.h"

#define CDV_PHOTO_PREFIX @"cdv_photo_"


@interface SOSPicker () <GMImagePickerControllerDelegate>
@end

@implementation SOSPicker 

@synthesize callbackId;

- (void) getPictures:(CDVInvokedUrlCommand *)command {
    
    NSArray * args = [ command arguments ];
    
    BOOL allow_video = [ [ args[0] objectForKey:@"allow_video" ] boolValue ];
    NSString * title = [args[0] objectForKey:@"title"];
    NSString * message = [args[0] objectForKey:@"message"];
    
    self.callbackId = command.callbackId;
    [self launchGMImagePicker:allow_video title:title message:message];
}

- (void)launchGMImagePicker:(bool)allow_video title:(NSString *)title message:(NSString *)message
{
    GMImagePickerController *picker = [[GMImagePickerController alloc] init:allow_video];
    picker.delegate = self;
    picker.title = title;
    picker.customNavigationBarPrompt = message;
    picker.colsInPortrait = 4;
    picker.colsInLandscape = 6;
    picker.minimumInteritemSpacing = 2.0;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.sourceView = nil;
    //popPC.sourceRect = nil;
    
    [self.viewController showViewController:picker sender:nil];
}


- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    return nil;
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"UIImagePickerController: User ended picking assets");
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"UIImagePickerController: User pressed cancel button");
}

#pragma mark - GMImagePickerControllerDelegate

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)fetchArray
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)fetchArray.count);
    
    CDVPluginResult* result = nil;
    NSMutableArray *resultStrings = [[NSMutableArray alloc] init];
    
    for (GMFetchItem *item in fetchArray) {
        [ resultStrings addObject:item.image_fullsize];
    }
    
    result = nil;
    if (nil == result) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultStrings];
    }
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    
}

//Optional implementation:
-(void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker
{
    NSLog(@"GMImagePicker: User pressed cancel button");
}


@end
