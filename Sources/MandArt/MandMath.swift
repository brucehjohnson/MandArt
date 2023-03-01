import CoreGraphics // CG Color
/**
 MandMath

 This is a Swift class that provides operations for MandArt.

 The operations are written in pure Swift,
 which allows for decoupling from SwiftUI and facilitates deploying in other ways.

 */
import Foundation

// set class/static constants first
// These are the same for every instance of MandMath

let windowGroupName: String = "Welcome to MandArt"
let defaultFileName: String = "default.mandart"

enum MandMath {
  // Define static functions below.................
  // static functions are the same for every instance of MandMat

  /// Returns the name of the default document to show when the app first starts up
  ///
  /// - Returns: a simple filename (e.g. "default.mandart")
  ///
  static func getDefaultDocumentName() -> String {
    defaultFileName
  }

  /// Returns the title/name of the window group
  ///
  /// - Returns: a simple window group title  (e.g. "Welcome to MandArt")
  ///
  static func getWindowGroupName() -> String {
    windowGroupName
  }

  /// Determines the printability of a given list of `Hue` objects.
  ///
  /// - Parameter hues: A list of `Hue` objects.
  /// - Returns: An array of Booleans indicating the printability of each `Hue` object.
  ///
  ///
  @available(macOS 12.0, *)
  static func getCalculatedPrintabilityOfHues(hues: [Hue]) -> [Bool] {
    // Map `hues` array to an array of booleans,
    // indicating the printability of each `Hue` object
    let boolList = hues.map { isColorPrintableByCalculation(color: $0.color.cgColor!, num: $0.num) }
    return boolList
  }

  /// Determines the printability of a list of hues.
  ///
  /// - Parameters:
  ///   - hues: An array of `Hue` objects to be evaluated for printability.
  ///
  /// - Returns: An array of booleans indicating whether each color in the `hues` array is
  ///   printable or not, as determined by the `isColorInPrintableList` function.
  ///
  /// # Example Usage:
  ///
  ///     let hues: [Hue] = [ ... ]
  ///     let printability = getListPrintabilityOfHues(hues: hues)
  ///
  ///  The static keyword in front of the func keyword
  ///  means this function is a "static function".
  ///  A static function is a function that belongs to the type itself,
  ///  rather than to instances of that type  -
  ///  no need to create an instance of MandMath to call this function.
  ///
  @available(macOS 12.0, *)
  static func getListPrintabilityOfHues(hues: [Hue]) -> [Bool] {
    // the result of the map function applied to the hues array.
    // The map function takes a closure (an anonymous function)
    // as its argument and applies it to each element of the hues array.
    let boolList = hues.map {
      isColorInPrintableList(
        color: $0.color.cgColor!,
        num: $0.num
      )
    }
    return boolList
  }

  /// Returns a boolean array indicating if the closest printable color of each hue in the `hues` array
  /// is present in the `MandMath.printableColorList`.
  ///
  /// - Parameter hues: An array of `Hue` objects.
  /// - Returns: An array of booleans, indicating if the closest printable color of each hue
  /// in the `hues` array is present in the `MandMath.printableColorList`.
  ///
  @available(macOS 12.0, *)
  static func getClosestPrintableColors(hues: [Hue]) -> [Bool] {
    // Map over each hue in the `hues` array,
    // and find the closest printable color
    return hues.map {
      let closestColors = getPrintableColorsWithMinimumDistance(
        color: $0.color.cgColor!,
        num: $0.num
      )

      // Return whether the closest color is present in `MandMath.printableColorList`
      return closestColors.contains {
        color in MandMath.printableColorList.contains(color)
      }
    }
  }

  /// Returns an array of printable color options from `MandMath.printableColorList`.
  ///
  /// - Parameter hue: A `Hue` object.
  /// - Returns: An array of CGColors  in the `MandMath.printableColorList`.
  ///
  @available(macOS 12.0, *)
  static func getPrintableOptions(hue: Hue) -> [CGColor] {
    let closestColorsAsInts = self.getPrintableColorsWithMinimumDistance(
      color: hue.color.cgColor!,
      num: hue.num
    )
    // Convert the array of [[r,g,b]] to an array of CGColor
    let closestColors = closestColorsAsInts.map { colorAsInts in
      let components = colorAsInts.map { CGFloat($0) / 255.0 }
      return CGColor(srgbRed: components[0], green: components[1], blue: components[2], alpha: 1.0)
    }
    return closestColors
  }

