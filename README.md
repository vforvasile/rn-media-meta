# React Native Media Meta

Fork from react-native-media-meta o support Pods and RN 0.60+ installs

> Get media file metadata in your React Native app

## Installation

```bash
$ npm install rn-media-meta --save
$ react-native link rn-media-meta and remove Android linking
```

or add into your Podfile this line an skip linking
`pod 'rn-media-meta', :path => '../node_modules/rn-media-meta'`

## Usage

```js
import MediaMeta from "rn-media-meta";
const path = "<your file path here>";

//first option
MediaMeta.get(path)
  .then(metadata => console.log(metadata))
  .catch(err => console.error(err));

//second option:
try {
  const data = await MediaMeta.get(path);
  console.log(data);
} catch (error) {
  console.log(error);
}
```

## API

#### `MediaMeta.get(path, options)` - Promise

Options: Object

- `getThumb` - Boolean, if false no thumb is returned.
- `thumbFormatAsJPG` - Boolean, if false PNG format is returned.
- `thumbCompression` - Float eg 0.5. If thumbFormatAsJPG, this compression is used.
- `thumbMaxWidth` - the max thumbnail width in pixels.
- `thumbMaxHeight` - the max thumbnail height in pixels.

Resolve: Object - included following keys (If it's found)

- `thumb` - Base64 image string (video: get first frame, audio: get artwork if exist)
- `duration` (video only)
- `width` - the thumb width
- `height` - the thumb height
- Others:

**_[Android]_** We using [FFmpegMediaMetadataRetriever](https://github.com/wseemann/FFmpegMediaMetadataRetriever), see [RNMediaMeta.java#L36](android/src/main/java/com/mybigday/rn/RNMediaMeta.java#L36) for more information.
**_[iOS]_** We using [official AVMatadataItem](https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVFoundationMetadataKeyReference/#//apple_ref/doc/constant_group/Common_Metadata_Keys), see [RNMediaMeta.m#L9](ios/RNMediaMeta/RNMediaMeta.m#L9) for more information.

## License

[MIT](LICENSE.md)
