'
'   Television channel module
'   @author: Hayden McParlane
'   @creation-date: 2.29.2016
Function AddEpisode(epProgramID as String, epTitle as String, shortDesc1 as String, shortDesc2 as String,desc as String, epRating as string, epStarRating as String, epReleaseDate as String, epLength as string, actorsArray as Object,epDirector as String)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "episode"
    o.Title = epTitle
    o.ShortDescriptionLine1 = shortDesc1
    o.ShortDescriptionLine2 = shortDesc2
    o.Description = desc
    o.Rating = epRating
    o.StarRating = epStarRating
    o.Length = epLength
    o.Actors = actorsArray
    o.Director = epDirector
    o.programID = epProgramID
    AppendToProgram(epProgramID, o)
End Function

' TODO: Refactor such that more efficient and ordered predictably
' TODO: Are below objects necessary? Remove unecessary objects. All values stored
' here should specifically be those that will populate tv objects. No need to create
' analogs to schedules direct api.
Function AddProgramKeyValue(programId as String, key as String, value as Object) as void
    base = GetPrograms()
    CreateIfDoesntExist(base, programId, "roAssociativeArray")
    program = base[programId]
    program[key] = value
End Function

Function AppendToProgram(programId as String, o as object)
    base = GetProgram(programId)
    CreateIfDoesntExist(base, programId, "roAssociativeArray")
    oKeyMapped = MapFromSchedulesDirect(o)
    base.Append(oKeyMapped)
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

Function GetEpisodes(category as String) as Object
    base = GetEpisodeSubcategory(category, EpisodeSubcategoryData())
    return base.episodes
End Function

'Function AddUpdateEpisodes(category as String, aa as Object) as void
'    base = GetEpisodeSubcategory(category, EpisodeSubcategoryData())
'    base = 
'End Function

Function GetEpisodeTitles(category as String) as Object
    base = GetEpisodeSubcategory(category, EpisodeSubcategoryTitles())
    return base.episodes
End Function

Function AppendToEpisodeList(newEpisode as Object) as void
    list = GetEpisodeList()
    list.Push(newEpisode)
End Function

Function AddUpdateEpisodeList(o as Object) as void
    base = GetTV()
    base.episodes = o
End Function        

Function GetEpisodeList() as Object
    base = GetTV()
    return base.episodes
End Function

Function AddEpisodeSubcategory(category as String, subcategory as String, catType as String) as void
    base = GetEpisodeCategories()
    if catType = "roArray"
        o = CreateObject(catType, 1, True)
    else if catType = "roAssociativeArray"
        o = CreateObject("roAssociativeArray")
    end if
    base[category][subcategory] = o
End Function

Function GetEpisodeSubcategory(category as String, subcategory as String) as Object
    base = GetEpisodeCategories()
    if base[category][subcategory] <> invalid
        return base[category][subcategory]
    else
        return invalid
    end if
End Function

Function AddUpdateEpisodeCategory(category as String) as void
    base = GetEpisodeCategories()
    base[category] = CreateObject("roAssociativeArray")
End Function

Function GetEpisodeCategory(category as String) as Object
    base = GetEpisodeCategories()
    if base[category] <> invalid
        return base[category]
    else
        return invalid
    end if
End Function

Function AddUpdateEpisodeCategories(o as Object) as void
    base = GetTV()
    base.categories = o
End Function

Function GetEpisodeCategories() as Object
    base = GetTV()
    return base.categories
End Function

Function EpisodeCategoryGenre() as String
    return "genre"
End Function

Function EpisodeCategoryTime() as String
    return "time"
End Function

Function EpisodeCategoryDate() as String
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
    map.AddReplace("airDateTime", "airDateTime")
    map.AddReplace("duration", "Length")    
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
    
    ep = m.tv.episodes
    cat = m.tv.categories
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
    if ep = invalid
        AddUpdateEpisodeList(CreateObject("roArray", 1, True))
        if GetEpisodeList() = invalid
            LogError("Add/Update vs. Getter for data store are inconsistent")
            success = False
            stop 
        end if        
    end if
    if cat = invalid
        AddUpdateEpisodeCategories(CreateObject("roAssociativeArray"))
        if GetEpisodeCategories() = invalid
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
    
    ' TODO: Figure out way to ensure categories and subcategories are defined when referenced
    ' Create two standard categories to display
    o = CreateObject("roArray", 1, True)
    o.Push(EpisodeCategoryGenre())
    o.Push(EpisodeCategoryTime())
    
    for i = 0 to o.Count() - 1
        AddUpdateEpisodeCategory(o[i])
        AddEpisodeSubcategory(o[i], EpisodeSubcategoryTitles(), "roArray")
        AddEpisodeSubcategory(o[i], EpisodeSubcategoryData(), "roAssociativeArray")
    end for    
    
    LogDebug("Initializing key-to-key mapper")
    InitKeyToKeyMapper()
    LogDebug("Initializing key-to-key mapper successful")
    
    LogDebug("Initializing TV data store successful")    
End Function
