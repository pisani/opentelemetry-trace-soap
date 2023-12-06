ROUTINE SOAP.OpenTelemetryHelp [Type=INC]
///#define OTELSpan(%arg1,%arg2)          set %arg1=$order(%OTELSpanArr(""),-1,%arg2)
	
#define OTELLog(%arg1)	        		do ##class(SOAP.OpenTelemetrySupport).OTELLogManualEvent(%arg1,"",1)
#define OTELLogAtt(%arg1,%arg2)    	    do ##class(SOAP.OpenTelemetrySupport).OTELLogManualEvent(%arg1,%arg2,1)


#define OTELPushChildSpan(%arg1)	       do ##class(SOAP.OpenTelemetrySupport).OTELPushChildSpan(%arg1,"")
#define OTELPushChildSpanAtt(%arg1,%arg2)  do ##class(SOAP.OpenTelemetrySupport).OTELPushChildSpan(%arg1,%arg2)
#define OTELPopChildSpan                   do ##class(SOAP.OpenTelemetrySupport).OTELPopChildSpan()