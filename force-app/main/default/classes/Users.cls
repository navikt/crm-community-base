public with sharing class Users extends ApplicationDomain {
    public Users(){
        super(new List<User>());
    }

    public Users(List<User> users){
        super(users);
    }

    public User createCommunityUser(ContactWrapper contact, Id profileId){
        User user=new User();
        user.FirstName=contact.firstName;
        user.LastName=contact.lastName;
        user.Username=contact.contactId + '@nav.portal';
        user.Email=contact.contactId + '@nav.portal';
        String contactIdString=(String)contact.contactId;
        user.Alias=contactIdString.right(8);
        user.TimeZoneSidKey = 'Europe/Paris';
        user.LocaleSidKey = 'no_NO';
        user.LanguageLocaleKey = 'no';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId=profileId;
        user.ContactId=contact.contactId;
        insert user;
        return user;
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Users(sObjectList);
        }
    }
}