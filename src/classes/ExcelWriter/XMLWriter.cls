CLASS Classes.ExcelWriter.XMLWriter FINAL:
    DEFINE PRIVATE PROPERTY ENCODING AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY xmlVersion AS CHARACTER GET. SET.
    DEFINE PRIVATE PROPERTY STANDALONE AS LOGICAL GET. SET.
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
        FIELD isNaive AS LOGICAL
        INDEX idx-id AS UNIQUE PRIMARY tagId.
    
    CONSTRUCTOR XMLWriter():
        ASSIGN
            ENCODING = 'UTF-8'
            xmlVersion = '1.0'
            STANDALONE = YES
            nextIndex = 1
            currentIndex = 0.
    END CONSTRUCTOR.
    
    METHOD PUBLIC VOID addTag(tagName AS CHARACTER):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = NO
            isClosingTag = NO
            isNaive = NO.
    END METHOD.

    METHOD PUBLIC VOID addTag(tagName AS CHARACTER, selfClosed AS LOGICAL):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = selfClosed
            isClosingTag = NO
            isNaive = NO.
    END METHOD.

    METHOD PUBLIC VOID addClosingTag(tagName AS CHARACTER):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = tagName
            isSelfClosed = NO
            isClosingTag = YES
            isNaive = NO.
    END METHOD.

    METHOD PUBLIC VOID addNaiveValue(val AS CHARACTER):
        CREATE xmlTags.
        ASSIGN
            xmlTags.tagId = getIndex()
            xmlTags.tagName = val
            isSelfClosed = NO
            isClosingTag = NO
            isNaive = YES.
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

        FIND FIRST xmlTags
            WHERE xmlTags.tagId = currentIndex.

        IF xmlTags.isClosingTag THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot assign property to tag id' + STRING(currentIndex) 
                + ' because is closing tag',
                -2702
            ).
        END.

        IF xmlTags.isNaive THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot assign property to naive value with id ' + STRING(currentIndex),
                -2705
            ).
        END.

        FIND FIRST xmlTagsProperties
            WHERE (
                xmlTagsProperties.tagId = currentIndex
                AND UPPER(xmlTagsProperties.propName) = UPPER(propertyName)
            ) NO-ERROR.

        IF NOT AVAILABLE xmlTagsProperties THEN DO:
            CREATE xmlTagsProperties.
        END.

        ASSIGN
            xmlTagsProperties.tagId = currentIndex
            xmlTagsProperties.propName = propertyName
            xmlTagsProperties.propValue = propertyValue.
    END METHOD.

    METHOD PUBLIC VOID addTagProperty(
        tagIdTarget AS INT64,
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

        IF xmlTags.isNaive THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'cannot assign property to naive value with id ' + STRING(tagIdTarget),
                -2705
            ).
        END.

        FIND FIRST xmlTagsProperties
            WHERE (
                xmlTagsProperties.tagId = tagIdTarget
                AND UPPER(xmlTagsProperties.propName) = UPPER(propertyName)
            ) NO-ERROR.

        IF NOT AVAILABLE xmlTagsProperties THEN DO:
            CREATE xmlTagsProperties.
        END.

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

        IF xmlTags.isNaive THEN RETURN xmlTags.tagName.

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
            + 'encoding="' + ENCODING + '" '
            + 'standalone="' + (IF STANDALONE THEN 'yes' ELSE 'no') + '"?>'.
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
        DEFINE VARIABLE xmlText AS LONGCHAR.
        ASSIGN xmlText = writeXMLText().
        COPY-LOB xmlText TO FILE fp.
    END METHOD.

    METHOD PUBLIC VOID clearWriter():
        FOR EACH xmlTags:
            DELETE xmlTags.
        END. 
        
        FOR EACH xmlTagsProperties:
            DELETE xmlTagsProperties.
        END.
    END METHOD.

    METHOD PUBLIC VOID removeTag():
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'no tag was created to remove it',
                -2703
            ).
        END.

        FIND FIRST xmlTags
            WHERE xmlTags.tagId = currentIndex.
        
        FOR EACH xmlTagsProperties WHERE (
            xmlTagsProperties.tagId = xmlTags.tagId
        ):
            DELETE xmlTagsProperties.
        END.

        DELETE xmlTags.
        ASSIGN
            nextIndex = currentIndex
            currentIndex = currentIndex - 1.
    END METHOD.

    METHOD PUBLIC VOID removeTag(tagIdTarget AS INT64):
        FIND FIRST xmlTags
            WHERE xmlTags.tagId = tagIdTarget
            NO-ERROR.
        
        IF NOT AVAILABLE xmlTags THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'tag with id ' + STRING(tagIdTarget) + ' was not found',
                -2701
            ).
        END.

        FOR EACH xmlTagsProperties WHERE (
            xmlTagsProperties.tagId = xmlTags.tagId
        ):
            DELETE xmlTagsProperties.
        END.

        FOR EACH xmlTags WHERE xmlTags.tagId > tagIdTarget:
            ASSIGN xmlTags.tagId = xmlTags.tagId - 1.
        END.

        DELETE xmlTags.
        ASSIGN
            nextIndex = currentIndex
            currentIndex = currentIndex - 1.
    END METHOD.

    METHOD PUBLIC VOID removeProperty(propertyName AS CHARACTER):
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'no tag was create to remove this property',
                -2704
            ).
        END.

        FIND FIRST xmlTagsProperties
            WHERE (
                xmlTagsProperties.tagId = currentIndex
                AND UPPER(xmlTagsProperties.propName) = UPPER(propertyName)
            ) NO-ERROR.

        IF AVAILABLE xmlTagsProperties THEN DELETE xmlTagsProperties.
    END METHOD.

    METHOD PUBLIC VOID removeProperty(
        tagIdTarget AS INT64,
        propertyName AS CHARACTER
    ):
        FIND FIRST xmlTags
            WHERE xmlTags.tagId = tagIdTarget
            NO-ERROR.
        
        IF NOT AVAILABLE xmlTags THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'tag with id ' + STRING(tagIdTarget) + ' was not found',
                -2701
            ).
        END.

        FIND FIRST xmlTagsProperties
            WHERE (
                xmlTagsProperties.tagId = currentIndex
                AND UPPER(xmlTagsProperties.propName) = UPPER(propertyName)
            ) NO-ERROR.
        IF AVAILABLE xmlTagsProperties THEN DELETE xmlTagsProperties.
    END METHOD.

    METHOD PRIVATE INT64 getIndex():
        ASSIGN
            currentIndex = nextIndex
            nextIndex = nextIndex + 1.
        RETURN currentIndex.
    END METHOD.
END CLASS.