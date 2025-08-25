public class AssociatedLocationTriggerHelper {
    public static void handleAfterInsertAccountTeamMember(List<Associated_location__c> newAssociatedLocations){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<String, Associated_location__c> uniqueAssociatedLocationsMap = new Map<String, Associated_location__c>();
        for(Associated_location__c associatedLocation : newAssociatedLocations) {
            accountIds.add(associatedLocation.Account__c);
            userIds.add(associatedLocation.User__c);
            uniqueAssociatedLocationsMap.put(associatedLocation.Account__c + '-' + associatedLocation.User__c, associatedLocation);
        }

        List<AccountTeamMember> accountTeamMembers = [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND UserId IN :userIds];
        Map<String, AccountTeamMember> accountTeamMemberMap = new Map<String, AccountTeamMember>();
        for(AccountTeamMember accountTeamMember : accountTeamMembers) {
            accountTeamMemberMap.put(accountTeamMember.AccountId + '-' + accountTeamMember.UserId, accountTeamMember);
        }

        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
        for(Associated_location__c uniqueAssociatedLocation : uniqueAssociatedLocationsMap.values()) {
            AccountTeamMember accountTeamMember = accountTeamMemberMap.get(uniqueAssociatedLocation.Account__c + '-' + uniqueAssociatedLocation.User__c);
            if(accountTeamMember == null) {
                newAccountTeamMembers.add(new AccountTeamMember(
                    AccountId = uniqueAssociatedLocation.Account__c,
                    UserId = uniqueAssociatedLocation.User__c
                ));
            }
        }

        insert newAccountTeamMembers;
    }

    public static void handleAfterUpdateAccountTeamMember(List<Associated_location__c> newAssociatedLocations, Map<Id,Associated_Location__c> oldAssociatedLocations){
        
    }

    public static void handleAfterDeleteAccountTeamMember(List<Associated_location__c> oldAssociatedLocations){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Associated_location__c associatedLocation : oldAssociatedLocations) {
            accountIds.add(associatedLocation.Account__c);
            userIds.add(associatedLocation.User__c);
        }

        List<Associated_location__c> associatedLocations = [SELECT Id, Account__c, User__c FROM Associated_location__c WHERE Account__c IN :accountIds AND User__c IN :userIds];
        Map<String, Associated_location__c> associatedLocationMap = new Map<String, Associated_location__c>();
        for(Associated_location__c associatedLocation : associatedLocations) {
            associatedLocationMap.put(associatedLocation.Account__c + '-' + associatedLocation.User__c, associatedLocation);
        }

        List<AccountTeamMember> accountTeamMembersToDelete = new List<AccountTeamMember>();
        for(AccountTeamMember accountTeamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND UserId IN :userIds]) {
            Associated_location__c associatedLocation = associatedLocationMap.get(accountTeamMember.AccountId + '-' + accountTeamMember.UserId);
            if(associatedLocation == null) {
                accountTeamMembersToDelete.add(new AccountTeamMember(Id=accountTeamMember.Id));
            }
        }
        delete accountTeamMembersToDelete;
    }
}
