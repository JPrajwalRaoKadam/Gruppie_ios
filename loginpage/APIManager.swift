//
//  APIManager.swift
//  loginpage
//
//  Created by apple on 11/02/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    // Define the base URL here
    let baseURL = "https://demo.gruppie.in/api/v1/"
    
    private init() {} // Prevents others from creating another instance
}


//{
//    "data": [
//        {
//            "dob": "2019-08-23",
//            "attendanceString": "34/44",
//            "percentage": 0.0,
//            "admissionNumber": "",
//            "fatherNumber": "",
//            "studentName": "AADHYASHREE.S",
//            "subjectMarksDetails": [
//                {
//                    "type": "grades",
//                    "subjectPriority": 4,
//                    "subjectName": "I ENJOY MY WORK",
//                    "subjectId": "66a8911c7864a70239388973",
//                    "subMarks": [],
//                    "startTime": "01:01 AM",
//                    "obtainedMarks": "0",
//                    "isLanguage": false,
//                    "endTime": "01:01 AM",
//                    "date": "03-02-2024",
//                    "canPost": false
//                },
//                {
//                    "type": "grades",
//                    "subjectPriority": 5,
//                    "subjectName": "I DO MY WORK CAREFULLY",
//                    "subjectId": "66a8911c7864a70239388975",
//                    "subMarks": [],
//                    "startTime": "01:01 AM",
//                    "obtainedMarks": "A",
//                    "isLanguage": false,
//                    "endTime": "01:01 AM",
//                    "date": "undefined-undefined-undefined",
//                    "canPost": false
//                }
//            ],
//            "motherNumber": "",
//            "sectionHeadings": [],
//            "totalAttendance": null,
//            "studentImage": "https://gruppiemedia.sgp1.digitaloceanspaces.com/images/gruppie_20_06_2024_01_03_32176.jpg",
//            "fatherName": "SHIVASHANKARA.V. L",
//            "optionalSubjects": null,
//            "totalNumberOfAbsent": null,
//            "passClass": "FAIL",
//            "totalMaxMarks": "0",
//            "noteForMarkscard": null,
//            "address": "# 889-3 2ND FLOOR 11TH MAIN RO",
//            "remarks": null,
//            "examDuration": "23-10-2024 to 23-10-2024",
//            "totalPresent": null,
//            "totalMinMarks": "0",
//            "rollNumber": "6669",
//            "totalObtainedMarks": 0,
//            "examTitle": "FA3",
//            "totalNumberOfPresent": null,
//            "motherName": "MANGALA GOWRI",
//            "satsNumber": "",
//            "section": [
//                {
//                    "value": "6565",
//                    "title": ""
//                }
//            ],
//            "offlineTestExamId": "6718aa997864a76cdd22096b",
//            "userId": "6601467344599b18ba6bf92d",
//            "phone": "+918197029701",
//            "imageNumber": null,
//            "grade": "E",
//            "hallticketNumber": null
//        },
//        {
//            "dob": "2019-08-23",
//            "attendanceString": "34/44",
//            "percentage": 0.0,
//            "admissionNumber": "",
//            "fatherNumber": "",
//            "studentName": "AADHYASHREE.S",
//            "subjectMarksDetails": [
//                {
//                    "type": "grades",
//                    "subjectPriority": 4,
//                    "subjectName": "I ENJOY MY WORK",
//                    "subjectId": "66a8911c7864a70239388973",
//                    "subMarks": [],
//                    "startTime": "01:01 AM",
//                    "obtainedMarks": "0",
//                    "isLanguage": false,
//                    "endTime": "01:01 AM",
//                    "date": "03-02-2024",
//                    "canPost": false
//                },
//                {
//                    "type": "grades",
//                    "subjectPriority": 5,
//                    "subjectName": "I DO MY WORK CAREFULLY",
//                    "subjectId": "66a8911c7864a70239388975",
//                    "subMarks": [],
//                    "startTime": "01:01 AM",
//                    "obtainedMarks": "A",
//                    "isLanguage": false,
//                    "endTime": "01:01 AM",
//                    "date": "undefined-undefined-undefined",
//                    "canPost": false
//                }
//            ],
//            "motherNumber": "",
//            "sectionHeadings": [],
//            "totalAttendance": null,
//            "studentImage": "https://gruppiemedia.sgp1.digitaloceanspaces.com/images/gruppie_20_06_2024_01_03_32176.jpg",
//            "fatherName": "SHIVASHANKARA.V. L",
//            "optionalSubjects": null,
//            "totalNumberOfAbsent": null,
//            "passClass": "FAIL",
//            "totalMaxMarks": "0",
//            "noteForMarkscard": null,
//            "address": "# 889-3 2ND FLOOR 11TH MAIN RO",
//            "remarks": null,
//            "examDuration": "23-10-2024 to 23-10-2024",
//            "totalPresent": null,
//            "totalMinMarks": "0",
//            "rollNumber": "6669",
//            "totalObtainedMarks": 0,
//            "examTitle": "FA3",
//            "totalNumberOfPresent": null,
//            "motherName": "MANGALA GOWRI",
//            "satsNumber": "",
//            "section": [
//                {
//                    "value": "6565",
//                    "title": ""
//                }
//            ],
//            "offlineTestExamId": "6718aa997864a76cdd22096b",
//            "userId": "6601467344599b18ba6bf92d",
//            "phone": "+918197029701",
//            "imageNumber": null,
//            "grade": "E",
//            "hallticketNumber": null
//        }
//    ]
//}
