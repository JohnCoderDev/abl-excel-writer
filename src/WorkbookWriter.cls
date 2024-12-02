CLASS WorkbookWriter:
    DEFINE PRIVATE PROPERTY workbookWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY relationshipWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY currentIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY nextIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY currentRelationIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY nextRelationIndex AS INT64 GET. SET.

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
            relationshipWriter = NEW XMLWriter()
            currentIndex = 0
            nextIndex = 1
            currentRelationIndex = 3
            nextRelationIndex = 4.
        
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
            worksheet.sheetName = sheetName
            worksheet.sheetRelationId = getRelationshipIndex().
    END METHOD.

    METHOD PRIVATE VOID addSheetRelationship():
        CREATE relationship.
        ASSIGN
            relationship.relationshipId = currentRelationIndex
            relationship.relationshipType = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
            relationship.relationshipTarget = "worksheets/sheet" + STRING(currentRelationIndex - 2) + ".xml".
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
        FIND FIRST relationship
            WHERE relationship.relationshipId = relationId
            NO-ERROR.
        
        IF NOT AVAILABLE relationship THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'relationship with id ' + STRING(relationId) + ' was not found',
                -2815
            ).
        END.

        DELETE relationship.

        FOR EACH relationship WHERE (relationship.relationshipId > relationId):
            ASSIGN
                relationship.relationshipId = relationship.relationshipId - 1
                relationship.relationshipTarget = "worksheets/sheet" 
                    + STRING(relationship.relationshipId  - 2) + ".xml".
        END.

        backRelationshipIndex().
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

    METHOD PRIVATE INT64 getRelationshipIndex():
        ASSIGN
            currentRelationIndex = nextRelationIndex
            nextRelationIndex = nextRelationIndex + 1.
        RETURN currentRelationIndex.
    END METHOD.

    METHOD PRIVATE VOID backRelationshipIndex():
        IF currentRelationIndex = 3 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'relation index could not be lower than 3',
                -2814
            ).
        END.
        ASSIGN
            nextRelationIndex = currentRelationIndex
            currentRelationIndex = currentRelationIndex - 1.
    END METHOD.

    METHOD PUBLIC LONGCHAR getWorkbookXMLText():
        workbookWriter:clearWriter().
        writeWorkbookHeader().
        writeWorkbookSheets().
        writeWorkbookFooter().
        RETURN workbookWriter:writeXMLText().
    END METHOD.

    METHOD PUBLIC LONGCHAR getWorkbookRelationshipXMLText():
        relationshipWriter:clearWriter().
        writeRelationshipsHeader().
        writeRelationshipsBody().
        writeWorkbookFooter().
        RETURN relationshipWriter:writeXMLText().
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

    METHOD PRIVATE VOID writeRelationshipsHeader():
        relationshipWriter:addTag("Relationships").
        relationshipWriter:addTagProperty("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships").

        CREATE relationship.
        ASSIGN
            relationship.relationshipId = 1
            relationship.relationshipType = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" 
            relationship.relationshipTarget = "theme/theme1.xml".

        CREATE relationship.
        ASSIGN
            relationship.relationshipId = 2
            relationship.relationshipType = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" 
            relationship.relationshipTarget = "styles.xml".

        CREATE relationship.
        ASSIGN
            relationship.relationshipId = 3
            relationship.relationshipType = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" 
            relationship.relationshipTarget = "sharedStrings.xml".
    END METHOD.

    METHOD PRIVATE VOID writeRelationshipsBody():
        FOR EACH relationship:
            relationshipWriter:addTag("Relationship").
            relationshipWriter:addTagProperty("Id", "rId" + STRING(relationship.relationshipId)).
            relationshipWriter:addTagProperty("Type", relationship.relationshipType).
            relationshipWriter:addTagProperty("Target", relationship.relationshipTarget).
        END.
    END METHOD.

    METHOD PRIVATE VOID writeRelationshipsFooter():
        relationshipWriter:addClosingTag("Relationships").
    END METHOD.
END CLASS.