@isTest
public class DMS_FieldPopulatedValidator_Test {
    static testmethod void CheckFieldObjectField_DoesNotThrowException_GivenPopulatedField()
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, Schema.sObjectType.Opportunity.fields.Name);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(!errorThrown);
    }

    static testmethod void CheckFieldObjectField_ThrowsException_GivenEmptyField()
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = '';

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, Schema.sObjectType.Opportunity.fields.Name);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(errorThrown);
    }

    static testmethod void CheckFieldObjectField_ThrowsException_GivenNullField()
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = null;

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, Schema.sObjectType.Opportunity.fields.Name);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(errorThrown);
    }


    static testmethod void CheckFieldObjectListField_DoesNotThrowException_GivenPopulatedFields()
    {
        List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
        Opportunity opportunity = new Opportunity();

        opportunity.Name = 'test';
        fields.add(Schema.sObjectType.Opportunity.fields.Name);

        opportunity.Description = 'test';
        fields.add(Schema.sObjectType.Opportunity.fields.Description);

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, fields);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(!errorThrown);
    }

    static testmethod void CheckFieldObjectListField_DoesNotThrowException_GivenFirstFieldIsPopulated()
    {
        List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
        Opportunity opportunity = new Opportunity();

        opportunity.Name = 'test';
        fields.add(Schema.sObjectType.Opportunity.fields.Name);

        opportunity.Description = '';
        fields.add(Schema.sObjectType.Opportunity.fields.Description);

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, fields);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(!errorThrown);
    }

    static testmethod void CheckFieldObjectListField_DoesNotThrowException_GivenSecondtFieldIsPopulated()
    {
        List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
        Opportunity opportunity = new Opportunity();

        opportunity.Name = '';
        fields.add(Schema.sObjectType.Opportunity.fields.Name);

        opportunity.Description = 'test';
        fields.add(Schema.sObjectType.Opportunity.fields.Description);

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, fields);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(!errorThrown);
    }

    static testmethod void CheckFieldObjectListField_ThrowsException_GivenNoPopulatedFields()
    {
        List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
        Opportunity opportunity = new Opportunity();

        opportunity.Name = '';
        fields.add(Schema.sObjectType.Opportunity.fields.Name);

        opportunity.Description = '';
        fields.add(Schema.sObjectType.Opportunity.fields.Description);

        boolean errorThrown = false;
        try
        {
            DMS_FieldPopulatedValidator.CheckField(opportunity, fields);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            errorThrown = true;
        }
        System.assert(errorThrown);
    }
}