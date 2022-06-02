/**
* Wrapper class for sending request to google calendar
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public class Toptal_CalendarRequestWrapper {

    public TimeSlot endTime {get;set;} 
    public TimeSlot startTime {get;set;} 

    public class TimeSlot {
        public String dateTime_Z {get;set;} 
        public String timeZone {get;set;} 
    }   
}