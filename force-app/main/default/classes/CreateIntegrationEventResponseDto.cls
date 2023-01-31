/**
 * Created by caleb on 12/09/2019.
 */

global with sharing class CreateIntegrationEventResponseDto extends BaseResponseDto
{
    private void init()
    {
        if (this.Errors == null)
        {
            this.Errors = new List<ErrorDto>();
        }
    }

    public CreateIntegrationEventResponseDto()
    {
        init();
    }

    public CreateIntegrationEventResponseDto(Boolean IsSuccess)
    {
        this();
        this.IsSuccess = IsSuccess;
    }

    public CreateIntegrationEventResponseDto(ErrorDto err)
    {
        this();
        this.IsSuccess = false;
        this.Errors.add(err);
    }

    public Boolean IsSuccess {get; set;}
}