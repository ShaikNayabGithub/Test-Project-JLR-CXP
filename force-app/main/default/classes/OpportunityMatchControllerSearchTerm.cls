/**
 * Created by caleb@argologic.com.au on 15/07/2020.
 */

public with sharing class OpportunityMatchControllerSearchTerm
{
    List<String> NameFirstFragments;
    List<String> NameLastFragments;
    List<String> PhoneMobileFragments;
    List<String> EmailFragments;
    List<String> accountNameFragments;

    public List<String> NameFirstTerms
    {
        get
        {
            return addPercentCharsToStrings(NameFirstFragments);
        }
    }

    public List<String> NameLastTerms
    {
        get
        {
            return addPercentCharsToStrings(NameLastFragments);
        }
    }

    public List<String> PhoneMobileTerms
    {
        get
        {
            return addPercentCharsToStrings(PhoneMobileFragments);
        }
    }

    public List<String> EmailTerms
    {
        get
        {
            return addPercentCharsToStrings(EmailFragments);
        }
    }

    public List<String> accountNameTerms
    {
        get
        {
            return addPercentCharsToStrings(accountNameFragments);
        }
    }

    public OpportunityMatchControllerSearchTerm(
            String NameFirst,
            String NameLast,
            String PhoneMobile,
            String Email,
            String AccountName
    )
    {
        List<Pattern> patterns = getCommonSearchTermPatterns();
        NameFirstFragments = getSearchFragments(NameFirst);
        NameLastFragments = getSearchFragments(NameLast);
        PhoneMobileFragments = getSearchFragments(PhoneMobile);
        EmailFragments = getSearchFragments(Email);
        accountNameFragments = getSearchFragments(AccountName, patterns);
    }

    public OpportunityMatchControllerSearchTerm(
            String NameFirst,
            String NameLast,
            String PhoneMobile,
            String Email
    )
    {
        List<Pattern> patterns = getCommonSearchTermPatterns();
        NameFirstFragments = getSearchFragments(NameFirst);
        NameLastFragments = getSearchFragments(NameLast);
        PhoneMobileFragments = getSearchFragments(PhoneMobile);
        EmailFragments = getSearchFragments(Email);
    }

    public static List<Pattern> getCommonSearchTermPatterns()
    {
        List<Dedupe_Common_Term__mdt> commonTerms = [SELECT Regex_Pattern__c FROM Dedupe_Common_Term__mdt];
        List<Pattern> patterns = new List<Pattern>();
        for (Dedupe_Common_Term__mdt commonTerm : commonTerms)
        {
            patterns.add(Pattern.compile(commonTerm.Regex_Pattern__c));
        }
        return patterns;
    }

    public static List<String> removeCommonTerms(List<String> terms, List<Pattern> patterns)
    {
        List<String> result = new List<String>();

        for (String term : terms)
        {
            if (String.isBlank(term)) continue;

            Boolean doInclude = true;
            for (Pattern pattern : patterns)
            {
                if (pattern.matcher(term).matches())
                {
                    doInclude = false;
                    break;
                }
            }
            if (doInclude) result.add(term);
        }
        return result;
    }

    public static String removeCommonTerms(String term, List<Pattern> patterns)
    {
        String result = term;

        for (Pattern pattern : patterns)
        {
            Matcher mat = pattern.matcher(result);
            result = mat.replaceAll('');
        }

        return result.trim();
    }

    public static List<String> getSearchFragments(String str)
    {
        if (String.isBlank(str)) return new List<String>();
        List<String> deDupedSearchTerms = removeCommonTerms(powerSet(str.trim().split('\\s+')), new List<Pattern>());
        return deDupedSearchTerms;
    }

    public static List<String> getSearchFragments(String str, List<Pattern> patterns)
    {
        if (String.isBlank(str)) return new List<String>();
        List<String> deDupedSearchTerms = removeCommonTerms(powerSet(str.trim().split('\\s+')), patterns);
        return deDupedSearchTerms;
    }

    public static List<String> addPercentCharsToStrings(List<String> strs)
    {
        List<String> result = new List<String>();
        for (String s : strs)
        {
            result.add('%' + s + '%');
        }
        return result;
    }

    public static Integer ACCOUNT_NAME_WEIGHT = 3;
    public static Integer FIRST_NAME_WEIGHT = 3;
    public static Integer LAST_NAME_WEIGHT = 3;
    public static Integer EMAIL_WEIGHT = 2;
    public static Integer MOBILE_WEIGHT = 1;

    // lower numbers are better
    public Double getPersonAccountMatchScore(String FirstName, String LastName, String PersonEmail, String PersonMobilePhone)
    {
        String bestFirstName = getBestLevenshteinDistanceMatches(NameFirstFragments, nullToBlank(FirstName));
        String bestLastName = getBestLevenshteinDistanceMatches(NameLastFragments, nullToBlank(LastName));
        String bestPersonEmail = getBestLevenshteinDistanceMatches(EmailFragments, nullToBlank(PersonEmail));
        String bestMobilePhone = getBestLevenshteinDistanceMatches(PhoneMobileFragments, nullToBlank(PersonMobilePhone));

        Double score = FIRST_NAME_WEIGHT * (bestFirstName == null ? 0 : normalisedLevenshteinDistance(bestFirstName, nullToBlank(FirstName).toUpperCase()))
                + LAST_NAME_WEIGHT * (bestLastName == null ? 0 : normalisedLevenshteinDistance(bestLastName, nullToBlank(LastName).toUpperCase()))
                + EMAIL_WEIGHT * (bestPersonEmail == null ? 0 : normalisedLevenshteinDistance(bestPersonEmail, nullToBlank(PersonEmail).toUpperCase()))
                + MOBILE_WEIGHT * (bestMobilePhone == null ? 0 : normalisedLevenshteinDistance(bestMobilePhone, nullToBlank(PersonMobilePhone).toUpperCase()));
        return score;
    }

    public Double getAccountMatchScore(String accountName, Double contactBestMatchScore)
    {
        List<Pattern> patterns = getCommonSearchTermPatterns();
        String bestAccountName = getBestLevenshteinDistanceMatches(accountNameFragments, removeCommonTerms(nullToBlank(accountName), patterns));

        Double score = ACCOUNT_NAME_WEIGHT * (bestAccountName == null ? 0 : normalisedLevenshteinDistance(bestAccountName, removeCommonTerms(nullToBlank(accountName), patterns).toUpperCase()))
                      + contactBestMatchScore;
                
        return score;
    }

    public Double getContactMatchScore(String contactFirstName, String contactLastName, String contactEmail, String contactMobilePhone)
    {
        String bestContactFirstName = getBestLevenshteinDistanceMatches(NameFirstFragments, nullToBlank(contactFirstName));
        String bestContactLastName = getBestLevenshteinDistanceMatches(NameLastFragments, nullToBlank(contactLastName));
        String bestContactEmail = getBestLevenshteinDistanceMatches(EmailFragments, nullToBlank(contactEmail));
        String bestContactMobilePhone = getBestLevenshteinDistanceMatches(PhoneMobileFragments, nullToBlank(contactMobilePhone));

        Double score = FIRST_NAME_WEIGHT * (bestContactFirstName == null ? 0 : normalisedLevenshteinDistance(bestContactFirstName, nullToBlank(contactFirstName).toUpperCase()))
                + LAST_NAME_WEIGHT * (bestContactLastName == null ? 0 : normalisedLevenshteinDistance(bestContactLastName, nullToBlank(contactLastName).toUpperCase()))
                + EMAIL_WEIGHT * (bestContactEmail == null ? 0 : normalisedLevenshteinDistance(bestContactEmail, nullToBlank(contactEmail).toUpperCase()))
                + MOBILE_WEIGHT * (bestContactMobilePhone == null ? 0 : normalisedLevenshteinDistance(bestContactMobilePhone, nullToBlank(contactMobilePhone).toUpperCase()));
                
        return score;
    }

    public static List<String> powerSet(List<String> strs)
    {
        if (strs.size() == 0) return new List<String>();
        List<String> result = new List<String>();
        for (Integer i = 0; i < strs.size(); i++)
        {
            result.add(strs[i]);
            List<String> subList = new List<String>(strs);
            for (Integer j = 0; j <= i; j++)
            {
                subList.remove(0);
            }
            List<String> subResults = powerSet(subList);
            for (String subResult : subResults)
            {
                result.add(strs[i] + ' ' + subResult);
            }
        }
        return result;
    }

    public static String nullToBlank(String str)
    {
        return str == null ? '' : str;
    }

    public static String getBestLevenshteinDistanceMatches(List<String> matches, String possibleMatch)
    {
        // best mach is normalised
        String possibleMatchNormalised = possibleMatch.toUpperCase();
        String bestMatch = null;
        for (String str : matches)
        {
            if (bestMatch == null)
            {
                bestMatch = str.toUpperCase();
            }
            else
            {
                if (normalisedLevenshteinDistance(bestMatch, possibleMatchNormalised) > normalisedLevenshteinDistance(str, possibleMatchNormalised))
                {
                    bestMatch = str.toUpperCase();
                }
            }
        }
        return bestMatch;
    }

    public static Double normalisedLevenshteinDistance(String s1, String s2)
    {
        return s1.getLevenshteinDistance(s2) / (Double)(s1.length() + s2.length());
    }
}