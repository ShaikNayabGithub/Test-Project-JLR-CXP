public class NxSoftphone {
  public String createSoftphone(
    String callFrom,
    String callTo,
    String callId,
    Boolean isInbound,
    String objectType,
    String objectId
  ) {
    if (callId == null || callId.length() == 0) {
      return null;
    }

    if (callFrom == null || callFrom.length() == 0) {
      return null;
    }

    if (callTo == null || callTo.length() == 0) {
      return null;
    }

    DateTime dt = Datetime.now();
    NxSoftphone__c softphone = new NxSoftphone__c();
    softphone.Call_Id__c = callId;
    softphone.from__c = callFrom;
    softphone.to__c = callTo;
    softphone.inbound__c = isInbound;
    softphone.Date__c = dt;

    // To-Do objectId로 Person Account일 경우 로직 추가
    if (objectType != null && objectType.equals('Lead'))
      softphone.Lead__c = objectId;
    if (objectType != null && objectType.equals('Opportunity'))
      softphone.Opportunity__c = objectId;
    if (objectType != null && objectType.equals('Account'))
      softphone.Account__c = objectId;
    insert softphone;

    System.debug('insert softphone.');
    System.debug('softphone id:' + softphone.id);

    return softphone.id;
  }

  public Integer updateSoftphone(
    String callId,
    Integer duration,
    String recordingUrl
  ) {
    Integer returnValue = -1;

    if (callId == null || callId.length() == 0) {
      return returnValue;
    }

    List<NxSoftphone__c> lstSoftphone = [
      SELECT id, Recording_URL__c, Duration__c
      FROM NxSoftphone__c
      WHERE Call_Id__c = :callId
    ];
    try {
      for (NxSoftphone__c ld : lstSoftphone) {
        ld.Duration__c = duration;
        if (recordingUrl != null && recordingUrl.length() > 0) {
          ld.Recording_URL__c = EncodingUtil.urlDecode(recordingUrl, 'UTF-8');
        }

        update ld;
        returnValue++;
      }
    } catch (DmlException e) {
      // returnValue = false;
      System.debug('An unexpected error has occurred: ' + e.getMessage());
    }

    return returnValue;
  }

  public static void totalCount(NxSoftphone__c[] softhphones) {
    System.debug('totalCount softphone.');
  }
}