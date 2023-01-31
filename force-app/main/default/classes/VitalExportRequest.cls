/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/11/2019.
 */

public with sharing class VitalExportRequest {

    public VitalExportRequest(){
        init();
    }

    public VitalExportRequest(List<OpportunityResourceDto> data){
        this();
        this.Data = data;
    }

    public void init(){
        if (Data == null){
            Data = new List<OpportunityResourceDto>();
        }
    }

    public List<OpportunityResourceDto> Data {get; set;}
}