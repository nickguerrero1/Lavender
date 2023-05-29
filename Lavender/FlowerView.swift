import SwiftUI

struct FlowerView: View {
    
    @State private var rarity: [Int] = Array(repeating: 0, count: numRarities)
    let images = [Image("Leaf1"), Image("Leaf2"), Image("Leaf3"), Image("Leaf4"), Image("Leaf5"), Image("Leaf6"), Image("Leaf7"), Image("Leaf8")]
    
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
            ScrollView {
                HStack{
                    VStack{
                        Rectangle()
                            .frame(width: 250, height: 60)
                        Rectangle()
                            .frame(width: 250, height: 60)
                        Rectangle()
                            .frame(width: 250, height: 60)
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

struct FlowerView_Previews: PreviewProvider {
    static var previews: some View {
        FlowerView()
    }
}
