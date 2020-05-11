//
//  ContentView.swift
//  BetterRest
//
//  Created by Josh Franco on 5/9/20.
//  Copyright © 2020 Josh Franco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmonut = 0
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    static private var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private var predictedBedtime: String {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let min = (components.minute ?? 0) * 60
        
        let prediction = try? model.prediction(wake: Double(hour + min),
                                               estimatedSleep: sleepAmount,
                                               coffee: Double(coffeeAmonut))
        
        if let prediction = prediction {
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return "Your ideal bed time is \(formatter.string(from: sleepTime))"
        } else {
            return "Sorr, there was a problem calculating your bedtime..."
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("When do you want to wake up?").font(.headline)) {
                        DatePicker("Please Enter a Time",
                                   selection: $wakeUp,
                                   displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    Section(header: Text("Desired amount of Sleep").font(.headline)) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g")")
                        }
                    }
                    
                    Section(header: Text("Daily coffee intake").font(.headline)) {
                        Picker("\(coffeeAmonut) \(coffeeAmonut == 1 ? "cup" : "cups")", selection: $coffeeAmonut) {
                            ForEach(0..<21) { cups in
                                Text("\(cups) \(cups == 1 ? "cup": "cups")")
                            }
                        }
                    }
                }
                
                Spacer()
                
                Text("\(predictedBedtime)")
                    .font(.headline)
                
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calcBettime) {
                    Text("Calc")
                }
            )
                
                .alert(isPresented: $showingAlert) { () -> Alert in
                    Alert(title: Text(alertTitle),
                          message: Text(alertMsg),
                          dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Private Methods
private extension ContentView {
    func calcBettime() {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let min = (components.minute ?? 0) * 60
        
        let prediction = try? model.prediction(wake: Double(hour + min),
                                               estimatedSleep: sleepAmount,
                                               coffee: Double(coffeeAmonut))
        
        if let prediction = prediction {
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMsg = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bed time is..."
        } else {
            alertTitle = "Error"
            alertMsg = "Sorr, there was a problem calculating your bedtime..."
        }
        
        showingAlert = true
    }
}

// MARK: - Prevews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
