'
'   This document contains functions to help with json construction
'   @author: Hayden McParlane
Function ConstructJSONStr(o as Object) as String
    json = ""  
    if type(o) = "roAssociativeArray"  
        firstKey = GetRandomKey(o)
        json = "{ " + EmbedInQuotes(firstKey) + ": " + EmbedInQuotes(o[firstKey])  
        for each key in o
            if key <> firstKey
                json = json + ", " + EmbedInQuotes(key) + ":" + EmbedInQuotes(o[key])
            end if
        end for
        json = json + " }"
    else if type(o) = "roArray"
        json = "[ " + o[0]
        for i = 1 to o.Count() - 1
            json = json + ", " + o[i]
        end for        
        json = json + " ]"
    else
        LogErrorObj("Object for json print isn't compatible type. Printing object -> ", o)
    end if
    return json
End Function
