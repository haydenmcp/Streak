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
    ' TODO: Below is O(num_keys_visible). Optimization can come from populating rows that aren't visible right before they become
    ' visible instead of populating all of the rows at once.       
    'titles = GetEpisodeTitles(EpisodeFilterTime())    
    episodes = GetEpisodes(EpisodeFilterGenre())
    titles = episodes.keys() 'TODO: Titles should be stored and retrieved. Its much Faster
    
    grid.SetupLists(titles.Count())
    grid.SetListNames(titles)  
    for i = 0 to TempEntityCount() - 1 '=> Linear time ( O(num_keys_visible) ) 
       grid.SetContentList(i,episodes[titles[i]]) '=> keys will hash to list for row. Filtration will occur by storing different title types
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
             end if
         end if
    end while
End Function  