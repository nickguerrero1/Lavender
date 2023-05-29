import SwiftUI

struct FlowerView: View {
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]
    
    let recipeCount = 10
    let recipeNames = ["Recipe1","Recipe2","Recipe3","Recipe4","Recipe5","Recipe6","Recipe7","Recipe8","Recipe9","Recipe10"]
    let recipes = [[(1,15),(2,5),(3,1)], [(1,60),(3,10),(4,3)],[(2,30),(4,10)],[(3,30),(5,1)],[(1,500),(2,250),(6,3)],[(3,50),(4,30),(5,10)],[(5,30)],[(4,50),(6,15),(7,1)],[(5,30),(8,5)],[(8,100)]]
    
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
                                        .frame(width: 250, height: 60)
                                        .foregroundColor(.green.opacity(0.20 + Double(index) * 0.05))
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("\(recipeNames[index])")
                                                .bold()
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
    @State private var recipeText = ""

    var body: some View {
        HStack{
            Text(recipeText)
                .onAppear {
                    recipeText = recipe.map {"\($0.1)x \($0.0)"}.joined(separator: ", ")
                }
        }
    }
}

struct FlowerView_Previews: PreviewProvider {
    static var previews: some View {
        FlowerView()
    }
}
