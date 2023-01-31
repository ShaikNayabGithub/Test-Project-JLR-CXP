public class NewCaseChronologicalReportController{

  private final string LABEL_CASE = 'Caso'; //mh new 
  private final string LABEL_OBJ_TASK =Schema.SObjectType.Task.Label; //mh new 
  private final string LABEL_OBJ_EMAILMSG = Schema.SObjectType.EmailMessage.Label; //mh new 
  private final string LABEL_OBJ_CASECOMMENT = Schema.SObjectType.CaseComment.Label; //mh new 
  private final string LABEL_OBJ_CASE = Schema.SObjectType.Case.Name; //mh new 
  private final string LABEL_OBJ_ATTACHMENT = Schema.SObjectType.Attachment.Label; //mh new  

  public Case caso {get; set;}
  public Account conta {get; set;}
  public Contact contato {get; set;} 
  public Asset veiculo {get; set;} // mx new

  public String idCase {get; set;}

  //Declarando as variáveis para formatar datas
  public String dateFormatCase {get; set;}
  public String dateFormatHandover {get; set;}
  public String dateFormatCsRb {get; set;} 
  public String dateFormatVeOd {get; set;}
  public String dateFormatVeGI {get; set;}
  public String dateFormatVeGF {get; set;}
  public String dateFormatVeGE {get; set;} 
  public String dateFormatEweD {get; set;} //mh new
  public String legalCaseValue{get;set;}
  
  //Variável pública que contém a Lista à ser inserida no relatório.
  public List<RelatorioCasoForm> lstRelatorio {get; set;}   

  public NewCaseChronologicalReportController(ApexPages.StandardController controller) {
        
    idCase = ApexPages.currentPage().getParameters().get('CaseId'); 
    
    caso = [select owner.name, Retailer__r.name, ContactId,AssetId,AccountId,casenumber,subject,toLabel(status),Description,createdby.name,toLabel(type),
            toLabel(Category_2__c),toLabel(Category_3__c),toLabel(Category_4__c), toLabel(Goodwill__c),toLabel(Goodwill_Responsibility__c), toLabel(Goodwill_Type__c), Legal_Case__c,
            Goodwill_Value__c, Other_Goodwill_Description__c, Goodwill_Approval_Date__c, Legal_Representative__c,
            Brand__c,Retailer__c,Country_ISO_Code__c,toLabel(Origin),OpenDaysOfCase__c,CreatedDate,ClosedDate,Case_Reopened_Date__c,Solved_Date__c
            from Case where id = : idCase]; //mh new
    if (caso.Description!=null && caso.Description.contains('\n')) caso.Description = caso.Description.replace('\n', '<br/>');
    
    
    if(caso.Legal_case__c==true)
        legalCaseValue= Label.yes;
    else
        legalCaseValue=Label.no;
        
    if(legalCaseValue!=null)
        legalCaseValue= legalCaseValue.toLowerCase();                 
  
    if(caso.AccountId != null)
      conta = [select toLabel(RecordType.Name), Type, Country_ISO_Code__c, PersonTitle, Brand__c, Name, Salutation, FirstName, LastName, 
                toLabel(ntt_Jaguar_Status__c) , 
                LegalEntityID__c, toLabel(Gender__pc), toLabel(ntt_Land_Rover_Status__c), PersonEmail, PersonMobilePhone, 
                PersonMailingStreet, PersonHomePhone, Phone, PersonOtherPhone, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, 
                PersonMailingCountry from Account where Id = :caso.AccountId]; //mh new
        
    if(caso.ContactId != null)
      contato = [select MailingCountry, firstname,lastname,Name,Account.Brand__c,Account.LegalEntityID__c,toLabel(Account.ntt_Jaguar_Status__c),
                  Account.Gender__pc, toLabel(Account.ntt_Land_Rover_Status__c) from Contact where Id = :caso.ContactId]; //mh new

    if(caso.AssetId != null)
      veiculo = [Select Handover_Date__c, VIN__c, Model__r.Name, Brand__r.Name, name, Extended_Warranty_End_Date__c, Warranty_Start_Date__c, Registration_Number__c, Warranty_End_Date__c, Brand__c, Model__c, Model_Year__c, 
                  Exterior_Colour__c, Interior_Color__c, Fuel_Type__c, Mileage_Checked_Date__c, Mileage__c  from Asset where Id = : caso.AssetId ]; //mh new
        
    List<Task> tasks = [select createddate, lastmodifieddate, Completed_Time__c, ActivityDate, toLabel(Status), Owner.name, toLabel(recordtype.name) from Task where WhatId = : idCase]; //mh new 

    BuscaCamposParaExibirRelatorio(); //mh update removed input parm
    
    //Formatando as datas de Casos/Conta/Contato/Veículo 
    dateFormatCase = formataDataEHora(caso.CreatedDate);    
            
    if(veiculo != null)
    {  
          dateFormatHandover = formataData(veiculo.Handover_Date__c); //mh new
          dateFormatEweD = formataData(veiculo.Extended_Warranty_End_Date__c); //mh new
          dateFormatVeOd = formataData(veiculo.Mileage_Checked_Date__c);
          dateFormatVeGI = formataData(veiculo.Warranty_Start_Date__c); //mh new 
          dateFormatVeGF = formataData(veiculo.Warranty_End_Date__c); //mh new
          dateFormatVeGE = formataData(veiculo.Extended_Warranty_End_Date__c);
    }
  }

  private String formataDataEHora(Datetime dataEHora) {
    if (dataEHora == null) return '';
    DateTime dt = dataEHora;
    String horario = dt.format('dd/MM/yyyy HH:mm');
    return horario;
  }

  private String formataData(Datetime data) {
    if (data == null) return '';
    //DateTime dt = data; //mh old 
    String horario = data.format('dd/MM/yyyy'); //mh update
    return horario;
  }

  public void BuscaCamposParaExibirRelatorio(){  //mh update removed method parms List<CRCMessage__c> lstMensagemCRC

    Map<DateTime, RelatorioCasoForm> mapaRelatorio = new Map<DateTime, RelatorioCasoForm>();

    for(EmailMessage email : [select CreatedDate, FromAddress, ToAddress, Subject, TextBody from EmailMessage where ParentId = : idCase]) { //mh update replaced DAO with SOQL
            RelatorioCasoForm form = new RelatorioCasoForm();
            form.type = 1; //mh new
            form.Tipo = LABEL_OBJ_EMAILMSG;
            form.dataHora = formataDataEHora(email.CreatedDate);
            form.de = email.FromAddress;
            form.para = (email.ToAddress).replace(';', ';<br/>');
            form.assunto = email.Subject;
        	if(email.TextBody != null){
            	form.descricao = (email.TextBody).replace('\n', '<br/>');
        	}
            mapaRelatorio.put(email.CreatedDate, form);
    }
    
    Set<Id> taskIdsForAttachments = new Set<Id>();

    for(Task tarefa : [SELECT Id, Duration_Hours_Task__c, lastmodifieddate, Completed_Time__c, ActivityDate, toLabel(Status), Owner.name, Internal_Description__c, Subject, WhatId, CreatedDate, CreatedBy.Name, Description FROM Task WHERE WhatId =: idCase])
    {
        RelatorioCasoForm form = new RelatorioCasoForm();
        form.type = 2; //mh new
        form.tipo = LABEL_OBJ_TASK; //mh update label
        form.dataHora = formataData(tarefa.ActivityDate);
        form.dataCreated = formataDataEHora(tarefa.CreatedDate);
        form.dataCompleted = formataDataEHora(tarefa.Completed_Time__c);
        form.dataLastModif = formataDataEHora(tarefa.LastModifiedDate);
        form.duration = String.ValueOf(tarefa.Duration_Hours_Task__c);
        form.status = tarefa.status;
        form.owner = tarefa.Owner.name;     
        form.de = tarefa.CreatedBy.Name;
        form.para = '';
        form.assunto = tarefa.Subject == null ? '' : tarefa.Subject;
        form.descricao = tarefa.Description == null ? '' : (tarefa.Description).replace('\n', '<br/>');
        form.internalDesc = tarefa.Internal_Description__c;
        
        form.resposta = '';
        form.infoResposta = '';
        form.idAnexo = '';
        mapaRelatorio.put(tarefa.CreatedDate, form);
        taskIdsForAttachments.add(tarefa.id);
    }
    
    Set<Id> contentDocIdSet = New Set<Id>();
    for(ContentDocumentLink cdLink:[select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId=:idCase OR LinkedEntityId IN:taskIdsForAttachments ])
    {
      contentDocIdSet.add(cdLink.ContentDocumentId);  
    }
    
    if(!contentDocIdSet.isEmpty()) 
    {
       for(ContentVersion anexo:[Select Id, Title, CreatedBy.Name, CreatedDate from ContentVersion where IsLatest=True AND ContentDocumentId IN:contentDocIdSet ]) 
       {
        RelatorioCasoForm form = new RelatorioCasoForm();
        form.type = 3; //mh new
        form.tipo = LABEL_OBJ_ATTACHMENT; //mh update label
        form.dataHora = formataDataEHora(anexo.CreatedDate);
        form.de = anexo.CreatedBy.Name;
        form.para = '';
        form.assunto = anexo.Title;
        form.descricao = '';
        form.idAnexo = anexo.Id;
        mapaRelatorio.put(anexo.CreatedDate, form);
       }
    }
    /*for(Attachment anexo : [SELECT Id, Name, Body, CreatedDate, CreatedBy.Name FROM Attachment WHERE ParentId =: idCase OR ParentID IN : taskIdsForAttachments])
    {
        RelatorioCasoForm form = new RelatorioCasoForm();
        form.type = 3; //mh new
        form.tipo = LABEL_OBJ_ATTACHMENT; //mh update label
        form.dataHora = formataDataEHora(anexo.CreatedDate);
        form.de = anexo.CreatedBy.Name;
        form.para = '';
        form.assunto = anexo.Name;
        form.descricao = '';
        form.idAnexo = anexo.Id;
        mapaRelatorio.put(anexo.CreatedDate, form);
    } */
    
    for(CaseComment comentario : [SELECT Id, IsPublished, CommentBody, CreatedDate, CreatedBy.Name FROM CaseComment WHERE ParentId =: idCase])
    {
        RelatorioCasoForm form = new RelatorioCasoForm();
        form.type = 4; //mh new
        form.tipo = LABEL_OBJ_CASECOMMENT; //mh update label
        form.dataHora = formataDataEHora(comentario.CreatedDate);
        form.de = comentario.CreatedBy.Name;

        if(comentario.CommentBody != null)
        {
          form.descricao = '<br/>' + (comentario.CommentBody).replace('\n', '<br/>');
        }
        else
        {
          form.descricao = ' ';
        }
        
        form.publico = comentario.IsPublished;

        mapaRelatorio.put(comentario.CreatedDate, form);
    }

    ordenaMapaECarregaListaParaExibicao(mapaRelatorio);
  }


  private void ordenaMapaECarregaListaParaExibicao(Map<DateTime, RelatorioCasoForm> mapaRelatorio){

    List<DateTime> lstDateTimeOrd = new List<DateTime>();
    lstDateTimeOrd.addAll(mapaRelatorio.keySet());
    lstDateTimeOrd.sort();

    lstRelatorio = new List<RelatorioCasoForm>();
    Integer posicao = lstDateTimeOrd.size();
    while (0 < posicao)
    {
      lstRelatorio.add(mapaRelatorio.get(lstDateTimeOrd[posicao-1]));
      posicao--;
    }
  }
  
  public class RelatorioCasoForm{

        public Integer type {get; set;} //mh new 1=Email, 2=Task, 3=Attachment, 4=CaseComment
        public String tipo {get; set;} // Email, Ligação telefônica (Inbound/Outbound), Atividades, Anexos, Formulários, Acionamento, Comentários
        public String dataHora {get; set;}
        public String dataCreated {get; set;} //mh new
        public String dataCompleted {get;set;} //mh new
        public String dataLastModif {get;set;} //mh new
        public String status {get;set;} //mh new
        public String owner {get;set;} //mh new
        public String duration {get;set;} //mh new
        public String de {get; set;}
        public String para {get; set;}
        public String assunto {get; set;}
        public String descricao {get; set;}
        public String internalDesc {get; set;} //mh new
        public String resposta {get; set;}
        public String infoResposta {get; set;}
        public String idAnexo {get; set;}
        public Boolean publico {get; set;} 
        
  }
}