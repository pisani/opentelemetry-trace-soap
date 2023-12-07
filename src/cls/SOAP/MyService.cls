/// SOAP.MyService
Class SOAP.MyService Extends (%SOAP.WebService, SOAP.OpenTelemetrySupport)
{

/// Name of the WebService.
Parameter SERVICENAME = "MyServiceTest";

/// TODO: change this to actual SOAP namespace.
/// SOAP Namespace for the WebService
Parameter NAMESPACE = "http://tempuri.org";

/// Namespaces of referenced classes will be used in the WSDL.
Parameter USECLASSNAMESPACES = 1;

/// The OnInternalFault method may be overridden by the user to change the default SOAP
///  fault returned by InterSystems IRIS for internal errors.
/// OnInternalFault is passed the fault which may be modified to suit the applications needs.
/// After OnInternalFault returns this fault will be sent to the SOAP client.
/// The %Status that represents the error is also passed.
ClassMethod OnInternalFault(fault As %SOAP.Fault, status As %Status) [ Private, ServerOnly = 1 ]
{
	if $IsObject($get(%OTELSpan)) do ..pyEndSpan(%OTELSpan,$SYSTEM.Status.GetErrorText(status))	
	Quit
}

/// GetVersion
Method GetIRISVersion() As %String [ WebMethod ]
{
	Return $H
}

/// Nested Spans
Method Divide(a = 999, b = 666) As %String [ WebMethod ]
{
	do {
		/// Outer span
		$$$OTELPushChildSpan("CodeBlock 1")
		$$$OTELLog("Log info for CodeBlock 1")
		/// some logic
		
		do {
			/// Inner Span
			$$$OTELPushChildSpan("CodeBlock 2")
			$$$OTELLog("Log info for CodeBlock 2")
			set answer = (a/b)
			$$$OTELPopChildSpan
		} while 0

		/// Pop Outer span
		$$$OTELPopChildSpan
	} while 0	

	Return answer
}

/// Sibling spans
Method RunQuery() As %String [ WebMethod ]
{
	set tStatement = ##class(%SQL.Statement).%New()
 	set tSQL=1
 	set tSQL(1)="SELECT count(*) as ClassCount from %Dictionary.CompiledClass"

	/// Prepare Query
	$$$OTELPushChildSpan("Preparing Query")
 	set tSC=tStatement.%Prepare(.tSQL)
 	if $$$ISOK(tSC) {
		$$$OTELLog("Query %Prepare method completed without Error: ")	
	} else {
		$$$OTELLog("Query %Prepare method returned error: "_$System.Status.GetErrorText(tSC))	
	}
	$$$OTELPopChildSpan

	/// Execute Query
	$$$OTELPushChildSpan("Executing Query")
	set tResult = tStatement.%Execute()
	do tResult.%Next()
	set retval=tResult.%Get("ClassCount")
	$$$OTELPopChildSpan

	return retval
}

}
