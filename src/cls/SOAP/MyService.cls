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

/// TODO: add arguments and implementation.
/// Test
Method Test() As %String [ WebMethod ]
{
	Return $H
}

Method Divide(a, b) As %String [ WebMethod ]
{
	hang 2
	$$$OTELPushChildSpan("mySubSpan")
 		$$$OTELLog("logic within mySubSpan")
		$$$OTELPushChildSpan("mySubSubSpan")
			hang 1
			$$$OTELLog("logic within mySub SubSpan")
		$$$OTELPopChildSpan
	$$$OTELPopChildSpan
	
	Return (a/b)
}

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

}
