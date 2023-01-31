public class SOAPXMLAttributeConstructor {
    private static final string SOAPAttributeTemplate = '<{2}:{0}>{1}</{2}:{0}>';
    private static final string defaultNamespace = 'jlr';
    
    public string AddAttribute(string name, boolean value){
        if(value == null){ return ''; }
        string textValue = '0';
        if(value){ textValue = '1'; }
        return AddAttribute(name, textValue);
    }
    
    
    public string AddAttribute(string name, string value){
        if(String.isEmpty(value) || String.isEmpty(name)){ return ''; }
        value = value.replace('&', '&amp;');
        value = value.replace('<', '&lt;');
        value = value.replace('>', '&gt;');
        value = value.replace('\'', '&apos;');
        value = value.replace('"', '&quot;');
        if(name.contains(' ')){ throw new XmlException('SOAP nodes (name: ' + name + ') must not contain spaces'); }
        return String.format(SOAPAttributeTemplate, new String[]{name, value, defaultNamespace});
    }
}