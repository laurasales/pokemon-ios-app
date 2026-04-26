import XCTest

final class PokemonListUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Launch

    func test_launch_showsPokedexTitle() {
        XCTAssertTrue(app.navigationBars["Pokédex"].waitForExistence(timeout: 5))
    }

    func test_launch_loadsPokemonList() {
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
    }

    // MARK: - Search

    func test_search_showsSearchPrompt_whenFieldIsActivated() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("b")

        XCTAssertTrue(app.staticTexts["Search Pokémon"].waitForExistence(timeout: 3))
    }

    func test_search_returnsResult_forValidPokemon() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("bulbasaur\n")

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 10))
    }

    func test_search_showsNoResults_forUnknownPokemon() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("zzzzunknown")
        searchField.typeText("\n")

        let noResults = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'No Results'")).firstMatch
        XCTAssertTrue(noResults.waitForExistence(timeout: 15))
    }

    func test_search_clearingText_returnsToList() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("bulbasaur")

        searchField.buttons["Clear text"].tap()

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Detail navigation

    func test_tappingPokemon_navigatesToDetailScreen() {
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()

        let backButton = app.navigationBars.buttons.matching(
            NSPredicate(format: "label == 'Pokédex' OR label == 'Back'")
        ).firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(identifier: "favouriteButton").firstMatch.waitForExistence(timeout: 10))
    }

    func test_detailScreen_backButton_returnsToList() {
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()

        let backButton = app.navigationBars.buttons.matching(
            NSPredicate(format: "label == 'Pokédex' OR label == 'Back'")
        ).firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        XCTAssertTrue(app.navigationBars["Pokédex"].waitForExistence(timeout: 5))
    }

    // MARK: - Favourites

    func test_favouriteButton_togglesState_onDetailScreen() {
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()

        let favouriteButton = app.buttons.matching(identifier: "favouriteButton").firstMatch
        XCTAssertTrue(favouriteButton.waitForExistence(timeout: 10))
        favouriteButton.tap()

        XCTAssertTrue(app.buttons.matching(identifier: "favouriteButton").firstMatch
            .waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.buttons.matching(identifier: "favouriteButton").firstMatch.label,
            "Remove from favourites"
        )
    }
}
