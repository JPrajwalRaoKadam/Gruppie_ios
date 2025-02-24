//
//  MISInstitutionModel.swift
//  Groupie
//
//  Created by Jailove on 05/07/24.
//  Copyright © 2024 Jailove Mewara. All rights reserved.
//

class MISInstitutionModel{

    var name : String!
    var image : String!

//    init(value: String) {
//            self.value = value
//        }

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        name = dictionary["name"] as? String
        image = dictionary["image"] as? String
    }

}
