import SwiftUI

struct Square: View {
    
    @State private var position: CGPoint
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        let initialX = 0.0 - width/2
        let initialY = UIScreen.main.bounds.height/2-height/2
        position = CGPoint(x: initialX, y: initialY)
    }

    var body: some View {
        Rectangle()
            .frame(width: width, height: height)
            .position(position)
            .onAppear(perform: startMoving)
    }

    func startMoving() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            let newX = CGFloat.random(in: width/2...UIScreen.main.bounds.width-width/2)
            let newY = CGFloat.random(in: 0...UIScreen.main.bounds.height-height)
            withAnimation(.easeInOut(duration: 10)) {
                position = CGPoint(x: newX, y: newY)
            }
        }
    }
}

struct PetView: View {
    var body: some View {
        Square(width: 100, height: 100)
    }
}

struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        PetView()
    }
}
