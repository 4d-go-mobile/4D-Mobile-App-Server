/*
Construct a Session object.

If you have only one application in your Session files (`MobileApps/`),
you can call the constructor with no parameter. 
However, if you have more than one, you will need to provide parameters 
to identify which application you want to send push notifications to.

MobileAppServer .Session.new() -> session // only if one application
MobileAppServer .Session.new( "TEAM123456.com.sample.myappname" ) -> session
MobileAppServer .Session.new( "com.sample.myappname" ) -> session
MobileAppServer .Session.new( "myappname" ) -> session
*/
Class constructor
	C_TEXT:C284($1)  // Application ID (teamID.bundleID) or Bundle ID or Application name or empty entry
	
	C_OBJECT:C1216($Dir_mobileApps; $appFolder)
	C_LONGINT:C283($folder_indx)
	C_BOOLEAN:C305($emptyParameter)
	ARRAY TEXT:C222($appFoldersList; 0)
	
	$Dir_mobileApps:=Folder:C1567(fk mobileApps folder:K87:18; *)
	
	If ($Dir_mobileApps.exists)
		
		// Each folder corresponds to an application
		FOLDER LIST:C473($Dir_mobileApps.platformPath; $appFoldersList)
		
		Case of 
				
			: (Count parameters:C259=0)
				
				$emptyParameter:=True:C214
				
			: (Length:C16(String:C10($1))=0)
				
				$emptyParameter:=True:C214
				
			Else 
				
				$emptyParameter:=False:C215
				
		End case 
		
		If (Bool:C1537($emptyParameter))  // Empty entry
			
			Case of 
					
				: (Size of array:C274($appFoldersList)=0)
					
					ASSERT:C1129(False:C215; "There is no application folder found")
					
				: (Size of array:C274($appFoldersList)=1)
					
					$appFolder:=$Dir_mobileApps.folder($appFoldersList{1})
					
					This:C1470.sessionDir:=$appFolder
					
				Else 
					
					ASSERT:C1129(False:C215; "There are several application folders, can't select appropriate application")
					
			End case 
			
		Else   // Application ID (teamID.bundleID) or Bundle ID or Application name
			
			$folder_indx:=Find in array:C230($appFoldersList; $1)
			
			
			C_TEXT:C284($folder_name)
			C_COLLECTION:C1488($Col_app)
			C_LONGINT:C283($pos; $app_indx)
			
			
			// Application ID (teamID.bundleID)
			
			If ($folder_indx>0)
				
				$appFolder:=$Dir_mobileApps.folder($appFoldersList{$folder_indx})
				
				If ($appFolder.exists)
					
					This:C1470.sessionDir:=$appFolder
					
					// Else : application directory doesn't exist
					
				End if 
				
				// Else : Application ID (teamID.bundleID) not found
				
			End if 
			
			
			// Application name
			
			If (This:C1470.sessionDir=Null:C1517)
				
				For ($app_indx; 1; Size of array:C274($appFoldersList); 1)
					
					$folder_name:=$appFoldersList{$app_indx}
					
					$Col_app:=Split string:C1554($folder_name; ".")
					
					If ($Col_app[$Col_app.length-1]=$1)
						
						$appFolder:=$Dir_mobileApps.folder($folder_name)
						
						If ($appFolder.exists)
							
							This:C1470.sessionDir:=$appFolder
							
							// Else : application directory doesn't exist
							
						End if 
						
						// Else : Application name not found
						
					End if 
					
				End for 
				
				// Else : sessionDir already found
				
			End if 
			
			
			// Bundle ID
			
			If (This:C1470.sessionDir=Null:C1517)
				
				For ($app_indx; 1; Size of array:C274($appFoldersList); 1)
					
					$folder_name:=$appFoldersList{$app_indx}
					
					$pos:=Position:C15($1; $folder_name)
					
					If ($pos>0)
						
						$appFolder:=$Dir_mobileApps.folder($folder_name)
						
						If ($appFolder.exists)
							
							This:C1470.sessionDir:=$appFolder
							
							// Else : application directory doesn't exist
							
						End if 
						
						// Else : BundleId found
						
					End if 
					
				End for 
				
				// Else : sessionDir already found
				
			End if 
			
			
		End if 
		
		// Else : couldn't find MobileApps folder in host database
		
	End if 
	
	If (This:C1470.sessionDir=Null:C1517)
		
		ASSERT:C1129(False:C215; "Session folder could not be found")
		
	End if 
	
	
	
	
	//-------------------------------------------------------------------------
Function getAllDeviceTokens
	
	C_OBJECT:C1216($0)
	
	If (This:C1470.sessionDir=Null:C1517)
		
		ASSERT:C1129(False:C215; "Session folder could not be found")
		
	End if 
	
	$0:=MOBILE APP Get all deviceTokens(This:C1470.sessionDir)
	
	//-------------------------------------------------------------------------
Function getAllMailAddresses
	
	C_OBJECT:C1216($0)
	
	If (This:C1470.sessionDir=Null:C1517)
		
		ASSERT:C1129(False:C215; "Session folder could not be found")
		
	End if 
	
	$0:=MA Get all mailAddresses(This:C1470.sessionDir)
	
	//-------------------------------------------------------------------------
Function getSessionInfoFromMail
	
	C_OBJECT:C1216($0)
	
	C_TEXT:C284($1)  // mail address
	
	If (This:C1470.sessionDir=Null:C1517)
		
		ASSERT:C1129(False:C215; "Session folder could not be found")
		
	End if 
	
	If (Asserted:C1132(Count parameters:C259>=1; "Missing mail address parameter"))
		
		ASSERT:C1129(Value type:C1509($1)=Is text:K8:3; "The function requires a mail address, a text is expected")
		
	End if 
	
	$0:=MOBILE APP Get session info(This:C1470.sessionDir; $1)
	
	//-------------------------------------------------------------------------
Function getSessionObjects
	C_COLLECTION:C1488($0; $sessionObjects)
	$sessionObjects:=New collection:C1472()
	If (This:C1470.sessionDir=Null:C1517)
		
		ASSERT:C1129(False:C215; "Session folder could not be found")
		
	End if 
	C_OBJECT:C1216($sessionFile)
	For each ($sessionFile; This:C1470.sessionDir.files())
		
		If ($sessionFile.extension="")
			
			$sessionObjects.push(cs:C1710.SessionObject.new($sessionFile))
			
		End if 
		
	End for each 
	
	$0:=$sessionObjects