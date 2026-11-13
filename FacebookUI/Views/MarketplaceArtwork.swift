//
//  MarketplaceArtwork.swift
//  FacebookUI
//
//  Locally rendered product scenes for sample Marketplace listings.
//

import SwiftUI

struct MarketplaceArtwork: View {
    let style: ListingArtworkStyle

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch style {
                case .vintageCamera:
                    cameraScene(in: proxy.size)
                case .armchair:
                    chairScene(in: proxy.size)
                case .roadBike:
                    bikeScene(in: proxy.size)
                case .deskLamp:
                    lampScene(in: proxy.size)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private func cameraScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "292C38"), Color(hex: "716259"), Color(hex: "211B1A")], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color(hex: "E8C9A4", opacity: 0.62), .clear], center: UnitPoint(x: 0.2, y: 0.35), startRadius: 0, endRadius: size.width * 0.48)

            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "725341"), Color(hex: "30241F")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.28)
                .frame(maxHeight: .infinity, alignment: .bottom)

            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.045 : 0.018))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            .blur(radius: 1)
            .frame(maxHeight: .infinity, alignment: .bottom)

            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "3C4147"), Color(hex: "101419"), Color(hex: "22262B")], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(hex: "AEB4B9", opacity: 0.7), lineWidth: 1))
                    .frame(width: size.width * 0.72, height: size.height * 0.42)
                    .position(x: size.width * 0.51, y: size.height * 0.62)

                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [Color(hex: "BFC3C5"), Color(hex: "555B61")], startPoint: .top, endPoint: .bottom))
                    .frame(width: size.width * 0.19, height: size.height * 0.16)
                    .position(x: size.width * 0.49, y: size.height * 0.405)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "20252A"))
                    .frame(width: size.width * 0.27, height: size.height * 0.045)
                    .position(x: size.width * 0.48, y: size.height * 0.46)

                Circle()
                    .fill(Color(hex: "15191E"))
                    .frame(width: size.height * 0.44, height: size.height * 0.44)
                    .overlay(Circle().strokeBorder(Color(hex: "AEB4B9"), lineWidth: 3))
                    .overlay(Circle().strokeBorder(Color(hex: "4A5159"), lineWidth: 7).padding(5))
                    .overlay(Circle().strokeBorder(Color(hex: "13171D"), lineWidth: 3).padding(14))
                    .overlay(Circle().fill(Color(hex: "283E53")).frame(width: size.height * 0.1, height: size.height * 0.1))
                    .shadow(color: .black.opacity(0.7), radius: 9, x: 2, y: 5)
                    .position(x: size.width * 0.62, y: size.height * 0.63)

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(Color(hex: "171A1E")).frame(width: 5, height: 5)
                    }
                }
                .position(x: size.width * 0.29, y: size.height * 0.54)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "E2E4E3"))
                    .frame(width: size.width * 0.1, height: size.height * 0.06)
                    .position(x: size.width * 0.76, y: size.height * 0.51)
            }
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 9)
        }
    }

    private func chairScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "C9BBAA"), Color(hex: "73675C"), Color(hex: "2B2A2B")], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: "FFE0AE", opacity: 0.56), .clear], center: UnitPoint(x: 0.88, y: 0.32), startRadius: 0, endRadius: size.width * 0.44)

            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "725944"), Color(hex: "342A24")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.21)
                .frame(maxHeight: .infinity, alignment: .bottom)

            Rectangle()
                .fill(Color(hex: "51463D", opacity: 0.5))
                .frame(width: 1)
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(x: -size.width * 0.3)

            Image(systemName: "leaf.fill")
                .font(.system(size: size.height * 0.5))
                .foregroundStyle(Color(hex: "26382F"))
                .rotationEffect(.degrees(-22))
                .position(x: size.width * 0.1, y: size.height * 0.37)
                .blur(radius: 1)

            Circle()
                .fill(Color(hex: "FFD59D", opacity: 0.4))
                .frame(width: size.width * 0.15, height: size.width * 0.15)
                .blur(radius: 13)
                .position(x: size.width * 0.88, y: size.height * 0.25)

            // Chair legs and frame sit behind the upholstered cushions.
            Capsule().fill(Color(hex: "61452F"))
                .frame(width: size.width * 0.035, height: size.height * 0.25)
                .rotationEffect(.degrees(7))
                .position(x: size.width * 0.34, y: size.height * 0.79)
            Capsule().fill(Color(hex: "61452F"))
                .frame(width: size.width * 0.035, height: size.height * 0.25)
                .rotationEffect(.degrees(-7))
                .position(x: size.width * 0.68, y: size.height * 0.79)
            Capsule().fill(Color(hex: "61452F"))
                .frame(width: size.width * 0.032, height: size.height * 0.2)
                .rotationEffect(.degrees(-10))
                .position(x: size.width * 0.27, y: size.height * 0.78)

            RoundedRectangle(cornerRadius: size.width * 0.13, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "14608D"), Color(hex: "063655"), Color(hex: "042B49")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: size.width * 0.13).strokeBorder(Color(hex: "77B8D5", opacity: 0.35), lineWidth: 1))
                .frame(width: size.width * 0.53, height: size.height * 0.49)
                .position(x: size.width * 0.51, y: size.height * 0.46)
                .shadow(color: .black.opacity(0.38), radius: 9, x: 3, y: 6)

            RoundedRectangle(cornerRadius: size.width * 0.12, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "0E5B86"), Color(hex: "073958")], startPoint: .top, endPoint: .bottom))
                .frame(width: size.width * 0.62, height: size.height * 0.19)
                .position(x: size.width * 0.51, y: size.height * 0.68)
                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 4)

            RoundedRectangle(cornerRadius: size.width * 0.07, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "0C4A70"), Color(hex: "062F4D")], startPoint: .leading, endPoint: .trailing))
                .frame(width: size.width * 0.17, height: size.height * 0.28)
                .position(x: size.width * 0.23, y: size.height * 0.65)
            RoundedRectangle(cornerRadius: size.width * 0.07, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "0A4265"), Color(hex: "052D49")], startPoint: .leading, endPoint: .trailing))
                .frame(width: size.width * 0.17, height: size.height * 0.28)
                .position(x: size.width * 0.79, y: size.height * 0.65)
        }
    }

    private func bikeScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "A7A7A3"), Color(hex: "5F6264"), Color(hex: "272B30")], startPoint: .top, endPoint: .bottom)
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.035 : 0.012))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "62605A"), Color(hex: "282724")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.2)
                .frame(maxHeight: .infinity, alignment: .bottom)

            Circle().stroke(Color(hex: "15191E"), lineWidth: 5)
                .frame(width: size.height * 0.58, height: size.height * 0.58)
                .position(x: size.width * 0.24, y: size.height * 0.69)
            Circle().stroke(Color(hex: "15191E"), lineWidth: 5)
                .frame(width: size.height * 0.58, height: size.height * 0.58)
                .position(x: size.width * 0.77, y: size.height * 0.69)

            BicycleFrame()
                .stroke(Color(hex: "111820"), style: StrokeStyle(lineWidth: max(size.width * 0.018, 2.5), lineCap: .round, lineJoin: .round))

            BicycleDetails()
                .stroke(Color(hex: "161D24"), style: StrokeStyle(lineWidth: max(size.width * 0.012, 1.7), lineCap: .round, lineJoin: .round))

            Circle().fill(Color(hex: "899197")).frame(width: 6, height: 6).position(x: size.width * 0.5, y: size.height * 0.7)
            LinearGradient(colors: [.clear, Color(hex: "171A1C", opacity: 0.18)], startPoint: .center, endPoint: .bottom)
        }
    }

    private func lampScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "241E1B"), Color(hex: "5A4433"), Color(hex: "1A1716")], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: "FFBF6B", opacity: 0.55), .clear], center: UnitPoint(x: 0.65, y: 0.48), startRadius: 0, endRadius: size.width * 0.56)

            Image(systemName: "leaf.fill")
                .font(.system(size: size.height * 0.48))
                .foregroundStyle(Color(hex: "25362C"))
                .rotationEffect(.degrees(-28))
                .position(x: size.width * 0.12, y: size.height * 0.48)
                .blur(radius: 1)

            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "66472E"), Color(hex: "271C15")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.24)
                .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(spacing: 0) {
                LampShade()
                    .fill(LinearGradient(colors: [Color(hex: "20252B"), Color(hex: "090D13")], startPoint: .top, endPoint: .bottom))
                    .overlay(LampShade().stroke(Color(hex: "76808A", opacity: 0.45), lineWidth: 1))
                    .frame(width: size.width * 0.38, height: size.height * 0.24)
                Ellipse()
                    .fill(Color(hex: "FFCC80"))
                    .frame(width: size.width * 0.25, height: size.height * 0.055)
                    .shadow(color: Color(hex: "FFB64E", opacity: 0.85), radius: 12)
                Capsule().fill(Color(hex: "252A30"))
                    .frame(width: size.width * 0.045, height: size.height * 0.35)
                Ellipse().fill(LinearGradient(colors: [Color(hex: "32363B"), Color(hex: "111519")], startPoint: .top, endPoint: .bottom))
                    .frame(width: size.width * 0.4, height: size.height * 0.095)
            }
            .position(x: size.width * 0.67, y: size.height * 0.61)
            .shadow(color: .black.opacity(0.42), radius: 8, x: 2, y: 5)

            VStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "806448"))
                        .frame(width: size.width * 0.2, height: size.height * 0.035)
                }
            }
            .position(x: size.width * 0.27, y: size.height * 0.83)
        }
    }
}

