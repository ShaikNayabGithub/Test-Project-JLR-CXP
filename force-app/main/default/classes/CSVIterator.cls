/*
Copyright © 2011, FinancialForce.com, inc

All rights reserved.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
OF SUCH DAMAGE.

*/
global with sharing class CSVIterator implements Iterator<String>, Iterable<String>
{
        private String m_CSVData;
        private String m_introValue;
        //JLR:
        private Integer rowIndex = CSVParser.ROW_START_INDEX;

        public CSVIterator(String fileData, String introValue)
        {
                m_CSVData = fileData;
                m_introValue = introValue; 
        }

        global Boolean hasNext()
        {
                return m_CSVData.length() > 1 ? true : false;
        }

        global String next()
        {
                Integer endIndex = m_CSVData.indexOf(m_introValue);
                String row;
               
               if(m_CSVData.length()==0 || m_CSVData.length()<endIndex)
                   System.debug('m_CSVDatais null: '+rowIndex++);
                else
                if(m_CSVData!=null)
                    if(m_CSVData.length()>=endIndex)
                    {
                        
                        if(endIndex!=-1)
                        {
                            row = m_CSVData.subString(0, endIndex);
                            System.debug('this is the row: '+row); 
                            m_CSVData = m_CSVData.subString(m_CSVData.indexOf(m_introValue) + m_introValue.length(),m_CSVData.length());
                           
                            //JLR:
                            row = rowIndex + CSVParser.ROW_NUMBER_TAG + row;
                            rowIndex++;
                        }
                    }    
                return row;
        }

        global Iterator<String> Iterator()
        {
                return this;   
        }
}