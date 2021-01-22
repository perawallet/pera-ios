//
//  algorand_tests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 7.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest
import CoreData

@testable import algorand_staging

class DBDecodeTests: XCTestCase {

    var applicationConfiguration: ApplicationConfiguration?

    override func tearDown() {
        super.tearDown()
        clearData()
    }

    func testApplicationConfiguration() {
        setupData(isUserUpdated: false)
        setApplicationConfiguration()
        XCTAssertNotNil(applicationConfiguration)
    }

    func testModifiedUser() {
        setupData(isUserUpdated: true)
        setApplicationConfiguration()
        XCTAssertNotNil(applicationConfiguration)
    }

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))]) else {
            fatalError("Error")
        }
        return managedObjectModel
    }()

    private lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "algorand", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition( description.type == NSInMemoryStoreType )
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
}

extension DBDecodeTests {
    private func setApplicationConfiguration() {
        let entityName = ApplicationConfiguration.entityName
        guard ApplicationConfiguration.hasResult(entity: entityName, in: mockPersistantContainer) else {
            return
        }

        let result = ApplicationConfiguration.fetchAllSyncronous(entity: entityName, in: mockPersistantContainer)

        switch result {
        case .result(let object):
            applicationConfiguration = object as? ApplicationConfiguration
        case .results(let objects):
            if let configuration = objects.first(where: { appConfig -> Bool in
                if appConfig is ApplicationConfiguration {
                    return true
                }
                return false
            }) as? ApplicationConfiguration {
                applicationConfiguration = configuration
            }
        case .error:
            break
        }
    }
}

extension DBDecodeTests {
    var userBase64: String {
        """
            eyJhY2NvdW50cyI6W3sicmVjZWl2ZXNOb3RpZmljYXRpb24iOnRydWUsIm5hbWUiOiJDaGFzZSIsInR5cGUiOiJzdGFuZGFyZCIsImFkZHJlc3MiOiJUNEVXQkRXUEV
            YTkxFSUxLTEQ3NFJCTE80SEZFR1k1MjJFTEhXNkpJR0NOUlg1VElTVUhDVVU2UVJNIn0seyJyZWNlaXZlc05vdGlmaWNhdGlvbiI6ZmFsc2UsIm5hbWUiOiJDbG9zZ
            SIsInR5cGUiOiJzdGFuZGFyZCIsImFkZHJlc3MiOiJGUENDWUxNMlBCTEZTM1RKRk9OM1lGMlJHVlBGNVlYSUZJUldJQ0Y2QVJSV1FCSTdHWEtIUDI1NzJJIn0seyJy
            ZWNlaXZlc05vdGlmaWNhdGlvbiI6dHJ1ZSwibmFtZSI6IlZlbnVlIiwidHlwZSI6InN0YW5kYXJkIiwiYWRkcmVzcyI6IlgyWUhRVTdXNk9KRzY2VE1MTDNQWjdKUVM
            yRDQyWUVHQVRCQk5EWEgyMlE2SlNOT0ZSNkxWWllYWE0ifV0sImRldmljZUlkIjoiMzM2ODk5OTc3MTQxMzI0MTM2MiIsImRlZmF1bHROb2RlIjoidGVzdG5ldCJ9
        """
    }

    var latestUserBase64: String {
        """
            ewogICJhY2NvdW50cyI6IFsKICAgIHsKICAgICAgImFkZHJlc3MiOiAiVDRFV0JEV1BFWE5MRUlMS0xENzRSQkxPNEhGRUdZNTIyRUxIVzZKSUdDTlJYNVRJU1VIQ1V
            VNlFSTSIsCiAgICAgICJyZWNlaXZlc05vdGlmaWNhdGlvbiI6IHRydWUsCiAgICAgICJuYW1lIjogIkNoYXNlIiwKICAgICAgInR5cGUiOiAic3RhbmRhcmQiCiAgIC
            B9LAogICAgewogICAgICAiYWRkcmVzcyI6ICJGUENDWUxNMlBCTEZTM1RKRk9OM1lGMlJHVlBGNVlYSUZJUldJQ0Y2QVJSV1FCSTdHWEtIUDI1NzJJIiwKICAgICAgI
            nJlY2VpdmVzTm90aWZpY2F0aW9uIjogZmFsc2UsCiAgICAgICJuYW1lIjogIkNsb3NlIiwKICAgICAgInR5cGUiOiAic3RhbmRhcmQiCiAgICB9LAogICAgewogICAg
            ICAiYWRkcmVzcyI6ICJYMllIUVU3VzZPSkc2NlRNTEwzUFo3SlFTMkQ0MllFR0FUQkJORFhIMjJRNkpTTk9GUjZMVlpZWFhNIiwKICAgICAgInJlY2VpdmVzTm90aWZ
            pY2F0aW9uIjogdHJ1ZSwKICAgICAgIm5hbWUiOiAiVmVudWUiLAogICAgICAidHlwZSI6ICJzdGFuZGFyZCIKICAgIH0sCiAgICB7CiAgICAgICJhZGRyZXNzIjogIj
            Y0RzRGU0hWWEozTk5VRFpIWE9MTU5VUTIyWU1VSE80N0wzVVRJTVhBRFhEQ05LTkZUTDUyMjJJNEEiLAogICAgICAicmVjZWl2ZXNOb3RpZmljYXRpb24iOiB0cnVl
            LAogICAgICAibmFtZSI6ICJSZWtleWVkIE5hbWUiLAogICAgICAidHlwZSI6ICJyZWtleWVkIiwKICAgICAgInJla2V5RGV0YWlsIiA6IHsKICAgICAgICAiT0E1VzN
            SWjRGTUJKM0dEQ1pQRTNDV09QU1hXRlVQNEpET0lNU09PSlpKWjdBSURXV1ZKWjJZNzdCNCIgOiB7CiAgICAgICAgICAiaWQiIDogIjI4Njc3MTRFLUZGRDYtMjI4NS
            00OTBDLTdFN0I3MTJCMDU2NSIsCiAgICAgICAgICAibmFtZSIgOiAiXGJOYW5vIFggODY5NiIsCiAgICAgICAgICAiaW5kZXgiIDogMAogICAgICAgIH0KICAgICAgf
            QogICAgfQogIF0sCiAgImRlZmF1bHROb2RlIjogInRlc3RuZXQiLAogICJkZXZpY2VJZCI6ICIzMzY4OTk5NzcxNDEzMjQxMzYyIgp9Cg==
        """
    }

    private func setupData(isUserUpdated: Bool) {
        guard let userData = Data(base64Encoded: isUserUpdated ? latestUserBase64 : userBase64, options: .ignoreUnknownCharacters) else {
            return
        }

        ApplicationConfiguration.create(
            entity: ApplicationConfiguration.entityName,
            with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData],
            in: mockPersistantContainer
        )
    }

    private func clearData() {
        applicationConfiguration?.remove(entity: ApplicationConfiguration.entityName, in: mockPersistantContainer)
    }
}
