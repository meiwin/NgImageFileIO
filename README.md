[![Build Status](https://travis-ci.org/meiwin/NgImageFileIO.svg)](https://travis-ci.org/meiwin/NgImageFileIO)

# NgImageFileIO

Simple objective-c ImageIO wrapper for iOS and Mac.

## Adding to your project

If you are using CocoaPods, add to your Podfile:

```ruby
pod NgImageFileIO
```

To manually add to your projects:

1. Add `NgImageFileIO.h` and `NgImageFileIO.m` to your project.

## Features

`NgImageFileIO` provides convenience APIs to work with image file/data.

* Loading image metadata
* Creating thumbnail

When working with image file, loading metadata and creating thumbnail does not cause image to be loaded into memory - allowing working with big image files a lot more trivial.

## Usage

```objective-c

// url to image file
NSURL * url = [NSURL fileURLWithPath:@"path-to-image-file.nef"]; // nef - Nikon raw format

// create `NgImageFileIO` instance
// the method will return `nil` if file is not an image.
NSError * error = nil;
NgImageFileIO * io = [NgImageFileIO imageFileIOWithURL:url error:&error];

if (error) NSLog(@"Failed to load image file: %@", error);
else {
  NSURL * thumbUrl = [NSURL fileURLWithPath:@"path-to-thumb-file.jpg"];
  [io createThumbnailWithMaxSize:100 atURL:thumbUrl error:&error];
  if (error) NSLog(@"Failed to create thumbnail: %@", error);
}
```

