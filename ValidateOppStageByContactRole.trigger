trigger validateOppStageByContactRole on Opportunity (after insert,before update) {
    /*to generate map with  new opportunites which stage changes got changed*/
    Map<Id, Opportunity> oppsToCheckMap = new Map<Id, Opportunity>();
    // to generate Map of opportunities with map of contact roles with count
    Map<Id,Map<String,integer>> opptyConRoleCount = new Map<Id,Map<String,integer>>();
    // to create list for new contact role creation
    List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
    // getting all records/mapping realted to Stage ==> Contact Role
    List<Stage_To_ContactRole__mdt> stcList = [Select 
                Id,StageName__c,Contact_Role__c from Stage_To_ContactRole__mdt];
    Map<String,String> stgConMap = new Map<String, String>();
    for (Stage_To_ContactRole__mdt s: stcList){
        stgConMap.put(s.StageName__c,s.Contact_Role__c);
    }
    List<Sttrigger validateContactRoleOnStage on Opportunity (after insert,before update) {
    /*to generate map with  new opportunites which stage changes got changed*/
    Map<Id, Opportunity> oppsToCheckMap = new Map<Id, Opportunity>();
    // to generate Map of opportunities with map of contact roles with count
    Map<Id,Map<String,integer>> opptyConRoleCount = new Map<Id,Map<String,integer>>();
    // to create list for new contact role creation
    List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
    // getting all records/mapping related to Stage ==> Contact Role
    List<Stage_To_ContactRole__mdt> stcList = [SELECT 
                                               Id,StageName__c,Contact_Role__c 
                                               FROM Stage_To_ContactRole__mdt];
    Map<String,String> stgConMap = new Map<String, String>();
    for (Stage_To_ContactRole__mdt s: stcList){
        stgConMap.put(s.StageName__c,s.Contact_Role__c);
    }
    List<String> conRoles = new List<String>(stgConMap.values());
    if(Trigger.isInsert) {
        for(Opportunity opp : Trigger.new) {
            if(opp.Contact__c != null) {
                //Creating new Contact Role 
                //with corrusponding role if Contact__c 
                //is selected on Opportuinity creation
                newContactRoleList.add(
                    new OpportunityContactRole(
                        ContactId=opp.Contact__c,
                        OpportunityId=opp.Id,
                        Role =stgConMap.get(opp.StageName),IsPrimary=true));
            }
        }
    }
    for(Opportunity opp : trigger.new) {
        // generating opp map if Stagename is changed
        if(trigger.isUpdate 
           && trigger.oldMap.get(opp.Id).StageName != opp.StageName)
            oppsToCheckMap.put(opp.Id, opp);
    }
    // For each Opportunity in the map keyset get the count of the
    // OpportunityContactRole with corrusping roles
    AggregateResult[] result = [SELECT OpportunityId,count(Id),Role
                                FROM OpportunityContactRole
                                WHERE
                                OpportunityId in :oppsToCheckMap.keySet() 
                                GROUP BY OpportunityId,Role];
    
    // If OCR doesn't have corrupsponding Contact Role,
    // The Error will be shown under StageName 
    for(AggregateResult OCRoles : result) {
        Id oppId = Id.valueOf(String.valueOf(OCRoles.get('OpportunityId')));
        Integer CountofType = Integer.ValueOF(OCRoles.get('expr0'));
        String NameofType = String.valueOf(OCRoles.get('Role'));
        
        if( !opptyConRoleCount.containsKey(oppId) ) 
        {
            opptyConRoleCount.put( oppId , new Map< string, integer >());
        }
        // opptyConRoleCount {Opp Id ==> {Role,count}}
        opptyConRoleCount.get( oppId ).Put( NameofType ,CountofType );            
        if(opptyConRoleCount.containsKey(oppId)){
            Opportunity opp = oppsToCheckMap.get(oppId);
            String conRole = stgConMap.get(opp.StageName);
            if(!opptyConRoleCount.get(oppId).containsKey(conRole)){ 
                // if opprunity doesn't contain contact role, will shown error
                opp.StageName.addError('Contact Role '+conRole+
                                       ' needs to be added to move '
                                       + opp.StageName);
            }
        }
    }
    try {
        //inserting new contact roles if contact is selected in after insert
        if(newContactRoleList.size()>0)upsert newContactRoleList;
    }catch(Exception e) {
        System.debug(e);
    }
    
}
ring> conRoles = new List<String>(stgConMap.values());
    if(Trigger.isInsert) {
        for(Opportunity opp : Trigger.new) {
            if(opp.Contact__c != null) {
                //Creating new Contact Role with corrusponding role if Contact__c is selected on Opportuinity creation
                newContactRoleList.add(
                  new OpportunityContactRole(
                    ContactId=opp.Contact__c,OpportunityId=opp.Id,
                    Role =stgConMap.get(opp.StageName),IsPrimary=true));
            }
        }
    }
    for(Opportunity opp : trigger.new) {
        // generating opp map if Stagename is changed
        if(trigger.isUpdate && trigger.oldMap.get(opp.Id).StageName != opp.StageName)
            oppsToCheckMap.put(opp.Id, opp);
    }
    // For each Opportunity in the map keyset get the count of the
    // OpportunityContactRole with corrusping roles
    AggregateResult[] result = [select OpportunityId,count(Id),Role
                                from OpportunityContactRole
                                where
                                OpportunityId in :oppsToCheckMap.keySet() group by OpportunityId,Role];
    
    // If OCR doesn't have corrupsponding Contact Role,Error will be shown under StageName 
    for(AggregateResult OLIPlays : result) {
        id oppId = Id.valueOf(String.valueOf(OLIPlays.get('OpportunityId')));
        integer CountofType = integer.ValueOF(OLIPLays.get('expr0'));
        string NameofType = string.valueOf(OLIPlays.get('Role'));
        
        if( !opptyConRoleCount.containsKey(oppId) ) 
        {
            opptyConRoleCount.put( oppId , new Map< string, integer >());
        }
        // opptyConRoleCount {Opp Id ==> {Role,count}}
        opptyConRoleCount.get( oppId ).Put( NameofType ,CountofType );            
        if(opptyConRoleCount.containsKey(oppId)){
            Opportunity opp = oppsToCheckMap.get(oppId);
            String conRole = stgConMap.get(opp.StageName);
            if(!opptyConRoleCount.get(oppId).containsKey(conRole)){ 
                // if opprunity doesn't contain contact role, will shown error
                opp.StageName.addError('Contact Role '+conRole+' needs to be added to move '+ opp.StageName);
            }
        }
    }
    try {
        //inserting new contact roles if contact is selected in after inset
        if(newContactRoleList.size()>0)upsert newContactRoleList;
    }catch(Exception e) {
        System.debug(e);
    }
    
}
