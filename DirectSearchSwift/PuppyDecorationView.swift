import SwiftUI

struct PuppyDecorationView: View {
    let isPink: Bool
    @State private var animationOffset: CGFloat = 0
    
    init(isPink: Bool = false) {
        self.isPink = isPink
    }
    
    var body: some View {
        ZStack {
            // Puppy face
            Circle()
                .fill(isPink ? Color(red: 1.0, green: 0.71, blue: 0.76) : Color(red: 1.0, green: 0.84, blue: 0.0))
                .frame(width: 60, height: 60)
                .overlay(
                    // Eyes
                    HStack(spacing: 15) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                    }
                    .offset(y: -5)
                )
                .overlay(
                    // Smile
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 35))
                        path.addQuadCurve(
                            to: CGPoint(x: 40, y: 35),
                            control: CGPoint(x: 30, y: 45)
                        )
                    }
                    .stroke(Color.black, lineWidth: 2)
                )
        }
        .frame(width: 120, height: 120)
        .offset(y: animationOffset)
        .rotationEffect(.degrees(animationOffset * 0.5))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                animationOffset = isPink ? -10 : 10
            }
        }
    }
}

struct PuppyDecorationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.71, green: 0.94, blue: 0.64)
                .ignoresSafeArea()
            
            HStack(spacing: 50) {
                PuppyDecorationView()
                PuppyDecorationView(isPink: true)
            }
        }
    }
} 