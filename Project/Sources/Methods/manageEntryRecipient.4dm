//%attributes = {"invisible":true,"preemptive":"capable"}
C_OBJECT:C1216($0)  // Returned recipient collections object
C_VARIANT:C1683($1)  // Input recipient(s)


// BUILD RECIPIENTS COLLECTIONS
//________________________________________

$0:=New object:C1471(\
"mails"; New collection:C1472; \
"deviceTokens"; New collection:C1472)

Case of 
	: (Value type:C1509($1)=Is object:K8:27)
		
		If (Value type:C1509($1.simulators)=Is collection:K8:32)
			
			// If user has provided a simulators collection, we put it in deviceTokens collection
			
			If (Not:C34(Value type:C1509($1.deviceTokens)=Is collection:K8:32))
				
				$1.deviceTokens:=New collection:C1472
				
			End if 
			
			$1.deviceTokens:=$1.deviceTokens.concat($1.simulators)
			
		End if 
		
		$0:=$1
		
	: (Value type:C1509($1)=Is collection:K8:32)
		
		C_VARIANT:C1683($item)
		
		For each ($item; $1)
			
			If (Value type:C1509($item)=Is text:K8:3)
				
				If (isEmail($item))
					
					$0.mails.push($item)
					
				Else 
					
					$0.deviceTokens.push($item)
					
				End if 
				
				// Else : $1 is not a collection of mails, nor a collection of deviceTokens, nor a collection of simulators UDID
				
			End if 
			
		End for each 
		
		$0.mails:=$0.mails.distinct()
		
	: (Value type:C1509($1)=Is text:K8:3)
		
		If (isEmail($1))
			
			$0.mails.push($1)
			
		Else 
			
			$0.deviceTokens.push($1)
			
		End if 
		
End case 
