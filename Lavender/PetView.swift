import SwiftUI
import Firebase
import FirebaseFirestore

struct Square: View {
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var hasStartedMoving = false
    @State private var position: CGPoint
    @State private var petals: [Petal] = []
    
    @State private var rarity: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
    
    @State private var tickled = false
    @State private var tickleCount = 0 //removes tickle effect after 5 pet position changes
    @State private var timer: Timer?
    @State private var petImage: Image = Image("Left")
    @State private var petalImage: Image?
    
    struct Petal: Identifiable {
        let id = UUID()
        let position: CGPoint
        let rarity: Int
        let image: Image
        let frameSize: Int
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
                    ForEach(0..<8) { index in
                        ZStack {
                            Rectangle()
                                .frame(width: 30, height: 20)
                                .foregroundColor(.green.opacity(0.20 + Double(index) * 0.10))
                                .cornerRadius(30)
                            Text("\(rarity[index])")
                                .bold()
                                .font(.system(size: 15))
                        }
                    }
                }
                ZStack {
                    ForEach(petals, id: \.id) { petal in
                        petal.image
                            .resizable()
                            .frame(width: CGFloat(petal.frameSize), height: CGFloat(petal.frameSize))
                            .gesture(TapGesture()
                                .onEnded { _ in
                                    petals.removeAll { $0.id == petal.id }
                                    
                                    for index in 0...7 {
                                        if petal.rarity == index + 1 {
                                            rarity[index] += 1
                                        }
                                    }
                                    
                                    let db = Firestore.firestore()
                                    let userID = Auth.auth().currentUser?.uid
                                    let userRef = db.collection("users").document(userID!)
                                    
                                    userRef.setData(["rarity1": rarity[0], "rarity2": rarity[1], "rarity3": rarity[2], "rarity4": rarity[3], "rarity5": rarity[4], "rarity6": rarity[5], "rarity7": rarity[6], "rarity8": rarity[7]], merge: true) { error in
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
            
            shed()
            
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
        let randomValue = Int.random(in: 1...768)
        if randomValue >= 256 {
            //no petal sheds
        }   else if randomValue >= 128 {
            petals.append(Petal(position: position, rarity: 1, image: Image("Leaf1"), frameSize: 50)) //50%
        }   else if randomValue >= 64 {
            petals.append(Petal(position: position, rarity: 2, image: Image("Leaf2"), frameSize: 40)) //25%
        }   else if randomValue >= 32 {
            petals.append(Petal(position: position, rarity: 3, image: Image("Leaf3"), frameSize: 50)) //12.5%
        }   else if randomValue >= 16 {
            petals.append(Petal(position: position, rarity: 4, image: Image("Leaf4"), frameSize: 60)) //6.25%
        }   else if randomValue >= 8 {
            petals.append(Petal(position: position, rarity: 5, image: Image("Leaf5"), frameSize: 60)) //3.13%
        }   else if randomValue >= 4 {
            petals.append(Petal(position: position, rarity: 6, image: Image("Leaf6"), frameSize: 60)) //1.56%
        }   else if randomValue >= 2 {
            petals.append(Petal(position: position, rarity: 7, image: Image("Leaf7"), frameSize: 60)) //0.78%
        }   else {
            petals.append(Petal(position: position, rarity: 8, image: Image("Leaf8"), frameSize: 70)) //0.39%
        }
    }
    
    func loadPetalCount() {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let rarity1Count = document.data()?["rarity1"] as? Int {
                        rarity[0] = rarity1Count
                    }
                    if let rarity2Count = document.data()?["rarity2"] as? Int {
                        rarity[1] = rarity2Count
                    }
                    if let rarity3Count = document.data()?["rarity3"] as? Int {
                        rarity[2] = rarity3Count
                    }
                    if let rarity4Count = document.data()?["rarity4"] as? Int {
                        rarity[3] = rarity4Count
                    }
                    if let rarity5Count = document.data()?["rarity5"] as? Int {
                        rarity[4] = rarity5Count
                    }
                    if let rarity6Count = document.data()?["rarity6"] as? Int {
                        rarity[5] = rarity6Count
                    }
                    if let rarity7Count = document.data()?["rarity7"] as? Int {
                        rarity[6] = rarity7Count
                    }
                    if let rarity8Count = document.data()?["rarity8"] as? Int {
                        rarity[7] = rarity8Count
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            for index in 0...7 {
                rarity[index] = 0
            }
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
