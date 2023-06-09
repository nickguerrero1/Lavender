import SwiftUI
import Firebase
import FirebaseFirestore

let numRarities = 8
let levelCount = 20

let frameSizes = [50, 40, 50, 60, 60, 70, 70, 70]
let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]
let xp = [4, 8, 16, 32, 64, 128, 256, 512]

struct Square: View {
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var hasStartedMoving = false
    @State private var position: CGPoint
    @State private var petals: [Petal] = []
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    @State private var levels: [Int]
    
    @State private var tickled = false
    @State private var tickleCount = 0 //removes tickle effect after 5 pet position changes
    @State private var timer: Timer?
    @State private var petImage: Image = Image("Left")
    @State private var petalImage: Image?
    
    @State private var experience = 0
    @State private var currentLevel = 0
    @State private var remainingXP = 0
    
    struct Petal: Identifiable {
        let id = UUID()
        let position: CGPoint
        let rarity: Int
        let image: Image
        let frameSize: Int
        let xp: Int
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        let initialX = UIScreen.main.bounds.width/2
        let initialY = UIScreen.main.bounds.height/2-height*1.5
        position = CGPoint(x: initialX, y: initialY)
        
        var levels: [Int] = Array(repeating: 100, count: levelCount)
        for index in 1..<levelCount {
            levels[index] = Int(round(Double(levels[index-1]) * 1.5))
        }
        self.levels = levels
    }

    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(.green.opacity(0.8))
                    .frame(width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.height*0.035)
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.height*0.025)
                HStack{
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(.green.opacity(0.35))
                        .frame(width: UIScreen.main.bounds.width * 0.7 * (Double(remainingXP) / Double(levels[currentLevel])), height: UIScreen.main.bounds.height*0.025)
                        .padding(.leading, UIScreen.main.bounds.width*0.15)
                    Spacer()
                }
                Text("Level " + String(currentLevel))
            }
            .padding(.bottom, 5)
            HStack{
                ForEach(0..<8) { index in
                    ZStack {
                        Rectangle()
                            .frame(width: measureTextWidth(text: "\(rarity[index])", fontSize: 15) + 12, height: 20)
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
                                
                                rarity[petal.rarity-1] += 1
                                experience += petal.xp
                                
                                let levelData = calculateLevel(experience: experience)
                                currentLevel = levelData[0]
                                remainingXP = levelData[1]
                                
                                let db = Firestore.firestore()
                                let userID = Auth.auth().currentUser?.uid
                                let userRef = db.collection("users").document(userID!)
                                
                                userRef.setData(["rarity": rarity, "xp": experience, "level": currentLevel], merge: true) { error in
                                    if let error = error {
                                        print("Error updating PetView: \(error)")
                                    } else {
                                        print("PetView updated in Firestore")
                                    }
                                }
                            }
                        )
                        .position(petal.position)
                }
                petImage
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width*0.5, height: UIScreen.main.bounds.width*0.5)
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
                        DataFetcher.loadPetalCount { fetchedRarity in
                            self.rarity = fetchedRarity
                        }
                        DataFetcher.loadExperience { fetchedExperience in
                            self.experience = fetchedExperience
                            let levelData = calculateLevel(experience: fetchedExperience)
                            currentLevel = levelData[0]
                            remainingXP = levelData[1]
                        }
                    }
            }
        }
        .onChange(of: tickled) { _ in
            startMoving()
        }
    }
    
    func calculateLevel(experience: Int) -> [Int] {
        var experience = experience
        var lvl = 0
        for index in 0..<levelCount {
            if experience >= levels[index] {
                lvl += 1
                experience -= levels[index]
            }   else {
                break
            }
        }
        return [lvl, experience]
    }
    
    func startMoving() {
        timer?.invalidate() //invalidate timer if startMoving() called again
        
        let speed: Double = tickled ? 1.0 : 5.0
        
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { _ in
            let newX = CGFloat.random(in: width/2...UIScreen.main.bounds.width-width/2)
            let newY = CGFloat.random(in: UIScreen.main.bounds.height * 0.05...UIScreen.main.bounds.height * 0.70)
            
            if petals.count >= 20 {
                petals.removeFirst()
            }
            
            shed()
            
            tickleCount += 1
            if tickleCount > 5 {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    tickled = false
                    tickleCount = 0
                }
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
        let randomValue = Double.random(in: 1.0..<768.0) //random value
        var shedChances = Array(repeating: 256.0 * pow(1.05, Double(currentLevel)), count: numRarities)
        
        for x in 1...numRarities-1 {
            for y in x...numRarities-1 {
                shedChances[y] = shedChances[y] / 2.0
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
            petals.append(Petal(position: position, rarity: chooseRarity!, image: images[chooseRarity!-1], frameSize: frameSizes[chooseRarity!-1], xp: xp[chooseRarity!-1]))
        }
    }
    
    func measureTextWidth(text: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()
        return size.width
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
