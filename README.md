# LDOTiledView

[![Version](https://img.shields.io/cocoapods/v/LDOTiledView.svg?style=flat)](https://cocoapods.org/pods/LDOTiledView)
[![License](https://img.shields.io/cocoapods/l/LDOTiledView.svg?style=flat)](https://cocoapods.org/pods/LDOTiledView)
[![Platform](https://img.shields.io/cocoapods/p/LDOTiledView.svg?style=flat)](https://cocoapods.org/pods/LDOTiledView)

![LDOTiledView demo](Screenshots/LDOTiledView.gif)

## Usage

- Add `LDOTiledView` to your view hierarchy (you probably want to embed it into a `UIScrollView`).
- Set `maximumZoomLevel`, `imageSize` and `tileSize` (details see below).
- Implement the only method of `LDOTiledViewDataSource`
  ```swift
  func tiledView(_ tiledView: LDOTiledView, tileForRow row: Int, column: Int, zoomLevel: Int) -> UIImage?
  ```

### Zoom Level vs Zoom Scale

A typical use case for `LDOTiledView` is to be able to zoom into an image. 
This is done by embedding it in a `UIScrollView`. 
However `UIScrollView.zoomScale` refers to the content size (as area) and thus grows exponentially.
Repeatadly doubling the size of an image, the zoom scale grows as follows: 1, 2, 4, 8.

`LDOTiledView` works with the more intuitive concept of zoom levels. 
In its smallest resolution an image is at zoom level 1. 
At twice the size it's at level 2, doubling the size again is level 3 and so on.
The zoom level grows linearly and at every level the image is twice as large as on the previous level.

### Image Size

The image size refers to the image dimensions in points at the smallest zoom level.

The following table illustrates the relationship between image size and zoom level.

| Zoom Level | Image Size [pt] | 2x Retina [px] | 3x Retina [px] |
|-----------:|----------------:|---------------:|---------------:|
|  1         | 410 x 890       | 820 x 1780     | 1230 x 2670    |
|  2         | 820 x 1780      | 1640 x 3560    | 2460 x 5340    |
|  3         | 1230 x 2670     | 2460 x 5340    | 3690 x 8010    |
|  4         | 1640 x 3560     | 3280 x 7120    | 4920 x 10680   |

That means to be able to zoom a full screen image on an iPhone Xs Max four times, you need a 52 MP source image.
In this example `maximumZoomLevel` would be 4 and `imageSize` would be 410 x 890.

### Tile Size

The general idea behind `CATiledLayer` and thus `LDOTiledView` is that instead of loading a huge image into memory at once, the image is split up in smaller sqares and only the squares that are currently visible are loaded.
That means no matter how large the image is, roughly the same number of small squares are loaded at any given time. As result the memory consumption is (nearly) constant and independant of the image dimensions.

The tile size specifies the size of the small squares you sliced your large image into. 
It is defined in points.
That means if you set your tile size to 256x256, your retina tiles have to be 512x512 px.
Consequently non-Retina, Retina and Super Retina images are sliced into the same number of tiles.

### Loading Tiles

A common complaint about the underlying `CATiledLayer` is that it sometimes displays black squares instead of image tiles.
In our experience, this is actually not a problem of `CATiledLayer`, but caused by a failing image load.
Sometimes `UIImage(named:)` will return `nil` if it's called too frequently. (This might be caused by the caching performed by `UIImage(named:)`, and the fact that the tile loading happens asynchronously.)
Loading the images as `Data` and creating the `UIImage` from that worked flawlessly for us. YMMV.

### Generating Tiles

While there are no strict requirements on how you create your image tiles, we included a small [Ruby script](gen_tiles.rb) to get you started.
It is based on [libvips](https://libvips.github.io/libvips/), so be sure to have that installed if you want to use it.

The script uses the input image for the largest zoom level at the highest scale (1x/2x/3x).
It then scales the image down for all smaller zoom levels and scales.

The tiles of the earth example were created with this command:

```bash
$ ./gen_tiles.rb Example/Demo\ Images/Earth/earth.jpg -scale 2 -scale 3 -levels 4
Level 1 image size: 450 x 450
```

Check `gen_tiles.rb --help` for more details.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

LDOTiledView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LDOTiledView'
```

## Author

Raschke & Ludwig GbR, https://www.lurado.com/

## License

LDOTiledView is available under the MIT license.
See the [LICENSE](LICENSE) file for more information.

## Credits

Inspired by and based on [JCTiledScrollView](https://github.com/jessedc/JCTiledScrollView).

The earth image in the example project comes from [NASA's earth observatory](https://earthobservatory.nasa.gov/images/84214/blue-marble-eastern-hemisphere): 
NASA Earth Observatory image by Robert Simmon, using Suomi NPP VIIRS imagery from NOAA's Environmental Visualization Laboratory. 
Suomi NPP is the result of a partnership between NASA, NOAA and the Department of Defense
