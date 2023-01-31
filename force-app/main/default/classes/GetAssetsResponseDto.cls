/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

public with sharing class GetAssetsResponseDto {


    private void init() {
        if (this.Data == null) {
            this.Data = new List<AssetResourceDto>();
        }

    }

    public GetAssetsResponseDto() {
        init();
    }

    public GetAssetsResponseDto(List<Asset> assets, String searchString) {
        this();
        this.MaxResults = String.isBlank(searchString) ?  Constants.MAX_RESULTS_ASSET_LIST : Constants.MAX_RESULTS_ASSET_SEARCH;
        this.NumberOfResults = assets == null ? 0 : assets.size();
        if (this.NumberOfResults > this.MaxResults) {
            this.IsMaxResultsExceeded = true;
        } else if (this.NumberOfResults > 0) {

            for (Asset a : assets) {
                AssetResourceDto resourceDto = new AssetResourceDto();
                resourceDto.Id = a.Id;
                resourceDto.Type = 'Asset';
                resourceDto.Attributes = new AssetAttributeDto(a);
                Data.add(resourceDto);
            }
        }

    }

    @AuraEnabled
    public List<AssetResourceDto> Data { get; set; }

    @AuraEnabled
    public Integer NumberOfResults { get; set; }

    @AuraEnabled
    public Integer MaxResults { get; set; }

    @AuraEnabled
    public Boolean IsMaxResultsExceeded { get; set; }
}