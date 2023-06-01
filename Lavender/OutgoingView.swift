import SwiftUI

struct OutgoingView: View {
    
    @State private var outgoingEmails: [String] = []
    
    var body: some View {
        VStack{
            Text("Outgoing Friend Requests")
                .bold()
                .padding(.top, 60)
            ScrollView(showsIndicators: false) {
                VStack{
                    ForEach(Array(0..<outgoingEmails.count), id: \.self) { index in
                        Text(outgoingEmails[index])
                    }
                }
            }
        }
        .onAppear {
            DataFetcher.loadOutgoing { fetchedOutgoing in
                outgoingEmails = fetchedOutgoing
            }
        }
    }
}

struct OutgoingView_Previews: PreviewProvider {
    static var previews: some View {
        OutgoingView()
    }
}