  /// Calculates the closest printable colors to a given color.
  ///
  /// - Parameters:
  ///   - color: The `CGColor` for which to determine the closest printable colors.
  ///   - num: An integer representing the number of the color being processed.
  ///
  /// - Returns: An array of arrays of integers representing the closest printable colors
  ///   to the input `color`.
  ///
  ///
  static func getPrintableColorsWithMinimumDistance(color: CGColor, num: Int)
    -> [[Int]] {
    guard let components = color.components else {
      // return an empty array if the color components cannot be retrieved
      return []
    }

    // extract the red, green, and blue components of the color
    let r = components[0]
    let g = components[1]
    let b = components[2]

    // convert the floating-point components to integers in the range 0-255
    let red = Int(round(r * 255.0))
    let green = Int(round(g * 255.0))
    let blue = Int(round(b * 255.0))

    // format the color components for printing
    let rr = self.padIntToThreeCharacters(number: red)
    let gg = self.padIntToThreeCharacters(number: green)
    let bb = self.padIntToThreeCharacters(number: blue)
    print("Color Number \(num)(\(rr)-\(gg)-\(bb)): Checking for closest")

    // calculate distances between the input color and each printable color
    let distances = MandMath.printableColorList.map { color -> Int in
      let rDiff = color[0] - red
      let gDiff = color[1] - green
      let bDiff = color[2] - blue
      return rDiff * rDiff + gDiff * gDiff + bDiff * bDiff
    }

    // find the printable color with the minimum distance to the input color
    let minDistance = distances.min()!
    let nearest = MandMath.printableColorList.enumerated()
      .filter { _, value -> Bool in
        let rDiff = value[0] - red
        let gDiff = value[1] - green
        let bDiff = value[2] - blue
        return rDiff * rDiff + gDiff * gDiff + bDiff * bDiff == minDistance
      }.map(\.element)

    for item in nearest {
      print("    closest:\(item)\n")
    }
    // return the closest printable color(s)
    return nearest
  }

  static func getMinimumDistance(color: CGColor, num _: Int) -> Int {
    guard let components = color.components else {
      return 100
    }

    // extract the red, green, and blue components of the color
    let r = components[0]
    let g = components[1]
    let b = components[2]

    // convert the floating-point components to integers in the range 0-255
    let red = Int(round(r * 255.0))
    let green = Int(round(g * 255.0))
    let blue = Int(round(b * 255.0))

    // calculate distances between the input color and each printable color
    let distances = MandMath.printableColorList.map { entry -> Int in
      let rDiff = entry[0] - red
      let gDiff = entry[1] - green
      let bDiff = entry[2] - blue
      let distance = rDiff * rDiff + gDiff * gDiff + bDiff * bDiff
      return distance
    }
    let minDistance = Int(distances.min()!)
    return minDistance
  }

  /// Function to check if a color is in the printable color list.
  ///
  /// - Parameters:
  ///   - color: The `CGColor` object representing the color to check.
  ///   - num: An integer representing the color number.
  ///
  /// - Returns:
  ///   - A boolean value indicating if the color is in the printable color list or not.
  static func isColorInPrintableList(color: CGColor, num _: Int) -> Bool {
    // Check if the components of the CGColor object can be accessed.
    guard let components = color.components else { return false }

    // Extract the red, green, and blue components from the CGColor object.
    let r = components[0]
    let g = components[1]
    let b = components[2]

    // Convert red, green, and blue components
    // to integer values between 0 and 255.
    let red = Int(round(r * 255.0))
    let green = Int(round(g * 255.0))
    let blue = Int(round(b * 255.0))

    // Check if [red, green, blue] values are in the printable color list.
    let inList = MandMath.printableColorList.contains([red, green, blue])
    return inList
  }

