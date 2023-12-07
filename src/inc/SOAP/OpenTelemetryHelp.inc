ROUTINE SOAP.OpenTelemetryHelp [Type=INC]
	
#define OTELLog(%arg1)	        		do ##class(SOAP.WebService).OTELLogManualEvent(%arg1,"",1)
#define OTELLogAtt(%arg1,%arg2)    	    do ##class(SOAP.WebService).OTELLogManualEvent(%arg1,%arg2,1)


#define OTELPushChildSpan(%arg1)	       do ##class(SOAP.WebService).OTELPushChildSpan(%arg1,"")
#define OTELPushChildSpanAtt(%arg1,%arg2)  do ##class(SOAP.WebService).OTELPushChildSpan(%arg1,%arg2)
#define OTELPopChildSpan                   do ##class(SOAP.WebService).OTELPopChildSpan()