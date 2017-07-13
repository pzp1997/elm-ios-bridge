function ready() {
    var helloLabel = {
        tag: "label",
        facts: {
            text: "Hello, world!",
            textColor: "red",
            shadowColor: "brown",
            shadowOffsetX: 0,
            shadowOffsetY: -3,
            fontSize: 28,
            YOGA: {
                margin: 20
            }
        }
    };
    
    var elmLabel = {
        tag: "label",
        facts: {
            text: "I am the skeleton of Elm for iOS :)",
            font: "Times",
            numberOfLines: 2,
            textColor: "blue",
            YOGA: {
                width: 100,
                margin: 20
            }
        }
    }
    
    var column = {
        tag: "view",
        facts: {
            YOGA: {
                flexDirection: "column",
                flexGrow: 1,
                justifyContent: "center",
                alignItems: "center"
            },
            backgroundColor: "yellow"
        },
        children: [helloLabel, elmLabel]
    };
    
    var redrawPatch = {
        ctor: "at",
        index: 0,
        patch: {
            ctor: "change",
            type: "redraw",
            data: elmLabel,
            node: undefined
        }
    };
    
    var factsMutationPatch = {
        ctor: "change",
        type: "facts",
        data: {
            tag: "view",
            backgroundColor: "cyan"
        },
        node: undefined
    };
    
    var factsAdditionPatch = {
        ctor: "at",
        index: 1,
        patch: {
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                shadowColor: "red"
            },
            node: undefined
        }
    };
    
    var factsRemovalPatch = {
        ctor: "at",
        index: 1,
        patch: {
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                numberOfLines: undefined,
                color: undefined
            },
            node: undefined
        }
    };
    
    var combinedPatch = {
        ctor: "at",
        index: 1,
        patch: {
            ctor: "batch",
            patches: [{
                ctor: "change",
                type: "facts",
                data: {
                    tag: "label",
                    numberOfLines: undefined,
                    color: undefined
                },
                node: undefined
            },
            {
                ctor: "change",
                type: "facts",
                data: {
                    tag: "label",
                    shadowColor: "red"
                },
                node: undefined
            }]
        }
    }

    var removeLastPatch = {
        ctor: "change",
        type: "remove-last",
        data: 1,
        node: undefined
    };
    
    var appendPatch = {
        ctor: "change",
        type: "append",
        data: [helloLabel],
        node: undefined
    };
    
    var batchedPatches = {
        ctor: "batch",
        patches: [removeLastPatch, appendPatch, redrawPatch, factsMutationPatch]
    };

    initialRender(column);
    
    applyPatches(batchedPatches);
    
}
