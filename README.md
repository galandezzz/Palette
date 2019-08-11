# Palette

Color palette generation from image written in Swfit.

## Installation

**Cocoapods:**

`pod 'Palette', :git => 'https://github.com/galandezzz/ios-Palette.git'`

**Carthage:**

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
let palette = Palette.from(image: YOUR_IMAGE).generate()
view.backgroundColor = palette.vibrantColor
```

or simply

```
view.backgroundColor = YOUR_IMAGE.createPalette().vibrantColor
```

### Asynchornous Palette generation

```
Palette.from(image: YOUR_IMAGE).generate { view.backgroundColor = $0.vibrantColor }
```

or using extension on `UIImage`

```
YOUR_IMAGE.createPalette { view.backgroudColor = $0.vibrantColor }
```

## License

Palette is available under the MIT license. See the LICENSE file for more info.
