//
//  ContentView.swift
//  Flags Challenge
//
//  Created by mac on 22/09/2025.
//

import SwiftUI
import Combine

import SwiftUI

struct ContentView: View {
    @State private var challengeTime = Date()
    @State private var isChallengeScheduled = false
    @State private var countdown: Int = 20
    @State private var isChallengeStarted = false
    @State private var isTimeSelected = false
    
    let screenWidth = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                LinearGradient(colors: [.white,.white],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                Rectangle()
                               .fill(Color("CustomOrange"))
                               .frame(height: 50)
                               .ignoresSafeArea(edges: .top)
                VStack{
                    if isChallengeStarted {
                        ChallengeView()
                    }
                    else if isChallengeScheduled {
                        VStack(spacing: 0){
                            HeadderTimer(timer: 0)
                            Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: screenWidth, height: 0.5)
                                            .padding(.top,0)
                            Spacer()
                            Text("CHALLENGE WILL START IN")
                                .font(.title)
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                            Text("00:\(String(format: "%02d", countdown))")
                                .font(.title)
                                .foregroundColor(Color.gray)
                                .onReceive(timer) { _ in
                                    if self.countdown > 0 {
                                        self.countdown -= 1
                                    } else {
                                        self.isChallengeStarted = true
                                    }
                                }
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                            Spacer()
                            Spacer()
                        }
                        .frame(width: screenWidth - 10, height: 350)
                        .background(Color("BackGroundColour"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        
                    }else{
                        if !isTimeSelected{
                            VStack(spacing: 0){
                                HeadderTimer(timer: 0)
                                Rectangle()
                                                .fill(Color.gray)
                                                .frame(width: screenWidth, height: 0.5)
                                                .padding(.top,0)
                                Spacer()
                                Text("Challenge Schedule")
                                    .font(.system(size: 32,weight: .medium,design: .default))
                                    .padding()

                                DatePicker("Select Time -", selection: $challengeTime,in: Date()..., displayedComponents: .hourAndMinute)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding(.trailing, 50)
                                    .padding(.leading, 50)
                                Spacer()
                                Button("Save") {
                                    scheduleChallenge()
                                }
                                .padding()
                                .frame(width: 280, height: 50, alignment: .center)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .font(.system(size: 20,weight: .bold, design: .default))
                                .cornerRadius(8)
                                Spacer()
                            }
                            .frame(width: screenWidth - 10, height: 350)
                            .background(Color("BackGroundColour"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            
                        }else{
                            Text("Selected Time: \(challengeTime, formatter: timeFormatter)")
                                               .font(.title2)
                                               .padding()
                        }
                    }
                    Spacer()
                }
                .padding(.top,20)
            }
        }
    }
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    func scheduleChallenge() {
        let timeInterval = challengeTime.timeIntervalSinceNow
        if timeInterval > 20 {
            Timer.scheduledTimer(withTimeInterval: timeInterval - 20, repeats: false) { _ in
                self.isChallengeScheduled = true
            }
        } else if timeInterval > 0 {
            self.countdown = Int(timeInterval)
            self.isChallengeScheduled = true
        }
        self.isTimeSelected = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct HeadderTimer: View {
    var timer:Int
    var body: some View {
        HStack{
            
            Text("00:\(timer)")
                .font(.system(size: 20,weight: .bold))
                .frame(width: 80, height: 70)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            Spacer()
            Text("Flags Challenge")
                .font(.system(size: 24,weight: .bold))
                .foregroundColor(Color("CustomOrange"))
            Spacer()
            Spacer()
        }
    }
}

struct QuestionCountView: View {
    var count:Int
    let screenWidth = UIScreen.main.bounds.width
    var body: some View {
        HStack{
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                        .frame(width: 70, height: 55)
                    Text("\(count)")
                        .font(.system(size: 20,weight: .bold))
                        .frame(width: 50, height: 50)
                        .background(Color("CustomOrange"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
            
            Spacer(minLength: 20)
            Text("GUESS THE COUNTRY FROM THE FLAG?")
                .font(.system(size: 15,weight: .medium))
                .frame(width: screenWidth - 90, height: 70)
                .foregroundColor(.black)
                .cornerRadius(10)
        }
    }
}
