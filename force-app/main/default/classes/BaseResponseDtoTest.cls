/**
 * Created by caleb@argologic.com.au on 3/08/2020.
 */

@IsTest
public with sharing class BaseResponseDtoTest
{
    @IsTest
    public static void test1()
    {
        // ACT
        BaseResponseDto res = new BaseResponseDto();
        res.addError(new ErrorDto());
        res.addError(new DateParsingException());
        res.addError(new JlrCustomException('this is an error'));
        res.addInfo('this is some info');

        // ASSERT
        System.assertEquals(false, res.IsSuccess);
    }
}