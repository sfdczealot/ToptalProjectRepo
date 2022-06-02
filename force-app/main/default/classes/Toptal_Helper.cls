/**
* Helper class for booking appoitments
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public with sharing class Toptal_Helper {
    
   /**
   * This reusable method is used to make callout
   * @param String - method type which is GET
   * @param String - endpointURL
   * @return HttpResponse - incoming response
   */
    public static HttpResponse getResponse(String method, String calloutURL){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(calloutURL);
        return http.send(request);
    }

    /**
    * This reusable method is used to make callout
    * @param String - method type which is POST
    * @param String - endpointURL
    * @param String - request body to send to external system
    * @return HttpResponse - incoming response
    */
    public static HttpResponse postResponse(String method, String calloutURL, String requestBody){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(calloutURL);
        request.setBody(requestBody);
        return http.send(request);
    }

    /**
    * This method is used to retrieve google calendar api key from custom metadata
    * so that this can be changed at any point of time if needed
    * without changing the code
    * @return String - apikey
    */
     public static String getAPIKEY() {
        GoogleAPI__mdt apiMetadata = GoogleAPI__mdt.getInstance('G_Calendar');
        return String.valueOf(apiMetadata.APIKEY__c);
    }

    /**
    * This method is used for conversion of the incoming time to the current user time zone
    * @param String - date time input
    * @return String - formatted date time
    */
    public static String ConvertTimeToLocale(String stringDatetime){
        DateTime resultDateTime = DateTime.Valueof(stringDatetime.replace('T', ' '));
        return resultDateTime.format('dd-MM-yyyy h:mm a',UserInfo.getTimeZone().getID());
    }

    /**
    * This method is used to fetch the static google calendar callout url
    * from the custom label
    * @param String - email of the physician
    * @return String - end point URL
    */
    public static String getCallOutURL(String physicianEmail){
        return Toptal_Constants.GCalendarURL+physicianEmail+'/events';
    }
    
    /**
    * This method is used to retrieve the available slots of the selected physician
    * @param Set - set of events
    * @param String - selected TimeSlot
    * @param Boolean - status of the event
    * @return String - end point URL
    */
    public static List<Toptal_WrapperUtil.EventAvailability> checkSlotAvailability(Set<String> setEventTime, String selectedTimeSlot,Boolean isNoEvent){
        List<Toptal_WrapperUtil.EventAvailability> evtAvailabilityList = new List<Toptal_WrapperUtil.EventAvailability>();
        if(Toptal_Constants.MorningSlotRange.equals(selectedTimeSlot)){
            evtAvailabilityList = getEvents(setEventTime,selectedTimeSlot,Toptal_Constants.MorningSlots,isNoEvent);
        }else if(Toptal_Constants.AfternoonSlotRange.equals(selectedTimeSlot)){
            evtAvailabilityList = getEvents(setEventTime,selectedTimeSlot,Toptal_Constants.AfternoonSlots,isNoEvent);
        }
        return evtAvailabilityList;
    }
    
    /**
    * This method is used to retrieve the available slots of the selected physician
    * @param Set - set of events
    * @param String - selected TimeSlot
    * @param List - total list of time slots
    * @param Boolean - status of the event
    * @return List<Toptal_WrapperUtil.EventAvailability> - list of available events of the physician
    */
    public static List<Toptal_WrapperUtil.EventAvailability> getEvents(Set<String> setEventTime, String selectedTimeSlot,List<String> timeSlotsList,Boolean isNoEvent){
        List<Toptal_WrapperUtil.EventAvailability> evtAvailabilityList = new List<Toptal_WrapperUtil.EventAvailability>();
        for(String slot : timeSlotsList){
            Toptal_WrapperUtil.EventAvailability evtAvailability;
            if(!isNoEvent && setEventTime.contains(slot.toLowerCase())){
                evtAvailability =new Toptal_WrapperUtil.EventAvailability(slot, Toptal_Constants.AvailabilityNo);
            }else{
                evtAvailability =new Toptal_WrapperUtil.EventAvailability(slot, Toptal_Constants.AvailabilityYes);
            }
            evtAvailabilityList.add(evtAvailability);
        }
        return evtAvailabilityList;
    }

    /**
    * This method is used to format the time based on the session
    * @param String - selected TimeSlot
    * @return String - formatted time slot
    */ 
    public static String formatTime(String selectedTimeSlot){
        if(selectedTimeSlot.contains('AM')){ 
          return selectedTimeSlot.split('AM').get(0).replace('.',':')+':00'+' '+'AM';
        }
        else if(selectedTimeSlot.contains('PM')){
          return selectedTimeSlot.split('PM').get(0).replace('.',':')+':00'+' '+'PM';
        }
        return '';
    }
    
    /**
    * This method is used to format the time based on the session
    * @param String - selected Date
    * @param String - selected TimeSlot
    * @param Boolean - end time
    * @return String - acutal date time based on the current user time zone
    */
    public static String getCalendarDateTime(String selectedDate,String selectedTimeSlot, Boolean isEndTime){
        String Regex      = '(\\d{1,2}):(\\d{1,2}):(\\d{1,2}) ([PA]M)';
        Pattern p         = Pattern.compile( Regex );
        Matcher m         = p.matcher(formatTime(selectedTimeSlot));

        if ( m.matches() ){
            Integer Hours = Integer.valueOf( m.group(1) )
          , Minutes = Integer.valueOf( m.group(2) )
          , Seconds = Integer.valueOf( m.group(3) )
          , PmShift = m.group(4) == 'PM' ? 12 : 0 ;
          
          Time startTime = Time.newInstance( Hours + PmShift , Minutes , Seconds , 0 );
          if(isEndTime == true){
            Time endTime = startTime.addMinutes(30);
            return selectedDate+'T'+(''+endTime).substring(0,(''+endTime).indexOf('.'))+'+'+getTimeZoneDiff();
          }else if(isEndTime == false){
            return selectedDate+'T'+(''+startTime).substring(0,(''+startTime).indexOf('.'))+'+'+getTimeZoneDiff();
          }
        }
        return null;
    }
    
    /**
    * This method is fetch the time zone detail
    * @return String - actual time zone
    */
    public static String getTimeZoneDiff(){
        String offSetTime = DateTime.now().format('Z');
        String offSetHours = offSetTime.substring(0,3);
        String timeDiff ='';
        if(offSetHours.startsWith('+')){
            offSetHours = offSetHours.substring(1);
            timeDiff = offSetHours +':'+offSetTime.substring(3);
        }
        return timeDiff ;
    }
}