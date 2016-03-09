'
'   This document contains the television schedule object which will
'   be used to encapsulate scheduling functionality such as record show,
'   search, etc.
'   @author: Hayden McParlane
'   @creation-date: 2.18.2016

' Perform search for tv schedule listings based on input filters
Function RenderTVSchedule() as integer
    port = CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    rowTitles = CreateObject("roArray", 10, true)
    ' TODO: Below is O(num_keys_visible). Optimization can come from populating rows that aren't visible right before they become
    ' visible instead of populating all of the rows at once.    
    'titles = GetEpisodeTitles(EpisodeCategoryTime())
    'episodes = GetEpisodes(EpisodeCategoryTime())
    'for j = 0 to titles.Count() - 1 => Linear time ( O(num_keys_visible) ) 
    '   rowTitles.Push(keys[j]) => titles will be hash values such as genre types (i.e, comedy, drama, etc)
    '   grid.SetContentList(j,episodes[titles[j]]) => keys will hash to list for row. Filtration will occur by storing different title types
    'end for
    'grid.SetupLists(rowTitles.Count())
    'grid.Show()
        
    for j = 0 to TempEntityCount()
        rowTitles.Push("[Row Title " + j.toStr() + " ] ")
    end for
    grid.SetupLists(rowTitles.Count())
    grid.SetListNames(rowTitles)    
    list = GetEpisodeList()    
    for j = 0 to TempEntityCount()
        grid.SetContentList(j, list)
        grid.Show()
    end for
    while true
         msg = wait(0, port)
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return -1
             else if msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
             else if msg.isListItemSelected()
                 print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
                 ' Grab list item corresponding to selection
                 
                 
                 
             end if
         end if
    end while
End Function  