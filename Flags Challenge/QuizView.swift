//
//  QuizView.swift
//  Flags Challenge
//
//  Created by mac on 22/09/2025.
//


import SwiftUI
import Combine

struct ChallengeView:View {
    @State private var currentIndex: Int = 0
    @State private var score = 0
    @State private var selectedId: Int? = nil
    @State private var isCorrect: Bool? = nil
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var questions: [Question] = []
    
    @State private var countdown: Int = 30
    @State private var showCorrectAnswer: Bool = false
    @State private var timerCancellable: AnyCancellable?
    @State private var isInteractionDisabled = false
    @State private var displayText = "GAME OVER"
      
      var body: some View {
          let screenWidth = UIScreen.main.bounds.width
          
          VStack(spacing: 0) {
              
              HeadderTimer(timer: countdown)
              Rectangle()
                              .fill(Color.gray)
                              .frame(width: screenWidth, height: 0.5)
                              .padding(.top,0)
              QuestionCountView(count: currentIndex + 1 )
              Spacer()
              // Questions
              if questions.isEmpty {
                             Text("Loading questions...")
                         } else if currentIndex < questions.count {
                             QuestionView(
                               question: questions[currentIndex],
                               selectedId: $selectedId,
                               isCorrect: $isCorrect,
                               showCorrectAnswer: $showCorrectAnswer,
                               isInteractionDisabled: isInteractionDisabled,
                               onAnswerSelected: answerTapped
                             )
                         } else {
                             Text(displayText)
                                 .font(.largeTitle)
                                 .foregroundColor(.black)
                                 .onAppear {
                                     stopTimer()
                                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                         displayText = "SCORE - \(score) / 15"
                                     }
                                 }
                         }
              Spacer()
          }
          .frame(width: screenWidth - 10, height: 300)
          .background(Color("BackGroundColour"))
          .cornerRadius(10)
          .overlay(
              RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.black, lineWidth: 0.5)
          )
          .onAppear{
              loadQuestions()
              startQuestionTimer()
          }
      }
    func stopTimer(){
        countdown = 0
        timerCancellable?.cancel()
    }
    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "Questions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(QuestionResponse.self, from: data)
                self.questions = response.questions
            } catch {
                print("Error loading questions: \(error)")
            }
        }
    }
    func startQuestionTimer() {
            countdown = 30
            showCorrectAnswer = false
            timerCancellable?.cancel()
            
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if countdown > 0 {
                        countdown -= 1
                    } else {
                        timerCancellable?.cancel()
                        showCorrectAnswer = true
                        startAnswerTimer()
                    }
                }
        }
    func startAnswerTimer() {
        countdown = 10
        timerCancellable?.cancel()
        isInteractionDisabled = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    timerCancellable?.cancel()
                    isInteractionDisabled = false
                    moveToNextQuestion()
                }
            }
    }
    private func goToNextQuestion() {
           startAnswerTimer()
           DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
               selectedId = nil
               isCorrect = nil
               currentIndex += 1
               
           }
       }
    private func moveToNextQuestion() {
           selectedId = nil
           isCorrect = nil
           showCorrectAnswer = false
           currentIndex += 1
           
           if currentIndex < questions.count {
               startQuestionTimer()
           }
       }
   private func answerTapped(selectedCountryId: Int) {
        timerCancellable?.cancel()
        selectedId = selectedCountryId
        isCorrect = (selectedCountryId == questions[currentIndex].answer_id)
       if selectedCountryId == questions[currentIndex].answer_id{
           score += 1
       }
        showCorrectAnswer = true
        isInteractionDisabled = true
        startAnswerTimer()
    }

}

struct QuestionView: View {
    let question: Question
    @Binding var selectedId: Int?
    @Binding var isCorrect: Bool?
    @Binding var showCorrectAnswer: Bool
    var isInteractionDisabled: Bool
    
    var onAnswerSelected: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Image(uiImage: UIImage(named: question.country_code) ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            VStack(spacing: 12) {
                ForEach(question.countries.prefix(2)) { country in
                    AnswerButton(
                        country: country,
                        correctAnswerId: question.answer_id,
                        selectedId: $selectedId,
                        isCorrect: $isCorrect,
                        showCorrectAnswer: $showCorrectAnswer,
                        isInteractionDisabled: isInteractionDisabled,
                        onAnswerSelected: onAnswerTapped
                    )
                }
            }
            
            VStack(spacing: 12) {
                ForEach(question.countries.suffix(2)) { country in
                    AnswerButton(
                        country: country,
                        correctAnswerId: question.answer_id,
                        selectedId: $selectedId,
                        isCorrect: $isCorrect,
                        showCorrectAnswer: $showCorrectAnswer,
                        isInteractionDisabled: isInteractionDisabled,
                        onAnswerSelected: onAnswerTapped
                    )
                }
            }
        }
        .padding()
    }
    
    private func onAnswerTapped(selectedCountryId: Int) {
        onAnswerSelected(selectedCountryId)
    }
}

struct AnswerButton: View {
    let country: Country
    let correctAnswerId: Int
    @Binding var selectedId: Int?
    @Binding var isCorrect: Bool?
    @Binding var showCorrectAnswer: Bool
    var isInteractionDisabled: Bool
    var onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {
                guard selectedId == nil else { return }
                selectedId = country.id
                isCorrect = (country.id == correctAnswerId)
                onAnswerSelected(country.id)
            }) {
                Text(country.country_name)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 110, height: 30)
                    .background(
                        (selectedId == country.id && isCorrect == false) ? Color("CustomOrange"):
                        Color.clear
                    )

                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                showCorrectAnswer && country.id == correctAnswerId ? Color.green :
                                selectedId == country.id && isCorrect == true ? Color.green :
                                selectedId == country.id && isCorrect == false ? Color("CustomOrange") : Color.black,
                                lineWidth: 1
                            )
                    )
            }
            .disabled(isInteractionDisabled)
            if selectedId == country.id || (showCorrectAnswer && country.id == correctAnswerId) {
                Text(
                    country.id == correctAnswerId ? "CORRECT" :
                    (selectedId == country.id && isCorrect == false ? "WRONG" : "")
                )
                .foregroundColor(
                    country.id == correctAnswerId ? .green :
                    (selectedId == country.id && isCorrect == false ? .red : .clear)
                )
                .font(.system(size: 10))
            }
        }
    }
}
