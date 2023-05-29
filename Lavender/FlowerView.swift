import SwiftUI

let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]

let recipes = [[(1,10),(2,7),(3,4)], [(1,60),(3,10),(4,3)],[(2,50),(4,12),(5,8)],[(3,30),(5,20),(6,10)],[(1,500),(2,250),(6,3)],[(3,50),(4,30),(6,10)],[(5,30),(6,20),(7,10)],[(4,120),(7,12),(8,8)],[(5,160),(7,40),(8,20)],[(3,3500),(7,200),(8,100)]]

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
                    }
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                HStack{
                    VStack {
                        ForEach(Array(0..<recipeCount), id: \.self) { index in
                            Button {
//                                for index2 in 0..<recipes[index].count {
//                                    let petalType = recipes[index][index2].0
//                                    let petalCount = recipes[index][index2].1
//                                    if rarity[petalType-1] < petalCount {
//                                        canAssemble = false
//                                    }
//                                }
//                                if canAssemble {
//                                    print("Can Assemble")
//                                }   else {
//                                    notEnough[index] = 2
//                                }
                            } label: {
                                ZStack{
                                    Rectangle()
                                        .frame(width: 250, height: 120)
                                        .foregroundColor(checkAssembly(rarity: rarity)[index] ? .green.opacity(0.25) : .red.opacity(0.25))
                                        .cornerRadius(15)
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("\(recipeNames[index])")
                                            RecipeTextView(recipe: recipes[index])
                                                .font(.system(size: 13))
                                        }
                                        .padding(.leading, 70)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
                    }
                    .padding(.leading, 80)
                }
            }
        }
        .onAppear {
            DataFetcher.loadPetalCount { fetchedRarity in
                self.rarity = fetchedRarity
            }
        }
    }
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
