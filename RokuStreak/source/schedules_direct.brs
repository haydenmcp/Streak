'
'   This document contains an API for use with the Schedules Direct
'   open source television data service.
'   @author: Hayden McParlane
'   @creation-date: 2.18.2016
Function SchedulesDirectBaseJsonUrl() as String
    return "https://json.schedulesdirect.org/20141201"
End Function

Function SchedulesDirectJsonTokenUrl() as String
    return SchedulesDirectBaseJsonUrl() + "/token"
End Function

Function SearchSchedulesDirect() as void
    Tokenize()
End Function

Function Tokenize() as void ' This may need to be changed such that it returns something
                            ' such as an associative array
                            
    ' Need to check to make sure token isn't already defined *** TODO
    LogInfo("Tokenizing with Schedules Direct")
    aa = CreateObject("roAssociativeArray")
    aa.AddReplace("username", Username())
    aa.AddReplace("password", Password())
    
    LogDebugObj("Associative Arr ->", aa)    
            
    timer = CreateObject("roTimeSpan")
    timer.Mark()
    u = CreateObject("roUrlTransfer")
    u.SetCertificatesFile(SSLCertificatePath())
    u.AddHeader("X-Roku-Reserved-Dev-Id","")
    u.InitClientCertificates()
    port = CreateObject("roMessagePort")
    u.SetPort(port)
    u.SetUrl(SchedulesDirectJsonTokenUrl())
    u.AsyncPostFromString(ConstructJSONStr(aa))
    while true
        msg = wait(100, port)
        if type(msg) = "roUrlEvent" then
            LogDebug("roUrlEvent received")
            LogDebugObj("Response Code is ", msg.GetResponseCode())
            if msg.GetResponseCode() = 200 then
                LogInfo("HTTP 200 Status Received")
                response = msg.GetString()
                headers = msg.GetResponseHeadersArray()
                LogDebug("Response -> " + NewLine() + response)
                LogDebugObj("Headers -> ", headers)
                exit while
            else
                u.AsyncCancel()
            end if
        else
            LogDebug("Do Useful stuff while wait for data")
        end if
   end while
    ' Modify system to use Async later on. Right now blocking call is useful for debug.    
    
    m.json = ParseJSON(response)    
    
    LogDebugObj("After Parsing -> ", m.json)
    
End Function
