'
'   Commands registered with application and "factory" to retrieve them
'   @author: Hayden McParlane
'   @creation-date: 3.10.2016
' TODO: Return boolean

Function ExecuteCommand(id as String) as void
    ' 1. Store arguments in shared data structure. This allows
    ' for dynamic command execution    
    'commands = GetCommandRegistry()    
    reg = GetCommandRegistry()
    if reg.DoesExist(id)
        command = reg[id]
    else
        LogError("Command does not exist. ID: " + id)
        stop
    end if
End Function

Function GetCommandArguments() as Object
    base = GetCommandBase()
    CreateIfDoesntExist(base, "args", "roAssociativeArray")
    return base.args
End Function

Function SetCommandArguments(args as Object) as void
        base = GetCommandBase()
        LogDebugObj("Printing base in SetCommandArgs -> ", args)
        base.args = args
End Function 

Function RegisterCommand(id as String, func as Object) as void
    LogDebug("Registering command. ID: " + id)    
    reg = GetCommandRegistry()
    reg[id] = func        
End Function

Function GetCommand(id as String) as Object
    reg = GetCommandRegistry()
    return reg[id]
End Function

Function GetCommandRegistry() as Object
    base = GetCommandBase()
    CreateIfDoesntExist(base, "reg", "roAssociativeArray")
    return base.reg
End Function

Function SetCommandRegistry(o as Object) as void
    base = GetCommandBase()
    base.reg = o
End Function

Function GetCommandBase() as Object
    CreateIfDoesntExist(m, "commands", "roAssociativeArray")
    return m.commands
End Function

Function SetCommandBase(o as Object) as Object
    CreateIfDoesntExist(m, "commands", "roAssociativeArray")
    return m.commands
End Function

'###########################################################################
'#   Commands
'#   Note: All commands should retrieve args using GetCommandArguments()
'#   before executing, unless args aren't passed. Follow command
'#   implementations below.
'###########################################################################
' TODO: MID Implement command parameter indexing to plan for future
' concurrency. This will be needed to ensure that parameters are
' matched to the appropriate screen pathway. Otherwise, the wrong
' parameters could be erroneously used during invokation   

Function CommandRenderKeyboardScreen() as String
    return "RenderKeyboardScreen"
End Function

Function ExecuteRenderKeyboardScreen() as void
    args = GetCommandArguments()
    requiredKeys = CreateObject("roArray", 3, True)
    requiredKeys.Push("title")
    requiredKeys.Push("displayText")
    requiredKeys.Push("buttons")
    success = VerifyKeys(args, requiredKeys)
    if not success
        LogCommandArgsFailedVerify("ExecuteRenderKeyboardScreen")
    end if
    RenderKeyboardScreen(args.title, args.displayText, args.buttons)    
End Function

Function CommandStoreUsername() as String
    return "storeUsername"
End Function

Function ExecuteStoreUsername() as String
    ' Store Username in non-volatile storage
    args = GetCommandArguments()
    stop
    if args.DoesExist("username")
        username = args.username
    else
        LogError("Command called without args stored -> StoreUsername")
        stop
    end if
    reg = CreateObject("roRegistry")
    regList = reg.GetSectionList()
    
    return "storeUsername"
End Function

Function CommandStorePassword() as String
    return "storePassword"
End Function

Function CommandLogin() as String
    return "login"
End Function

Function LogCommandArgsFailedVerify(command as String) as void
    LogError("Command called without args stored -> " + command)
    stop
End Function