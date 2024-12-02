CLASS RelationshipWriter:
    DEFINE PRIVATE PROPERTY relationshipWriter AS XMLWriter GET. SET.
    DEFINE PRIVATE PROPERTY currentIndex AS INT64 GET. SET.
    DEFINE PRIVATE PROPERTY nextIndex AS INT64 GET. SET.

    DEFINE PRIVATE TEMP-TABLE relationship
        FIELD relationshipId AS INT64
        FIELD relationshipType AS CHARACTER
        FIELD relationshipTarget AS CHARACTER
        INDEX idx-id AS UNIQUE PRIMARY relationshipId ASCENDING.

    CONSTRUCTOR RelationshipWriter():
        ASSIGN relationshipWriter = NEW XMLWriter().
    END CONSTRUCTOR.

    METHOD PUBLIC VOID addRelationship(
        relationType AS CHARACTER,
        relationTarget AS CHARACTER
    ):
        CREATE relationship.
        ASSIGN
            relationship.relationshipId = getIndex()
            relationship.relationshipType = relationType
            relationship.relationshipTarget = relationTarget.
    END METHOD.

    METHOD PUBLIC VOID editRelationship(
        relationshipId AS INT64,
        relatioshipType AS CHARACTER,
        relationshipTarget AS CHARACTER
    ):
        FIND FIRST relationship
            WHERE relationship.relationshipId = relationshipId
            NO-ERROR.

        IF NOT AVAILABLE relationship THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'relationship with id ' + STRING(relationshipId) + ' was not found',
                -2816
            ).
        END.
        
        ASSIGN
            relationship.relationshipType = IF relationshipType <> ?
                THEN relationshipType
                ELSE relationship.relationshipType
            relationship.relationshipTarget = IF relationshipTarget <> ?
                THEN relationshipTarget
                ELSE relationship.relationshipTarget.
    END METHOD.

    METHOD PUBLIC INT64 removeRelationship():
        IF currentIndex = 0 THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'no relation ship was created to be deleted',
                -2818
            ).
        END.

        FIND FIRST relationship
            WHERE relationship.relationshipId = currentIndex.

        DELETE relationship.
        FOR EACH relationship WHERE (relationship.relationshipId > currentIndex):
            ASSIGN
                relationship.relationshipId = relationship.relationshipId - 1.
        END.

        backIndex().
    END METHOD.

    METHOD PUBLIC INT64 removeRelationship(relationId AS INT64):
        FIND FIRST relationship
            WHERE relationship.relationshipId = relationId
            NO-ERROR.

        IF NOT AVAILABLE relationship THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                'relationship with id ' + STRING(relationshipId) + ' was not found',
                -2816
            ).
        END.

        DELETE relationship.
        FOR EACH relationship WHERE (relationship.relationshipId > relationId):
            ASSIGN
                relationship.relationshipId = relationship.relationshipId - 1.
        END.

        backIndex().
    END METHOD.

    METHOD PUBLIC LONGCHAR getRelationshipsXMLText():
        relationshipWriter:clearWriter().
        relationshipWriter:addTag("Relationships").
        relationshipWriter:addTagProperty("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships").

        FOR EACH relationship:
            relationshipWriter:addTag("Relationship", TRUE).
            relationshipWriter:addTagProperty("Id", "rId" + STRING(relationship.relationshipId)).
            relationshipWriter:addTagProperty("Type", relationship.relationshipType).
            relationshipWriter:addTagProperty("Target", relationship.relationshipTarget).
        END.

        relationshipWriter:addClosingTag("Relationships").

        RETURN relationshipWriter:writeXMLText().
    END METHOD.

    METHOD PUBLIC INT64 relationsCounter():
        RETURN currentIndex.
    END METHOD.

    METHOD PRIVATE INT64 getIndex():
        ASSIGN
            currentIndex = nextIndex
            nextIndex = nextIndex + 1.
        RETURN currentIndex.
    END METHOD.

    METHOD PRIVATE VOID backIndex():
        ASSIGN
            nextIndex = currentIndex
            currentIndex = currentIndex - 1.
    END METHOD.
END CLASS.