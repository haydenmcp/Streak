'
'   This document contains an API for use with the Schedules Direct
'   open source television data service.
'   @author: Hayden McParlane
'   @creation-date: 2.18.2016
Function SearchSchedulesDirect() as void
    ' TODO: Some of these functions will need to be removed and placed elsewhere. I.e, GetSchedulesDirectAccountStatus() should be called
    ' when the application is first launched from the Roku shell (home screen). That way, account status can be checked asynchronously
    ' to ensure it's ready when the user begins to use it (or, if it's not, the user can be prompted to enter updated account info some
    ' how.
    InitSchedulesDirect()
    SchedulesDirectTokenize()
    ' TODO: Modify as appropriate. Cable headends may not need fetch.    
    GetCableHeadends("USA", "66103")    
    GetChannelsFromLineupUri("/lineups/USA-OTA-66103")
    GetProgramsFromStationId()
    GetProgramInfo()
    GetProgramDescription()
End Function

' TODO: GetSchedulesDirectAccountStatus()
' TODO: GetSchedulesDirectVersionInfo()
' TODO: GetSchedulesDirectServiceList()
' TODO: CheckSchedulesDirectAccountStatus()
' TODO: CheckSchedulesDirectClientVersion()

' TODO: Later on, ensure tokenize implements token refresh if needed
Function SchedulesDirectTokenize() as void ' This may need to be changed such that it returns something
                            ' such as an associative array
    if HasSchedulesDirectToken()        
        LogInfo("Token already present. Skipping tokenize.")
    else          
        LogInfo("Tokenizing with Schedules Direct")
        headers = CreateObject("roAssociativeArray")
        body = CreateObject("roAssociativeArray")
        
        ' 1. Populate headers and body for network packet
        headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
        body.AddReplace("username", SchedulesDirectUsername())
        body.AddReplace("password", SchedulesDirectPassword())        
        
        ' 2. Make request to API
        response = PostRequest(SchedulesDirectJSONTokenUrl(), headers, body)
        
        ' 3. Check server status code (not HTTP status, that's checked in network module)            
        if response.headers["code"] = 3000
            LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
            ' TODO: Program shouldn't be halted. What should be done here?
            stop
        else if response.json["code"] <> 0
            LogErrorObj("Schedules Direct response status code non-zero (Abnormal).", response.json)
            stop
        end if
    
        ' 4. Store result in m-hierarchy        
        AddUpdateSchedulesDirectToken(response.json["token"])            
        LogInfo("Tokenize Complete Successfully -> " + GetSchedulesDirectToken())
    end if   
End Function

Function GetCableHeadends(country as String, zipcode as String)
    LogInfo("Fetching cable headends")    
    headers = CreateObject("roAssociativeArray")
    body = CreateObject("roAssociativeArray")
    
    ' 1. Populate headers and body for network packet    
    headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
    ' TODO: Token may not have been populated here, or may need to be refreshed.
    ' How to implement?
    headers.AddReplace("token",GetSchedulesDirectToken())
    body.AddReplace("username", SchedulesDirectUsername())
    body.AddReplace("password", SchedulesDirectPassword())               
    
    ' 2. Make request to API
    response = GetRequest(SchedulesDirectJSONCableHeadendsUrl(country, zipcode), headers, body)
    
    ' 3. Check server status code (not HTTP status, that's checked in network module)            
    if response.headers["code"] = 3000
        LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
        ' TODO: Program shouldn't be halted. What should be done here?
        stop
    end if          
    
    ' 4. Store result in m-hierarchy        
    AddUpdateSchedulesDirectCableHeadends(response.json)
    
    LogDebug("Printing m-hierarchy cable headends -> ")
    for each headend in GetSchedulesDirectCableHeadends()
        if headend["transport"] = "Antenna"
            LogDebugObj("", headend)
            for each lineup in headend["lineups"]
            LogDebugObj("", lineup)
            end for
        end if
    end for
    LogDebug("Fetch cable headends succeeded")            
End Function

