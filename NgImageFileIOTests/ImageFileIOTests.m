//
//  NgImageFileIOTests.m
//  NgImageFileIOTests
//
//  Created by Meiwin Fu on 26/2/15.
//  Copyright (c) 2015 Piethis Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NgImageFileIO.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface NgImageFileIOTests : XCTestCase

@end

@implementation NgImageFileIOTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}
- (NSURL *)bundleURLForFilename:(NSString *)filename ext:(NSString *)ext
{
  return [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:ext];
}
- (NSURL *)uniqueURLForWriting
{
  NSString * uuid = [[NSUUID UUID] UUIDString];
  return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", uuid]];
}
- (void)testInvalidURL
{
  NSURL * URL = [NSURL URLWithString:@"http://google.com"];
  NSError * error = nil;
  XCTAssertNil([NgImageFileIO imageFileIOWithURL:URL error:&error]);
  XCTAssertNotNil(error);
}
- (void)testJPG
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test" ext:@"jpg"];
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:nil];
  XCTAssertNotNil(io);
  
  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([props framesCount], 1);
  XCTAssertEqual([props scale], 1.f);
  XCTAssertEqual([props orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(5184, 3456)]);

  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(300, thumbnail.size.width);
  XCTAssertEqual(200, thumbnail.size.height);
  
  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([thumbprops framesCount], 1);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(300, 200)]);
  
}
- (void)testJPGFromIPhoneCamera
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_iphonetest" ext:@"JPG"];
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:nil];
  XCTAssertNotNil(io);

  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([props framesCount], 1);
  XCTAssertEqual([props scale], 1.f);
  XCTAssertEqual([props orientation], UIImageOrientationRight);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(3264, 2448)]);
  
  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(225, thumbnail.size.width);
  XCTAssertEqual(300, thumbnail.size.height);

  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([thumbprops framesCount], 1);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(225, 300)]);
}
- (void)testGIF
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test" ext:@"gif"];
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:nil];
  XCTAssertNotNil(io);
  
  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], (__bridge NSString *)kUTTypeGIF);
  XCTAssertEqual([props framesCount], 8);
  XCTAssertEqual([props scale], 1.f);
  XCTAssertEqual([props orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(700, 435)]);
  
  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(300, thumbnail.size.width);
  XCTAssertEqual(186, thumbnail.size.height);

  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeGIF);
  XCTAssertEqual([thumbprops framesCount], 8);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(300, 186)]);
}
- (void)testPNG
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test@2x" ext:@"png"];
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:nil];
  XCTAssertNotNil(io);

  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], (__bridge NSString *)kUTTypePNG);
  XCTAssertEqual([props framesCount], 1);
  XCTAssertEqual([props scale], 2.f);
  XCTAssertEqual([props orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(24, 24)]);

  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(24, thumbnail.size.width);
  XCTAssertEqual(24, thumbnail.size.height);
  XCTAssertEqual(2, thumbnail.scale);

  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([thumbprops framesCount], 1);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(48, 48)]);
}
- (void)testNEF // nikon raw
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test" ext:@"nef"];
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:nil];
  XCTAssertNotNil(io);

  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], @"com.nikon.raw-image");
  XCTAssertEqual([props framesCount], 1);
  XCTAssertEqual([props scale], 1.f);
  XCTAssertEqual([props orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(4256, 2832)]);

  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(300, thumbnail.size.width);
  XCTAssertEqual(199, thumbnail.size.height);

  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([thumbprops framesCount], 1);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(300, 199)]);
}
- (void)testNonImageFile
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test" ext:@"txt"];
  NSError * error = nil;
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:URL error:&error];
  XCTAssertNil(io);
  XCTAssertNotNil(error);
}
- (void)testImageFromNSData
{
  NSURL * URL = [self bundleURLForFilename:@"imagefileio_test@2x" ext:@"png"];
  NSData * data = [NSData dataWithContentsOfURL:URL];

  NgImageFileIO * io = [NgImageFileIO imageFileIOWithData:data error:nil];
  XCTAssertNotNil(io);
  
  NgImageProperties * props = [io properties];
  XCTAssertNotNil(props);
  
  XCTAssertEqualObjects([props UTI], (__bridge NSString *)kUTTypePNG);
  XCTAssertEqual([props framesCount], 1);
  XCTAssertEqual([props scale], 1.f);
  XCTAssertEqual([props orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[props pixel]], [NSValue valueWithCGSize:CGSizeMake(48, 48)]);
  
  NSError * error = nil;
  UIImage * thumbnail = [io createThumbnailWithMaxSize:300 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(thumbnail);
  XCTAssertEqual(48, thumbnail.size.width);
  XCTAssertEqual(48, thumbnail.size.height);
  XCTAssertEqual(1, thumbnail.scale);
  
  NSURL * writeToURL = [self uniqueURLForWriting];
  error = nil;
  BOOL successful = [io createThumbnailWithMaxSize:300 atURL:writeToURL error:&error];
  XCTAssertEqual(successful, YES);
  XCTAssertNil(error);
  
  NgImageFileIO * thumbio = [NgImageFileIO imageFileIOWithURL:writeToURL error:nil];
  XCTAssertNotNil(thumbio);
  
  NgImageProperties * thumbprops = [thumbio properties];
  XCTAssertEqualObjects([thumbprops UTI], (__bridge NSString *)kUTTypeJPEG);
  XCTAssertEqual([thumbprops framesCount], 1);
  XCTAssertEqual([thumbprops scale], 1.f);
  XCTAssertEqual([thumbprops orientation], UIImageOrientationUp);
  XCTAssertEqualObjects([NSValue valueWithCGSize:[thumbprops pixel]], [NSValue valueWithCGSize:CGSizeMake(48, 48)]);

}
@end
