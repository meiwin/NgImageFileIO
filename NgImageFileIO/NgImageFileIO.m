//
//  NgImageFileIO.m
//  NgImageFileIO
//
//  Created by Meiwin Fu on 26/2/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "NgImageFileIO.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

extern UIImageOrientation CGImageOrientationToUIImageOrientation(int cgimageOrientation) {

  UIImageOrientation o = UIImageOrientationUp;
  switch (cgimageOrientation) {
    case 1:
      o = UIImageOrientationUp;
      break;
      
    case 3:
      o = UIImageOrientationDown;
      break;
      
    case 8:
      o = UIImageOrientationLeft;
      break;
      
    case 6:
      o = UIImageOrientationRight;
      break;
      
    case 2:
      o = UIImageOrientationUpMirrored;
      break;
      
    case 4:
      o = UIImageOrientationDownMirrored;
      break;
      
    case 5:
      o = UIImageOrientationLeftMirrored;
      break;
      
    case 7:
      o = UIImageOrientationRightMirrored;
      break;
    default:
      break;
  }
  return o;
}

extern int UIImageOrientationToCGImageOrientation(UIImageOrientation uiimageOrientation) {
  int exifOrientation = 6;
  switch (uiimageOrientation) {
    case UIImageOrientationUp:
      exifOrientation = 1;
      break;
      
    case UIImageOrientationDown:
      exifOrientation = 3;
      break;
      
    case UIImageOrientationLeft:
      exifOrientation = 8;
      break;
      
    case UIImageOrientationRight:
      exifOrientation = 6;
      break;
      
    case UIImageOrientationUpMirrored:
      exifOrientation = 2;
      break;
      
    case UIImageOrientationDownMirrored:
      exifOrientation = 4;
      break;
      
    case UIImageOrientationLeftMirrored:
      exifOrientation = 5;
      break;
      
    case UIImageOrientationRightMirrored:
      exifOrientation = 7;
      break;
    default:
      break;
  }
  return exifOrientation;
}

#pragma mark - 
@implementation NgImageProperties
- (instancetype)initWithScale:(CGFloat)scale
{
  self = [super init];
  if (self)
  {
    _scale = scale;
  }
  return self;
}
- (instancetype)init
{
  self = [super init];
  if (self)
  {
    _scale = 1.f;
  }
  return self;
}
- (void)setUTI:(NSString *)UTI
{
  _UTI = UTI;
}
- (void)setColorModel:(NSString *)colorModel
{
  _colorModel = colorModel;
}
- (void)setDPI:(CGSize)DPI
{
  _DPI = DPI;
}
- (void)setDepth:(CGFloat)depth
{
  _depth = depth;
}
- (void)setOrientation:(UIImageOrientation)orientation
{
  _orientation = orientation;
}
- (void)setPixel:(CGSize)pixel
{
  _pixel = pixel;
}
- (void)loadFromDictionary:(NSDictionary *)dic
{
  [self setColorModel:dic[(NSString *)kCGImagePropertyColorModel]];
  [self setDepth:[dic[(NSString *)kCGImagePropertyDepth] floatValue]];
  [self setOrientation:CGImageOrientationToUIImageOrientation([dic[(NSString *)kCGImagePropertyOrientation] intValue])];
  
  CGSize DPI;
  DPI.height = [dic[(NSString *)kCGImagePropertyDPIHeight] floatValue];
  DPI.width = [dic[(NSString *)kCGImagePropertyDPIWidth] floatValue];
  [self setDPI:DPI];
  
  CGSize pixel;
  pixel.height = [dic[(NSString *)kCGImagePropertyPixelHeight] floatValue]/_scale;
  pixel.width = [dic[(NSString *)kCGImagePropertyPixelWidth] floatValue]/_scale;
  [self setPixel:pixel];
}
- (void)setFramesCount:(NSInteger)framesCount
{
  _framesCount = framesCount;
}
@end

#pragma mark -
@interface NgImageFileIO ()
{
  UIImage * _image;
  CGImageSourceRef _imageSourceRef;
}
- (instancetype)initWithURL:(NSURL *)URL error:(NSError **)error;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;
@end

