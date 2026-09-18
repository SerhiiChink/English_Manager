//
//  EditProfileViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

final class EditProfileViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: EditProfileViewModel!
    private var mockFirestoreService: MockFirestoreService!
    private var mockStorageService: MockStorageService!
    private var initialUser: User!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockFirestoreService = MockFirestoreService()
        mockStorageService = MockStorageService()
        initialUser = User(
            id: "user_123",
            name: "John",
            surname: "Doe",
            email: "john@example.com",
            role: .student
        )
        mockFirestoreService.users[initialUser.id] = initialUser
        sut = EditProfileViewModel(
            user: initialUser,
            firestoreService: mockFirestoreService,
            storageService: mockStorageService
        )
    }

    override func tearDown() {
        sut = nil
        mockFirestoreService = nil
        mockStorageService = nil
        initialUser = nil
        super.tearDown()
    }
    
    // MARK: - Save Tests
    func testSaveSuccessTriggersSuccessCallbackAndUpdatesFirestoreUser() {
        let expectation = expectation(description: "Save Profile Success")
        var loadingStates: [Bool] = []
        sut.onLoading = { isLoading in
            loadingStates.append(isLoading)
        }
        sut.onSuccess = {
            expectation.fulfill()
        }
        sut.save(name: "NewName", surname: "NewSurname")
        waitForExpectations(timeout: 1.0)
        let updatedUser = mockFirestoreService.users["user_123"]
        XCTAssertEqual(updatedUser?.name, "NewName")
        XCTAssertEqual(updatedUser?.surname, "NewSurname")
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testSaveEmptyNameTriggersErrorCallback() {
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
        }
        sut.save(name: "", surname: "NewSurname")
        XCTAssertEqual(errorMessage, "Name is empty")
        let userInFirestore = mockFirestoreService.users["user_123"]
        XCTAssertEqual(userInFirestore?.name, "John")
    }

    // MARK: - Save Error Test
    func testSaveErrorTriggersErrorCallback() {
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "Save Profile Error")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
            exp.fulfill()
        }
        sut.save(name: "NewName", surname: "NewSurname")
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(errorMessage, "Mock Firestore Error")
    }

    // MARK: - Upload Avatar Tests
    func testUploadAvatarSuccessUpdatesUserPhotoURL() {
        let expectation = expectation(description: "Upload Avatar Success")
        let dummyData = Data([0x00, 0x01, 0x02])
        var loadingStates: [Bool] = []
        sut.onLoading = { isLoading in
            loadingStates.append(isLoading)
            if !isLoading { expectation.fulfill() }
        }
        sut.uploadAvatar(dummyData)
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockStorageService.uploadAvatarCalledWith?.userId, "user_123")
        XCTAssertEqual(mockStorageService.uploadAvatarCalledWith?.imageData, dummyData)
        let updatedUserInFirestore = mockFirestoreService.users["user_123"]
        XCTAssertEqual(updatedUserInFirestore?.photoURL, mockStorageService.mockedAvatarURL)
        XCTAssertEqual(sut.user.photoURL, mockStorageService.mockedAvatarURL)
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testUploadAvatarErrorTriggersErrorCallback() {
        mockStorageService.shouldReturnError = true
        let expectation = expectation(description: "Upload Avatar Error")
        let dummyData = Data([0x00, 0x01, 0x02])
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
            expectation.fulfill()
        }
        sut.uploadAvatar(dummyData)
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(errorMessage, "Mock Storage Upload Error")
        XCTAssertNil(sut.user.photoURL)
    }
}
