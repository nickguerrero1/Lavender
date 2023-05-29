import SwiftUI

let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]

struct FlowerView: View {
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    
    let recipeCount = 10
    let recipeNames = ["Revolting Ragweed","Small Twig","Mediocre Shrub","Delicate Daisy", "Elegant Lily of the Valley", "Enchanting Orchid","Cupid's Rose","Cosmic Blossom","Flower of Royalty","Legendary Iris"]
    let recipes = [[(1,10),(2,7),(3,4)], [(1,60),(3,10),(4,3)],[(2,50),(4,12)],[(3,30),(5,1)],[(1,500),(2,250),(6,3)],[(3,50),(4,30),(5,10)],[(5,30)],[(4,50),(6,15),(7,1)],[(5,30),(8,5)],[(8,100)]]
    
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
                                //assemble flower
                            } label: {
                                ZStack{
                                    Rectangle()
                                        .frame(width: 250, height: 130)
                                        .foregroundColor(.green.opacity(0.20 + Double(index) * 0.05))
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
                            .buttonStyle(.plain)
                        }
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