  static func isColorNearPrintableList(color: CGColor, num: Int) -> Bool {
    // Check if the components of the CGColor object can be accessed.
    guard let components = color.components else { return false }

    // Extract the red, green, and blue components from the CGColor object.
    let r = components[0]
    let g = components[1]
    let b = components[2]

    // Convert red, green, and blue components
    // to integer values between 0 and 255.
    let red = Int(round(r * 255.0))
    let green = Int(round(g * 255.0))
    let blue = Int(round(b * 255.0))

    // Check if [red, green, blue] values are in the printable color list.
    let inList = MandMath.printableColorList.contains([red, green, blue])

    if inList {
      return true
    }
    // otherwise, check minimum distance to see if close enough
    let minDistance = MandMath.getMinimumDistance(color: color, num: num)
    let limit = 33 * 33
    if minDistance <= limit {
      return true
    } else {
      return false
    }
  }

  /// Get a display indicator for the color row
  /// to indicate if this color is likely to print well
  /// Or if the printed color may be different than
  /// what appears on screen.
  ///
  ///  Function is in MandMath which knows about all colors.
  ///  Hue class only knows about one color.
  func isPrintableDisplayText(color: CGColor, num: Int) -> String {
    if MandMath.isColorInPrintableList(color: color, num: num) {
      return " "
    } else {
      return "!"
    }
  }

  /// Decomposes a CGColor into its
  /// red, green, and blue components,
  /// and returns true if all of them are between 0 and 1, inclusive.
  ///
  /// This indicates that the color is printable,
  /// as the RGB color space used by Core Graphics uses
  /// values between 0 and 1 to represent color intensity.
  ///
  /// - Parameter: CGColor
  /// - Returns:boolean true if printable
  static func isColorPrintableByCalculation(color: CGColor, num: Int) -> Bool {
    guard let components = color.components else { return false }
    let r = components[0]
    let g = components[1]
    let b = components[2]

    let isPrintable = r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1

    let red = Int(round(r * 255.0))
    let green = Int(round(g * 255.0))
    let blue = Int(round(b * 255.0))
    print(num, red, green, blue)

    let rr = self.padIntToThreeCharacters(number: red)
    let gg = self.padIntToThreeCharacters(number: green)
    let bb = self.padIntToThreeCharacters(number: blue)

    print("Color Number \(num)(\(rr)-\(gg)-\(bb)): calculated printable: ", isPrintable)
    return isPrintable
  }

  /// This function formats the input number to a string with three characters.
  ///
  /// - Parameters:
  ///   - number: The input integer to format.
  ///
  /// - Returns: The formatted string with three characters.
  ///
  /// Example:
  ///
  ///     let result = padIntToThreeCharacters(number: 123)
  ///     print(result) // Output: "123"
  static func padIntToThreeCharacters(number: Int) -> String {
    String(format: "%03d", number)
  }

