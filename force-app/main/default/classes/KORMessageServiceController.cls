/**
 * @description       : message service control
 * @author            : HK
 * @group             :
 * @last modified on  : 2022. 07. 05
 * @last modified by  : HK
 **/

public without sharing class KORMessageServiceController {
  private static String EVENT_DEFINITION_KEY;
  private static String CLIENT_ID;
  private static String CLIENT_SECRET;
  private static String AUTH_END_POINT;

  static {
    Map<String, KOR_MMS_MC_Setting__mdt> korMmsMetaMap = KOR_MMS_MC_Setting__mdt.getAll();
    KOR_MMS_MC_Setting__mdt korMmsMeta = isSandbox()
      ? korMmsMetaMap.get('SANDBOX')
      : korMmsMetaMap.get('PRODUCTION');
    EVENT_DEFINITION_KEY = korMmsMeta.API_Event__c;
    CLIENT_ID = korMmsMeta.Client_Id__c;
    CLIENT_SECRET = korMmsMeta.Client_Secret__c;
    AUTH_END_POINT = korMmsMeta.End_Point__c;
  }

  public KORMessageServiceController() {
  }

  private static Boolean isSandbox() {
    String sandboxName = DomainParser.parse(
        DomainCreator.getOrgMyDomainHostname()
      )
      .getSandboxName();
    return !String.isEmpty(sandboxName);
  }


  private static String generateUUID() {
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String uuid =
      h.SubString(0, 8) +
      '-' +
      h.SubString(8, 12) +
      '-' +
      h.SubString(12, 16) +
      '-' +
      h.SubString(16, 20) +
      '-' +
      h.substring(20);
    return uuid;
  }

  @AuraEnabled
  public static void sendSMSbyId(String recordId, String toNumber, String content) {
    try {
      String uuid = generateUUID();

      KORGetTokenCallout.TokenResponseWrapper wrapper = new KORGetTokenCallout()
        .getAccessToken(CLIENT_ID, CLIENT_SECRET, AUTH_END_POINT);
      String access_token = wrapper.access_token;
      String rest_instance_url = wrapper.rest_instance_url;

      KORSendMessageCallout sendMessageCallout = new KORSendMessageCallout(
        access_token,
        rest_instance_url
      );
      KORSendMessageCallout.BodyWrapper bodyWrapper = new KORSendMessageCallout.BodyWrapper();
      KORSendMessageCallout.Data data = new KORSendMessageCallout.Data();

      data.recordId = recordId;
      data.toNumber = toNumber;
      data.content = content;
      data.uuid = uuid;

      bodyWrapper.contactKey = recordId;
      bodyWrapper.EventDefinitionKey = EVENT_DEFINITION_KEY;
      bodyWrapper.data = data;

      String jsonStr = JSON.serialize(bodyWrapper);
      sendMessageCallout.send2Dataextension(jsonStr);

      logMessage(recordId, content);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static sObject getRecord(String recordId) {
    String sObjectName = Id.valueOf(recordId)
      .getSObjectType()
      .getDescribe()
      .getName();
    String queryTemplate = 'SELECT Id, Phone, PersonMobilePhone FROM {0} WHERE Id=\'\'{1}\'\' LIMIT 1';
    List<String> params = new List<String>();
    params.add(sObjectName);
    params.add(recordId);

    String formattedQuery = String.format(queryTemplate, params);
    // System.debug(formattedQuery);
    List<sObject> returnObj = Database.query(formattedQuery);

    return !returnObj.isEmpty() ? returnObj.get(0) : null;
  }

  private static void logMessage(Id recordId, String content) {
    try {
      List<Contact> customer = [
        SELECT Id, Account.Record_Type_Name__c
        FROM Contact
        WHERE AccountId = :recordId
          AND Account.Record_Type_Name__c = 'Individual_Golden_Record'
      ];

      Task messageLog = new Task();
      messageLog.WhatId = recordId;
      messageLog.WhoId = customer.isEmpty() ? null : customer.get(0)?.Id;
      messageLog.Description = content;
      messageLog.Subject = '문자';
      messageLog.Status = 'Completed';
      insert messageLog;
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }
}