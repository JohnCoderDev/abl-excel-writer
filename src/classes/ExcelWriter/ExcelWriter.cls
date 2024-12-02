USING Classes.ExcelWriter.*.
CLASS Classes.ExcelWriter.ExcelWriter:
    DEFINE PRIVATE PROPERTY workbookWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY sheetsWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY themesWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY drawingsWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY relsWriter AS XMLWriter GET. SET.

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
        // 2415020
    END METHOD.

    METHOD PUBLIC VOID addValue(
        val AS DATE,
        idxRow AS INT64,
        idxColumn AS INT64
    ):
        // 2415020
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
END CLASS.