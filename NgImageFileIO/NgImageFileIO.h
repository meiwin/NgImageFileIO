//
//  NgImageFileIO.h
//  NgImageFileIO
//
//  Created by Meiwin Fu on 26/2/15.
//  Copyright (c) 2015 Meiwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern UIImageOrientation CGImageOrientationToUIImageOrientation(int exifOrientation);
extern int UIImageOrientationToCGImageOrientation(UIImageOrientation cgImageOrientation);

@interface NgImageProperties : NSObject
@property (nonatomic, strong, readonly) NSString * UTI;
@property (nonatomic, strong, readonly) NSString * colorModel;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGSize DPI;
@property (nonatomic, readonly) CGSize pixel;
@property (nonatomic, readonly) CGFloat depth;
@property (nonatomic, readonly) UIImageOrientation orientation;
@property (nonatomic, readonly) NSInteger framesCount;
@end

@interface NgImageFileIO : NSObject
@property (nonatomic, strong, readonly) NSURL * URL;
@property (nonatomic, strong, readonly) NSData * data;
@property (nonatomic, strong, readonly) NgImageProperties * properties;
@property (nonatomic, strong, readonly) UIImage * image;
+ (instancetype)imageFileIOWithURL:(NSURL *)fileURL error:(NSError **)error;
+ (instancetype)imageFileIOWithData:(NSData *)data error:(NSError **)error;
+ (void)saveImage:(UIImage *)image
        toFileURL:(NSURL *)URL
          quality:(CGFloat)quality
             info:(NSDictionary *)info
       completion:(void(^)(NSError *))completion;

- (UIImage *)createThumbnailWithMaxSize:(int)maxSize error:(NSError **)error;
- (BOOL)createThumbnailWithMaxSize:(int)maxSize atURL:(NSURL *)URL error:(NSError **)error;

@end
