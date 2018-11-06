/*******************************************************************************
 * File:  CompetitorSelectListController.cls
 * Date:  July 1st, 2018
 * Author:  Dennis Le
 * Description: multi select list option for Competitors name 
 * *******************************************************************************/
public class CompetitorSelectListController {
		
    public CompetitorSelectListController(ApexPages.StandardController stdController) {
		System.debug('StandardController constructor');
        theOpportunity = queryOpportunity(stdController.getId());
        LeftSelectedList = new list<String>();
        RightSelectedList = new list<String>();
        getCurrentCompetitors();
        displayInputputText = true;
        saveAfterdisplay = true;
    }

	public Opportunity theOpportunity{get;set;}
    public String disableValue { get; set; }
    public Boolean displayInputputText {get;set;}
    public Boolean saveAfterdisplay {get;set;}
    public Boolean chkBx {get;set;}
    public String input {get; set{input = value; Find();}}
    map<String, Competitor__c> LeftOptionMap = new map<String, Competitor__c>();
    map<String, Competitor__c> RightOptionMap = new map<String, Competitor__c>();
    public Static map<Id, String> staticCompetitorsMap {get;set;}
    public list<String> LeftSelectedList {get;set;}
    public list<String> RightSelectedList {get;set;}

    public CompetitorSelectListController () {
    	System.debug('CompetitorSelectListController constructor');
    }
    
	public PageReference save() {
		/*System.debug('keys in the map: ' + RightOptionMap.keySet());
        System.debug('list of values in the map : ' + RightOptionMap.values());*/
		staticCompetitorsMap = new map<Id, String>();
        
        List<Competitor__c> l_selectOptions = new List<Competitor__c>();
        List<SObject> scope = [Select Id, Name, Competitive_takeaway__c From Competitor__c where Competitive_takeaway__c = :theOpportunity.Id];
        		
    	if(scope.size() > 0 || scope != null) {  
    		try {  			
    			for (SObject obj : scope) {
    				Competitor__c rec = (Competitor__c) obj;
    				Competitor__c comp = new Competitor__c(Id = rec.Id, Competitive_takeaway__c = null);
    				l_selectOptions.add(comp);	
    			}
    	 		update l_selectOptions;
    	 		
    	  	}catch(DmlException e) {
    			System.debug('An unexpected error has occurred updated l_selectOptions: ' + e.getMessage());
		  	} 
		}
         
        List<Competitor__c> selected_list = new List<Competitor__c>();    
        for (Competitor__c value : RightOptionMap.values()) {
            System.debug(value.Id);
            System.debug(value.Name);
            staticCompetitorsMap.put(value.Id, value.Name);
            Competitor__c ct = new Competitor__c (Id=value.Id, Competitive_takeaway__c = theOpportunity.Id);
            selected_list.add(ct);
        }
        
        try {
       		if (selected_list.size() > 0 ) {
        		update selected_list;
        	}	
        } catch(DmlException e) {
    		System.debug('An unexpected error has occurred: ' + e.getMessage());
		}	
		
		saveAfterdisplay = false;
		LeftOptionMap.clear();
		
        PageReference reference = new PageReference('/apex/CompetitorSelectListController?id=' + theOpportunity.Id);
		reference.setRedirect(false);
  
        return reference;
    }
    
    public void removeMembers() {
        if (!RightSelectedList.isEmpty()) {
            for (String s : RightSelectedList) {
                if (RightOptionMap.containsKey(s)) {
                    LeftOptionMap.put(s, RightOptionMap.get(s));        
                }
                RightOptionMap.remove(s);
            }
        }
    }
    
    public void addMembers() {     
        for(String s : LeftSelectedList) {
            if (LeftOptionMap.containsKey(s)) {
                RightOptionMap.put(s, LeftOptionMap.get(s));        
            }
            LeftOptionMap.remove(s);
        } 
    }
    
    public list<SelectOption> getSelectedOptionValues(){
        list<SelectOption> TempOptionList = new list<SelectOption>();
        list<Competitor__c> TempValueList;
 
        TempValueList = RightOptionMap.values();
        TempValueList.sort();  // sort by name
        for (Competitor__c T : TempValueList) { 
            TempOptionList.add(new SelectOption(T.Id, T.Name));
        }   
        
        return TempOptionList;
    }

    public void Find() {
        
        String SearchText = null; 
        List<Competitor__c> compList = new List<Competitor__c>();   
        
        if (input.length() > 1) { 
        	SearchText = '%'+input+'%';
        	compList = [SELECT Id, Name FROM Competitor__c where Name like :SearchText limit 100];
        	if (compList.size() > 0 || compList != null)
        		LeftOptionMap.clear();        
        }
        
        if (compList != null && compList.size() > 0) {
        	for (Competitor__c Co : compList) {
            	if (!RightOptionMap.containsKey(Co.Id)) {
            	LeftOptionMap.put(Co.Id, Co);
            	}
        	}
        	saveAfterdisplay = true;
        }  
    }  
    
    public list<SelectOption> getUnSelectedValues() {
        
        list<SelectOption> TempOptionList = new list<SelectOption>();
        list<Competitor__c> TempValueList; 
  
        TempValueList = LeftOptionMap.values();
        TempValueList.sort(); 
        for (Competitor__c O : TempValueList) { 
            TempOptionList.add(new SelectOption(O.Id, O.Name));
        }
        return TempOptionList;
    }  
       
	public PageReference click(){    
		//chkBx = false;    	
		
        if(chkBx){
            displayInputputText = true;
            saveAfterdisplay = true;
            disableValue = 'enabled';
        }
        else{
            displayInputputText = false;
            saveAfterdisplay = false;
            disableValue = 'disabled';
        }
        
        return null;
    }
     
	public PageReference getCurrentCompetitors() {  
     	List<Competitor__c> theOppCompetitors;
     	     	
		theOppCompetitors = [Select Id, Name From Competitor__c where Competitive_takeaway__c = :theOpportunity.Id];
		
		LeftOptionMap.clear();
		if ( theOppCompetitors.size() > 0) {
        	for (Competitor__c cObject : theOppCompetitors) {
            	RightOptionMap.put(cObject.Id, cObject);
            }
        }
        
        PageReference oppPage = new PageReference('/apex/CompetitorSelectListController?id=' + theOpportunity.Id);
		oppPage.setRedirect(true);
          
        return oppPage;
   	}  
 
 	private static Opportunity queryOpportunity(id OppId)
    {
        return [select id, name from Opportunity where id =: OppId];
    }
    
	public PageReference Cancel()
	{	
		PageReference m_stc = new PageReference('/apex/CompetitorSelectListController?id=' + ApexPages.currentPage().getParameters().get('Id'));
		m_stc.setRedirect(true);
		
    	return m_stc;
  	}	
     
}