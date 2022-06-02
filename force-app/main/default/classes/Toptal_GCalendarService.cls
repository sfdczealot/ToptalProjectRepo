/**
* Service class for making callout to google calendar
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public with sharing class Toptal_GCalendarService {
    public static List<Toptal_WrapperUtil.EventAvailability> evtAvailabilityList = new List<Toptal_WrapperUtil.EventAvailability>();
    
    /**
    * This method is used to make callout to google calendar
    * to fetch the physicians availability
    * @param Toptal_WrapperUtil.CalendarDetails - physician info
    * @return List<Toptal_WrapperUtil.EventAvailability> - list of available time slots
    */
    @AuraEnabled
    public static List<Toptal_WrapperUtil.EventAvailability> fetchPhysicianCalendarEvents(Toptal_WrapperUtil.CalendarDetails processCalendar){
        if(String.isNotBlank(processCalendar.physicianName) && String.isNotBlank(processCalendar.selectedDate) && 
           String.isNotBlank(processCalendar.selectedTimeSlot)) {
            HttpResponse apiResponse = Toptal_Helper.getResponse('GET', Toptal_Helper.getCallOutURL(processCalendar.physicianEmail));
            if (apiResponse.getStatusCode() == 201 || apiResponse.getStatusCode() == 200 ) {
                evtAvailabilityList = handleSuccessResponse(apiResponse.getBody(), processCalendar);
            }else{
                handleErrorResponse(apiResponse, processCalendar);
            }
        }
        return evtAvailabilityList;
    }
    
    /**
    * This method is used to handle the success response received from the google calendar
    * @param String - response received from google calendar
    * @param Toptal_WrapperUtil.CalendarDetails - physician info
    * @return List<Toptal_WrapperUtil.EventAvailability> - list of available time slots
    */
    public static List<Toptal_WrapperUtil.EventAvailability> handleSuccessResponse(String apiResponse, Toptal_WrapperUtil.CalendarDetails processCalendar){
        Toptal_CalendarResponseWrapper response = (Toptal_CalendarResponseWrapper) JSON.deserialize(apiResponse.replace('"dateTime":', '"dateTime_Z":') , Toptal_CalendarResponseWrapper.class);
        if(response.items!=null){
            evtAvailabilityList = getEventsTime(response, processCalendar);
        }else{
            //Display toast message about the error
        }
        return evtAvailabilityList;
    }
    
    /**
    * This method is used to handle the failure response received from the google calendar
    * by logging it into the integration failure object for the future reference for the developers
    * to debug easily
    * @param HTTPResponse - response received from google calendar
    * @param Toptal_WrapperUtil.CalendarDetails - physician info
    * @return List<Toptal_WrapperUtil.EventAvailability> - list of available time slots
    */
    public static Integration_Failure__c handleErrorResponse(HTTPResponse apiResponse, Toptal_WrapperUtil.CalendarDetails processCalendar){
        Integration_Failure__c fail = new Integration_Failure__c();
        fail.Type__c = 'G-Calendar';
        fail.Failure_Code__c = String.valueOf(apiResponse.getStatusCode());
        fail.Failure_Reason__c = 'G-Calendar Exception happened';
        insert fail;
        if(fail != null) {
            return fail;
        }
        return fail;
    }
    
    /**
    * This resuable method is used to fetch the event times of the physician
    * @param HTTPResponse - response received from google calendar
    * @param Toptal_WrapperUtil.CalendarDetails - physician info
    * @return List<Toptal_WrapperUtil.EventAvailability> - list of available time slots
    */
    public static List<Toptal_WrapperUtil.EventAvailability> getEventsTime(Toptal_CalendarResponseWrapper response, Toptal_WrapperUtil.CalendarDetails processCalendar){
        Set<String> setEventTime = new Set<String>();
        for(Toptal_CalendarResponseWrapper.Items item : response.items){
            String eventTime = '';
            if(Date.valueOf(item.start.dateTime_Z) == Date.valueOf(processCalendar.selectedDate)){
                List<String> lstStartDateTime = Toptal_Helper.ConvertTimeToLocale(item.start.dateTime_Z).split(' ');
                eventTime = lstStartDateTime.get(1).replace(':', '.')+lstStartDateTime.get(2);
                setEventTime.add(eventTime.toLowerCase());
            }
        }
        if(!setEventTime.isEmpty()){
            evtAvailabilityList = Toptal_Helper.checkSlotAvailability(setEventTime, processCalendar.selectedTimeSlot,false);                      
        }else{
            evtAvailabilityList = Toptal_Helper.checkSlotAvailability(setEventTime, processCalendar.selectedTimeSlot,true);
        }
        return evtAvailabilityList;
    }
    
    /**
    * This resuable method is used to make callout to post the event in phsyician calendar
    * @param Toptal_WrapperUtil.CalendarDetails - physician calendar details
    * @return List<Toptal_WrapperUtil.EventAvailability> - details of the particular event
    */
    @AuraEnabled
    public static Toptal_WrapperUtil.CalendarResponse postEventToPhysicianCalendar(Toptal_WrapperUtil.CalendarDetails createCalendarEvent){
        Toptal_WrapperUtil.CalendarResponse calendarResponseDetails = new Toptal_WrapperUtil.CalendarResponse();
        if(String.isNotEmpty(createCalendarEvent.physicianName) && String.isNotEmpty(createCalendarEvent.selectedDate) && String.isNotEmpty(createCalendarEvent.selectedTimeSlot) && String.isNotEmpty(createCalendarEvent.selectedTime)){
            Toptal_CalendarRequestWrapper requestWrapper = new Toptal_CalendarRequestWrapper();
            requestWrapper.startTime = getTimeSlot(createCalendarEvent, false);
            requestWrapper.endTime = getTimeSlot(createCalendarEvent, true);
            System.debug('=========request==='+JSON.serialize(requestWrapper).replace('endTime', 'end1').replace('dateTime_Z', 'dateTime').replace('startTime', 'start'));
            HttpResponse apiResponse = Toptal_Helper.postResponse('POST', Toptal_Helper.getCallOutURL(createCalendarEvent.physicianEmail),JSON.serialize(requestWrapper).replace('end_Z', 'end').replace('dateTime_Z', 'dateTime'));
            if(apiResponse.getStatusCode() == 200 || apiResponse.getStatusCode() == 201){
                calendarResponseDetails.statusCode = apiResponse.getStatusCode();
                calendarResponseDetails.isEventCreated = true;
            }
            else{
                calendarResponseDetails.statusCode = apiResponse.getStatusCode();
                calendarResponseDetails.isEventCreated = false;
            }
        }
        return calendarResponseDetails;
    } 
    
    /**
    * This resuable method is used to retrieve the time slots of the physician
    * @param Toptal_WrapperUtil.CalendarDetails - physician calendar details
    * @param Boolean - status of the event time slot
    * @return List<Toptal_WrapperUtil.EventAvailability> - details of the particular event
    */
    public static Toptal_CalendarRequestWrapper.TimeSlot getTimeSlot(Toptal_WrapperUtil.CalendarDetails createCalendarEvent, Boolean isStartTime) {
        Toptal_CalendarRequestWrapper.TimeSlot slot = new Toptal_CalendarRequestWrapper.TimeSlot();
        slot.dateTime_Z = Toptal_Helper.getCalendarDateTime(createCalendarEvent.selectedDate,createCalendarEvent.selectedTime,isStartTime);           
        slot.timeZone = UserInfo.getTimeZone().getID();
        return slot;
    }
}