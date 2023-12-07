Include SOAP.OpenTelemetryHelp

Class SOAP.OpenTelemetrySupport [ Abstract ]
{

/// Http Endpoint for OTLPCollector 
Parameter OTLPCOLLECTOREP As %String = "http://jaeger:4317";

/// Process Spans immediatly (versus batch) - defines SpanProcessor type 
Parameter SIMPLESPAN As %Boolean = 1;

/// The OnPreWebMethod method will be called before any web method in a web service.
/// OnPreWebMethod cannot return a value and thus cannot change the execution of the
/// web service except by returning a SOAP fault in the same way that a web method 
/// would return a SOAP fault. OnPreWebMethod can look at %request, %session and
/// the web service properties to control its behavior. 
/// MsgClass is a web service property which is the message descriptor class which 
/// contains the web method arguments. 
Method OnPreWebMethod() [ GenerateAfter = OnPreWebMethod, ServerOnly = 1 ]
{
 
	kill %OTELSpanArr
	set setupOK=..pySetupTraceProvider(..#OTLPCOLLECTOREP,$SYSTEM,..#SIMPLESPAN) 

	if setupOK {
		set otelOperation=..OTELSoapOperationName()
		set otelSpanAttributes=..OTELDefineSpanAttributes()
		; create telemetry span object, and, array of spans for this process
		set (%OTELSpan,%OTELSpanArr(0))=..pyStartSpan(otelOperation,otelOperation,otelSpanAttributes)	
	}
}

/// End the initial span
Method OnPostWebMethod() [ GenerateAfter = OnPreWebMethod, ServerOnly = 1 ]
{
	quit:'$d(%OTELSpan)

	set span=$Get(%OTELSpanArr(0))
	if $IsObject(span) {
		do ..pyEndSpan(span,"")
		kill %OTELSpanArr,%OTELSpan
	}
}

/// Define Open Telemetry Operation string using values from %session or %request
/// eg: for URL without web method arguments:  				"/csp/irisapp/SOAP.MyService.cls?soap_method=DivideNumbers"
/// 	quit $piece(%request.CgiEnvs("REQUEST_URI"),"&")
/// 
Method OTELSoapOperationName() As %String
{
	quit ..#SERVICENAME
}

/// Create array of attributes as required to be defined with *every* web method here.
Method OTELDefineSpanAttributes() As %ArrayOfDataTypes
{
	set attributes=##class(%ArrayOfDataTypes).%New()
	; add default span attributes.
	do attributes.SetAt(%session.SessionId,"CSP SessionId")
	do attributes.SetAt(%request.PageName,"IRIS_ClassName")
	do attributes.SetAt($job,"IRIS_JobID")
	
	return attributes
}

/// Log a Trace Event. 
ClassMethod OTELLogManualEvent(EventText, EventAttributes As %Library.ArrayOfDataTypes, AutoTimeStamp = 1)
{
	; quit of no to telemetry span defined.
	quit:'$IsObject($get(%OTELSpan))

	set pyAttributes = ##class(%SYS.Python).Builtins().dict()
	
	; automatically add time stamp by default.
	if $g(AutoTimeStamp)=0 {
		; not adding a timestamp
		
	}elseif $g(AutoTimeStamp)=1 {
		; auto generate timestamp
		do pyAttributes.setdefault("TimeStamp",$ZDT($H,3))
		
	} elseif $g(AutoTimeStamp)'=0 {
		; use provided value
		do pyAttributes.setdefault("TimeStamp",AutoTimeStamp)
	}
	
	; turn ArrayOfDataTypes into Python Dictionary object
	if $IsObject($get(EventAttributes)) {
		set key=""
		for  {
			set value=EventAttributes.GetNext(.key) quit:key=""
			do pyAttributes.setdefault(key,value)
		}
	}
	do ..pyOTELLogManualEvent(%OTELSpan,EventText,pyAttributes)
}

/// Log a Trace Event.  This is *not working*
ClassMethod pyOTELLogManualEvent(span As %SYS.Python, EventText, EventAttributes) [ Language = python ]
{
	from opentelemetry import trace

	try :
		# Add event to span 
		with trace.use_span(span) as useSpan:
			useSpan.add_event(EventText, attributes=EventAttributes)


	except Exception as e:
        # Set the status of the span to indicate an error
		useSpan.set_status(trace.StatusCode.ERROR, str(e))
}

/// ref: https://opentelemetry.io/docs/instrumentation/python/exporters/#otlp-endpoint-or-collector
ClassMethod pySetupTraceProvider(OTLPCOLLECTOREP, SERVICENAME, SIMPLESPAN) As %Boolean [ Language = python ]
{
	
	from opentelemetry import trace
	from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
	from opentelemetry.sdk.resources import SERVICE_NAME, Resource
	from opentelemetry.sdk.trace import TracerProvider
	from opentelemetry.sdk.trace.export import BatchSpanProcessor,SimpleSpanProcessor

	tracer_provider=trace.get_tracer_provider()

	# Service name is required for most backends
	resource = Resource(attributes={
	    SERVICE_NAME: SERVICENAME
	})


	try: 
		# check if already setup
		if (isinstance(tracer_provider,TracerProvider)==False):
			# define TraceProvider with defined resource ServiceName
			provider = TracerProvider(resource=resource)
			
			# Create a span processer of type BatchSpanProcessor, and add the exporter to it
			if SIMPLESPAN==0:
				span_processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=OTLPCOLLECTOREP,insecure=True))
			else: 
				span_processor = SimpleSpanProcessor(OTLPSpanExporter(endpoint=OTLPCOLLECTOREP,insecure=True))
				

			# add the span processor to the provider				
			provider.add_span_processor(span_processor)

			# add provider to trace
			trace.set_tracer_provider(provider)
			

	except Exception as e:
		return 0
	
	return 1
}

