public with sharing class AssociatedLocationTriggerHandler {
    private static Boolean isEnabled;

    static {
        isEnabled = true; // Set to false to disable the trigger
    }

    public static Boolean isTriggerEnabled() {
        return isEnabled;
    }

    public static void disableTrigger() {
        isEnabled = false;
    }

    public static void enableTrigger() {
        isEnabled = true;
    }

    List<Associated_Location__c> oldRecordLists {get; set;}
    List<Associated_Location__c> newRecordLists {get; set;}
    Map<Id, Associated_Location__c> oldRecordMaps {get; set;}
    Map<Id, Associated_Location__c> newRecordMaps {get; set;}

    public AssociatedLocationTriggerHandler(List<Associated_Location__c> oldRecords, 
    List<Associated_Location__c> newRecords, 
    Map<Id, Associated_Location__c> oldRecordMaps, 
    Map<Id, Associated_Location__c> newRecordMaps) {
        this.oldRecordLists = oldRecords;
        this.newRecordLists = newRecords;
        this.oldRecordMaps = oldRecordMaps;
        this.newRecordMaps = newRecordMaps;
    }

    public void afterInsert(){
        AssociatedLocationTriggerHelper.handleAfterInsertAccountTeamMember(this.newRecordLists);
    }

    public void afterUpdate(){
        AssociatedLocationTriggerHelper.handleAfterUpdateAccountTeamMember(this.newRecordLists, this.oldRecordMaps);
    }

    public void afterDelete(){
        AssociatedLocationTriggerHelper.handleAfterDeleteAccountTeamMember(this.oldRecordLists);
    }
}