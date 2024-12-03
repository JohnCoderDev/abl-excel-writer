USING Classes.ExcelWriter.*.
CLASS Classes.ExcelWriter.ExcelWriter:
    DEFINE PUBLIC PROPERTY filePath AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY workbook AS WorkbookWriter GET. SET.
    DEFINE PRIVATE PROPERTY sheets AS WorksheetWriter GET. SET.
    DEFINE PRIVATE PROPERTY relationships AS RelationshipWriter GET. SET.

    DEFINE PRIVATE TEMP-TABLE sharedStrings
        FIELD strId AS INT64
        FIELD strValue AS CHARACTER
        INDEX idx-id AS UNIQUE PRIMARY strId
        INDEX idx-val AS WORD-INDEX strValue.

    CONSTRUCTOR ExcelWriter():
    END CONSTRUCTOR.

    CONSTRUCTOR ExcelWriter(fp AS CHARACTER):
        ASSIGN
            filePath = fp
            relationships = NEW RelationshipWriter()
            .
    END CONSTRUCTOR.

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