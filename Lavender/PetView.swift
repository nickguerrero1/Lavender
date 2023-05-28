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
        
        let numRarities = 8
        let randomValue = Int.random(in: 1...768)
        
        let frameSizes = [50, 40, 50, 60, 60, 60, 70, 70]
        let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]
        var shedChances = Array(repeating: 256, count: numRarities)
        
        for x in 1...numRarities-1 {
            for y in x...numRarities-1 {
                shedChances[y] = shedChances[y] / 2
            }
        }
        
        if randomValue >= 256 {
            //no petal sheds
        }   else {
            var chooseRarity: Int?
            for index in 1...numRarities {
                if randomValue < shedChances[index - 1] {
                    chooseRarity = index
                }
            }
            petals.append(Petal(position: position, rarity: chooseRarity!, image: images[chooseRarity!-1], frameSize: frameSizes[chooseRarity!-1]))
        }
    }
    
    func loadPetalCount() {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let firebaseRar = ["rarity1","rarity2","rarity3","rarity4","rarity5","rarity6","rarity7","rarity8"]
                    for index in 0...7 {
                        if let rarityCount = document.data()?[firebaseRar[index]] as? Int {
                            rarity[index] = rarityCount
                        }
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