@implementation NgImageFileIO
+ (instancetype)imageFileIOWithURL:(NSURL *)fileURL error:(NSError **)error
{
  NgImageFileIO * instance = [[NgImageFileIO alloc] initWithURL:fileURL error:error];
  return instance;
}
+ (instancetype)imageFileIOWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
  NgImageFileIO * instance = [[NgImageFileIO alloc] initWithData:data error:error];
  return instance;
}
#pragma mark Init
- (instancetype)initWithURL:(NSURL *)URL error:(NSError **)error
{
  self = [super init];
  if (self)
  {
    if (URL == nil)
    {
      if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                              code:-1
                                          userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Invalid parameter: URL cannot be nil."
                                                     }];
      return nil;
    }
    _URL = URL;
    if (![NgImageFileIO checkIsFileURL:URL])
    {
      if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                              code:-1
                                          userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Invalid URL: must be a file."
                                                     }];
      return nil;
    }
    _imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)_URL, NULL);
    if (_imageSourceRef == NULL)
    {
      if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                              code:-1
                                          userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Failed to create images source."
                                                     }];
      return nil;
    }
    if (![self loadImageProperties:error])
    {
      return nil;
    }
  }
  return self;
}
- (instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
  self = [super init];
  if (self)
  {
    if (data == nil)
    {
      if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                              code:-1
                                          userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Invalid parameter: data cannot be nil."
                                                     }];
      return nil;
    }
    _data = data;
    _imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)_data, NULL);
    if (_imageSourceRef == NULL)
    {
      if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                              code:-1
                                          userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Failed to create images source."
                                                     }];
      return nil;
    }
    if (![self loadImageProperties:error])
    {
      return nil;
    }
  }
  return self;
}
- (void)dealloc
{
  if (_imageSourceRef != NULL)
  {
    CFRelease(_imageSourceRef);
  }
}
+ (BOOL)checkIsFileURL:(NSURL *)URL
{
  return [[URL scheme] isEqual:@"file"];
}
+ (CGFloat)getScaleFromURL:(NSURL *)URL
{
  NSString * extension = [URL pathExtension];
  NSString * tmp = [URL lastPathComponent];
  NSString * filename = [tmp substringWithRange:NSMakeRange(0, tmp.length - extension.length)];

  NSRange atRange = [filename rangeOfString:@"@" options:NSBackwardsSearch];
  if (atRange.location != NSNotFound)
  {
    NSString * scaleStr = [filename substringFromIndex:atRange.location+1];
    return MAX(1.f, [scaleStr floatValue]);
  }
  return 1.f;
}
- (BOOL)loadImageProperties:(NSError **)error
{
  NSString * UTI = (__bridge NSString *)CGImageSourceGetType(_imageSourceRef);
  if (!UTI)
  {
    if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                            code:-1
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey : @"Invalid image file: unknown type."
                                                   }];
    return NO;
  }
  
  // detect scale based on filename
  CGFloat scale = [NgImageFileIO getScaleFromURL:_URL];
  NgImageProperties * imageProperties = [[NgImageProperties alloc] initWithScale:scale];
  
  // UTI
  [imageProperties setUTI:UTI];
  
  // Frames count
  [imageProperties setFramesCount:CGImageSourceGetCount(_imageSourceRef)];
  
  // Other properties
  NSDictionary * properties = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(_imageSourceRef, 0, NULL);
  [imageProperties loadFromDictionary:properties];
  _properties = imageProperties;
  
  return YES;
}

