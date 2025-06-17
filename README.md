# Palette

Color palette generation from image written in Swift.

## Installation

**[Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)**

To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter its repository URL: [https://github.com/galandezzz/Palette](https://github.com/galandezzz/Palette)

**[Cocoapods](https://guides.cocoapods.org/using/using-cocoapods.html)**

`pod 'Palette', :git => 'https://github.com/galandezzz/Palette.git'`

**[Carthage](https://guides.cocoapods.org/using/using-cocoapods.html)**

`github "galandezzz/Palette" ~> 1.0`

## Usage

### Targets

There are six built-in targets for palette generation:

- Light vibrant
- Vibrant
- Dark vibrant
- Light muted
- Muted
- Dark muted


You can also create your own targets using `Target.Builder` class:
```
let target = Target.Builder()
                .with(targetSaturation: 0.7)
                .with(targetLightness: 0.7)
                .build()
```

### Synchronous Palette generation

```
let palette = Palette.from(image: YOUR_IMAGE).build()
view.backgroundColor = palette.vibrantColor
```

or simply

```
view.backgroundColor = YOUR_IMAGE.createPalette().vibrantColor
```

### Asynchornous Palette generation

```
// GCD variant
Palette.from(image: YOUR_IMAGE).build { view.backgroundColor = $0.vibrantColor }

// Swift Concurrency variant
view.backgroundColor = await Palette.from(image: YOUR_IMAGE).build().vibrantColor
```

or using extension on `UIImage`

```
// GCD variant
YOUR_IMAGE.createPalette { view.backgroudColor = $0.vibrantColor }

// Swift Concurrency variant
view.backgroundColor = await YOUR_IMAGE.createPalette().vibrantColor
```

## License

Palette is available under the MIT license. See the LICENSE file for more info.
