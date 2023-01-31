public class XMLParser {
     
    // To find the root element so that we can enclose it in the curly braces 
    public static String rootElementName; 
     
    /* Method which is parsing the XML content into JSON 
     * @param xml : XML String 
     * return     : JSON String
    */
     
    public static String xmlToJson(String xml) {
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XMLNode root = doc.getRootElement();
        String jsonContent = XMLParser.parse(root, false);         
        return jsonContent;
    }
     
     
    /* Method which makes the recursive calls and creates the JSON for
     * each element, it processes each node and finds the attributes and text content of a node
     * @param node      : Dom.XMLNode instance - XML node which will be processed
     * @param isChild   : Boolean - To control the structure of JSON, should be true for child element
     * return           : JSON string 
    */
    public static String parse(Dom.XMLNode node, Boolean isChild){
         
        String json = '';
        Boolean isArray = false;
        if ( rootElementName == null ) {
            rootElementName = node.getName();
        }         
        if ( node.getNodeType() == Dom.XmlNodeType.ELEMENT ){             
            Map<String, List<String>> mapChildrenJSON = new Map<String, List<String>>();
            List<String> lstJSONForChildren = new List<String>();
            List<Dom.XMLNode> children = node.getChildElements();             
            if ( children.size() > 0 ){
                for ( Dom.XMLNode child : children ){                     
                    String tmp = parse( child, true );                     
                    if( tmp != '' ) {                     
                        if ( !mapChildrenJSON.containsKey( child.getName() ) ){                         
                            mapChildrenJSON.put( child.getName(), new List<String>() );  
                        }                         
                        mapChildrenJSON.get( child.getName() ).add( tmp );                       
                    }                     
                } 
                for ( String key : mapChildrenJSON.keySet() ){
                    if ( mapChildrenJSON.get(key).size() > 1 ){
                        if(isChild) {                         
                            lstJSONForChildren.add( '[' + String.join(mapChildrenJSON.get(key), ', ') + ']' );                         
                        }
                        else {                         
                            lstJSONForChildren.add( '"' + key + '": [' + String.join(mapChildrenJSON.get(key), ', ') + ']' );                                 
                        }
                        isArray = true;
                    }
                    else {                     
                        lstJSONForChildren.add( '"' + key + '": ' + mapChildrenJSON.get(key)[0] );                     
                    }
                }
            }
            List<String> lstAttributes = new List<String>( lstJSONForChildren );             
            for ( Integer i=0; i<node.getAttributeCount(); i++){                 
                String key = node.getAttributeKeyAt( i );
                String value = node.getAttribute( key, '' );
                lstAttributes.add( '"' + key + '": "' + value + '"' );  
            }  
            String textContent = node.getText();
            if ( textContent != null && textContent.trim() != '' ) {             
                textContent = textContent.replace( '"', '\\"' );
                lstAttributes.add( '"ele_text": "' + textContent + '"' );                     
            }
            if ( !isChild ){             
                if(!isArray) {                 
                    json = '"' + node.getName() + '": {' + String.join(lstAttributes,  ', ') + '}';                     
                }
                else {                 
                    json = ' {' + String.join(lstAttributes,  ', ') + '}';                      
                }
            }
            else {
                if ( lstAttributes.size() == 1  && textContent != null && textContent.trim() != '' ){                     
                    json = '"' + textContent + '"';                     
                } 
                else {
                    if(!isArray) {                     
                        if( lstAttributes.size() > 0 ){                         
                            json = '{' + String.join(lstAttributes,  ', ') + '}';                              
                        }                         
                    }
                    else {                     
                        json = String.join(lstAttributes,  ', ');                          
                    }
                }   
            }
        }
        if ( rootElementName == node.getName() ) {         
            if(!isArray) {             
                json = '{' + json + '}';             
            }
            else {                 
                json = '{"' + node.getName() + '" : ' + json + '}';                 
            }         
        }  
        return json;
    }
     
}