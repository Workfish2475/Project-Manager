import SwiftUI

class TaskEntryModelTest {
    let viewModelTest = TaskEntryModel()
    
    func runTests() {
        testResetState()
        print("All tests run.")
    }
    
    func testResetState() {
        viewModelTest.title = "Testing title"
        viewModelTest.description = "Testing desc"
        viewModelTest.status = .Done
        viewModelTest.priority = .Medium
        
        viewModelTest.resetState()
        
        assert(viewModelTest.title == "", "Test failed: title not reset")
        assert(viewModelTest.description == "", "Test failed: description not reset")
        assert(viewModelTest.status == .Backlog, "Test failed: status not reset")
        assert(viewModelTest.priority == .None, "Test failed: priority not reset")
    }
}
