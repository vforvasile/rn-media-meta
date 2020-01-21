import { NativeModules } from 'react-native'

const { RNMediaMeta } = NativeModules

export default {
  get(path, options) {
    return RNMediaMeta.get(path, {
      getThumb: true,
      thumbFormatAsJPG: true,
      thumbCompression: 0.5, // 50 percent compression
      thumbMaxWidth: 300,
      thumbMaxHeight: 300,
      ...options,
    })
  },
}
