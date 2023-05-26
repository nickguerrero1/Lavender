import SwiftUI
import Firebase
import FirebaseFirestore

struct Square: View {
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var hasStartedMoving = false
    @State private var position: CGPoint
    @State private var petals: [Petal] = []
    @State private var petalCounter: Int = 0
    @State private var timerSpeed: Double = 5.0
    @State private var petColor: Color = .purple.opacity(0.50)

    
    struct Petal: Identifiable {
        let id = UUID()
        let position: CGPoint
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        let initialX = UIScreen.main.bounds.width/2
        let initialY = UIScreen.main.bounds.height/2-height*1.5
        position = CGPoint(x: initialX, y: initialY)
    }

    var body: some View {
        VStack{
            HStack{
                ZStack{
                    Rectangle()
                        .frame(width: 100, height: 30)
                        .foregroundColor(.yellow)
                        .cornerRadius(30)
                    Text("Petals: \(petalCounter)")
                }
                .padding(.leading)
                Spacer()
            }
            Button(action: {
                timerSpeed = 2
                petColor = .red.opacity(0.50)
            }) {
                Rectangle()
                    .foregroundColor(petColor)
                    .frame(width: width, height: height)
                    .position(position)
                    .zIndex(1)
                    .onAppear {
                        if !hasStartedMoving {
                            startMoving()
                            hasStartedMoving = true
                        }
                        loadPetalCount()
                    }
            }
        }
        .overlay(
            ZStack {
                ForEach(petals, id: \.id) { petal in
                    Button(action: {
                        petals.removeAll { $0.id == petal.id }
                        petalCounter += 1
                        
                        let db = Firestore.firestore()
                        let userID = Auth.auth().currentUser?.uid
                        let userRef = db.collection("users").document(userID!)
                        
                        userRef.setData(["petalCount": petalCounter], merge: true) { error in
                            if let error = error {
                                print("Error updating petal count: \(error)")
                            } else {
                                print("Petal count updated in Firestore")
                            }
                        }
                    }) {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.white)
                            )
                    }
                    .position(CGPoint(x: petal.position.x, y: petal.position.y + height/2 + 5))
                }
            }
        )
    }

    func startMoving() {
        Timer.scheduledTimer(withTimeInterval: timerSpeed, repeats: true) { _ in
            let newX = CGFloat.random(in: width/2...UIScreen.main.bounds.width-width/2)
            let newY = CGFloat.random(in: 0...UIScreen.main.bounds.height-height*3.5)
            
            if petals.count >= 20 {
                petals.removeFirst()
            }
            let randomNumber = Int.random(in: 1...100)
            if randomNumber <= 100 {
                shed()
            }
            
            withAnimation(.easeInOut(duration: timerSpeed)) {
                position = CGPoint(x: newX, y: newY)
            }
        }
    }
    
    func shed() {
        petals.append(Petal(position: position))
    }
    
    func loadPetalCount() {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let petalCount = document.data()?["petalCount"] as? Int {
                        petalCounter = petalCount
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            petalCounter = 0
        }
    }
}

struct PetView: View {
    var body: some View {
        Square(width: 75, height: 75)
    }
}

struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        PetView()
    }
}