private struct BicycleFrame: Shape {
    func path(in rect: CGRect) -> Path {
        let rear = CGPoint(x: rect.width * 0.24, y: rect.height * 0.69)
        let front = CGPoint(x: rect.width * 0.77, y: rect.height * 0.69)
        let crank = CGPoint(x: rect.width * 0.5, y: rect.height * 0.69)
        let seat = CGPoint(x: rect.width * 0.39, y: rect.height * 0.36)
        let head = CGPoint(x: rect.width * 0.64, y: rect.height * 0.38)
        var path = Path()
        path.move(to: rear); path.addLine(to: seat); path.addLine(to: crank); path.addLine(to: rear)
        path.move(to: seat); path.addLine(to: head); path.addLine(to: crank)
        path.move(to: head); path.addLine(to: front)
        return path
    }
}

private struct BicycleDetails: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.38, y: rect.height * 0.36))
        path.addLine(to: CGPoint(x: rect.width * 0.32, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width * 0.47, y: rect.height * 0.3))
        path.move(to: CGPoint(x: rect.width * 0.64, y: rect.height * 0.38))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.29))
        path.addLine(to: CGPoint(x: rect.width * 0.82, y: rect.height * 0.29))
        path.move(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.29))
        path.addLine(to: CGPoint(x: rect.width * 0.76, y: rect.height * 0.69))
        path.move(to: CGPoint(x: rect.width * 0.49, y: rect.height * 0.69))
        path.addLine(to: CGPoint(x: rect.width * 0.53, y: rect.height * 0.65))
        path.addLine(to: CGPoint(x: rect.width * 0.56, y: rect.height * 0.69))
        return path
    }
}

private struct LampShade: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.22, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.width * 0.78, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
