CLASS ExcelWriter:
    DEFINE PRIVATE PROPERTY workbookWriter AS XMLWriter.
    DEFINE PRIVATE PROPERTY sheetsWriter AS XMLWriter.
    DEFINE PRIVATE PROPERTY sharedStringsWriter AS XMLWriter.
    DEFINE PRIVATE PROPERTY themesWriter AS XMLWriter.
    DEFINE PRIVATE PROPERTY drawingsWriter AS XMLWriter.
    DEFINE PRIVATE PROPERTY relsWriter AS XMLWriter.

    DEFINE PRIVATE PROPERTY valuesCounter AS INT64.
    DEFINE PRIVATE PROPERTY distinctStringsCounter AS INT64.

    DEFINE PRIVATE TEMP-TABLE sharedStrings
        FIELD strId AS INT64
        FIELD strValue AS CHARACTER
        INDEX idx-id AS UNIQUE PRIMARY strId
        INDEX idx-val AS WORD-INDEX strValue.
    
    // TODO: methods to add values to the object
    METHOD PUBLIC VOID addValue(
        val AS CHARACTER,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
    END METHOD.

    METHOD PUBLIC VOID addValue(
        val AS DATETIME,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
    END METHOD.

    METHOD PUBLIC VOID addValue(
        val AS DATE,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
    END METHOD.

    METHOD PUBLIC VOID addValue(
        val AS INTEGER,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
    END METHOD.

    METHOD PUBLIC VOID addValue(
        val AS INT64,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
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