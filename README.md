# React Native Media Meta [![NPM version](http://img.shields.io/npm/v/react-native-media-meta.svg?style=flat)](https://www.npmjs.com/package/react-native-media-meta)

> Get media file metadata in your React Native app

## Installation

```bash
$ npm install react-native-media-meta --save
$ react-native link
```

## Usage

```js
import MediaMeta from 'react-native-media-meta';
const path = '<your file path here>';

MediaMeta.get(path)
  .then(metadata => console.log(metadata))
  .catch(err => console.error(err));
```

## API

#### `MediaMeta.get(path, options)` - Promise

Options: Object
* `getThumb` - Boolean, if false no thumb is returned.
* `thumbFormatAsJPG` - Boolean, if false PNG format is returned.
* `thumbCompression` - Float eg 0.5.  If thumbFormatAsJPG, this compression is used.
* `thumbMaxWidth` - the max thumbnail width in pixels.
* `thumbMaxHeight` - the max thumbnail height in pixels.

Resolve: Object - included following keys (If it's found)
* `thumb` - Base64 image string (video: get first frame, audio: get artwork if exist)
* `duration` (video only)
* `width` - the thumb width
* `height` - the thumb height
* Others:

__*[Android]*__ We using [FFmpegMediaMetadataRetriever](https://github.com/wseemann/FFmpegMediaMetadataRetriever), see [RNMediaMeta.java#L36](android/src/main/java/com/mybigday/rn/RNMediaMeta.java#L36) for more information.
__*[iOS]*__ We using [official AVMatadataItem](https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVFoundationMetadataKeyReference/#//apple_ref/doc/constant_group/Common_Metadata_Keys), see [RNMediaMeta.m#L9](ios/RNMediaMeta/RNMediaMeta.m#L9) for more information.

## License

[MIT](LICENSE.md)
