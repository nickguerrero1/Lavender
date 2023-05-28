import SwiftUI

struct CalendarView: View {
    
    @State private var selectedDate = Date()
    
    private func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let referenceDate = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: referenceDate, to: startDate)
        return (components.day ?? 0) * -1
    }
    
    var body: some View {
        
        VStack{
            ZStack{
                Rectangle()
                    .foregroundColor(.green.opacity(0.12))
                    .frame(height: 60)
                DatePicker("Anniversary", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .bold()
            }
            .padding(.top, 20)
            
            VStack{
                Text("It's been ")
                +
                Text("\(daysSince(selectedDate))")
                    .bold()
                +
                Text(" days since you've started dating")
            }
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

