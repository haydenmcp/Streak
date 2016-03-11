'
'   Television channel module
'   @author: Hayden McParlane
'   @creation-date: 2.29.2016

' TODO: Refactor such that more efficient and ordered predictably
Function AddProgramKeyValue(programId as String, key as String, value as Object) as void
    base = GetPrograms()
    CreateIfDoesntExist(base, programId, "roAssociativeArray")
    program = base[programId]
    program[key] = value
End Function

Function AppendToProgram(programId as String, o as object)
    base = GetPrograms()
    CreateIfDoesntExist(base, programId, "roAssociativeArray")
    oMapped = MapFromSchedulesDirect(o)
    base[programId].Append(oMapped)
End Function

Function GetProgram(programId as String) as Object
    base = GetPrograms()
    CreateIfDoesntExist(base, programId, "roAssociativeArray")
    return base[programId]
End Function

Function AddUpdatePrograms(o as object) as void
    base = GetTV()
    CreateIfDoesntExist(base, "programs", "roAssociativeArray")
    base.programs = o
End Function

Function GetPrograms() as object
    base = GetTV()
    CreateIfDoesntExist(base, "programs", "roAssociativeArray")
    return base.programs
End Function

' TODO: Modify channels to be filter category not main storage
Function AddUpdateChannel(id as String, o as object) as void
    base = GetChannels()    
    base[id] = o
End Function

Function GetChannel(id as String) as Object
    base = GetChannels()
    return base[id]
End Function

Function AddUpdateChannels(o as object) as void
    base = GetTV()
    base.channels = o
End Function

Function GetChannels() as Object
    base = GetTV()
    return base.channels
End Function

Function AddUpdateTV(o as Object) as void
    m.tv = o
End Function

Function GetTV() as Object
    return m.tv
End Function

' TODO: REFACTOR EPISODES METHODS. TOo many references to Episode objects. It'll be confusing
' without knowing the internals. Come up with better names to differentiate.
Function AppendToFilterList(filter as String, hash as String, programID as String) as void
    base = GetEpisodeSubcategory(filter, EpisodeSubcategoryData())
    CreateIfDoesntExist(base, hash, "roArray")
    base[hash].Push(GetProgram(programID))
End Function

Function GetEpisodes(filter as String) as Object     
    return GetEpisodeSubcategory(filter, EpisodeSubcategoryData())
End Function

Function AddUpdateEpisodes(filter as String, o as Object) as Object     
    base = GetEpisodeSubcategory(filter, EpisodeSubcategoryData())
    base = o
End Function

Function GetEpisodeTitles(filter as String) as Object
    return GetEpisodeSubcategory(filter, EpisodeSubcategoryTitles())    
End Function

' TODO: Bug found related to using same level get. Pass by value maybe?
' Fix in commands module was to include base.cur_level = o. How to do here?
Function AddUpdateEpisodeTitles(filter as String, o as Object) as void    
    base = GetEpisodeSubcategory(filter, EpisodeSubcategoryTitles())
    LogDebugObj("Printing Ep Titles -> ", o)
    base = o
End Function

Function AddEpisodeSubcategory(filter as String, subcategory as String, catType as String) as void
    base = GetEpisodeFilter(filter)
    CreateIfDoesntExist(base, subcategory, catType)
End Function

Function GetEpisodeSubcategory(filter as String, subcategory as String) as Object
    base = GetEpisodeFilter(filter)
    CreateIfDoesntExist(base, subcategory, "roAssociativeArray")
    return base[subcategory]    
End Function

Function AddUpdateEpisodeFilter(filter as String, o as Object) as void
    base = GetEpisodeFilters()
    CreateIfDoesntExist(base, filter, "roAssociativeArray")
    base[filter] = o
End Function

Function GetEpisodeFilter(filter as String) as Object
    base = GetEpisodeFilters()
    CreateIfDoesntExist(base, filter, "roAssociativeArray")
    return base[filter]
End Function

Function AddUpdateEpisodeFilters(o as Object) as void
    base = GetTV()
    CreateIfDoesntExist(base, "filters", "roAssociativeArray")
    base.filters = o
End Function

Function GetEpisodeFilters() as Object
    base = GetTV()
    CreateIfDoesntExist(base, "filters", "roAssociativeArray")
    return base.filters
End Function

Function EpisodeFilterGenre() as String
    return "genre"
End Function

Function EpisodeFilterTime() as String
    return "time"
End Function

Function EpisodeFilterDate() as String
    return "date"
End Function

Function EpisodeSubcategoryTitles() as String
    return "titles"
End Function

Function EpisodeSubcategoryData() as String
    return "data"
End Function

Function MapFromSchedulesDirect(aa as Object) as Object
    keySet = aa.Keys()
    newAA = CreateObject("roAssociativeArray")
    for i = 0 to keySet.Count() - 1
        currentKey = keySet[i]
        newAA[MapKeyFromSchedulesDirect(currentKey)] = aa[currentKey]
    end for
    return newAA
End Function

Function MapKeyFromSchedulesDirect(key as String) as String       
    mapper = GetKeyToKeyMapper()
    if mapper.DoesExist(key)
        result = mapper[key]
    else
        result = key
    end if 
    return result
End Function

Function GetKeyToKeyMapper()
    return m.keymap
End Function

Function InitKeyToKeyMapper() as void
    m.keymap = CreateObject("roAssociativeArray")
    map = m.keymap
    map.AddReplace(SchedulesDirectKeyAirDateTime(), "airDateTime")
    map.AddReplace(SchedulesDirectKeyDuration(), "Length")
    map.AddReplace(SchedulesDirectKeyOriginalAirDate(), "ReleaseDate")
    map.AddReplace(SchedulesDirectKeyRatings(), "rating")
    map.AddReplace("title120", "Title")        
End Function

Function InitTelevisionDataStore() as Boolean
    LogDebug("Initializing TV data store")

    ' Setup the data store hierarchy
    base = m.tv
    if base = invalid
        AddUpdateTV(CreateObject("roAssociativeArray"))
        if GetTV() = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if
        
    filters = m.tv.filters
    channels = m.tv.channels
    prog = m.tv.programs
    if channels = invalid
        AddUpdateChannels(CreateObject("roAssociativeArray"))
        if GetChannels() = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if            
    if filters = invalid
        AddUpdateEpisodeFilters(CreateObject("roAssociativeArray"))
        if GetEpisodeFilters() = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if
    if prog = invalid
        AddUpdatePrograms(CreateObject("roAssociativeArray"))
        if GetPrograms() = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if
    
    channel = m.tv.channels.channel
    if channel = invalid
        AddUpdateChannel("NULL", CreateObject("roAssociativeArray"))
        if GetChannel("NULL") = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if
    
    ' TODO: Figure out way to ensure filters and subcategories are defined when referenced
    ' Create two standard filters to display
    o = CreateObject("roArray", 1, True)
    o.Push(EpisodeFilterGenre())
    o.Push(EpisodeFilterTime())
    
    for i = 0 to o.Count() - 1
        AddUpdateEpisodeFilter(o[i], CreateObject("roAssociativeArray"))
        AddEpisodeSubcategory(o[i], EpisodeSubcategoryTitles(), "roArray")
        AddEpisodeSubcategory(o[i], EpisodeSubcategoryData(), "roAssociativeArray")
    end for    
    
    LogDebug("Initializing key-to-key mapper")
    InitKeyToKeyMapper()
    LogDebug("Initializing key-to-key mapper successful")
    
    LogDebug("Initializing TV data store successful")    
End Function
