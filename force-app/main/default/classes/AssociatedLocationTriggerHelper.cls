public class AssociatedLocationTriggerHelper {
    public static void handleAfterInsertAccountTeamMember(List<Associated_Location__c> newAssociatedLocations){
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Associated_location__c associatedLocation : newAssociatedLocations) {
            accountIds.add(associatedLocation.Account__c);
            userIds.add(associatedLocation.User__c);
        }

        List<AccountTeamMember> accountTeamMembers = [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountID IN :accountIds AND UserId IN :userIds];
        

        for(Associated_location__c associatedLocation : newAssociatedLocations){
            Boolean isAssociationLocationExists = false;
            for(AccountTeamMember accountTeamMember : accountTeamMembers) {
                if(accountTeamMember.AccountId == associatedLocation.Account__c && accountTeamMember.UserId == associatedLocation.User__c) {
                    isAssociationLocationExists = true;
                    break;
                }
            }

            if(!isAssociationLocationExists) {
                newAccountTeamMembers.add(new AccountTeamMember(
                    AccountId = associatedLocation.Account__c,
                    UserId = associatedLocation.User__c
                ));
            }
        }

        insert newAccountTeamMembers;
    }

    public static void handleAfterUpdateAccountTeamMember(List<Associated_Location__c> newAssociatedLocations, Map<Id,Associated_Location__c> oldAssociatedLocations){

    }

    public static void handleAfterDeleteAccountTeamMember(List<Associated_Location__c> oldAssociatedLocations){
        List<AccountTeamMember> accountTeamMembersToDelete = new List<AccountTeamMember>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Associated_location__c associatedLocation : oldAssociatedLocations) {
            accountIds.add(associatedLocation.Account__c);
            userIds.add(associatedLocation.User__c);
        }


        List<Associated_location__c> associatedLocations = [SELECT Id, Account__c, User__c FROM Associated_location__c WHERE Account__c IN :accountIds AND User__c IN :userIds];
        
        for(AccountTeamMember accountTeamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND UserId IN :userIds]) {
            Boolean isAssociationLocationExists = false;
            for(Associated_location__c associatedLocation : associatedLocations){
                if(accountTeamMember.AccountId == associatedLocation.Account__c && accountTeamMember.UserId == associatedLocation.User__c) {
                    isAssociationLocationExists = true;
                    break;
                }
            }

            if(!isAssociationLocationExists) {
                accountTeamMembersToDelete.add(new AccountTeamMember(Id=accountTeamMember.Id));
            }
        }

        delete accountTeamMembersToDelete;
    }
}
