Class FHIRSMARTEx.Util.SimpleTrace Extends %RegisteredObject
{

ClassMethod Append(pText As %String)
{
	Set ^fset($Increment(^fset)) = $ZDateTime($Horolog, 3) _ ": " _ pText
}

ClassMethod Purge()
{
	Kill ^fset
}

ClassMethod Tail()
{
	#Dim tNext As %Integer = 1
	While (1) {
		While (tNext <= $Get(^fset)) {
			Write tNext _ ": " _ ^fset(tNext), !
			Set tNext = tNext + 1
		}
		hang 2
	}
}

}
