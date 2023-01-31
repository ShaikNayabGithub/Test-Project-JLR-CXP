/**
 * Created by caleb@argologic.com.au on 24/10/2019.
 */

@RestResource(UrlMapping='/v1/QantasBusinessRewards')
global with sharing class QantasBusinessRewardsService {
    @HttpGet
    global static QantasBusinessRewardsResponseDto get() {
        QantasBusinessRewardsResponseDto response = new QantasBusinessRewardsResponseDto();
        try {
            GetQantasBusinessRewardsRequestDto request = new GetQantasBusinessRewardsRequestDto();
            request.startDatetime = JlrDateParser.parseStringAsDateTime(RestContext.request.params.get(Constants.REST_PARAMETERS_DATE_START));
            response = QantasController.FetchQantasBusinessRewardsTransactions(request);
        } catch (DateParsingException ex) {
            response.addError(ex);
        } catch (Exception ex) {
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }
}