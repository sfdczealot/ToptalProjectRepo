/**
* Constant class to store the static values
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public with sharing class Toptal_Constants {
     public static List<String> MorningSlots = Label.Toptal_MorningSlots.split(',');
     public static List<String> AfternoonSlots = Label.Toptal_AfternoonSlots.split(',');
     public static String MorningSlotRange = Label.Toptal_AvailableSlots.split(',')[0];
     public static String AfternoonSlotRange = Label.Toptal_AvailableSlots.split(',')[1];
     public static String GCalendarURL = Label.Toptal_CalendarCalloutURL;
     public static String AvailabilityYes = Label.Toptal_AvailabilityYes;
     public static String AvailabilityNo = Label.Toptal_AvailabilityNo;
}