//
//  FakeData.swift
//  ACS Contacts
//
//  Created by snow on 9/30/24.
//

import Foundation


func contactsFromJson() async {
    if let db = DatabaseManager.shared.database {
        let contacts: [IndividualContactResponse] = allContacts.map {
            try! JSONDecoder().decode(IndividualContactResponse.self, from: $0.data(using: .utf8)!)
        }
        for apiResponse in contacts {
            do {
                UserDefaults.standard.set(true, forKey: "switchPhotosWithCats")
                let contact = Contact(from: apiResponse)
                try await contact.write(to: db)
                
                for remoteAddress in apiResponse.Addresses {
                    let address = Address(from: remoteAddress, for: contact.indvId)
                    try await address.write(to: db)
                }
                
                for remoteEmail in apiResponse.Emails {
                    let email = Email(from: remoteEmail, for: contact.indvId)
                    try await email.write(to: db)
                }
                
                for remotePhone in apiResponse.Phones {
                    let phone = Phone(from: remotePhone, for: contact.indvId)
                    try await phone.write(to: db)
                }
                
            } catch {
                print("Failed to create contact: \(error)")
            }
        }
    }
}



let allContacts = [
    contactOne,
    contactTwo,
    contactThree,
    contactFour,
    contactFive,
    contactSix,
    contactSeven,
    contactEight,
    contactNine,
]

