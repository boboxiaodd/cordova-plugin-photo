#import <Cordova/CDV.h>
#import "CDVPhotoPicker.h"
#import "HXPhotoPicker.h"
#import "UIImage+Resize.h"

@interface CDVPhotoPicker () <HXCustomNavigationControllerDelegate>
@property (nonatomic,strong) HXPhotoManager * manager;
@property (nonatomic,strong) CDVInvokedUrlCommand * pk_command;
@property (nonatomic,assign) BOOL isAvatar;
@property (nonatomic,assign) int photo_max_size;
@end

#define kPhotoMaxSize 1024;
@implementation CDVPhotoPicker
- (void)pluginInitialize
{

}

#pragma mark HXCustomNavigationControllerDelegate 协议实现
-(void)photoNavigationViewController:(HXCustomNavigationController *)photoNavigationViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original
{
    if(photoList.count > 0){
        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSMutableArray * list = [NSMutableArray array];
        for(int i = 0; i< photoList.count ;i ++) {
            //压缩图片尺寸
            UIImage *newImg;
            if(photoList[i].photoEdit){
                newImg = [photoList[i].photoEdit.editPreviewImage resize:_photo_max_size];
            }else{
                newImg = [photoList[i].previewPhoto resize:_photo_max_size];
            }
            NSData *imageData = UIImageJPEGRepresentation(newImg,0.8);
            NSLog(@"filesize: %lu",(unsigned long)[imageData length]);
            NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@"jpg"];
            [imageData writeToURL:fileURL atomically:YES];
            imageData = nil;
            [list addObject: [fileURL path]];
        }
        [self send_event: _pk_command withMessage:@{@"list": list} Alive:NO State:YES];
    }
}
-(void)photoNavigationViewControllerDidCancel:(HXCustomNavigationController *)photoNavigationViewController
{

}



#pragma mark Cordova 接口
-(void) picker:(CDVInvokedUrlCommand *)command
{
    _pk_command = command;
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    int picker_type = [[options valueForKey:@"picker_type"] intValue] || 1;
    int max_num = [[options valueForKey:@"max"] intValue] || 1;
    int is_avatar = [[options valueForKey:@"is_avatar"] boolValue] || NO;
    int max_size = [[options valueForKey:@"max_size"] intValue];
    if(max_size) _photo_max_size = max_size; else  _photo_max_size = kPhotoMaxSize;
    if(picker_type == 1) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        if(is_avatar){
            _isAvatar = YES;
            _manager.configuration.hideOriginalBtn = YES;
            _manager.configuration.singleSelected = YES;
            _manager.configuration.singleJumpEdit = YES;
            _manager.configuration.photoCanEdit = YES;
            _manager.configuration.photoEditConfigur.supportRotation = YES;
            _manager.configuration.photoEditConfigur.onlyCliping = YES;
            _manager.configuration.photoEditConfigur.aspectRatio = HXPhotoEditAspectRatioType_1x1;
        }else{
            _isAvatar = NO;
            _manager.configuration.maxNum = max_num;
            _manager.configuration.hideOriginalBtn = YES;
            _manager.configuration.requestOriginalImage = YES;
            _manager.configuration.requestImageAfterFinishingSelection = YES;
        }
    }else{
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
    }
    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithManager:self.manager delegate:self];
    [self.viewController presentViewController:nav animated:YES completion:nil];

}

#pragma mark 公共函数
- (void)send_event:(CDVInvokedUrlCommand *)command withMessage:(NSDictionary *)message Alive:(BOOL)alive State:(BOOL)state{
    CDVPluginResult* res = [CDVPluginResult resultWithStatus: (state ? CDVCommandStatus_OK : CDVCommandStatus_ERROR) messageAsDictionary:message];
    if(alive) [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult: res callbackId: command.callbackId];
}

@end
