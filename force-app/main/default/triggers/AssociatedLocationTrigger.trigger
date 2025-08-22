trigger AssociatedLocationTrigger on Associated_location__c (after insert, after update, after delete) {
    System.debug('Associated_location__c Trigger Start =>' + Trigger.operationType);

    AssociatedLocationTriggerHandler handler = new AssociatedLocationTriggerHandler(
        Trigger.old,
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );

    if(AssociatedLocationTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when AFTER_INSERT {
                handler.afterInsert();
            }
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
            when AFTER_DELETE {
                handler.afterDelete();
            }
        }
    }
}