Function GetChannelsFromLineupUri(lineupUri as String) as void
    LogInfo("Fetching lineup channels")    
    headers = CreateObject("roAssociativeArray")
    body = CreateObject("roAssociativeArray")
    
    ' 1. Populate headers and body for network packet    
    headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
    ' TODO: Token may not have been populated here, or may need to be refreshed.
    ' How to implement?
    headers.AddReplace("token",GetSchedulesDirectToken())
    ' TODO: Does username and password need to be supplied in body for this
    ' or GetCableHeadends above?                   
    body.AddReplace("username", SchedulesDirectUsername())
    body.AddReplace("password", SchedulesDirectPassword())
    ' 2. Make request to API
    response = GetRequest(SchedulesDirectJSONChannelMapUrl(lineupUri), headers, body)
    
    ' 3. Check server status code (not HTTP status, that's checked in network module)            
    if response.headers["code"] = 3000
        LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
        ' TODO: Program shouldn't be halted. What should be done here?
        stop
    end if          
    
    ' 4. Store result in m-hierarchy        
    AddUpdateSchedulesDirectChannels(response.json)
    LogDebugObj("Printing m-hierarchy channels -> ", GetSchedulesDirectChannels())
    LogDebug("Printing m-hierarchy channels -> ")
    stations = GetSchedulesDirectChannels()["stations"]
    for idx = 0 to stations.Count() - 1
        LogDebugObj("",stations[idx])
    end for
    LogDebug("Fetch channels succeeded")            
End Function

Function GetProgramsFromStationId() as void ' TODO: replace params -> stationIDs as Object
    LogInfo("Fetching stations with channel listings")    
    headers = CreateObject("roAssociativeArray")
    body = CreateObject("roArray", 1, True)
    station = CreateObject("roAssociativeArray")
    
    ' 1. Populate headers and body for network packet    
    headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
    ' TODO: Token may not have been populated here, or may need to be refreshed.
    ' How to implement?
    headers.AddReplace("token",GetSchedulesDirectToken())
    ' TODO: Does username and password need to be supplied in body for this
    ' or GetCableHeadends above?                   
    'body.AddReplace("username", SchedulesDirectUsername())
    'body.AddReplace("password", SchedulesDirectPassword())
    station.AddReplace("stationID","73365")
    body.Push(station)
    ' 2. Make request to API
    response = PostRequest(SchedulesDirectJSONSchedulesUrl(), headers, body)
    
    ' 3. Check server status code (not HTTP status, that's checked in network module)            
    if response.headers["code"] = 3000
        LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
        ' TODO: Program shouldn't be halted. What should be done here?
        stop
    end if          
    
    ' 4. Store result in m-hierarchy        
    AddUpdateSchedulesDirectStations(response.json)
    LogDebugObj("Printing stations -> ", GetSchedulesDirectStations())
    for each station in GetSchedulesDirectStations()
        LogDebugObj("", station)
        for i = 0 to station.programs.Count()
            LogDebugObj("", station.programs[i])
        end for
    end for
'    LogDebug("Printing m-hierarchy channels -> ")
'    stations = GetSchedulesDirectStations()["stations"]
'    for idx = 0 to stations.Count() - 1
'        LogDebugObj("",stations[idx])
'    end for
    LogDebug("Fetch stations succeeded")            
End Function

Function GetProgramInfo() as void ' TODO replace these params -> aProgramIDs as Object
    LogInfo("Fetching program data")    
    headers = CreateObject("roAssociativeArray")
    body = CreateObject("roArray", 1, True)
    
    body.Push("SH011425150000")
    body.Push("SH019486590000")
    
    ' 1. Populate headers and body for network packet    
    headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
    ' TODO: Token may not have been populated here, or may need to be refreshed.
    ' How to implement?
    headers.AddReplace("token",GetSchedulesDirectToken())
    headers.AddReplace("Accept-Encoding","deflate,gzip") ' TODO: Deplate gzip due to bug, may already be fixed
    ' TODO: Does username and password need to be supplied in body for this
    ' or GetCableHeadends above?                   
    'body.AddReplace("username", SchedulesDirectUsername())
    'body.AddReplace("password", SchedulesDirectPassword())
    
    ' 2. Make request to API
    response = PostRequest(SchedulesDirectJSONProgramInfoUrl(), headers, body)
    
    ' 3. Check server status code (not HTTP status, that's checked in network module)            
    if response.headers["code"] = 3000
        LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
        ' TODO: Program shouldn't be halted. What should be done here?
        stop
    end if          
    
    ' 4. Store result in m-hierarchy        
    AddUpdateSchedulesDirectPrograms(response.json)
    
    for each entry in GetSchedulesDirectPrograms()
        LogDebugObj("", entry)
    end for
    
    LogDebug("Fetch program data successful")            
End Function