#pragma mark Create Image
- (CGImageRef)createThumbnailImageWithImageSource:(CGImageSourceRef)imageSourceRef index:(int)index maxSize:(int)maxSize error:(NSError **)error
{
  CGImageRef thumbnailRef = NULL;
  CFDictionaryRef optionsRef = NULL;
  CFStringRef optionKeys[3];
  CFTypeRef optionValues[3];
  
  CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &maxSize);
  
  // set thumbnail options
  optionKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
  optionValues[0] = (CFTypeRef)kCFBooleanTrue;
  
  optionKeys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
  optionValues[1] = (CFTypeRef)kCFBooleanTrue;
  
  optionKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
  optionValues[2] = (CFTypeRef)thumbnailSize;
  
  optionsRef = CFDictionaryCreate(
                                  NULL,
                                  (const void **)optionKeys,
                                  (const void **)optionValues,
                                  3,
                                  &kCFTypeDictionaryKeyCallBacks,
                                  &kCFTypeDictionaryValueCallBacks);
  
  thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSourceRef, index, optionsRef);
  
  CFRelease(thumbnailSize);
  CFRelease(optionsRef);
  
  if (thumbnailRef == NULL)
  {
    if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                            code:-1
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey : @"Failed to create thumbnail image."
                                                   }];
    return NULL;
  }
  return thumbnailRef;
}
- (NSString *)preferredDestinationUTI
{
  if ([_properties.UTI isEqual:(NSString *)kUTTypeGIF]) return (NSString *)kUTTypeGIF;
  return (NSString *)kUTTypeJPEG;
}
- (UIImage *)createThumbnailWithMaxSize:(int)maxSize error:(NSError **)error;
{
  CGImageRef thumbnailRef = [self createThumbnailImageWithImageSource:_imageSourceRef index:0 maxSize:maxSize error:error];
  
  if (thumbnailRef)
  {
    UIImage * thumbnail = [UIImage imageWithCGImage:thumbnailRef
                                              scale:_properties.scale
                                        orientation:UIImageOrientationUp];
    CFRelease(thumbnailRef);
    return thumbnail;
  }
  return nil;
}
- (BOOL)createThumbnailWithMaxSize:(int)maxSize atURL:(NSURL *)URL error:(NSError **)error
{
  if (![NgImageFileIO checkIsFileURL:URL])
  {
    if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                            code:-1
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey : @"Invalid URL: must be a file."
                                                   }];
    return NO;
  }
  
  NSString * destinationUTI = [self preferredDestinationUTI];
  CGImageDestinationRef imageDestRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)URL,
                                                                    (__bridge CFStringRef)destinationUTI,
                                                                    _properties.framesCount,
                                                                    NULL);
  if (imageDestRef == NULL)
  {
    if (error) *error = [NSError errorWithDomain:@"NgImageFileIO"
                                            code:-1
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey : @"Failed to create image destination."
                                                   }];
    return NO;
  }
  
  for (int i = 0; i < _properties.framesCount; i++)
  {
    CGImageRef frameRef = [self createThumbnailImageWithImageSource:_imageSourceRef
                                                              index:i
                                                            maxSize:maxSize
                                                              error:error];
    if (frameRef == NULL)
    {
      CFRelease(imageDestRef);
      return NO;
    }
    
    NSDictionary * originalImageProps = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(_imageSourceRef, i, NULL);
    NSMutableDictionary * gifProps = nil;
    if (originalImageProps[(NSString *)kCGImagePropertyGIFDictionary])
    {
      gifProps = [NSMutableDictionary dictionary];
      gifProps[(NSString *)kCGImagePropertyGIFDictionary] = originalImageProps[(NSString *)kCGImagePropertyGIFDictionary];
    }

    CGImageDestinationAddImage(imageDestRef, frameRef, (__bridge CFDictionaryRef)gifProps);
    CFRelease(frameRef);
  }

  CGImageDestinationFinalize(imageDestRef);
  CFRelease(imageDestRef);
  return YES;
}
- (UIImage *)image
{
  if (!_image)
  {
    [self loadImage];
  }
  return _image;
}
- (void)loadImage
{
  NSData * imageData = _data;
  
  if (!imageData && _URL) {
    imageData = [NSData dataWithContentsOfURL:_URL];
  }
  
  UIImage * image = [UIImage imageWithData:imageData];
  if (image) {
    image = [UIImage imageWithCGImage:[image CGImage] scale:_properties.scale orientation:_properties.orientation];
  }
  _image = image;
}

#pragma mark Convenience method to save image to file
+ (void)saveImage:(UIImage *)image
        toFileURL:(NSURL *)URL
          quality:(CGFloat)quality
             info:(NSDictionary *)info
       completion:(void(^)(NSError *))completion
{
  if (URL == nil)
  {
    if (completion) completion([NSError errorWithDomain:@"NgImageFileIO" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid paramter: URL cannot be nil." }]);
    return;
  }
  if (image == nil)
  {
    if (completion) completion([NSError errorWithDomain:@"NgImageFileIO" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid paramter: image cannot be nil." }]);
    return;
  }
  if (![NgImageFileIO checkIsFileURL:URL])
  {
    if (completion) completion([NSError errorWithDomain:@"NgImageFileIO" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid URL: must be file URL." }]);
    return;
  }
  
  CGImageDestinationRef imageDestRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)URL, kUTTypeJPEG, 1, NULL);
  if (imageDestRef == NULL)
  {
    if (completion) completion([NSError errorWithDomain:@"NgImageFileIO" code:-1
                                               userInfo:@{ NSLocalizedDescriptionKey : @"Failed to create image destination." }]);
    return;
  }
  
  NSMutableDictionary *destOptions = [NSMutableDictionary dictionaryWithObject:@(MIN(1.f, quality)) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
  if (info) [destOptions addEntriesFromDictionary:info];
  if (!destOptions[(__bridge NSString *)kCGImagePropertyOrientation]) {
    destOptions[(__bridge NSString *)kCGImagePropertyOrientation] = @(UIImageOrientationToCGImageOrientation(image.imageOrientation));
  }
  CGImageDestinationAddImage(imageDestRef, image.CGImage, (__bridge CFDictionaryRef)destOptions);
  CGImageDestinationFinalize(imageDestRef);
  CFRelease(imageDestRef);
  if (completion) completion(nil);
}
@end
