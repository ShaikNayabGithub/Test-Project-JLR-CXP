public class JUDAAN_ProtoSelectedBean {
    public Integer selectedBrand { get; set; }
    public Integer selectedModel;
    public Integer selectedGrade;
    public Integer selectedYear;
    public String selectedCate;
    public Integer selectedColor;
    public Integer selectedMileage;
    public Integer tradeinvalue;
    public String  myVehicle;
    public String cate_id;
    public String handle_id;
    public String year_num;
    public List<Data> Brands {get; set; } 
    public List<Data> Models { get; set; }
    public List<Data> Grades { get; set; }
    public List<Data> Years { get; set; }
    public List<Data> Cates { get; set; }
    public List<Data> Colors { get; set; }
    public List<Data> Mileages { get; set; }
	public class Data 
    {
        public String Id { get; set; }
        public String Name { get; set; }
        public Data(String id, String name) 
        {
            this.Id = id;
			this.Name = name;            
        }
	}
    public JUDAAN_ProtoSelectedBean(){}
	public static JUDAAN_ProtoSelectedBean parse(String json) 
    {
		return (JUDAAN_ProtoSelectedBean) System.JSON.deserialize(json, JUDAAN_ProtoSelectedBean.class);
	}
}