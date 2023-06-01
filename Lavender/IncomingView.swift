import SwiftUI

struct IncomingView: View {
    
    @State private var incomingEmails: [String] = []
    
    var body: some View {
        VStack{
            Text("Incoming Friend Requests")
                .bold()
                .padding(.top, 60)
            ScrollView(showsIndicators: false) {
                VStack{
                    ForEach(Array(0..<incomingEmails.count), id: \.self) { index in
                        Text(incomingEmails[index])
                    }
                }
            }
        }
        .onAppear {
            DataFetcher.loadIncoming { fetchedIncoming in
                incomingEmails = fetchedIncoming
            }
        }
    }
}

struct IncomingView_Previews: PreviewProvider {
    static var previews: some View {
        IncomingView()
    }
}
