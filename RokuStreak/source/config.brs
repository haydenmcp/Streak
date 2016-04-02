'
'   This document contains configuration information for reuse. All common data
'   should be entered here to avoid needing numerous code changes upon code modification.
'   @author: Hayden McParlane
'   @creation-date: 2.18.2016
Function Authentication() as String
    return "authentication"
End Function

Function ScheduleAPIName() as String
    return "Schedules Direct"
End Function

Function SSLCertificatePath() as String
    return "common:/certs/ca-bundle.crt"
End Function

Function XRokuReservedDevId() as String    
    return ""
End Function

Function TempEntityCount() as Integer
    return 15
End Function

Function Username() as String
    return "username"
End Function

Function Password() as String
    return "password"
End Function

Function SetAuthData(section as String, user as String, pass as String) as Object
    sec = CreateObject("roRegistrySection", section)
    sec.Write(Username(), user)
    sec.Write(Password(), pass)
    sec.Flush()
End Function

Function GetAuthUsername(section as String) as Dynamic
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(Username())
        return sec.Read(Username())
    end if
    return invalid
End Function

Function GetAuthPassword(section as String) as Dynamic
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(Password())
        return sec.Read(Password())
    end if
    return invalid
End Function

'################################################################################
'   AppManager Application Settings
'################################################################################
Sub SetApplicationTheme()
    ' TODO: Configure specific display properties for app

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")
    
    ' Shared
    'theme.AddReplace("BackgroundColor","#000000")
    
    ' Poster screen    
    theme.AddReplace("FilterBannerActiveColor","#3F007F")
    
    ' Grid screen
    theme.AddReplace("GridScreenBackgroundColor","#3F007F")
    
    app.SetTheme(theme)
End Sub

'################################################################################
'   Application runtime configuration and setup
'################################################################################
Function ConfigureApplicationEssentials() as void
    ' TODO: Application data stores should be setup and initialized here,
    ' not during tests.
    ' TODO: Include tests for user credentials. If they haven't logged in,
    ' prompt for uname and password or something     
    InitSchedulesDirectDataStore()   
    InitTelevisionDataStore()   
    'RenderFacadeScreen() 
End Function
