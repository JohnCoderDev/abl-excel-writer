CLASS XMLWriter FINAL:
    DEFINE PRIVATE PROPERTY encoding AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY xmlVersion AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY standalone as LOGICAL GET. SET.
    DEFINE PRIVATE PROPERTY nextIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY currentIndex AS INT64 GET. SET.

    DEFINE PRIVATE TEMP-TABLE xmlTagsProperties
        FIELD tagId AS INT64
        FIELD propName AS CHARACTER
        FIELD propValue AS CHARACTER
        INDEX idx-name AS WORD-INDEX propName.
    
    DEFINE PRIVATE TEMP-TABLE xmlTags
        FIELD tagId AS INT64
        FIELD tagName AS CHARACTER
        FIELD isSelfClosed AS LOGICAL
        FIELD isClosingTag AS LOGICAL
        INDEX idx-id AS UNIQUE PRIMARY tagId.
    
    CONSTRUCTOR XMLWriter():
        ASSIGN
            encoding = 'UTF-8'
            xmlVersion = '1.0'
            standalone = YES
            nextIndex = 1
            currentIndex = 0.
    END CONSTRUCTOR.
    
    METHOD PUBLIC VOID addTag(tagName AS CHARACTER):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = NO
            isClosingTag = NO.
    END METHOD.

    METHOD PUBLIC VOID addTag(tagName AS CHARACTER, selfClosed AS LOGICAL):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = selfClosed
            isClosingTag = NO.
    END METHOD.

    METHOD PUBLIC VOID addClosingTag(tagName AS CHARACTER):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = NO
            isClosingTag = YES.
    END METHOD.

    METHOD PUBLIC VOID addTagProperty(
        propertyName AS CHARACTER,
        propertyValue AS CHARACTER
    ):
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'no tag was created to assign this property',
                -2700
            ).
        END.
        CREATE xmlTagsProperties.
        ASSIGN
            xmlTagsProperties.tagId = currentIndex
            xmlTagsProperties.propName = propertyName
            xmlTagsProperties.propValue = propertyValue.
    END METHOD.

    METHOD PUBLIC VOID addTagProperty(
        tagIdTarget AS INT64
        propertyName AS CHARACTER,
        propertyValue AS CHARACTER
    ):
        FIND FIRST xmlTags 
            WHERE xmlTags.tagId = tagIdTarget
            NO-LOCK NO-ERROR.

        IF NOT AVAILABLE xmlTags THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'tag with id ' + STRING(tagIdTarget) + ' was not found',
                -2701
            ).
        END.

        IF xmlTags.isClosingTag THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot assign property to tag id' + STRING(tagIdTarget) 
                + ' because is closing tag',
                -2702
            ).
        END.

        CREATE xmlTagsProperties.
        ASSIGN
            xmlTagsProperties.tagId = xmlTags.tagId
            xmlTagsProperties.propName = propertyName
            xmlTagsProperties.propValue = propertyValue.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getTagText(tagIdTarget AS INT64):
        FIND FIRST xmlTags
            WHERE xmlTags.tagId = tagIdTarget
            NO-LOCK NO-ERROR. 

        IF NOT AVAILABLE xmlTags THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'tag with id ' + STRING(tagIdTarget) + ' was not found',
                -2701
            ).
        END.

        DEFINE VARIABLE propertiesText AS CHARACTER NO-UNDO.
        IF NOT xmlTags.isClosingTag THEN DO:
            FOR EACH xmlTagsProperties WHERE (
                xmlTagsProperties.tagId = tagIdTarget
            ):
                ASSIGN propertiesText = propertiesText + " " 
                    + xmlTagsProperties.propName + '="'
                    + xmlTagsProperties.propValue + '"'.
            END.
        END.

        DEFINE VARIABLE tagStart AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tagEnd AS CHARACTER NO-UNDO.

        IF xmlTags.isClosingTag THEN DO:
            ASSIGN
                tagStart = '</'
                tagEnd = '>'.
        END.
        ELSE IF xmlTags.isSelfClosed THEN DO:
            ASSIGN
                tagStart = '<'
                tagEnd = '/>'.
        END.
        ELSE DO:
            ASSIGN
                tagStart = '<'
                tagEnd = '>'.
        END. 

        RETURN tagStart + xmlTags.tagName + propertiesText + ' ' + tagEnd.
    END METHOD.

    METHOD PUBLIC CHARACTER getHeaderTag():
        RETURN '<?xml version="' + xmlVersion + '" '
            + 'encoding="' + encoding + '" '
            + 'standalone="' (IF standalone THEN 'yes' ELSE 'no') + '"?>'.
    END METHOD.
    
    METHOD PUBLIC LONGCHAR writeXMLText():
        DEFINE VARIABLE xmlText AS LONGCHAR.
        ASSIGN xmlText = getHeaderTag().
        FOR EACH xmlTags NO-LOCK:
            ASSIGN xmlText = xmlText + getTagText(xmlTags.tagId).
        END.
        RETURN xmlText.
    END METHOD.

    METHOD PUBLIC VOID writeXMLFile(fp AS CHARACTER):
        OUTPUT TO VALUE(fp).
            PUT UNFORMATTED writeXMLText().
        CLOSE OUTPUT.
    END METHOD.

    METHOD PRIVATE INT64 getIndex():
        ASSIGN
            currentIndex = nextIndex
            nextIndex = nextIndex + 1.
        RETURN currentIndex.
    END METHOD.
END CLASS.