/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class GetVariantsResponseDto  extends BaseResponseDto {

    global GetVariantsResponseDto() {
        super();
        init();
    }

    global GetVariantsResponseDto(List<Product2> products) {
        this();
        Data = ProductTransformer.transformVariants(products);

    }

    global GetVariantsResponseDto(List<PricebookEntry> entries) {
        this();
        Data = ProductTransformer.transformVariants(entries);

    }

    global GetVariantsResponseDto(Exception ex){
        //this.Data = null;
        this.Errors = new List<ErrorDto>();
        Errors.add(new ErrorDto(ex));
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<VariantResourceDto>();
        }
    }

    @AuraEnabled
    global List<VariantResourceDto> Data {get; set;}
}