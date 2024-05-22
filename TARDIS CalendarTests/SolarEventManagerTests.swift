//
//  SolarEventManagerTests.swift
//  TARDIS CalendarTests
//
//  Created by Monty Harper on 5/3/24.
//

import XCTest
@testable import TARDIS_Calendar

final class SolarEventManagerTests: XCTestCase {

    func testFetchSolarDaysFromBackup() {
        
        // Arrange
        let minDay = Date.now
        let manager = SolarEventManager()
        
        // Act
        manager.fetchSolarDaysFromBackup(minDay: minDay)
        
        // Assert
        XCTAssertGreaterThan(manager.solarDays.count, 0)
    }

}
