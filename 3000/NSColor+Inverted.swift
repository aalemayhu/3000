// https://stackoverflow.com/questions/2144979/is-there-a-conventional-method-for-inverting-nscolor-values

import Cocoa

extension NSColor {
    func inverted() -> NSColor {
        return NSColor(calibratedRed: 0.5-redComponent,
                       green: 0.5-greenComponent,
                       blue: 0.5-blueComponent,
                       alpha: alphaComponent)
    }
}
