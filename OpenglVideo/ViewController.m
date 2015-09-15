//
//  ViewController.m
//  OpenglVideo
//
//  Created by Lightning on 15/9/8.
//  Copyright © 2015年 Lightning. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "SJPlayerView.h"
#import <CoreVideo/CoreVideo.h>

typedef NS_ENUM(NSInteger, VideoEffectType){
    VideoEffectNone = 0,
    VideoEffectOne = 1,
    VideoEffectTwo = 2,
    VideoEffectThree = 3
};


@interface ViewController ()<UIImagePickerControllerDelegate,AVPlayerItemOutputPullDelegate>
{
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    dispatch_queue_t _myVideoOutputQueue;
    id _notificationToken;
    id _timeObserver;
}
@property (weak, nonatomic) IBOutlet SJPlayerView *playerView;

@property AVPlayerItemVideoOutput *videoOutput;
@property CADisplayLink *displayLink;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self displayLink] setPaused:YES];
    
    // Setup AVPlayerItemVideoOutput with the required pixelbuffer attributes.
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    CMTime outputItemTime = kCMTimeInvalid;
    
    // Calculate the nextVsync time which is when the screen will be refreshed next.
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    outputItemTime = [[self videoOutput] itemTimeForHostTime:nextVSync];
    if ([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime]) {
        CMTimeShow(outputItemTime);

        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
#warning To Do
        [self.playerView displayPixelBuffer:pixelBuffer];
    }
}

- (IBAction)playBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    sender.hidden = !sender.hidden;
    if (sender.selected) {
        [_player play];
        [self.displayLink setPaused:NO];
    } else {
        [_player pause];
    }
}

- (IBAction)effectionBtnClicked:(UIButton *)sender {
    
}
- (IBAction)libraryBtnClick:(id)sender {
    [_player pause];
    [self.displayLink setPaused:YES];
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.popover = [[UIPopoverController alloc] initWithContentViewController:videoPicker];
//        self.popover.delegate = self;
//        [[self popover] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//    }
//    else {
        [self presentViewController:videoPicker animated:YES completion:nil];
//    }
}
- (IBAction)outputVideo:(id)sender {
    
}


- (void)prepareVideoWithUrl:(NSURL *)videoUrl
{
    if (_player) {
    
    }
    _playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    AVAsset *asset = [_playerItem asset];
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                // Choose the first video track.
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                    
                    if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                        CGAffineTransform preferredTransform = [videoTrack preferredTransform];
//                        self.playerView.preferSize = [videoTrack naturalSize];
                        CGSize videoSize = videoTrack.naturalSize;
                        CGSize presentationSize = _playerItem.presentationSize;
                        NSLog(@"video - %@--item - %@",NSStringFromCGSize(videoSize),NSStringFromCGSize(presentationSize));
                        CGFloat scale = [UIScreen mainScreen].scale;
                        self.playerView.preferSize = CGSizeMake(videoSize.width, videoSize.height);
                        self.playerView.preferredRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
//                        [self.playerView setupGL]
                        [self addDidPlayToEndTimeNotificationForPlayerItem:_playerItem];
                        
                    }}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_playerItem addOutput:self.videoOutput];
                    [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.1];
//                    [_player play];
                });
                
            }}
    }];
    
}

- (void)addDidPlayToEndTimeNotificationForPlayerItem:(AVPlayerItem *)item
{
    if (_notificationToken)
        _notificationToken = nil;
    
    /*
     Setting actionAtItemEnd to None prevents the movie from getting paused at item end. A very simplistic, and not gapless, looped playback.
     */
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // Simple item playback rewind.
        
        [[_player currentItem] seekToTime:kCMTimeZero];
    }];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *videoUrl = info[UIImagePickerControllerReferenceURL];
//    [self.playerView setupGL];
    [self prepareVideoWithUrl:videoUrl];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVPlayerItemOutputPullDelegate

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    // Restart display link.
//    [[self displayLink] setPaused:NO];
}

@end
