'
'   This document contains helper functions for use while working with networking.
'   For example, accessing response status codes, checking those codes, etc is done
'   here.
'   @author: Hayden McParlane
Function temp() as void
    ' TODO: Refine generic network access routines
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
End Function