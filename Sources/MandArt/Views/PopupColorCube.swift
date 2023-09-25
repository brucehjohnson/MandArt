import Foundation
import SwiftUI

struct PopupColorCube: View {

  @ObservedObject var doc: MandArtDocument
  @ObservedObject var popupManager: PopupManager
  @State var selectedColor: (r: Int, g: Int, b: Int)?

  var hues: [Hue]

  init(
    doc: MandArtDocument,
    popupManager: PopupManager,
    hues: [Hue]
  ) {
    self.doc = doc
    self.popupManager = popupManager
    self.hues = hues
  }

  var body: some View {
    ZStack(alignment: .top) {
      Color.white
        .opacity(0.5)
        .edgesIgnoringSafeArea(.all)

      VStack {
        HStack(alignment: .bottom) {
          closeButton

          Text("Click to add a color to your list. Showing Color Cube.")

          if let selected = selectedColor {
            Text("Added: (\(selected.r), \(selected.g), \(selected.b))")

          }
        }
        colorCubeContent
      }
      .padding()
      .background(Color.white)
      .cornerRadius(8)
      .shadow(radius: 10)
      .padding()
    }
    .padding()
  }

  private var closeButton: some View {
    Button(action: {
      popupManager.showingCube = .None
    }) {
      Image(systemName: "xmark.circle")
    }
    .padding(.top, 10)
  }

  private var colorCubeContent: some View {
    VStack(spacing: 10) {
      ForEach(0..<2, id: \.self) { rowIndex in
        HStack(spacing: 10) {
          ForEach(0..<4, id: \.self) { columnIndex in
            let sliceIndex = rowIndex * 4 + columnIndex
            let start = sliceIndex * 8 * 8
            // -1 to correctly end at the last index of the slice
            let end = (sliceIndex + 1) * 8 * 8 - 1
            PopupColorSlice(doc: doc, selectedColor: $selectedColor, arrColors: currentColors, start: start, end: end)
          }
        }
      }
    }
    .padding(.top, 2)
  }

  private func getColors(from cgColors: [CGColor]) -> [Color] {
    return cgColors.map { Color($0) }
  }

  private var currentColors: [Color] {
    switch popupManager.showingCube {
      case .AllRed:
        return getColors(from: MandMath.getAllCGColorsList(iSort: 6))
      case .AllGreen:
        return getColors(from: MandMath.getAllCGColorsList(iSort: 8))
      case .AllBlue:
        return getColors(from: MandMath.getAllCGColorsList(iSort: 7))
      case .APRed:
        return getColors(from: MandMath.getAllPrintableCGColorsList(iSort: 6))
      case .APGreen:
        return getColors(from: MandMath.getAllPrintableCGColorsList(iSort: 8))
      case .APBlue:
        return getColors(from: MandMath.getAllPrintableCGColorsList(iSort: 7))
      case .None:
        return []
    }
  }
}
