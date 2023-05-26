import SwiftUI

struct Square: View {
    
    @State private var hasStartedMoving = false
    
    @State private var position: CGPoint
    let width: CGFloat
    let height: CGFloat
    
    struct Petal: Identifiable {
        let id = UUID()
        let position: CGPoint
    }
    
    @State private var petals: [Petal] = []
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        let initialX = UIScreen.main.bounds.width/2
        let initialY = UIScreen.main.bounds.height/2-height/2
        position = CGPoint(x: initialX, y: initialY)
    }

    var body: some View {
        Rectangle()
            .foregroundColor(.purple.opacity(0.50))
            .frame(width: width, height: height)
            .position(position)
            .overlay(
                ForEach(petals, id: \.id) { petal in
                    Circle()
                        .foregroundColor(.purple.opacity(0.5))
                        .frame(width: 20, height: 20)
                        .position(petal.position)
                }
            )
            .onAppear {
                if !hasStartedMoving {
                    startMoving()
                    hasStartedMoving = true
                }
            }
    }

    func startMoving() {
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            let newX = CGFloat.random(in: width/2...UIScreen.main.bounds.width-width/2)
            let newY = CGFloat.random(in: 0...UIScreen.main.bounds.height-height*3.5)
            withAnimation(.easeInOut(duration: 5)) {
                position = CGPoint(x: newX, y: newY)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                shed()
            }
        }
    }
    
    func shed() {
        petals.append(Petal(position: position))
    }
}

struct PetView: View {
    var body: some View {
        Square(width: 50, height: 50)
    }
}

struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        PetView()
    }
}
