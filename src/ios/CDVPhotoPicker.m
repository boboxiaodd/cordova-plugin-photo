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
                    if(!photoList[i].photoEdit.editPreviewImage) continue;
                    newImg = photoList[i].photoEdit.editPreviewImage;
                }else{
                    if(!photoList[i].previewPhoto) continue;
                    newImg = photoList[i].previewPhoto;
                }
                NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:@"jpg"];
                NSData *imageData = UIImageJPEGRepresentation(newImg,0.8);
                unsigned long filesize = imageData.length;
                [imageData writeToFile:[fileURL path] atomically:YES];
                imageData = nil;
                [list addObject: @{@"path":[fileURL path],
                                   @"filesize": @(filesize),
                                   @"size": @{@"width": @(newImg.size.width) ,@"height": @(newImg.size.height)}
                                 }];
            }
            [self send_event: _pk_command withMessage:@{@"list": list} Alive:NO State:YES];
        }
    if(videoList.count > 0){
        NSMutableArray * list = [NSMutableArray array];
        for(int i = 0; i< videoList.count ;i ++) {
            NSLog(@"videoDuration: %d",(int)videoList[i].videoDuration);
            [list addObject: @{@"path":[videoList[i].videoURL path],
                               @"duration": @(videoList[i].videoDuration),
                               @"filesize": @([self getFileSize:[videoList[i].videoURL path]])
                             }];
        }
        [self send_event: _pk_command withMessage:@{@"list": list} Alive:NO State:YES];
    }
    _manager = nil;
}
-(void)photoNavigationViewControllerDidCancel:(HXCustomNavigationController *)photoNavigationViewController
{

}