ClassMethod pyStartSpan(TraceName, SpanName, spanAttributes) As %SYS.Python [ Language = python ]
{
		
	from opentelemetry import trace
	tracer = trace.get_tracer(TraceName)
	span=""

	try:
		# start, bring in context, and, don't end span after with block
		with tracer.start_as_current_span(SpanName,  kind=trace.SpanKind.SERVER,end_on_exit=False) as span:
			for customAttribute,customValue in spanAttributes.items():
				span.set_attribute(customAttribute, customValue)
					
	except Exception as e:
        # Set the status of the span to indicate an error
		if not(span==""):
		 span.set_status(trace.StatusCode.ERROR, str(e))
	

	return span
}

/// End span (main, or nested)
ClassMethod pyEndSpan(span As %SYS.Python, errString) [ Language = python ]
{
	from opentelemetry import trace 
	try:	
		# bring in context.
		with trace.use_span(span) as useSpan:
		 if not (errString==""):
		 	useSpan.set_status(trace.StatusCode.ERROR, errString)

	except Exception as e:
        # Set the status of the span to indicate an error
		useSpan.set_status(trace.StatusCode.ERROR, str(e))
		
	useSpan.end()
}

ClassMethod OTELPushChildSpan(childSpanName, spanAttributes = "")
{
	if '$ISOBJECT(spanAttributes) {
		set spanAttributes=##Class(%ArrayOfDataTypes).%New()
	}
 

	; work with current span to create child span
	set childSpan=..pyOTELPushChildSpan(%OTELSpan,childSpanName,spanAttributes)
	if $ISOBJECT(childSpan) {
		set (%OTELSpan,%OTELSpanArr($i(%OTELSpanArr)))=childSpan
	}
}

/// Create a nested span
ClassMethod pyOTELPushChildSpan(parent, childSpanName, childSpanAttributes) As %SYS.Python [ Language = python ]
{
	from opentelemetry import trace
	from opentelemetry.trace import set_span_in_context
	
	tracer = trace.get_tracer(parent.name) 	
	childSpan=tracer.start_span(childSpanName, context=set_span_in_context(parent))
	for childSpanAttributes,customValue in childSpanAttributes.items():
		childSpan.set_attribute(childSpanAttributes, customValue) 

	return childSpan
}

ClassMethod OTELPopChildSpan()
{
	/// bring into focus the latest current span
	set internalID=$order(%OTELSpanArr(""),-1,%OTELSpan)
	
	do ..pyEndSpan(%OTELSpan,"")
	kill %OTELSpanArr(internalID)
	
	// check if it wasn't the first, root/initial span that was just deleted, as node 0 will 
	// not exist - so avoid <undef> error.
	if internalID'=0 {
		set internalID=$order(%OTELSpanArr(""),-1,%OTELSpan)
	}
}

}