Function GetProgramDescription() as void
    LogInfo("Fetching program descriptions")    
    headers = CreateObject("roAssociativeArray")
    'body = CreateObject("roAssociativeArray")
    body = CreateObject("roArray", 1, True)
    
    body.Push("SH011425150000")
    body.Push("SH019486590000")
    
    ' 1. Populate headers and body for network packet    
    headers.AddReplace("User-Agent",SchedulesDirectUserAgentHeader())
    'headers.AddReplace("Accept-Encoding","deflate,gzip") ' TODO: Deplate gzip due to bug, may already be fixed
    ' TODO: Token may not have been populated here, or may need to be refreshed.
    ' How to implement?
    headers.AddReplace("token",GetSchedulesDirectToken())
    'headers.AddReplace("Accept-Encoding","deflate,gzip") ' TODO: Deplate gzip due to bug, may already be fixed       
    
    ' 2. Make request to API
    response = PostRequest(SchedulesDirectJSONProgramDescriptionUrl(), headers, body)
    
    ' 3. Check server status code (not HTTP status, that's checked in network module)            
    if response.headers["code"] = 3000
        LogErrorObj("Schedules Direct server offline. Try again later.", response.json)
        ' TODO: Program shouldn't be halted. What should be done here?
        stop
    end if          
    
    ' 4. Store result in m-hierarchy
    ' TODO: Is storage of this information necessary? What to do here?        
    ' AddUpdateSchedulesDirectProgramInfo(response.json)
    LogDebugObj("Program Descriptions -> ", response.json)
    
    for each program in response.json
        for each field in program
            LogDebugObj("", field)
        end for
    end for
    
    LogDebug("Fetch program descriptions successful")            
End Function

'###################################################################################
' The following functions define the applications schedules direct
' data hierarchy present in m (i.e, m.schedulesAPI.data....). 
'###################################################################################

