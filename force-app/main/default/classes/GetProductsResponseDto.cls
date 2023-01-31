/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/08/2019.
 */

global with sharing class GetProductsResponseDto  extends BaseResponseDto{

    @AuraEnabled
    public List<Product2> Products {get; set;}

}