  static func getPrintableCGColorList() -> [CGColor] {
    let lst = MandMath.printableColorList.map { colorValues in
      let red = CGFloat(colorValues[0]) / 255.0
      let green = CGFloat(colorValues[1]) / 255.0
      let blue = CGFloat(colorValues[2]) / 255.0
      return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    return lst
  }

  static func getPrintableCGColorListSorted(iSort: Int) -> [CGColor] {
    var lst: [CGColor] = []
    switch iSort {
    case 0: // rgb
      lst = MandMath.printableColorListRGB.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    case 1: // rbg
      lst = MandMath.printableColorListRBG.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    case 2: // grb
      lst = MandMath.printableColorListGRB.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    case 3: // gbr
      lst = MandMath.printableColorListGBR.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    case 4: // brg
      lst = MandMath.printableColorListBRG.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    default: // bgr
      lst = MandMath.printableColorListBGR.map { colorValues in
        let red = CGFloat(colorValues[0]) / 255.0
        let green = CGFloat(colorValues[1]) / 255.0
        let blue = CGFloat(colorValues[2]) / 255.0
        return CGColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    }
    return lst
  }

  ///  Get ALL screen colors to display as little squares
  ///  Parameter: iSort indicates the order to present the colors
  ///  iSort:
  ///  0 = rgb, 1 = rbg
  ///  2 = grb, 3 = gbr
  ///  4 = brg, 5 = bgr
  static func getAllCGColorsList(iSort: Int) -> [CGColor] {
    var allColors: [CGColor] = []
    switch iSort {
    case 0: // rgb
      for r in self.colorInts {
        for g in self.colorInts {
          for b in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    case 1: // rbg
      for r in self.colorInts {
        for b in self.colorInts {
          for g in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    case 2: // grb
      for g in self.colorInts {
        for r in self.colorInts {
          for b in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    case 3: // gbr
      for g in self.colorInts {
        for b in self.colorInts {
          for r in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    case 4: // brg
      for b in self.colorInts {
        for r in self.colorInts {
          for g in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    default: // bgr
      for b in self.colorInts {
        for g in self.colorInts {
          for r in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            allColors.append(color)
          }
        }
      }
    }
    return allColors
  }

  ///  Get ALL PRINTABLE  colors to display as little squares
  ///  If a screen color is NOT printable, it will be replaced with a white square
  ///  Parameter: iSort indicates the order to present the colors
  ///  iSort:
  ///  0 = rgb, 1 = rbg
  ///  2 = grb, 3 = gbr
  ///  4 = brg, 5 = bgr
  static func getAllPrintableCGColorsList(iSort: Int) -> [CGColor] {
    var allColors: [CGColor] = []
    switch iSort {
    case 0: // rgb
      for r in self.colorInts {
        for g in self.colorInts {
          for b in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    case 1: // rbg
      for r in self.colorInts {
        for b in self.colorInts {
          for g in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    case 2: // grb
      for g in self.colorInts {
        for r in self.colorInts {
          for b in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    case 3: // gbr
      for g in self.colorInts {
        for b in self.colorInts {
          for r in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    case 4: // brg
      for b in self.colorInts {
        for r in self.colorInts {
          for g in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    default: // bgr
      for b in self.colorInts {
        for g in self.colorInts {
          for r in self.colorInts {
            let red = round(CGFloat(r)) / 255.0
            let green = round(CGFloat(g)) / 255.0
            let blue = round(CGFloat(b)) / 255.0
            let color = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
            if MandMath.isColorInPrintableList(color: color, num: 1) {
              allColors.append(color)
            } else {
              allColors.append(CGColor.white)
            }
          }
        }
      }
    }
    return allColors
  }

  static let colorInts = [0, 36, 73, 109, 146, 182, 219, 255]

  static let printableColorListRGB = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[0] != rhs[0] {
      // Sort by first column red
      return lhs[0] < rhs[0]
    } else if lhs[1] != rhs[1] {
      // Sort by second column
      return lhs[1] < rhs[1]
    } else {
      // Sort by third column
      return lhs[2] < rhs[2]
    }
  }

  static let printableColorListRBG = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[0] != rhs[0] {
      // Sort by first column red
      return lhs[0] < rhs[0]
    } else if lhs[2] != rhs[2] {
      // Sort by third column
      return lhs[2] < rhs[2]
    } else {
      // Sort by second column
      return lhs[1] < rhs[1]
    }
  }

  static let printableColorListGRB = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[1] != rhs[1] {
      // Sort by second column green
      return lhs[1] < rhs[1]
    } else if lhs[0] != rhs[0] {
      // sort by first
      return lhs[0] < rhs[0]
    } else {
      // Sort by third
      return lhs[2] < rhs[2]
    }
  }

  static let printableColorListGBR = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[1] != rhs[1] {
      // Sort by second column green
      return lhs[1] < rhs[1]
    } else if lhs[2] != rhs[2] {
      // sort by third
      return lhs[2] < rhs[2]
    } else {
      // Sort by first
      return lhs[0] < rhs[0]
    }
  }

  static let printableColorListBRG = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[2] != rhs[2] {
      // Sort by third column blue
      return lhs[2] < rhs[2]
    } else if lhs[0] != rhs[0] {
      // sort by first
      return lhs[0] < rhs[0]
    } else {
      // Sort by second
      return lhs[1] < rhs[1]
    }
  }

  static let printableColorListBGR = printableColorList.sorted { lhs, rhs -> Bool in
    if lhs[2] != rhs[2] {
      // Sort by third column blue
      return lhs[2] < rhs[2]
    } else if lhs[1] != rhs[1] {
      // sort by second
      return lhs[1] < rhs[1]
    } else {
      // Sort by first
      return lhs[0] < rhs[0]
    }
  }

  /// MandMath keeps a list of known printable colors
  ///
  /// # Example Usage:
  ///
  ///     let lst = MandMath.printableColorList
  ///
  static let printableColorList = [
    [0, 73, 36],
    [0, 73, 73],
    [0, 73, 109],
    [0, 73, 146],
    [0, 109, 73],
    [0, 109, 109],
    [0, 109, 146],
    [0, 109, 182],
    [0, 146, 73],
    [0, 146, 109],
    [0, 146, 146],
    [0, 146, 182],
    [0, 182, 73],
    [0, 182, 109],
    [0, 182, 146],
    [0, 182, 182],
    [36, 36, 109],
    [36, 73, 36],
    [36, 73, 73],
    [36, 73, 109],
    [36, 73, 146],
    [36, 109, 0],
    [36, 109, 36],
    [36, 109, 73],
    [36, 109, 109],
    [36, 109, 146],
    [36, 109, 182],
    [36, 146, 0],
    [36, 146, 36],
    [36, 146, 73],
    [36, 146, 109],
    [36, 146, 146],
    [36, 146, 182],
    [36, 146, 219],
    [36, 182, 73],
    [36, 182, 109],
    [36, 182, 146],
    [36, 182, 182],
    [36, 182, 219],
    [36, 219, 182],
    [36, 219, 219],
    [73, 0, 109],
    [73, 36, 109],
    [73, 36, 146],
    [73, 73, 0],
    [73, 73, 36],
    [73, 73, 73],
    [73, 73, 109],
    [73, 73, 146],
    [73, 73, 182],
    [73, 109, 0],
    [73, 109, 36],
    [73, 109, 73],
    [73, 109, 109],
    [73, 109, 146],
    [73, 109, 182],
    [73, 109, 219],
    [73, 146, 0],
    [73, 146, 36],
    [73, 146, 73],
    [73, 146, 109],
    [73, 146, 146],
    [73, 146, 182],
    [73, 146, 219],
    [73, 182, 0],
    [73, 182, 36],
    [73, 182, 73],
    [73, 182, 109],
    [73, 182, 146],
    [73, 182, 182],
    [73, 182, 219],
    [73, 219, 182],
    [73, 219, 219],
    [73, 219, 255],
    [109, 0, 0],
    [109, 0, 36],
    [109, 0, 73],
    [109, 0, 109],
    [109, 0, 146],
    [109, 0, 182],
    [109, 36, 0],
    [109, 36, 36],
    [109, 36, 73],
    [109, 36, 109],
    [109, 36, 146],
    [109, 36, 182],
    [109, 73, 0],
    [109, 73, 36],
    [109, 73, 73],
    [109, 73, 109],
    [109, 73, 146],
    [109, 73, 182],
    [109, 109, 0],
    [109, 109, 36],
    [109, 109, 73],
    [109, 109, 109],
    [109, 109, 146],
    [109, 109, 182],
    [109, 146, 0],
    [109, 146, 36],
    [109, 146, 73],
    [109, 146, 109],
    [109, 146, 146],
    [109, 146, 182],
    [109, 146, 219],
    [109, 182, 0],
    [109, 182, 36],
    [109, 182, 73],
    [109, 182, 109],
    [109, 182, 146],
    [109, 182, 182],
    [109, 182, 219],
    [109, 182, 255],
    [109, 219, 109],
    [109, 219, 146],
    [109, 219, 182],
    [109, 219, 219],
    [109, 219, 255],
    [146, 0, 0],
    [146, 0, 36],
    [146, 0, 73],
    [146, 0, 109],
    [146, 0, 146],
    [146, 36, 0],
    [146, 36, 36],
    [146, 36, 73],
    [146, 36, 109],
    [146, 36, 146],
    [146, 73, 0],
    [146, 73, 36],
    [146, 73, 73],
    [146, 73, 109],
    [146, 73, 146],
    [146, 109, 0],
    [146, 109, 36],
    [146, 109, 73],
    [146, 109, 109],
    [146, 109, 146],
    [146, 109, 182],
    [146, 146, 0],
    [146, 146, 36],
    [146, 146, 73],
    [146, 146, 109],
    [146, 146, 146],
    [146, 146, 182],
    [146, 146, 219],
    [146, 182, 0],
    [146, 182, 36],
    [146, 182, 73],
    [146, 182, 109],
    [146, 182, 146],
    [146, 182, 182],
    [146, 182, 219],
    [146, 219, 36],
    [146, 219, 73],
    [146, 219, 109],
    [146, 219, 146],
    [146, 219, 182],
    [146, 219, 219],
    [146, 219, 255],
    [182, 0, 0],
    [182, 0, 36],
    [182, 0, 73],
    [182, 0, 109],
    [182, 0, 146],
    [182, 36, 0],
    [182, 36, 36],
    [182, 36, 73],
    [182, 36, 109],
    [182, 36, 146],
    [182, 73, 0],
    [182, 73, 36],
    [182, 73, 73],
    [182, 73, 109],
    [182, 73, 146],
    [182, 109, 0],
    [182, 109, 36],
    [182, 109, 73],
    [182, 109, 109],
    [182, 109, 146],
    [182, 109, 182],
    [182, 146, 0],
    [182, 146, 36],
    [182, 146, 73],
    [182, 146, 109],
    [182, 146, 146],
    [182, 146, 182],
    [182, 146, 219],
    [182, 182, 0],
    [182, 182, 36],
    [182, 182, 73],
    [182, 182, 109],
    [182, 182, 146],
    [182, 182, 182],
    [182, 182, 219],
    [182, 219, 0],
    [182, 219, 36],
    [182, 219, 73],
    [182, 219, 109],
    [182, 219, 146],
    [182, 219, 182],
    [182, 219, 219],
    [182, 219, 255],
    [182, 255, 255],
    [219, 0, 0],
    [219, 0, 36],
    [219, 0, 73],
    [219, 0, 109],
    [219, 0, 146],
    [219, 36, 0],
    [219, 36, 36],
    [219, 36, 73],
    [219, 36, 109],
    [219, 36, 146],
    [219, 73, 0],
    [219, 73, 36],
    [219, 73, 73],
    [219, 73, 109],
    [219, 73, 146],
    [219, 109, 0],
    [219, 109, 36],
    [219, 109, 73],
    [219, 109, 109],
    [219, 109, 146],
    [219, 109, 182],
    [219, 146, 0],
    [219, 146, 36],
    [219, 146, 73],
    [219, 146, 109],
    [219, 146, 146],
    [219, 146, 182],
    [219, 146, 219],
    [219, 182, 0],
    [219, 182, 36],
    [219, 182, 73],
    [219, 182, 109],
    [219, 182, 146],
    [219, 182, 182],
    [219, 182, 219],
    [219, 219, 0],
    [219, 219, 36],
    [219, 219, 73],
    [219, 219, 109],
    [219, 219, 146],
    [219, 219, 182],
    [219, 219, 219],
    [219, 219, 255],
    [219, 255, 73],
    [219, 255, 109],
    [219, 255, 146],
    [219, 255, 182],
    [219, 255, 219],
    [219, 255, 255],
    [255, 36, 73],
    [255, 36, 109],
    [255, 73, 73],
    [255, 73, 109],
    [255, 109, 0],
    [255, 109, 36],
    [255, 109, 73],
    [255, 109, 109],
    [255, 109, 146],
    [255, 146, 0],
    [255, 146, 36],
    [255, 146, 73],
    [255, 146, 109],
    [255, 146, 146],
    [255, 146, 182],
    [255, 146, 219],
    [255, 182, 0],
    [255, 182, 36],
    [255, 182, 73],
    [255, 182, 109],
    [255, 182, 146],
    [255, 182, 182],
    [255, 182, 219],
    [255, 219, 0],
    [255, 219, 36],
    [255, 219, 73],
    [255, 219, 109],
    [255, 219, 146],
    [255, 219, 182],
    [255, 219, 219],
    [255, 219, 255],
    [255, 255, 0],
    [255, 255, 36],
    [255, 255, 73],
    [255, 255, 109],
    [255, 255, 146],
    [255, 255, 182],
    [255, 255, 219],
    [255, 255, 255],
  ]
}
