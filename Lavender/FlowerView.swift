import SwiftUI
import Firebase
import FirebaseFirestore

let leafImages = [Image("Leaf1"),Image("Leaf2"),Image("Leaf3"), Image("Leaf4"),Image("Leaf5"),Image("Leaf6"),Image("Leaf7"),Image("Leaf8")]
let flowerImages = [Image("Flower1"),Image("Flower2"),Image("Flower3"),Image("Flower4"),Image("Flower5"),Image("Flower6"),Image("Flower7"),Image("Flower8"),Image("Flower9"),Image("Flower10")]
let recipeNames = [["Revolting","Ragweed"],["Delicate","Daisy"],["Bluebell","Tulip"],["Hypnotic","Ember"],["Lily of","the Valley"], ["Enchanting","Orchid"],["Cosmic","Blossom"],["Cupid's Rose"],["Flower","of Royalty"],["Legendary","Iris"]]
let recipeFrames = [160,160,160,160,160,160,145,160,160,160]
let recipes = [[(1,5),(2,2),(3,1)], [(1,15),(2,8),(3,3)],
               [(2,15),(3,5),(4,2)],[(2,20),(4,3),(5,1)],
               [(1,40),(5,2),(6,1)],[(3,25),(4,12),(6,3)],
               [(3,45),(6,5),(7,2)],[(4,25),(7,3),(8,1)],
               [(3,100),(5,25),(8,3)],[(6,30),(7,15),(8,10)]]
let recipeCount = 10

struct FlowerView: View {
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    @State private var flowerInv: [Int] = Array(repeating: 0, count: recipeCount)
    @State private var unlocked: [Bool] = [true] + Array(repeating: false, count: recipeCount - 1)
    
    var body: some View {
        HStack{
            Spacer().frame(width: UIScreen.main.bounds.width * 0.20)
            VStack{
                    ForEach(0..<8) { index in
                        ZStack {
                            Rectangle()
                                .frame(width: 65, height: 25)
                                .foregroundColor(.green.opacity(0.20 + Double(index) * 0.10))
                                .cornerRadius(30)
                            HStack{
                                leafImages[index]
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(rarity[index])")
                                    .bold()
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    Spacer()
                    ForEach(0..<10) { index in
                        ZStack {
                            Rectangle()
                                .frame(width: 65, height: 25)
                                .foregroundColor(.purple.opacity(0.1 + Double(index) * 0.05))
                                .cornerRadius(30)
                            HStack{
                                flowerImages[index]
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                Text("\(flowerInv[index])")
                                    .bold()
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
            }
            ScrollView(showsIndicators: false) {
                HStack{
                    Spacer()
                    VStack {
                        ForEach(Array(0..<recipeCount), id: \.self) { index in
                            Button {
                                if checkAssembly(rarity: rarity)[index] && unlocked[index] {
                                    flowerInv[index] += 1
                                    if index != recipeCount-1 {
                                        unlocked[index+1] = true
                                    }
                                    rarity = subtractPetals(recipe: recipes[index], rarity: rarity)
                                    let db = Firestore.firestore()
                                    let userID = Auth.auth().currentUser?.uid
                                    let userRef = db.collection("users").document(userID!)
                                    
                                    userRef.setData(["rarity": rarity, "flowerInv": flowerInv], merge: true) { error in
                                        if let error = error {
                                            print("Error updating FlowerView: \(error)")
                                        } else {
                                            print("FlowerView updated in Firestore")
                                        }
                                    }
                                }
                            } label: {
                                ZStack{
                                    Rectangle()
                                        .frame(width: UIScreen.main.bounds.width * 0.62, height: CGFloat(recipeFrames[index]))
                                        .foregroundColor(unlocked[index] ? (checkAssembly(rarity: rarity)[index] ? .green.opacity(0.5) : .red.opacity(0.5)) : .gray.opacity(0.5))
                                        .cornerRadius(15)
                                    HStack{
                                        ZStack{
                                            Rectangle()
                                                .frame(width: UIScreen.main.bounds.width * 0.30, height: CGFloat(recipeFrames[index]-20))
                                                .foregroundColor(.white.opacity(0.25))
                                                .cornerRadius(20)
                                            VStack{
                                                RecipeTitleView(title: recipeNames[index])
                                                RecipeTextView(recipe: recipes[index])
                                                    .font(.system(size: 13))
                                            }
                                        }
                                        Spacer().frame(width: UIScreen.main.bounds.width * 0.03)
                                        ZStack{
                                            Rectangle()
                                                .frame(width: UIScreen.main.bounds.width * 0.23, height: CGFloat(recipeFrames[index]-20))
                                                .cornerRadius(20)
                                                .foregroundColor(.white)
                                            flowerImages[index]
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 4)
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(height: UIScreen.main.bounds.width * 0.14)
                    }
                }
            }
            Spacer().frame(width: UIScreen.main.bounds.width * 0.20)
        }
        .onAppear {
            DataFetcher.loadPetalCount { fetchedRarity in
                self.rarity = fetchedRarity
            }
            DataFetcher.loadFlowerInv { fetchedFlowerInv in
                self.flowerInv = fetchedFlowerInv
            }
        }
    }
}

func subtractPetals(recipe: [(Int, Int)], rarity: [Int]) -> [Int]{
    var newRar = rarity
    for index in 0..<recipe.count {
        let petalType = recipe[index].0
        let petalCount = recipe[index].1
        newRar[petalType-1] -= petalCount
    }
    return newRar
}

func checkAssembly(rarity: [Int]) -> [Bool] {
    var canAssemble = Array(repeating: true, count: recipeCount)
    for index in 0..<recipeCount {
        for index2 in 0..<recipes[index].count {
            let petalType = recipes[index][index2].0
            let petalCount = recipes[index][index2].1
            if rarity[petalType-1] < petalCount {
                canAssemble[index] = false
            }
        }
    }
    return canAssemble
}

struct RecipeTitleView: View {
    let title: [String]
    var body: some View {
        VStack{
            ForEach(0..<title.count, id: \.self) { index in
                Text("\(title[index])")
            }
        }
    }
}

struct RecipeTextView: View {
    let recipe: [(Int, Int)]

    var body: some View {
        VStack{
            ForEach(0..<recipe.count, id: \.self) { index in
                let petalType = recipe[index].0
                let petalCount = recipe[index].1
                let image = leafImages[petalType-1]
                
                HStack{
                    image
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("\(petalCount)")
                        .bold()
                }
                .padding(.bottom,-5)
            }
        }
    }
}

struct FlowerView_Previews: PreviewProvider {
    static var previews: some View {
        FlowerView()
    }
}