let contactOne = """
{
    "IndvId": 1,
    "PrimFamily": 1001,
    "LastName": "Smith",
    "FirstName": "John",
    "MiddleName": null,
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Smith, John",
    "FriendlyName": "John Smith",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 101,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "123 Maple St",
            "Address2": null,
            "City": "Springfield",
            "State": "IL",
            "Zipcode": "62704",
            "CityStateZip": "Springfield, IL 62704",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 101,
            "EmailType": "Personal",
            "EmailTypeId": 1,
            "Preferred": true,
            "Email": "johnsmith@testmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 101,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-123-4567",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5551234567,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""

let contactTwo = """
    {
    "IndvId": 2,
    "PrimFamily": 1002,
    "LastName": "Doe",
    "FirstName": "Jane",
    "MiddleName": "A",
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Doe, Jane A",
    "FriendlyName": "Jane Doe",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 102,
            "AddrTypeId": 2,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "456 Elm St",
            "Address2": null,
            "City": "Oakland",
            "State": "CA",
            "Zipcode": "94607",
            "CityStateZip": "Oakland, CA 94607",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 102,
            "EmailType": "Personal",
            "EmailTypeId": 1,
            "Preferred": true,
            "Email": "janedoe@testmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 102,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-987-6543",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5559876543,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactThree = """
    {
    "IndvId": 3,
    "PrimFamily": 1003,
    "LastName": "Johnson",
    "FirstName": "Michael",
    "MiddleName": "B",
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Johnson, Michael B",
    "FriendlyName": "Michael Johnson",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 103,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "789 Oak Ave",
            "Address2": null,
            "City": "Dallas",
            "State": "TX",
            "Zipcode": "75201",
            "CityStateZip": "Dallas, TX 75201",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 103,
            "EmailType": "Work",
            "EmailTypeId": 2,
            "Preferred": true,
            "Email": "mjohnson@workmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 103,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-321-7654",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5553217654,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactFour = """
    {
    "IndvId": 4,
    "PrimFamily": 1004,
    "LastName": "Williams",
    "FirstName": "Sarah",
    "MiddleName": null,
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Williams, Sarah",
    "FriendlyName": "Sarah Williams",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 104,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "234 Pine St",
            "Address2": null,
            "City": "Seattle",
            "State": "WA",
            "Zipcode": "98101",
            "CityStateZip": "Seattle, WA 98101",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 104,
            "EmailType": "Personal",
            "EmailTypeId": 1,
            "Preferred": true,
            "Email": "sarahwilliams@testmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 104,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-654-3210",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5556543210,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactFive = """
    {
    "IndvId": 5,
    "PrimFamily": 1005,
    "LastName": "Brown",
    "FirstName": "Emily",
    "MiddleName": null,
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Brown, Emily",
    "FriendlyName": "Emily Brown",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 105,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "321 Birch Rd",
            "Address2": null,
            "City": "Chicago",
            "State": "IL",
            "Zipcode": "60601",
            "CityStateZip": "Chicago, IL 60601",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 105,
            "EmailType": "Work",
            "EmailTypeId": 2,
            "Preferred": true,
            "Email": "ebrown@workmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 105,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-789-0123",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5557890123,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactSix = """
    {
    "IndvId": 6,
    "PrimFamily": 1006,
    "LastName": "Garcia",
    "FirstName": "Carlos",
    "MiddleName": "L",
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Garcia, Carlos L",
    "FriendlyName": "Carlos Garcia",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 106,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "654 Cedar Blvd",
            "Address2": null,
            "City": "Miami",
            "State": "FL",
            "Zipcode": "33101",
            "CityStateZip": "Miami, FL 33101",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 106,
            "EmailType": "Personal",
            "EmailTypeId": 1,
            "Preferred": true,
            "Email": "cgarcia@testmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 106,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-234-5678",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5552345678,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactSeven = """
    {
    "IndvId": 7,
    "PrimFamily": 1007,
    "LastName": "Martinez",
    "FirstName": "Anna",
    "MiddleName": null,
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Martinez, Anna",
    "FriendlyName": "Anna Martinez",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 107,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "789 Walnut St",
            "Address2": null,
            "City": "Phoenix",
            "State": "AZ",
            "Zipcode": "85001",
            "CityStateZip": "Phoenix, AZ 85001",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 107,
            "EmailType": "Work",
            "EmailTypeId": 2,
            "Preferred": true,
            "Email": "amartinez@workmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 107,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-987-1234",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5559871234,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactEight = """
    {
    "IndvId": 8,
    "PrimFamily": 1008,
    "LastName": "Lee",
    "FirstName": "David",
    "MiddleName": "C",
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Lee, David C",
    "FriendlyName": "David Lee",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 108,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "101 Pine Blvd",
            "Address2": null,
            "City": "Los Angeles",
            "State": "CA",
            "Zipcode": "90001",
            "CityStateZip": "Los Angeles, CA 90001",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 108,
            "EmailType": "Personal",
            "EmailTypeId": 1,
            "Preferred": true,
            "Email": "dlee@testmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 108,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-654-7890",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5556547890,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
let contactNine = """
    {
    "IndvId": 9,
    "PrimFamily": 1009,
    "LastName": "Miller",
    "FirstName": "Sophia",
    "MiddleName": null,
    "GoesbyName": null,
    "Suffix": null,
    "Title": null,
    "FullName": "Miller, Sophia",
    "FriendlyName": "Sophia Miller",
    "PictureUrl": "",
    "FamilyPictureUrl": "",
    "DateOfBirth": "",
    "MemberStatus": "",
    "FamilyPosition": "",
    "UserIsLeaderOf": false,
    "IsCRPending": false,
    "Addresses": [
        {
            "AddrId": 109,
            "AddrTypeId": 1,
            "AddrType": "Home",
            "FamilyAddress": true,
            "ActiveAddress": true,
            "MailAddress": true,
            "StatementAddress": true,
            "Country": "USA",
            "Company": null,
            "Address": "456 Cypress Dr",
            "Address2": null,
            "City": "Atlanta",
            "State": "GA",
            "Zipcode": "30301",
            "CityStateZip": "Atlanta, GA 30301",
            "Latitude": "",
            "Longitude": "",
            "Delete": false
        }
    ],
    "Emails": [
        {
            "EmailId": 109,
            "EmailType": "Work",
            "EmailTypeId": 2,
            "Preferred": true,
            "Email": "smiller@workmail.com",
            "Listed": true,
            "Delete": false
        }
    ],
    "Phones": [
        {
            "PhoneId": 109,
            "Preferred": true,
            "PhoneTypeId": 1,
            "PhoneType": "Cell",
            "FamilyPhone": false,
            "PhoneNumber": "555-321-6549",
            "Extension": null,
            "Listed": true,
            "AddrPhone": false,
            "PhoneRef": 5553216549,
            "Delete": false
        }
    ],
    "FamilyMembers": [],
    "OtherRelationships": []
}
"""