#pragma mark Cordova 接口
-(void) picker:(CDVInvokedUrlCommand *)command
{
    _pk_command = command;
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    int picker_type = [[options valueForKey:@"picker_type"] intValue];
    int max_num = [[options valueForKey:@"max"] intValue];
    if(picker_type == 1) {
        int is_avatar = [[options valueForKey:@"is_avatar"] boolValue] || NO;
        int max_size = [[options valueForKey:@"max_size"] intValue];
        BOOL onlyCliping = [[options valueForKey:@"onlyCliping"] boolValue] || NO;
        if(max_size) _photo_max_size = max_size; else  _photo_max_size = kPhotoMaxSize;
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.themeColor = [UIColor whiteColor];
        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        _manager.configuration.navigationTitleColor = [UIColor whiteColor];
        _manager.configuration.navBarBackgroudColor = [UIColor blackColor];
        _manager.configuration.navBarStyle = UIBarStyleBlack;
        _manager.configuration.bottomDoneBtnBgColor = [self colorWithHex:0x4aa321];
        _manager.configuration.bottomDoneBtnTitleColor = [UIColor whiteColor];
        _manager.configuration.selectedTitleColor = [UIColor whiteColor];
        _manager.configuration.cellSelectedBgColor = [self colorWithHex:0x4aa321];
        _manager.configuration.photoEditConfigur.themeColor = [self colorWithHex:0x4aa321];
        _manager.configuration.bottomViewBgColor = [UIColor blackColor];
        _manager.configuration.cameraCanLocation = NO;
        _manager.configuration.photoStyle = HXPhotoStyleInvariant;
        if(is_avatar){
            _isAvatar = YES;
            _manager.configuration.hideOriginalBtn = YES;
            _manager.configuration.singleSelected = YES;
            _manager.configuration.singleJumpEdit = YES;
            _manager.configuration.cameraPhotoJumpEdit = YES;
            _manager.configuration.photoCanEdit = YES;
            _manager.configuration.defaultFrontCamera = YES;
            _manager.configuration.photoEditConfigur.supportRotation = YES;
            _manager.configuration.photoEditConfigur.onlyCliping = YES;
            _manager.configuration.photoEditConfigur.aspectRatio = HXPhotoEditAspectRatioType_1x1;
        }else{
            _isAvatar = NO;
            _manager.configuration.photoMaxNum = max_num;
            _manager.configuration.hideOriginalBtn = YES;
            _manager.configuration.requestOriginalImage = NO;
            _manager.configuration.photoEditConfigur.supportRotation = YES;
            _manager.configuration.photoEditConfigur.onlyCliping = onlyCliping;
            _manager.configuration.requestImageAfterFinishingSelection = YES;
            NSArray *emoji = [options objectForKey:@"emoji"];
            if(emoji.count > 0){
                NSMutableArray * emojiList = [NSMutableArray array];
                for(int i = 0 ;i <emoji.count ; i++ ){
                    NSMutableArray * chartList = [NSMutableArray array];
                    NSArray * list = (NSArray *)emoji[i];
                    HXPhotoEditChartletTitleModel * titleModel = [HXPhotoEditChartletTitleModel modelWithNetworkNURL:[NSURL URLWithString:list[0]]];
                    for(int j = 0; j< list.count; j++ ){
                        HXPhotoEditChartletModel * model = [HXPhotoEditChartletModel modelWithNetworkNURL:[NSURL URLWithString:list[j]]];
                        [chartList addObject:model];
                    }
                    titleModel.models = chartList;
                    if(i == 0) titleModel.selected = YES;
                    [emojiList addObject:titleModel];
                }
                _manager.configuration.photoEditConfigur.chartletModels = emojiList;
            }
        }
    }else{
        int max_duration = [[options valueForKey:@"max_duration"] intValue];
        int min_duration = [[options valueForKey:@"min_duration"] intValue];
        int quality = [[options valueForKey:@"quality"] intValue];
        BOOL original = [[options valueForKey:@"original"] boolValue];
        int limitVideoSize = [[options valueForKey:@"limitVideoSize"] intValue];
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];

        _manager.configuration.themeColor = [UIColor whiteColor];
        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        _manager.configuration.navigationTitleColor = [UIColor whiteColor];
        _manager.configuration.navBarBackgroudColor = [UIColor blackColor];
        _manager.configuration.navBarStyle = UIBarStyleBlack;
        _manager.configuration.bottomDoneBtnBgColor = [self colorWithHex:0x4aa321];
        _manager.configuration.bottomDoneBtnTitleColor = [UIColor whiteColor];
        _manager.configuration.selectedTitleColor = [UIColor whiteColor];
        _manager.configuration.cellSelectedBgColor = [self colorWithHex:0x4aa321];
        _manager.configuration.bottomViewBgColor = [UIColor blackColor];
        _manager.configuration.cameraCanLocation = NO;

        _manager.configuration.hideOriginalBtn = YES;
        if(max_num == 1){
            _manager.configuration.singleSelected = YES;
            _manager.configuration.singleJumpEdit = YES;
        }else{
            _manager.configuration.videoMaxNum = max_num;
        }
        _manager.configuration.openCamera = NO;
        _manager.configuration.videoMaximumDuration = max_duration;
        _manager.configuration.videoMaximumSelectDuration = max_duration;
        _manager.configuration.videoMinimumDuration = min_duration;
        _manager.configuration.videoMinimumSelectDuration = min_duration;
        _manager.configuration.selectVideoLimitSize = YES;
        _manager.configuration.limitVideoSize = limitVideoSize;
        if(original){
            _manager.configuration.requestOriginalImage = YES;
            _manager.configuration.exportVideoURLForHighestQuality = YES;
        }else{
            _manager.configuration.editVideoExportPreset = HXVideoEditorExportPresetMediumQuality;
            _manager.configuration.videoQuality = quality;
        }
        _manager.configuration.selectVideoBeyondTheLimitTimeAutoEdit = YES;
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        _manager.configuration.minVideoClippingTime = min_duration;
        _manager.configuration.maxVideoClippingTime = max_duration;
        _manager.configuration.themeColor = [UIColor whiteColor];
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

-(long long)getFileSize:(NSString *)filepath
{
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: filepath error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber longLongValue];
}
- (UIColor *) colorWithHex:(int)color {
    float red = (color & 0xff0000) >> 16;
    float green = (color & 0x00ff00) >> 8;
    float blue = (color & 0x0000ff);
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
