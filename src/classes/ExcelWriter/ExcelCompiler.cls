CLASS Classes.ExcelWriter.ExcelCompiler:
    DEFINE PUBLIC PROPERTY filePath AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY engine AS CHARACTER GET. SET.
    
    CONSTRUCTOR ExcelCompiler():
        ASSIGN engine = 'powershell.exe'.
    END CONSTRUCTOR.

    CONSTRUCTOR ExcelCompiler(fp AS CHARACTER):
        ASSIGN
            filePath = fp
            engine = 'powershell.exe'.
    END CONSTRUCTOR.

    METHOD PRIVATE VOID buildDirectoryStructure():
        doCommand("mkdir " + filePath).
        doCommand("mkdir " + filePath + "\_rels").
        doCommand("mkdir " + filePath + "\xl").
            doCommand("mkdir " + filePath + "\xl\_rels").
            doCommand("mkdir " + filePath + "\xl\drawings").
            doCommand("mkdir " + filePath + "\xl\theme").
            doCommand("mkdir " + filePath + "\xl\worksheets").
                doCommand("mkdir " + filePath + "\xl\worksheets\_rels").
    END METHOD.

    METHOD PRIVATE VOID compileDirectory():
        doCommand(
            "Compress-Archive " + 
            + "-Path " + filePath + " "
            + "-DestinationPath " + filePath ".xlsx"
        ).
    END METHOD.

    METHOD PRIVATE VOID doCommand(cmd AS CHARACTER):
        ASSIGN cmd = engine + "-executionpolicy bypass $(" + cmd + ")".
        OS-COMMAND NO-WAIT NO-CONSOLE SILENT cmd.
    END METHOD.
END CLASS.