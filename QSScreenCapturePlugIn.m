//
//  QSScreenCapturePlugIn.m
//  QSScreenCapturePlugIn
//
//  Created by Nicholas Jitkoff on 11/26/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSScreenCapturePlugIn.h"
#define SCTOOL @"/usr/sbin/screencapture"

//usage: screencapture [-icmwsWx] [files]
//-i         capture screen interactively, by selection or window
//	control key - causes screen shot to go to clipboard
//	space key   - toggle between mouse selection and
//	window selection modes
//	escape key  - cancels interactive screen shot
//-c         force screen capture to go to the clipboard
//-m         only capture the main monitor, undefined if -i is set
//-w         only allow window selection mode
//-s         only allow mouse selection mode
//-W         start interaction in window selection mode
//-x         do not play sounds
//-S         in window capture mode, capture the screen not the window
//-C         capture the cursor as well as the screen. only in non-interactive modes
//-t<format> image format to create, default is png
//	files   where to save the screen capture, 1 file per screen

@implementation QSScreenCapturePlugIn

- (QSObject *)captureScreen:(QSObject *)dObject{
	NSString *destinationPath = [self filePathForCaptureType:@"Screen Shot"];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObject:destinationPath]];
	[task waitUntilExit];
    QSObject *capturedImage = [QSObject fileObjectWithPath:destinationPath];
	[[QSReg preferredCommandInterface] selectObject:capturedImage];
	[[QSReg preferredCommandInterface] actionActivate:nil];
    NSDictionary *info = @{@"object": capturedImage};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QSEventNotification" object:@"QSCapturedScreen" userInfo:info];
	return nil;
}

- (QSObject *)captureRegion:(QSObject *)dObject{
	NSString *destinationPath = [self filePathForCaptureType:@"Screen Region"];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObjects:@"-is",destinationPath,nil]];
	[task waitUntilExit];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        QSObject *capturedImage = [QSObject fileObjectWithPath:destinationPath];
        [[QSReg preferredCommandInterface] selectObject:capturedImage];
        [[QSReg preferredCommandInterface] actionActivate:nil];
        NSDictionary *info = @{@"object": capturedImage};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QSEventNotification" object:@"QSCapturedRegion" userInfo:info];
    }
	return nil;
}

- (QSObject *)captureWindow:(QSObject *)dObject{
	NSString *destinationPath = [self filePathForCaptureType:@"Window"];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObjects:@"-iW",destinationPath,nil]];
	[task waitUntilExit];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        QSObject *capturedImage = [QSObject fileObjectWithPath:destinationPath];
        [[QSReg preferredCommandInterface] selectObject:capturedImage];
        [[QSReg preferredCommandInterface] actionActivate:nil];
        NSDictionary *info = @{@"object": capturedImage};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QSEventNotification" object:@"QSCapturedWindow" userInfo:info];
    }
	return nil;
}

- (NSString *)filePathForCaptureType:(NSString *)type
{
    NSDate *now = [NSDate date];
    NSString *timestamp = [now descriptionWithCalendarFormat:@"%Y-%m-%d at %H.%M.%S" timeZone:nil locale:nil];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // fallback directory
    NSString *screenshotDirectory = @"~/Desktop";
    // attempt to read system default screenshot location
    NSString *systemDefaultScreenCaptureLocationString = [[defaults persistentDomainForName:@"com.apple.screencapture"] valueForKey:@"location"];
    
    // if the system default screenshot location exists then use that location
    if( [[NSFileManager defaultManager] fileExistsAtPath:systemDefaultScreenCaptureLocationString] )
    {
        NSURL *screenshotLocationPreference =[NSURL fileURLWithPath:systemDefaultScreenCaptureLocationString isDirectory: YES];
        screenshotDirectory = [screenshotLocationPreference path];
    }

    NSString *path = [NSString stringWithFormat:@"%@/%@ %@.png", screenshotDirectory, type, timestamp];
    return [path stringByStandardizingPath];
}
@end
