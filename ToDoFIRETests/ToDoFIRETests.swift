//
//  ToDoFIRETests.swift
//  ToDoFIRETests
//
//  Created by Zhanibek Bakyt on 05.02.2025.
//

import Testing
@testable import ToDoFIRE

struct ToDoFIRETests {
    
    @Test
    func testTaskInitialization() throws {
        let task = Task(title: "Test", userId: "001")
        #expect(task.title == "Test")
        #expect(task.userId == "001")
        #expect(task.completed == false)
        #expect(task.ref == nil)
    }

    @Test
    func testConvertToDictionary() throws {
        let task = Task(title: "Do homework", userId: "002")
        let dict = task.convertToDictionary() as! [String: Any]
        #expect(dict["title"] as? String == "Do homework")
        #expect(dict["userId"] as? String == "002")
        #expect(dict["completed"] as? Bool == false)
    }
    
    @Test
    func testCompletedFlagChange() throws {
        var task = Task(title: "Walk the dog", userId: "007")
        task.completed = true
        
        #expect(task.title == "Walk the dog")
        #expect(task.userId == "007")
        #expect(task.completed == true)
    }

}
