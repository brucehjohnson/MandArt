import SwiftUI
import UniformTypeIdentifiers

struct TabFind: View {
  @ObservedObject var doc: MandArtDocument
  @Binding var activeDisplayState: ActiveDisplayChoice
  @State private var scale: Double

  init(doc: MandArtDocument, activeDisplayState: Binding<ActiveDisplayChoice>) {
    self._doc = ObservedObject(initialValue: doc)
    self._activeDisplayState = activeDisplayState
    self._scale = State(initialValue: doc.picdef.scale)
  }

  func zoomIn() {
    scale *= 2.0
    doc.picdef.scale = scale
  }

  func zoomOut() {
    scale /= 2.0
    doc.picdef.scale = scale
  }

  func aspectRatio() -> Double {
    let h = Double(doc.picdef.imageHeight)
    let w = Double(doc.picdef.imageWidth)
    return max(h / w, w / h)
  }

  var body: some View {
    ScrollView {
      VStack {

        Section(header:
                  Text("Set Image Size")
          .font(.headline)
          .fontWeight(.medium)
          .padding(.bottom)
        ) {

          HStack {

            VStack {

              Text("Width, px:")
              Text("(imageWidth)")
              DelayedTextFieldInt(
                placeholder: "1100",
                value: $doc.picdef.imageWidth,
                formatter: MAFormatters.fmtImageWidthHeight
              )
              .textFieldStyle(.roundedBorder)
              .multilineTextAlignment(.trailing)
              .frame(maxWidth: 80)
              .padding(10)
              .help("Enter the width, in pixels, of the image.")
              .onChange(of: doc.picdef.imageWidth) { _ in
                print("onChange width")
                activeDisplayState = .MandArt
              }

            } // end vstack

            VStack {
              Text("Height, px")
              Text("(imageHeight)")
              DelayedTextFieldInt(
                placeholder: "1000",
                value: $doc.picdef.imageHeight,
                formatter: MAFormatters.fmtImageWidthHeight
              )
              .frame(maxWidth: 80)
              .padding(10)
              .help("Enter the height, in pixels, of the image.")
              .onChange(of: doc.picdef.imageHeight) { _ in
                print("onChange height")
                activeDisplayState = .MandArt
              }

            } // end vstack

            VStack {
              Text("Aspect")
              Text("ratio:")

              Text(String(format: "%.1f", aspectRatio()))
                .padding(1)
                .help("Calculated value of image width over image height.")
            }

          } // end hstack
        } // end section

        Divider()

        Section(
          header:
            Text("")
            .font(.headline)
            .fontWeight(.medium)
            .padding(.bottom)
        ) {

          HStack {
            VStack { // vertical container
              Text("Enter center x")
              Text("Between -2 and 2")
              Text("(xCenter)")
              DelayedTextFieldDouble(
                placeholder: "-0.75",
                value: $doc.picdef.xCenter,
                formatter: MAFormatters.fmtXY
              )
              .textFieldStyle(.roundedBorder)
              .multilineTextAlignment(.trailing)
              .frame(maxWidth: 170)
              .help(
                "Enter the x value in the Mandelbrot coordinate system for the center of the image."
              )
              .onChange(of: doc.picdef.xCenter) { _ in
                print("onChange x")
                activeDisplayState = .MandArt
              }
            } // end vstack

            VStack { //  vertical container
              Text("Enter center y")
              Text("Between -2 and 2")
              Text("(yCenter)")
              DelayedTextFieldDouble(
                placeholder: "0.0",
                value: $doc.picdef.yCenter,
                formatter: MAFormatters.fmtXY
              )
              .textFieldStyle(.roundedBorder)
              .multilineTextAlignment(.trailing)
              .frame(maxWidth: 170)
              .help(
                "Enter the Y value in the Mandelbrot coordinate system for the center of the image."
              )
              .onChange(of: doc.picdef.yCenter) { _ in
                print("onChange y")
                activeDisplayState = .MandArt
              }
            }
          } // end HStack for XY

          //  Show Row (HStack) of Scale Next

          HStack {
            VStack {
              Text("Rotate (º)")
                .help("Enter degress to rotate (theta).")

              DelayedTextFieldDouble(
                placeholder: "0",
                value: $doc.picdef.theta,
                formatter: MAFormatters.fmtRotationTheta
              )
              .textFieldStyle(.roundedBorder)
              .multilineTextAlignment(.trailing)
              .frame(maxWidth: 60)
              .help("Enter the angle to rotate the image counterclockwise, in degrees.")
              .onChange(of: doc.picdef.theta) { _ in
                print("onChange theta")
                activeDisplayState = .MandArt
              }
            }

            VStack {
              Text("Scale (scale)")
              DelayedTextFieldDouble(
                placeholder: "430",
                // value: $scale,
                value: $doc.picdef.scale,
                formatter: MAFormatters.fmtScale
              )
              .textFieldStyle(.roundedBorder)
              .multilineTextAlignment(.trailing)
              .frame(maxWidth: 180)
              .help("Enter the magnification (may take a while).")
              .onChange(of: doc.picdef.scale) { _ in
                print("onChange scale")
                activeDisplayState = .MandArt
              }
            }

            VStack {
              Text("Zoom")

              HStack {
                Button("+") { zoomIn() }
                  .help("Zoom in by factor of 2 (may take a while).")

                Button("-") { zoomOut() }
                  .help("Zoom out by factor of 2 (may take a while).")
              }
            }
          }

          //  Divider()

          HStack {
            Text("Sharpening (iterationsMax):")

            DelayedTextFieldDouble(
              placeholder: "10,000",
              value: $doc.picdef.iterationsMax,
              formatter: MAFormatters.fmtSharpeningItMax
            )
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .help(
              "Enter the maximum number of iterations for a given point in the image. A larger value will increase the resolution, but slow down the calculation."
            )
            .frame(maxWidth: 70)
            .onChange(of: doc.picdef.iterationsMax) { _ in
              print("onChange iterationsMax")
              activeDisplayState = .MandArt
            }
          }
          .padding(.horizontal)

          HStack {
            Text("Color smoothing (rSqLimit):")

            DelayedTextFieldDouble(
              placeholder: "400",
              value: $doc.picdef.rSqLimit,
              formatter: MAFormatters.fmtSmootingRSqLimit
            )
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 60)
            .help(
              "Enter min value for square of distance from origin. A larger value will smooth the color gradient, but slow down the calculation."
            )
            .onChange(of: doc.picdef.rSqLimit) { _ in
              print("onChange rSqLimit")
              activeDisplayState = .MandArt
            }
          }

        } // end section

        Spacer()

      } //  vstack
    } // scrollview
  } //  body
}
