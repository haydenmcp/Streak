'
'   This document contains helper functions for use while working with networking.
'   For example, accessing response status codes, checking those codes, etc is done
'   here.
'   @author: Hayden McParlane

'   Execute POST request at specified URL
Function PostRequest(destUrl as String, aaHeaders as Object, aaBody as Object) as Object                                 
    response = Request(POST(), destUrl, aaHeaders, aaBody)
    return response
End Function

Function GetRequest(destUrl as String, aaHeaders as Object, aaBody as Object) as Object                                 
    response = Request(GET(), destUrl, aaHeaders, aaBody)
    return response
End Function

Function Request(requestType as String, destUrl as String, aaHeaders as Object, aaBody as Object) as Object    
    urlTransfer = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    timer = CreateObject("roTimeSpan")
    timer.Mark()
    urlTransfer.SetPort(port)
    urlTransfer.SetUrl(destUrl)
    
    packet = ConstructPacket(urlTransfer, aaHeaders, aaBody)
    
    LogInfo("Initiating " + requestType + " request to -> " + destUrl)    
    if requestType = POST()
        urlTransfer.AsyncPostFromString(packet)
    else if requestType = GET()
        ' TODO: Test a GET request using this same function
        urlTransfer.AsyncGetToString(packet)
    else
        LogError("Invalid request type -> " + requestType)
        stop
    end if
    
    while true
        LogDebug("Waiting for server response")
        msg = wait(100, port)
        if type(msg) = "roUrlEvent" then
            LogDebug("Server response received")
            LogDebugObj("Response Code is ", msg.GetResponseCode())
            ' TODO: Efficiently implement check of different response status codes here
            if msg.GetResponseCode() = 200 then             
                response = BuildResponse(msg)                
                exit while
            else
                u.AsyncCancel()
            end if
        else
            ' TODO: Make async request useful instead of blocking
            'LogDebug("Do Useful stuff while wait for data")
        end if
   end while   
   return response    
End Function

Function BuildResponse(message as Object) as Object
    if message = invalid
        LogError("UrlTransfer Message received was invalid")
        stop
    else
        ' TODO: Think about event data that may be useful to include here. For reference, look @ 
        ' https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent
        LogDebug("Constructing response object")
        response = CreateObject("roAssociativeArray")                        
        response.json = ParseJSON(message.GetString())
        response.jsonString = message.GetString()
        response.headers = message.GetResponseHeadersArray()  
        LogDebug("Value of response.body -> " + response.jsonString)
        LogDebugObj("Value of response.json -> ", response.json)        
        for each header in response.headers    
            LogDebugObj("Value of response.headers -> ", header)           
        end for
        LogDebug("Response object build successful")
    end if
    return response
End Function

Function ConstructPacket(urlTransfer as Object, aaHeaders as Object, aaBody as Object) as String            
    InitClient(urlTransfer)               
    ConstructPacketHeader(urlTransfer, aaHeaders)
    bodyStr = ConstructPacketBody(aaBody)
    return bodyStr
End Function

Function ConstructPacketHeader(urlTransfer as Object, aaHeaders as Object) as void
    if aaHeaders = invalid
        ' Do nothing
    else    
        for each header in aaHeaders
            urlTransfer.AddHeader(header, aaHeaders[header])
        end for
    end if    
End Function

Function ConstructPacketBody(aaBody as Object) as String
    if aaBody = invalid
        bodyStr = ""
    else
        bodyStr = ConstructJSONStr(aaBody)
    end if   
    return bodyStr
End Function

Function InitClient(urlTransfer as Object) as void    
    urlTransfer.SetCertificatesFile(SSLCertificatePath())
    urlTransfer.AddHeader("X-Roku-Reserved-Dev-Id",XRokuReservedDevId())
    urlTransfer.InitClientCertificates()    
End Function

Function POST() as String
    return "POST"
End Function

Function GET() as String
    return "GET"
End Function