//
//	RootClass.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

class CommunicationModel{

	var groupId : String!
	var image : String!
	var kanName : String!
	var name : String!
	var type : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		groupId = dictionary["groupId"] as? String
		image = dictionary["image"] as? String
		kanName = dictionary["kanName"] as? String
		name = dictionary["name"] as? String
		type = dictionary["type"] as? String
	}

}
