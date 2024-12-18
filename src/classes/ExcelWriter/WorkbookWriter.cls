USING Classes.ExcelWriter.*.
CLASS Classes.ExcelWriter.WorkbookWriter:
    DEFINE PRIVATE PROPERTY workbookWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY relationshipWriter AS RelationshipWriter GET. SET.
    DEFINE PRIVATE PROPERTY currentIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY nextIndex AS INT64 GET. SET.

    DEFINE PRIVATE TEMP-TABLE worksheet
        FIELD sheetId AS INT64
        FIELD sheetRelationId AS INT64
        FIELD sheetName AS CHARACTER
        INDEX idx-id AS UNIQUE PRIMARY sheetId ASCENDING
        INDEX idx-name AS WORD-INDEX sheetName.
    
    DEFINE PRIVATE TEMP-TABLE relationship
        FIELD relationshipId AS INT64
        FIELD relationshipType AS CHARACTER
        FIELD relationshipTarget AS CHARACTER
        INDEX idx-id AS UNIQUE PRIMARY relationshipId ASCENDING.

    CONSTRUCTOR WorkbookWriter():
        ASSIGN
            workbookWriter = NEW XMLWriter()
            relationshipWriter = NEW RelationshipWriter()
            currentIndex = 0
            nextIndex = 1.
        
        relationshipWriter:addRelationship(
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
            "theme/theme1.xml"
        ).

        relationshipWriter:addRelationship(
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
            "styles.xml"
        ).

        relationshipWriter:addRelationship(
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings",
            "sharedStrings.xml"
        ).
    END CONSTRUCTOR.

    METHOD PUBLIC VOID addSheet(sheetName AS CHARACTER):
        FIND FIRST worksheet
            WHERE worksheet.sheetName = sheetName
            NO-ERROR.

        IF AVAILABLE worksheet THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'sheet with name ' + sheetName + ' already exists',
                -2809
            ).
        END.

        CREATE worksheet.
        ASSIGN
            worksheet.sheetId = getIndex()
            worksheet.sheetName = sheetName.
        
        addSheetRelationship().

        ASSIGN worksheet.sheetRelationId = relationshipWriter:relationsCounter().
    END METHOD.

    METHOD PRIVATE VOID addSheetRelationship():
        relationshipWriter:addRelationship(
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
            "worksheets/sheet" + STRING(currentIndex) + ".xml"
        ).
    END METHOD.

    METHOD PUBLIC VOID removeSheet(sheetId AS INT64):
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'no worksheet was created in the object',
                -2810
            ).
        END.
        
        FIND FIRST worksheet
            WHERE worksheet.sheetId = sheetId
            NO-ERROR.

        IF NOT AVAILABLE worksheet THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot find worksheet with id ' + STRING(sheetId),
                -2812
            ).
        END.

        removeSheetRelationship(worksheet.sheetRelationId).
        DELETE worksheet.

        FOR EACH worksheet WHERE (worksheet.sheetId > sheetId):
            ASSIGN
                worksheet.sheetId = worksheet.sheetId - 1
                worksheet.sheetRelationId = worksheet.sheetRelationId - 1.
        END.
        backIndex().
    END METHOD.

    METHOD PUBLIC VOID removeSheet(sheetName AS CHARACTER):
        DEFINE VARIABLE boundId AS INT64.
        FIND FIRST worksheet
            WHERE (UPPER(worksheet.sheetName) = UPPER(sheetName))
            NO-ERROR.
        
        IF NOT AVAILABLE worksheet THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot find worksheet with name ' + sheetName,
                -2813
            ).
        END.

        removeSheetRelationship(worksheet.sheetRelationId).
        ASSIGN boundId = worksheet.sheetId.
        DELETE worksheet.

        FOR EACH worksheet WHERE (worksheet.sheetId > boundId):
            ASSIGN
                worksheet.sheetId = worksheet.sheetId - 1
                worksheet.sheetRelationId = worksheet.sheetRelationId - 1.
        END.

        backIndex().
    END METHOD.

    METHOD PRIVATE VOID removeSheetRelationship(relationId AS INT64):
        IF relationId < 4 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot delete relationships that is not sheet relationship',
                -2820
            ).
        END.

        relationshipWriter:removeRelationship(relationId).
        FOR EACH worksheet WHERE worksheet.sheetRelationId > relationId:
            relationshipWriter:editRelationship(
                worksheet.sheetRelationId - 1, ?,
                "worksheets/sheet" + STRING(worksheet.sheetId - 1) + ".xml"
            ).
        END.
    END METHOD.

    METHOD PRIVATE INT64 getIndex():
        ASSIGN
            currentIndex = nextIndex
            nextIndex = nextIndex + 1.
        RETURN currentIndex.
    END METHOD.

    METHOD PRIVATE VOID backIndex():
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot back index to less than 0',
                -2811
            ).
        END.
        ASSIGN
            nextIndex = currentIndex
            currentIndex = currentIndex - 1.
    END METHOD.

    METHOD PUBLIC LONGCHAR getWorkbookXMLText():
        workbookWriter:clearWriter().
        writeWorkbookHeader().
        writeWorkbookSheets().
        writeWorkbookFooter().
        RETURN workbookWriter:writeXMLText().
    END METHOD.

    METHOD PUBLIC LONGCHAR getWorkbookRelationshipXMLText():
        RETURN relationshipWriter:getRelationshipsXMLText().
    END METHOD.

    METHOD PRIVATE VOID writeWorkbookHeader():
        workbookWriter:addTag('workbook').
        workbookWriter:addTagProperty("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main").
        workbookWriter:addTagProperty("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships").
        workbookWriter:addTagProperty("xmlns:mx", "http://schemas.microsoft.com/office/mac/excel/2008/main").
        workbookWriter:addTagProperty("xmlns:mc", "http://schemas.openxmlformats.org/markup-compatibility/2006").
        workbookWriter:addTagProperty("xmlns:mv", "urn:schemas-microsoft-com:mac:vml").
        workbookWriter:addTagProperty("xmlns:x14", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/main").
        workbookWriter:addTagProperty("xmlns:x15", "http://schemas.microsoft.com/office/spreadsheetml/2010/11/main").
        workbookWriter:addTagProperty("xmlns:x14ac", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac").
        workbookWriter:addTagProperty("xmlns:xm", "http://schemas.microsoft.com/office/excel/2006/main").

        workbookWriter:addTag("workbookPr", TRUE).
        workbookWriter:addTag("sheets").
    END METHOD.

    METHOD PRIVATE VOID writeWorkbookSheets():
        FOR EACH worksheet:
            workbookWriter:addTag("sheet", TRUE).
            workbookWriter:addTagProperty("state", "visible").
            workbookWriter:addTagProperty("name", worksheet.sheetName).
            workbookWriter:addTagProperty("sheetId", STRING(worksheet.sheetId)).
            workbookWriter:addTagProperty("r:id", "rId" + STRING(worksheet.sheetRelationId)).
        END.
    END METHOD.

    METHOD PRIVATE VOID writeWorkbookFooter():
        workbookWriter:addClosingTag("sheets").
        workbookWriter:addTag("definedNames", TRUE).
        workbookWriter:addTag("calcPr", TRUE).
        workbookWriter:addClosingTag("workbook").
    END METHOD.
END CLASS.