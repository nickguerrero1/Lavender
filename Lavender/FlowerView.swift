import SwiftUI
import Firebase
import FirebaseFirestore

let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]

let recipes = [[(1,5),(2,2),(3,1)], [(1,20),(2,10),(3,3)],[(2,20),(3,5),(4,2)],[(2,40),(4,3),(5,1)],[(1,160),(5, 2),(6,1)],[(3,30),(4,12),(6,3)],[(5,30),(6,20),(7,10)],[(4,120),(7,12),(8,8)],[(5,160),(7,40),(8,20)],[(3,3500),(7,200),(8,100)]]

let recipeCount = 10

struct FlowerView: View {
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    @State private var flowerInv: [Int] = Array(repeating: 0, count: recipeCount)
    
    let recipeNames = ["Revolting Ragweed","Small Twig","Mediocre Shrub","Delicate Daisy", "Elegant Lily of the Valley", "Enchanting Orchid","Cupid's Rose","Cosmic Blossom","Flower of Royalty","Legendary Iris"]
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    VStack{
                        ForEach(0..<8) { index in
                            ZStack {
                                Rectangle()
                                    .frame(width: 70, height: 25)
                                    .foregroundColor(.green.opacity(0.20 + Double(index) * 0.10))
                                    .cornerRadius(30)
                                HStack{
                                    images[index]
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
                                    .frame(width: 70, height: 25)
                                    .foregroundColor(.purple.opacity(0.20 + Double(index) * 0.10))
                                    .cornerRadius(30)
                                HStack{
                                    Text("\(flowerInv[index])")
                                        .bold()
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.06)
                    }
                    .padding(.leading, 30)
                    Spacer()
                }
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                HStack{
                    Spacer()
                    VStack {
                        ForEach(Array(0..<recipeCount), id: \.self) { index in
                            Button {
                                if checkAssembly(rarity: rarity)[index] {
                                    flowerInv[index] += 1
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
                                    HStack{
                                        Spacer().frame(width: 120)
                                        Rectangle()
                                            .frame(width: 250, height: 120)
                                            .foregroundColor(checkAssembly(rarity: rarity)[index] ? .green.opacity(0.25) : .red.opacity(0.25))
                                            .cornerRadius(15)
                                    }
                                    HStack{
                                        Spacer().frame(width: 150)
                                        VStack(alignment: .leading){
                                            Text("\(recipeNames[index])")
                                            RecipeTextView(recipe: recipes[index])
                                                .font(.system(size: 13))
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
                    }
                    .padding(.trailing, 30)
                }
            }
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

struct RecipeTextView: View {
    let recipe: [(Int, Int)]

    var body: some View {
        VStack{
            ForEach(0..<recipe.count, id: \.self) { index in
                let petalType = recipe[index].0
                let petalCount = recipe[index].1
                let image = images[petalType-1]
                
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
