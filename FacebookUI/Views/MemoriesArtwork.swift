//
//  MemoriesArtwork.swift
//  FacebookUI
//
//  Atmospheric, locally rendered scenes for archived memory posts.
//

import SwiftUI

struct MemoriesArtwork: View {
    let style: MemoryArtworkStyle

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch style {
                case .city:
                    cityScene(in: proxy.size)
                case .coast:
                    coastScene(in: proxy.size)
                case .road:
                    roadScene(in: proxy.size)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private func cityScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "263555"), Color(hex: "A96D83"), Color(hex: "F5A37C")],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(Color(hex: "FFD7AE", opacity: 0.82))
                .frame(width: size.height * 0.2, height: size.height * 0.2)
                .blur(radius: 1)
                .position(x: size.width * 0.77, y: size.height * 0.32)

            HStack(alignment: .bottom, spacing: size.width * 0.025) {
                ForEach(Array([0.44, 0.57, 0.39, 0.67, 0.51, 0.62, 0.42].enumerated()), id: \.offset) { index, height in
                    VStack(spacing: 0) {
                        if index == 4 {
                            DomeSilhouette()
                                .fill(Color(hex: "263149"))
                                .frame(width: size.width * 0.15, height: size.height * 0.22)
                        }
                        Rectangle()
                            .fill(Color(hex: index.isMultiple(of: 2) ? "30334A" : "37334A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: size.height * height)
                            .overlay(alignment: .top) {
                                VStack(spacing: 5) {
                                    ForEach(0..<2, id: \.self) { _ in
                                        HStack(spacing: 5) {
                                            ForEach(0..<2, id: \.self) { _ in
                                                Rectangle()
                                                    .fill(Color(hex: "FFD29C", opacity: 0.72))
                                                    .frame(width: 3, height: 4)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            BridgeSilhouette()
                .fill(Color(hex: "242A3D"))
                .frame(height: size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .bottom)

            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "573A4F"), Color(hex: "17243A")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.2)
                .frame(maxHeight: .infinity, alignment: .bottom)

            HStack(spacing: size.width * 0.06) {
                ForEach(0..<6, id: \.self) { index in
                    Capsule()
                        .fill(Color(hex: "FFC27C", opacity: index.isMultiple(of: 2) ? 0.54 : 0.3))
                        .frame(width: size.width * 0.025, height: size.height * 0.03)
                        .blur(radius: 2)
                }
            }
            .position(x: size.width * 0.7, y: size.height * 0.87)

            Image(systemName: "figure.stand")
                .font(.system(size: size.height * 0.48, weight: .regular))
                .foregroundStyle(Color(hex: "111827"))
                .position(x: size.width * 0.23, y: size.height * 0.72)
        }
    }

    private func coastScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "435274"), Color(hex: "C88992"), Color(hex: "F4B293")],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(Color(hex: "FFDDB7", opacity: 0.78))
                .frame(width: size.height * 0.23, height: size.height * 0.23)
                .position(x: size.width * 0.7, y: size.height * 0.4)

            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "557C91"), Color(hex: "1B3448")], startPoint: .top, endPoint: .bottom))
                .frame(height: size.height * 0.45)
                .frame(maxHeight: .infinity, alignment: .bottom)

            Coastline(variant: 0)
                .fill(Color(hex: "28394D"))
            Coastline(variant: 1)
                .fill(Color(hex: "17283B"))

            HStack(spacing: 5) {
                ForEach(0..<9, id: \.self) { index in
                    Capsule()
                        .fill(Color(hex: "FFD9AF", opacity: 0.4))
                        .frame(width: size.width * (index.isMultiple(of: 3) ? 0.06 : 0.035), height: 2)
                }
            }
            .position(x: size.width * 0.6, y: size.height * 0.76)
        }
    }

    private func roadScene(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "586884"), Color(hex: "D28E92"), Color(hex: "F0B17E")],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(Color(hex: "FFE0A9", opacity: 0.75))
                .frame(width: size.height * 0.2, height: size.height * 0.2)
                .position(x: size.width * 0.73, y: size.height * 0.34)

            MountainSilhouette(variant: 0)
                .fill(Color(hex: "596175"))
            MountainSilhouette(variant: 1)
                .fill(Color(hex: "30384A"))

            RoadShape()
                .fill(LinearGradient(colors: [Color(hex: "35383C"), Color(hex: "111821")], startPoint: .top, endPoint: .bottom))

            RoadStripe()
                .stroke(Color(hex: "F0D9B1", opacity: 0.7), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 9]))
        }
    }
}

private struct DomeSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.54))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.54), control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct BridgeSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.24))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.46))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.height * 0.46), control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.24))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.24))
        path.closeSubpath()
        return path
    }
}

private struct Coastline: Shape {
    let variant: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.height * (variant == 0 ? 0.56 : 0.71)))
        path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.height * 0.43))
        path.addLine(to: CGPoint(x: rect.width * 0.39, y: rect.height * (variant == 0 ? 0.62 : 0.75)))
        path.addLine(to: CGPoint(x: rect.width * 0.62, y: rect.height * 0.49))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * (variant == 0 ? 0.63 : 0.77)))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct MountainSilhouette: Shape {
    let variant: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.14, y: rect.height * 0.56))
        path.addLine(to: CGPoint(x: rect.width * 0.31, y: rect.height * 0.22))
        path.addLine(to: CGPoint(x: rect.width * 0.49, y: rect.height * 0.61))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * (variant == 0 ? 0.28 : 0.42)))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.58))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct RoadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.43, y: rect.height * 0.54))
        path.addLine(to: CGPoint(x: rect.width * 0.58, y: rect.height * 0.54))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct RoadStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
