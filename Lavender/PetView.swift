import SwiftUI
import Firebase
import FirebaseFirestore

struct Square: View {
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var hasStartedMoving = false
    @State private var position: CGPoint
    @State private var petals: [Petal] = []
    @State private var rarity1: Int = 0 // Petal counts
    @State private var rarity2: Int = 0
    @State private var tickled = false
    @State private var tickleCount = 0 //removes tickle effect after 5 pet position changes
    @State private var timer: Timer?
    @State private var petImage: Image = Image("Left")
    
    struct Petal: Identifiable {
        let id = UUID()
        let position: CGPoint
        let rarity: Int
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        let initialX = UIScreen.main.bounds.width/2
        let initialY = UIScreen.main.bounds.height/2-height*1.5
        position = CGPoint(x: initialX, y: initialY)
    }

    var body: some View {
        ZStack{
            //Add background rectangle here if needed
            VStack{
                HStack{
                    ZStack{
                        Rectangle()
                            .frame(width: 100, height: 30)
                            .foregroundColor(.yellow.opacity(0.15))
                            .cornerRadius(30)
                        Text("rar1: \(rarity1)")
                            .bold()
                    }
                    .padding(.leading)
                    ZStack{
                        Rectangle()
                            .frame(width: 100, height: 30)
                            .foregroundColor(.blue.opacity(0.15))
                            .cornerRadius(30)
                        Text("rar2: \(rarity2)")
                            .bold()
                    }
                    Spacer()
                }
                ZStack {
                    ForEach(petals, id: \.id) { petal in
                        let petalImage = petal.rarity == 1 ? Image("Leaf1") : Image("Leaf2")
                        
                        petalImage
                            .resizable()
                            .frame(width: 50, height: 50)
                            .gesture(TapGesture()
                                .onEnded { _ in
                                    petals.removeAll { $0.id == petal.id }
                                    
                                    if petal.rarity == 1 {
                                        rarity1 += 1
                                    }   else {
                                        rarity2 += 1
                                    }
                                    
                                    let db = Firestore.firestore()
                                    let userID = Auth.auth().currentUser?.uid
                                    let userRef = db.collection("users").document(userID!)
                                    
                                    userRef.setData(["rarity1": rarity1, "rarity2": rarity2], merge: true) { error in
                                        if let error = error {
                                            print("Error updating petal count: \(error)")
                                        } else {
                                            print("Petal count updated in Firestore")
                                        }
                                    }
                                }
                            )
                            .position(petal.position)
                    }
                    petImage
                        .resizable()
                        .frame(width: 200, height: 200)
                        .position(position)
                        .gesture(TapGesture()
                            .onEnded { _ in
                                tickled = true
                            }
                        )
                        .onAppear {
                            if !hasStartedMoving {
                                startMoving()
                                hasStartedMoving = true
                            }
                            loadPetalCount()
                        }
                }
            }
            .onChange(of: tickled) { _ in
                startMoving()
            }
        }
    }

    func startMoving() {
        
        timer?.invalidate() //invalidate timer if startMoving() called again
        
        let speed: Double = tickled ? 1.0 : 5.0
        
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { _ in
            let newX = CGFloat.random(in: width/2...UIScreen.main.bounds.width-width/2)
            let newY = CGFloat.random(in: height*0.5...UIScreen.main.bounds.height-height*3.5)
            
            if petals.count >= 20 {
                petals.removeFirst()
            }
            let randomNumber = Int.random(in: 1...100)
            if randomNumber <= 33 {
                shed()
            }
            
            tickleCount += 1
            if tickleCount > 5 {
                tickled = false
                tickleCount = 0
            }
            
            if !tickled {
                if newX > position.x {
                    petImage = Image("Right")
                }   else {
                    petImage = Image("Left")
                }
            } else {
                if newX > position.x {
                    petImage = Image("TickleRight")
                }   else {
                    petImage = Image("TickleLeft")
                }
            }
            
            withAnimation(.easeInOut(duration: speed)) {
                position = CGPoint(x: newX, y: newY)
            }
        }
    }
    
    func shed() {
        let randomRarity = Int.random(in: 1...2)
        petals.append(Petal(position: position, rarity: randomRarity))
    }
    
    func loadPetalCount() {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let rarity1Count = document.data()?["rarity1"] as? Int {
                        rarity1 = rarity1Count
                    }
                    if let rarity2Count = document.data()?["rarity2"] as? Int {
                        rarity2 = rarity2Count
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            rarity1 = 0
            rarity2 = 0
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
