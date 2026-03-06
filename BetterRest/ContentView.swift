//
//  ContentView.swift
//  BetterRest
//
//  Created by Luki on 04/03/2026.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State var wakeUp = defaultWakeTime
    @State var sleepAmount = 8.0
    @State var coffeeAmount = 1
    
  
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var recommendedBedtime: String {
         do {
             let config = MLModelConfiguration()
             let model = try SleepCalculator(configuration: config)
             let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
             let hour = (components.hour ?? 0) * 60 * 60
             let minute = (components.minute ?? 0) * 60

             let prediction = try model.prediction(
                 wake: Double(hour + minute),
                 estimatedSleep: sleepAmount,
                 coffee: Double(coffeeAmount)
             )
             let sleepTime = wakeUp - prediction.actualSleep
             return sleepTime.formatted(date: .omitted, time: .shortened)
         } catch {
             return "Error calculating bedtime"
         }
     }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(0..<21) { amount in
                            Text(amount == 1 ? "1 cup" : "\(amount) cups")
                        }
                    }
                }
                Section("Reccommended bedtime") {
                    Text(recommendedBedtime)
                        .font(.title)
                        .foregroundColor(.blue)
                }
                    
                .navigationTitle("BetterRest")
            }
        }
    }
    }
        
        
#Preview {
    ContentView()
}
