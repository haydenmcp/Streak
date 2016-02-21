'
'   This document contains the logging system for this component
'   of the software system
'   @author: Hayden McParlane
'   @creation-date: 2.18.2016
Function LogDebug(msg as String) as void
    print NewLine() + "--DEBUG    : ";msg;    
End Function

Function LogDebugObj(msg as String, o as Object) as void
    print NewLine() + "--DEBUG    : ";msg;
    LogObject(o)
End Function

Function LogInfo(msg as String) as void
    print NewLine() + "--INFO     : ";msg;    
End Function

Function LogInfoObj(msg as String, o as Object) as void
    print NewLine() + "--INFO     : ";msg;    
    LogObject(o)
End Function

Function LogWarning(msg as String) as void
    print NewLine() + "--WARNING  : ";msg;    
End Function

Function LogWarningObj(msg as String, o as Object) as void
    print NewLine() + "--WARNING  : ";msg;
    LogObject(o)
End Function

Function LogError(msg as String) as void
    print NewLine() + "--ERROR    : ";msg;
End Function

Function LogErrorObj(msg as String, o as Object) as void
    print NewLine() + "--ERROR    : ";msg;
    LogObject(o)
End Function

Function LogCritical(msg as String) as void
    print NewLine() + "--CRITICAL : ";msg;
End Function

Function LogCriticalObj(msg as String, o as Object) as void
    print NewLine() + "--CRITICAL : ";msg;
    LogObject(o)
End Function

Function LogObject(o as Object) as void    
    print NewLine()
    print o
End Function