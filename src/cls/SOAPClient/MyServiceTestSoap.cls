Class SOAPClient.MyServiceTestSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
Parameter LOCATION = "http://localhost:52774/csp/healthshare/sonic/SOAP.MyService.cls";

/// This is the namespace used by the Service
Parameter NAMESPACE = "http://tempuri.org";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// Determines handling of Security header.
Parameter SECURITYIN = "ALLOW";

/// This is the name of the Service
Parameter SERVICENAME = "MyServiceTest";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

Method Divide(a As %String, b As %String) As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("Divide").Invoke($this,"http://tempuri.org/SOAP.MyService.Divide",.a,.b)
}

Method GetIRISVersion() As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("GetIRISVersion").Invoke($this,"http://tempuri.org/SOAP.MyService.GetIRISVersion")
}

Method RunQuery() As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("RunQuery").Invoke($this,"http://tempuri.org/SOAP.MyService.RunQuery")
}

}
