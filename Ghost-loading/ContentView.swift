//
//  ContentView.swift
//  Ghost-loading
//
//  Created by Abraao Nascimento on 20/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var isAnimation = false
    @State var isAnimatingBody = false
    @State var blinkAnimating = true
    @State var bubleAnimating = false
    let bothEyeAnimate = Bool.random()
    
    var body: some View {
        ZStack {
            
            Color.purple
                .ignoresSafeArea()
//            Image(uiImage: UIImage(named: "halloween-wallpaper")!)
//                .resizable()
//                .opacity(0.55)
//                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                GhostBody(legsOffset: isAnimation ? 15 : 2,
                          position: isAnimatingBody ? 4 : -4)
                    .fill(.linearGradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.45)], startPoint: .top,
                                          endPoint: .bottom))
                    .frame(width: 100, height: 300)
                    .padding(.top, (UIScreen.main.bounds.height - 500) / 2)
            }
            .overlay {
                Eye(leftEye: blinkAnimating ? 20 : bothEyeAnimate ? 1 : 20,
                    rightEye: blinkAnimating ? 20 : 1)
                    .opacity(0.65)
                
                Mounth(offset: isAnimation ? 16 : 8)
                    .opacity(0.65)
                
                Shadow(offset: isAnimatingBody ? 4 : -4)
                    .fill(.black)
                    .opacity(isAnimatingBody ? 0.55 : 0.15)
                    .blur(radius: 2, opaque: false)
                Bubble()
                    .fill(.white)
                    .overlay {
                        Text("Boooo!")
                            .fontDesign(.monospaced)
                            .foregroundColor(.black)
                            .position(x: -40, y: 168)
                    }
                    .scaleEffect(x: bubleAnimating ? 1.0 : 0.001,
                                 y: bubleAnimating ? 1.0 : 0.001)
            }
            .padding()
            .onAppear {
                withAnimation(Animation.linear(duration: 3).repeatForever()) {
                    isAnimation.toggle()
                }
                
                withAnimation(Animation.linear(duration: 1).repeatForever()) {
                    isAnimatingBody.toggle()
                }
                
                withAnimation(Animation.linear(duration: 0.15).delay(Double.random(in: 1.5 ..< 2.4)).repeatForever(autoreverses: false)) {
                    blinkAnimating.toggle()
                }
                
                withAnimation(Animation.spring(dampingFraction: 0.2).delay(3).repeatForever()) {
                    bubleAnimating.toggle()
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GhostBody: Shape {
    
    var legsOffset: Double = 0.0
    var position: CGFloat = 0.0
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(legsOffset, CGFloat(position)) }
        set {
            legsOffset = newValue.first
            position = CGFloat(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let spacing = rect.width / 100
            let headSize = (rect.width) / 2
            let height = (rect.width * 1.2) - headSize
            let rect = CGRect(x: rect.origin.x + spacing ,
                              y: ((rect.origin.y + headSize) / 2) + 10 + position,
                              width: rect.width,
                              height: height)
            
            // head
            path.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                        radius: headSize,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 0),
                        clockwise: false)
            
            // body
            /*
             0 _ _ _ 1
             |       |
             |       |
             |_ _ _ _|
             3       2
             */
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // 0
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // 1
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 25)) // 2
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 25)) // 3
            
            // legs
            
            let numberOFLegs = 4
            let legsHeight = 50.0
            let legWidth = rect.width / CGFloat(numberOFLegs)
            
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            
            for i in 0..<numberOFLegs {
                let b = legWidth * CGFloat(i)
                let legsHeightOffset: CGFloat = i % 2 == 0 ? +legsOffset : -legsOffset
                let xTo = legWidth + b
                let xControl = (legWidth + b + b) / 2
                
                path.addQuadCurve(to: CGPoint(x: xTo, y: rect.maxY),
                                  control: CGPoint(x: xControl,
                                                   y: rect.maxY + legsHeightOffset))
            }
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (legsHeight / 2)))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - (legsHeight / 2)))
            
            
//            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        }
    }
}

struct Shadow: Shape {
    
    var offset: Double = 0.0
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let distance = 140.0 + offset
            let margin = 12.0
            let width = rect.width - margin
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addEllipse(in: CGRect(origin: CGPoint(x: rect.minX + (margin / 2), y: rect.maxY - distance),
                                       size: CGSize(width: width, height: margin)))
            
        }
    }
}

struct Eye: Shape {
    
    var leftEye: Double = 20.0
    var rightEye: Double = 20.0
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(leftEye, rightEye) }
        set {
            leftEye = newValue.first
            rightEye = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let space = 16.0
            let width = 16.0
            let distance = 40.0
            
            path.addEllipse(in: CGRect(origin: CGPoint(x: rect.midX - space, y: rect.midY - distance),
                                       size: CGSize(width: width, height: leftEye)))
            
            path.addEllipse(in: CGRect(origin: CGPoint(x: rect.midX + space, y: rect.midY - distance),
                                       size: CGSize(width: width, height: rightEye)))
            
        }
    }
}

struct Mounth: Shape {
    var offset: Double = 0.0
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = 20.0
            path.move(to: CGPoint(x: rect.midX - (width / 2), y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.midX + (width / 2), y: rect.midY),
                              control: CGPoint(x: (offset + rect.midX + width + width / 2) / 2, y: rect.midY + offset))
            
        }
    }
}

struct Bubble: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = 140.0
            let height = 100.0
            
            path.addEllipse(in: CGRect(origin: CGPoint(x: rect.midX - (width + 20), y: rect.minY + 120),
                                       size: CGSize(width: width, height: height)))
            
            path.move(to: CGPoint(x: rect.minX - 100, y: rect.minY + 150))// 0
            path.addLine(to: CGPoint(x: rect.maxX - 130, y: rect.minY + 150)) // 1
            path.addLine(to: CGPoint(x: rect.midX - 20, y: rect.midY)) // 4
//            path.addLine(to: CGPoint(x: rect.minY, y: rect.midY)) // 3
            
//            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            
//            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxX),
//                              control: CGPoint(x: rect.minX + 100, y: rect.midY + 20))
        }
    }
    
    
}
