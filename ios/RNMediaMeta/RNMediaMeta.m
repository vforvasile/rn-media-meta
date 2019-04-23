#import "RNMediaMeta.h"

static NSArray *metadatas;
@implementation RNMediaMeta

- (NSArray *)metadatas
{
  if (!metadatas) {
    metadatas = @[
      @"albumName",
      @"artist",
      @"comment",
      @"copyrights",
      @"creationDate",
      @"date",
      @"encodedby",
      @"genre",
      @"language",
      @"location",
      @"lastModifiedDate",
      @"performer",
      @"publisher",
      @"title"
    ];
  }
  return metadatas;
}

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_queue_create("com.mybigday.rn.MediaMetaQueue", DISPATCH_QUEUE_SERIAL);
}

RCT_EXPORT_METHOD(get:(NSString *)path
                  withOptions:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSFileManager *fileManager = [NSFileManager defaultManager];

  BOOL isDir;
  if (![fileManager fileExistsAtPath:path isDirectory:&isDir] || isDir){
    NSError *err = [NSError errorWithDomain:@"file not found" code:-15 userInfo:nil];
    reject([NSString stringWithFormat: @"%lu", (long)err.code], err.localizedDescription, err);
    return;
  }

  NSMutableDictionary *result = [NSMutableDictionary new];
  NSDictionary *assetOptions = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:assetOptions];

  NSArray *keys = [NSArray arrayWithObjects:@"commonMetadata", nil];
  [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
    // string keys
    for (NSString *key in [self metadatas]) {
      NSArray *items = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                    withKey:key
                                                    keySpace:AVMetadataKeySpaceCommon];
      for (AVMetadataItem *item in items) {
        [result setObject:item.value forKey:key];
      }
    }

    if (options[@"getThumb"]) {
      UIImage *thumbnail;
      CGImageRef imageRef;
      NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                        withKey:AVMetadataCommonKeyArtwork
                                                        keySpace:AVMetadataKeySpaceCommon];
      if (artworks) {
        // artwork thumb
        for (AVMetadataItem *item in artworks) {
          thumbnail = [UIImage imageWithData:item.value];
        }
      } else {
        // video frame thumb
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMake(0, 600);
        imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        thumbnail = [UIImage imageWithCGImage:imageRef];

        if (thumbnail) {
          // return the video dimensions
          [result setObject:@(thumbnail.size.width) forKey:@"width"];
          [result setObject:@(thumbnail.size.height) forKey:@"height"];
        }

        // return the video duration
        [result setObject:@((CMTimeGetSeconds(asset.duration) * 1000)) forKey:@"duration"];
      }

      // resize thumbnail data and return
      if (thumbnail) {
        // resize image
        float actualHeight = thumbnail.size.height;
        float actualWidth = thumbnail.size.width;
        NSNumber *maxHeightNumber = [options valueForKey:@"thumbMaxHeight"];
        float maxHeight = [maxHeightNumber floatValue];
        NSNumber *maxWidthNumber = [options valueForKey:@"thumbMaxWidth"];
        float maxWidth = [maxWidthNumber floatValue];
        float imgRatio = actualWidth/actualHeight;
        float maxRatio = maxWidth/maxHeight;
        NSNumber *thumbCompressionNumber = [options valueForKey:@"thumbCompression"];
        float compressionQuality = [thumbCompressionNumber floatValue];

        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
          if(imgRatio < maxRatio)
          {
              //adjust width according to maxHeight
              imgRatio = maxHeight / actualHeight;
              actualWidth = imgRatio * actualWidth;
              actualHeight = maxHeight;
          }
          else if(imgRatio > maxRatio)
          {
              //adjust height according to maxWidth
              imgRatio = maxWidth / actualWidth;
              actualHeight = imgRatio * actualHeight;
              actualWidth = maxWidth;
          }
          else
          {
              actualHeight = maxHeight;
              actualWidth = maxWidth;
          }
        }

        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [thumbnail drawInRect:rect];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

        NSData *imageData;
        if (options[@"thumbFormatAsJPG"]) {
          imageData = UIImageJPEGRepresentation(img, compressionQuality);
        } else {
          imageData = UIImagePNGRepresentation(img);
        }

        UIGraphicsEndImageContext();

        NSString *data = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

        [result setObject:data
                  forKey:@"thumb"];
        [result setObject:data
                  forKey:@"thumbTest"];
      }
      CGImageRelease(imageRef);
    }

    resolve(result);
  }];
}

@end
