Class SOAPClient.LoadTest Extends %RegisteredObject
{

/// Clients: number of jobs acting as SOAP Clients
/// WithErrors: inject errors for the Divide() method
/// nTests: number of iterations for the Test() SOAP method
/// nDivides: number of iterations for the Divide() SOAP method
ClassMethod Run(Clients = 5, WithErrors = 0, nTests = 20, nDivides = 20)
{

	for i=1:1:Clients {
		job ##class(SOAPClient.LoadTest).Client(WithErrors,nTests,nDivides)
	}
}

ClassMethod Client(WithErrors, nTests, nDivides)
{

	set client=##Class(SOAPClient.MyServiceTestSoap).%New()
	set client.Username="superuser"
	set client.Password="SYS"

	for i=1:1:nTests {
		do client.GetIRISVersion()
	}

	for i=1:1:nDivides {
		do client.Divide($r(1000),$r(1000)+$s(WithErrors:1,1:0))
	}
}

}
