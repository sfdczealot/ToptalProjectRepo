/**
* Wrapper class for receving the response from google calendar
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/
public with sharing class Toptal_CalendarResponseWrapper {
    @AuraEnabled
    public String conferenceId {get;set;} 
    @AuraEnabled
    public String kind {get;set;} 
    @AuraEnabled
    public String etag {get;set;} 
    @AuraEnabled
    public String summary {get;set;} 
    @AuraEnabled
    public String updated {get;set;} 
    @AuraEnabled
    public String timeZone {get;set;} 
    @AuraEnabled
    public String accessRole {get;set;} 
    @AuraEnabled
    public String nextSyncToken {get;set;} 
    @AuraEnabled
    public List<Items> items {get;set;} 

    
    public class Start {
        public String dateTime_Z {get;set;} 
        public String timeZone {get;set;} 
    }

    public class Items {
        @AuraEnabled
        public String kind {get;set;} 
        @AuraEnabled
        public String etag {get;set;} 
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public String htmlLink {get;set;} 
        @AuraEnabled
        public String created {get;set;} 
        @AuraEnabled
        public String updated {get;set;} 
        @AuraEnabled
        public String summary {get;set;} 
        @AuraEnabled
        public Creator creator {get;set;} 
        @AuraEnabled
        public Creator organizer {get;set;} 
        @AuraEnabled
        public Start start {get;set;} 
        @AuraEnabled
        public Start end_Z {get;set;} 
        @AuraEnabled
        public String iCalUID {get;set;} 
        @AuraEnabled
        public Integer sequence {get;set;} 
        @AuraEnabled
        public String eventType {get;set;} 
        @AuraEnabled
        public String description {get;set;} 
        @AuraEnabled
        public String location {get;set;} 
        @AuraEnabled
        public List<Attendees> attendees {get;set;} 
        @AuraEnabled
        public String hangoutLink {get;set;} 
        @AuraEnabled
        public ConferenceData conferenceData {get;set;} 
        @AuraEnabled
        public String visibility {get;set;} 
    }

    public class Creator {
        public String email {get;set;} 
    }


    public class Attendees {
        public String email {get;set;} 
        public Boolean self {get;set;} 
        public String responseStatus {get;set;} 
    }


    public class ConferenceData {
        public List<EntryPoints> entryPoints {get;set;} 
        public ConferenceSolution conferenceSolution {get;set;} 
        public String conferenceId {get;set;} 
    }


    public class EntryPoints {
        public String entryPointType {get;set;} 
        public String uri {get;set;} 
        public String label {get;set;} 
    }


    public class ConferenceSolution {
        public Key key {get;set;} 
        public String name {get;set;} 
        public String iconUri {get;set;} 
    }

    public class Key {
        public String type {get;set;} 
    }

}