//
//  ScoreView.swift
//  Flags Challenge
//
//  Created by mac on 22/09/2025.
//


import SwiftUI

struct ScoreView: View {
    var score: Int
    var totalQuestions: Int

    var body: some View {
        VStack {
            Text("GAME OVER")
                .font(.largeTitle)
                .padding()
            Text("SCORE: \(score)/\(totalQuestions)")
                .font(.title)
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(score: 10, totalQuestions: 15)
    }
}
