//
//  LearnMode.swift
//  HocLaiXe
//
//  Created by Admin on 7/26/16.
//  Copyright © 2016 Han Luong. All rights reserved.
//

import UIKit

class LearnMode: NSObject {
    
    let title: String
    let questionType: String
    let numberOfQuestion: Int
    let numberOfAnswerCompleted: Int
    
    init(title: String, questionType: String, numQuest: Int, numAnswer: Int) {
        self.title = title
        self.questionType = questionType
        self.numberOfQuestion = numQuest
        self.numberOfAnswerCompleted = numAnswer
    }
    
//    func getNumberOfQuestion() -> Int {
//        return 10
//    }
//
//    func getNumberOfAnsersCompleted() -> Int {
//        return 5
//    }
}
