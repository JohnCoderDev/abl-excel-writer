CLASS WorksheetWriter:
    DEFINE PRIVATE PROPERTY sheetWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY relsWriter AS XMLWriter GET. SET.
    DEFINE PUBLIC PROPERTY sheetId AS CHARACTER GET. SET.
    DEFINE PUBLIC PROPERTY sheetName AS CHARACTER GET. SET.

    DEFINE PRIVATE TEMP-TABLE worksheetValues
        FIELD val AS DECIMAL
        FIELD valType AS CHARACTER
        FIELD idxRow AS INT64 
        FIELD idxCol AS INT64
        INDEX idx-row-col IS UNIQUE PRIMARY 
            idxRow ASCENDING
            idxCol ASCENDING.
    
    DEFINE PRIVATE TEMP-TABLE rowsTracker
        FIELD idxRow AS INT64
        INDEX idx-row IS UNIQUE PRIMARY idxRow ASCENDING.
    
    CONSTRUCTOR WorksheetWriter(
        worksheetId AS INT64,
        worksheetName AS CHARACTER
    ):
        ASSIGN
            sheetId = STRING(worksheetId)
            sheetName = worksheetName
            sheetWriter = NEW XMLWriter()
            relsWriter = NEW XMLWriter().

        sheetWriter:clearWriter().
        relsWriter:clearWriter().
    END CONSTRUCTOR.
    
    METHOD PUBLIC VOID addValue(
        val AS DECIMAL,
        typeVal AS CHARACTER,
        ixRow AS INT64,
        ixCol AS INT64 
    ):
        FIND FIRST worksheetValues 
            WHERE (
                worksheetValues.idxRow = ixRow
                AND worksheetValues.idxCol = ixCol
            ) NO-ERROR.

        IF NOT AVAILABLE worksheetValues THEN CREATE worksheetValues.
        ASSIGN
            worksheetValues.val = val
            worksheetValues.valType = typeVal
            worksheetValues.idxRow = ixRow
            worksheetValues.idxCol = ixCol.

        FIND FIRST rowsTracker
            WHERE rowsTracker.idxRow = ixRow
            NO-LOCK NO-ERROR.

        IF NOT AVAILABLE rowsTracker THEN DO:
            CREATE rowsTracker.
            ASSIGN rowsTracker.idxRow = ixRow.
        END.
    END METHOD.

    METHOD PUBLIC LONGCHAR writeWorksheetXMLText():
        sheetWriter:clearWriter().
        writeSheetHeader().
        writeSheetValues().
        writeSheetFooter().
        RETURN sheetWriter:writeXMLText().
    END METHOD.

    METHOD PRIVATE VOID writeSheetHeader():
        sheetWriter:addTag("worksheet").
        sheetWriter:addTagProperty("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main").
        sheetWriter:addTagProperty("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships").
        sheetWriter:addTagProperty("xmlns:mx", "http://schemas.microsoft.com/office/mac/excel/2008/main").
        sheetWriter:addTagProperty("xmlns:mc", "http://schemas.openxmlformats.org/markup-compatibility/2006").
        sheetWriter:addTagProperty("xmlns:mv", "urn:schemas-microsoft-com:mac:vml").
        sheetWriter:addTagProperty("xmlns:x14", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/main").
        sheetWriter:addTagProperty("xmlns:x15", "http://schemas.microsoft.com/office/spreadsheetml/2010/11/main").
        sheetWriter:addTagProperty("xmlns:x14ac", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac").
        sheetWriter:addTagProperty("xmlns:xm", "http://schemas.microsoft.com/office/excel/2006/main").

        sheetWriter:addTag("sheetPr").
            sheetWriter:addTag("outlinePr").
            sheetWriter:addTagProperty("summaryBelow", "0").
            sheetWriter:addTagProperty("summaryRight", "0").
        sheetWriter:addClosingTag("sheetPr").

        sheetWriter:addTag("sheetViews").
            sheetWriter:addTag("sheetView").
            sheetWriter:addTagProperty("workbookViewId", "0").
        sheetWriter:addClosingTag("sheetViews").
        
        sheetWriter:addTag("sheetFormatPr", TRUE).
        sheetWriter:addTagProperty("customHeight", "1").
        sheetWriter:addTagProperty("defaultColWidth", "12.63").
        sheetWriter:addTagProperty("defaultRowHeight", "15.75").

        sheetWriter:addTag("sheetData").
    END METHOD.

    METHOD PRIVATE VOID writeSheetValues():
        DEFINE VARIABLE cellRef AS CHARACTER NO-UNDO.
        FOR EACH rowsTracker:
            sheetWriter:addTag("row").
            sheetWriter:addTagProperty("r", STRING(rowsTracker.idxRow)).

            FOR EACH worksheetValues WHERE (
                worksheetValues.idxRow = rowsTracker.idxRow
            ):
                ASSIGN cellRef = getCellReference(worksheetValues.idxRow, worksheetValues.idxCol).
                sheetWriter:addTag("c").
                sheetWriter:addTagProperty("r", cellRef).

                IF worksheetValues.valType = "string" THEN DO:
                    sheetWriter:addTagProperty("s", "1").
                    sheetWriter:addTagProperty("t", "s").
                    sheetWriter:addTag("v").
                        sheetWriter:addNaiveValue(STRING(INT64(worksheetValues.val))).
                    sheetWriter:addClosingTag("v").
                END.
                ELSE IF worksheetValues.valType = "number" THEN DO:
                    sheetWriter:addTagProperty("s", "1").
                    sheetWriter:addTag("v").
                        sheetWriter:addNaiveValue(STRING(worksheetValues.val)).
                    sheetWriter:addClosingTag("v").
                END.
                ELSE IF worksheetValues.valType = "date" THEN DO:
                    sheetWriter:addTagProperty("s", "2").
                    sheetWriter:addTag("v").
                        sheetWriter:addNaiveValue(STRING(worksheetValues.val)).
                    sheetWriter:addClosingTag("v").
                END.
                ELSE DO:
                    UNDO, THROW NEW Progress.Lang.AppError(
                        "invalid data type " + worksheetValues.valType,
                        -2807
                    ).
                END.
                sheetWriter:addClosingTag("c").
            END.
            sheetWriter:addClosingTag("row").
        END.
    END METHOD.

    METHOD PRIVATE VOID writeSheetFooter():
        sheetWriter:addClosingTag("sheetData").

        sheetWriter:addTag("drawing", TRUE).
        sheetWriter:addTagProperty("r:id", "rId" + STRING(sheetId)).

        sheetWriter:addClosingTag("worksheet").
    END METHOD.
    
    METHOD PRIVATE CHARACTER getCellReference(idxRow AS INT64, idxColumn AS INT64):
        DEFINE VARIABLE columnChar AS CHARACTER.
        IF (idxRow <= 0 OR idxColumn <= 0) THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'rows and columns indexes must be greater than 0',
                -2800
            ).
        END.

        IF (idxRow > 1048576) THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'rows must be lower than 1048576',
                -2801
            ).
        END.

        IF (idxColumn > 16384) THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'columns must be lower than 16384',
                -2802
            ).
        END.

        DO WHILE idxColumn > 26:
            IF idxColumn MOD 26 = 0 THEN DO:
                ASSIGN columnChar = 'Z' + columnChar.
            END.
            ELSE DO:
                ASSIGN columnChar = CHR((idxColumn MOD 26) + 64) + columnChar.
            END. 
            ASSIGN idxColumn = INT64(idxColumn / 26) - (IF idxColumn MOD 26 = 0 THEN 1 ELSE 0).
        END.
        ASSIGN columnChar = CHR(((idxColumn - 1) MOD 26) + 65) + columnChar.
        RETURN columnChar + STRING(idxRow).
    END.
END CLASS.