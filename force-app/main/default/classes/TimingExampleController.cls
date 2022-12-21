public with sharing class TimingExampleController {

	@AuraEnabled
	public static List<Contact> getContacts(Integer sizeLimit) {
		return [SELECT Id, Name, Email, Phone FROM Contact LIMIT :sizeLimit];
	}

}