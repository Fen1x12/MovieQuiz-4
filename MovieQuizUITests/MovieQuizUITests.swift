import XCTest

var app: XCUIApplication!

final class MovieQuizUITests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        sleep(2 )
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstQuestion = app.staticTexts["question"]
        
        app.buttons["Yes"].tap()
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondQuestion = app.staticTexts["question"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstQuestion, secondQuestion)
    }
    
    func testNoButton() {
        sleep(2)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let firstQuestion = app.staticTexts["question"]
        
        app.buttons["No"].tap()
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let secondQuestion = app.staticTexts["question"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstQuestion, secondQuestion)
    }
    
    func testGameAlert() {
        let yesButton = app.buttons["Yes"]
        let noButton = app.buttons["No"]
        let numberOfTaps: UInt8 = 10
        let alert = app.alerts["Game result"]
        
        sleep(2)
        
        for _ in 1...numberOfTaps {
            let random = arc4random_uniform(2)
            if random == 0 {
                noButton.tap()
                print("Tapped on No button")
            } else {
                yesButton.tap()
                print("Tapped on Yes button")
            }
            sleep(2)
        }
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
}
