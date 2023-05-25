import SwiftUI

struct MainView: View {
    
    @State private var startDate = Date()
    
    var body: some View {
        
            VStack{
                Text("Select Anniversary Date")
                    .font(.custom("Arial", size: 25))
                
                DatePicker("Anniversary", selection: $startDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.top, 15)
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
