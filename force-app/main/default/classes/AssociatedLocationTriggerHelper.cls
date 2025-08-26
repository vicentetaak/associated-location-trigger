public class AssociatedLocationTriggerHelper {
    public static void handleAfterInsertAccountTeamMember(List<Associated_location__c> newAssociatedLocations) {
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
            
            if(accountTeamMember == null && String.isNotBlank(uniqueAssociatedLocation.User__c)) {
                newAccountTeamMembers.add(new AccountTeamMember(
                    AccountId = uniqueAssociatedLocation.Account__c,
                    UserId = uniqueAssociatedLocation.User__c
                ));
            }
        }   

        List<Database.SaveResult> results = Database.insert(records, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                System.debug('failed to insert: ' + objectType);
                return false;
            }
        }

        // List<Database.SaveResult> results = Database.insert(records, false); //allOrNone
        // for (Database.SaveResult result : results) {
        //     if (!result.isSuccess() && result.getId()) {
        //         System.debug('failed to insert: ' + objectType);
        //         return false;
        //     }
        // }

        try {
            insert newAccountTeamMembers;
        } catch(Exception e){
            System.debug('Exception occurred while inserting AccountTeamMember: ' + e.getMessage() + e.getStackTraceString());
        }
    }

    public static void handleAfterUpdateAccountTeamMember(List<Associated_location__c> newAssociatedLocations, Map<Id,Associated_Location__c> oldAssociatedLocationsMap){
        Set<Id> newUserIds = new Set<Id>();
        Set<Id> newAccountIds = new Set<Id>();
        Set<Id> oldAccountIds = new Set<Id>();
        Set<Id> oldUserIds = new Set<Id>();
        for(Associated_location__c newAssociatedLocation : newAssociatedLocations) {
            Associated_location__c oldAssociatedLocation = oldAssociatedLocationsMap.get(newAssociatedLocation.Id);
            if(oldAssociatedLocation != null) {
                if(newAssociatedLocation.User__c != oldAssociatedLocation.User__c || newAssociatedLocation.Account__c != oldAssociatedLocation.Account__c) {
                    newUserIds.add(newAssociatedLocation.User__c);
                    newAccountIds.add(newAssociatedLocation.Account__c);
                }
                oldAccountIds.add(oldAssociatedLocation.Account__c);
                oldUserIds.add(oldAssociatedLocation.User__c);
            }
        }

        List<AccountTeamMember> accountsTeamMembers = [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :newAccountIds AND UserId IN :newUserIds];
        List<Associated_location__c> associatedLocations = [SELECT Account__c, User__c FROM Associated_location__c WHERE Account__c IN :newAccountIds AND User__c IN :newUserIds];
        Map<String, AccountTeamMember> accountTeamMemberMap = new Map<String, AccountTeamMember>();

        for(AccountTeamMember accountTeamMember : accountsTeamMembers) {
            accountTeamMemberMap.put(accountTeamMember.AccountId + '-' + accountTeamMember.UserId, accountTeamMember);
        }

        List<AccountTeamMember> accountTeamMembersToUpdate = new List<AccountTeamMember>();
        for(Associated_location__c associatedLocation : associatedLocations) {
            if(accountTeamMemberMap.get(associatedLocation.Account__c + '-' + associatedLocation.User__c) == null && String.isNotBlank(associatedLocation.User__c)) {
                AccountTeamMember accountTeamMember = new AccountTeamMember(
                    AccountId = associatedLocation.Account__c,
                    UserId = associatedLocation.User__c
                );
                accountTeamMembersToUpdate.add(accountTeamMember);
                accountTeamMemberMap.put(associatedLocation.Account__c + '-' + associatedLocation.User__c, accountTeamMember);
            }
        }

        List<AccountTeamMember> oldAccountTeamMembers = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :oldAccountIds AND UserId IN :oldUserIds];
        List<Associated_location__c> oldAssociatedLocations = [SELECT Account__c, User__c FROM Associated_location__c WHERE Account__c IN :oldAccountIds AND User__c IN :oldUserIds];
        Map<String, Associated_location__c> oldAssociatedLocationMap = new Map<String, Associated_location__c>();
        for(Associated_location__c oldAssociatedLocation : oldAssociatedLocations) {
            oldAssociatedLocationMap.put(oldAssociatedLocation.Account__c + '-' + oldAssociatedLocation.User__c, oldAssociatedLocation);
        }

        List<AccountTeamMember> accountTeamMembersToDelete = new List<AccountTeamMember>();
        for(AccountTeamMember oldAccountTeamMember : oldAccountTeamMembers) {
            if(oldAssociatedLocationMap.get(oldAccountTeamMember.AccountId + '-' + oldAccountTeamMember.UserId) == null) {
                accountTeamMembersToDelete.add(oldAccountTeamMember);
            }
        }
        delete accountTeamMembersToDelete;
        insert accountTeamMembersToUpdate;
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
                accountTeamMembersToDelete.add(accountTeamMember);
            }
        }
        delete accountTeamMembersToDelete;
    }
}