' TODO: Right now, two changes are required to each change of schedules direct access
' because the names are used here as well as the getter/setter functions. Better way
' to initialize? This function should be called immediately upon app launch.
Function InitSchedulesDirect() as void
    LogDebug("Initializing Schedules Direct m-hierarchy and testing for run-time function consistency")
    
    ' !!! NOTE !!! THIS FUNCTION IS EXTREMELY SENSITIVE TO FUNCTION CALL ORDER. ONLY CHANGE
    ' IF YOU UNDERSTAND THE LOGICAL DESIGN OF THE M-HIERARCHY (I.E, m.schedulesAPI.data.... etc)
    base_dir = m.schedulesAPI         
    if base_dir = invalid        
        AddUpdateSchedulesDirectBase(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectBase() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if
    end if
    
    network_dir = m.schedulesAPI.network
    data_dir = m.schedulesAPI.data
    
    if network_dir = invalid            
        AddUpdateSchedulesDirectNetwork(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectNetwork() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if
    end if    
    if data_dir = invalid
        AddUpdateSchedulesDirectData(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectData() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if
    end if
    
    headers_dir = m.schedulesAPI.network.headers
    cableHeadends_dir = m.schedulesAPI.data.cableHeadends
    channels_dir = m.schedulesAPI.data.channels
    programs_dir = m.schedulesAPI.data.programs
    stations_dir = m.schedulesAPI.data.stations
    
    if headers_dir = invalid        
        AddUpdateSchedulesDirectHeaders(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectHeaders() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if
    end if
    if cableHeadends_dir = invalid
        AddUpdateSchedulesDirectCableHeadends(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectCableHeadends() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if        
    end if
    if channels_dir = invalid
        AddUpdateSchedulesDirectChannels(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectChannels() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop
        end if
    end if
    if programs_dir = invalid
        AddUpdateSchedulesDirectPrograms(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectPrograms() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop
        end if
    end if
    if stations_dir = invalid
        AddUpdateSchedulesDirectStations(CreateObject("roAssociativeArray"))
        if GetSchedulesDirectStations() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop
        end if
    end if            
    
    token_loc = m.schedulesAPI.network.headers.token
    
    if token_loc = invalid
        AddUpdateSchedulesDirectToken("")
        if GetSchedulesDirectToken() = invalid
            LogError("Add/Update vs. Getter for Schedules Direct m-hierarchy are inconsistent")
            stop 
        end if        
    end if        
End Function
        
Function AddUpdateSchedulesDirectStations(stations as Object) as void
    obj = GetSchedulesDirectData()
    obj.stations = stations
End Function

Function GetSchedulesDirectStations() as Object
    obj= GetSchedulesDirectData()
    return obj.stations
End Function        

Function AddUpdateSchedulesDirectPrograms(aaPrograms as Object) as void
    obj = GetSchedulesDirectData()
    obj.programs = aaPrograms
End Function

Function GetSchedulesDirectPrograms() as Object
    obj= GetSchedulesDirectData()
    return obj.programs
End Function

Function AddUpdateSchedulesDirectChannels(aaChannels as Object) as void
    obj = GetSchedulesDirectData()
    obj.channels = aaChannels
End Function

Function GetSchedulesDirectChannels() as Object
    obj= GetSchedulesDirectData()
    return obj.channels
End Function


Function AddUpdateSchedulesDirectCableHeadends(aaCableHeadends as Object) as void
    obj = GetSchedulesDirectData()
    obj.cableHeadends = aaCableHeadends
End Function

Function GetSchedulesDirectCableHeadends() as Object
    obj= GetSchedulesDirectData()
    return obj.cableHeadends
End Function

Function AddUpdateSchedulesDirectData(aaData as Object) as void
    obj = GetSchedulesDirectBase()
    obj.data = aaData
End Function

Function GetSchedulesDirectData() as Object
    obj = GetSchedulesDirectBase()
    return obj.data
End Function

Function AddUpdateSchedulesDirectToken(newToken as String) as void
    obj = GetSchedulesDirectHeaders()
    obj.token = newToken
End Function

Function GetSchedulesDirectToken() as String
    obj = GetSchedulesDirectHeaders()
    return obj.token
End Function

Function AddUpdateSchedulesDirectHeaders(aaHeaders as Object) as void
    obj = GetSchedulesDirectNetwork()
    obj.headers = aaHeaders
End Function

Function GetSchedulesDirectHeaders() as Object
    obj = GetSchedulesDirectNetwork()  
    return obj.headers
End Function

Function AddUpdateSchedulesDirectNetwork(aaNetwork as Object) as void
    obj = GetSchedulesDirectBase()
    obj.network = aaNetwork
End Function

Function GetSchedulesDirectNetwork() as Object
    obj = GetSchedulesDirectBase()
    return obj.network
End Function

Function AddUpdateSchedulesDirectBase(aaSchedulesDirectBase as Object) as Object    
    m.schedulesAPI = aaSchedulesDirectBase
End Function

Function GetSchedulesDirectBase() as Object    
    return m.schedulesAPI
End Function

Function HasSchedulesDirectToken() as Boolean
    result = False    
    if GetSchedulesDirectToken() = ""
        ' Do nothing
    else
        result = True
    end if
    return result
End Function

Function HasSchedulesDirectCableHeadends() as Boolean
    result = False
    if GetSchedulesDirectCableHeadends() = invalid
        ' Do nothing
    else
        result = True
    end if
    return result
End Function

Function SchedulesDirectUsername() as String
    return Username()
End Function

Function SchedulesDirectPassword() as String
    return Sha1Digest(RawPassword())
End Function

Function SchedulesDirectUserAgentHeader() as String
    return "RokuStreak"
End Function

Function SchedulesDirectBaseJSONUrl() as String
    return "https://json.schedulesdirect.org/20141201"
End Function

Function SchedulesDirectJSONTokenUrl() as String
    return SchedulesDirectBaseJSONUrl() + "/token"
End Function

Function SchedulesDirectJSONCableHeadendsUrl(country as String, zipcode as String) as String
    ' TODO: Validate country entry style? Builder to translate entered strings into required strings?
    return SchedulesDirectBaseJSONUrl() + "/headends?country=" + country + "&" + "postalcode=" + zipcode
End Function

Function SchedulesDirectJSONChannelMapUrl(lineupUri as String) as String
    ' TODO: Validate country entry style? Builder to translate entered strings into required strings?
    return SchedulesDirectBaseJSONUrl() + lineupUri
End Function

Function SchedulesDirectJSONSchedulesUrl() as String
    ' TODO: Validate country entry style? Builder to translate entered strings into required strings?
    return SchedulesDirectBaseJSONUrl() + "/schedules"
End Function


Function SchedulesDirectJSONProgramInfoUrl() as String
    ' TODO: Validate country entry style? Builder to translate entered strings into required strings?
    return SchedulesDirectBaseJSONUrl() + "/programs"
End Function

Function SchedulesDirectJSONProgramDescriptionUrl() as String
    ' TODO: Validate country entry style? Builder to translate entered strings into required strings?
    return SchedulesDirectBaseJSONUrl() + "/metadata/description"
End Function



