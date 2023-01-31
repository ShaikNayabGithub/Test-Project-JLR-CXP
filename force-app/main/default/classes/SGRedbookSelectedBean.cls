public class SGRedbookSelectedBean{
    public String selectedBrand { get; set; }
    public String selectedModel { get; set; }
    public Integer selectedYear { get; set; }
    public Integer mileage { get; set; }
    public Integer price { get; set; }
    public String selectedVehicle {get; set; }
    public String  myVehicle { get; set; }
    
    public List<Data> Brands {get; set; } 
    public List<Data> Models { get; set; }
    public List<Data> Years { get; set; }
    public List<Data> Vehicles { get; set; }
    public class Data 
    {
        public String Id{ get; set; }
        public String Name { get; set; }
        public Data(String id, String name) 
        {
            this.Id = id;
            this.Name = name;            
        }
        public Data(Integer id, Integer name)
        {
            this.Id = String.valueOf(Id);
            this.Name = String.valueOf(name);
        }
    }
    public SGRedbookSelectedBean(){}
    public static SGRedbookSelectedBean parse(String json) 
    {
        return (SGRedbookSelectedBean) System.JSON.deserialize(json, SGRedbookSelectedBean.class);
    }
}