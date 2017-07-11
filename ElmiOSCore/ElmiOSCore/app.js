function ready() {
    consoleLog("ready called!");
    
    //    var label = {
    //        "tag": "label",
    //        "facts": {
    //            "text": "hello world!",
    //            "textColor": "red",
    //            "position": "absolute",
    //            "top": 200,
    //            "left": 200
    //        }
    //    };
    
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
        patches: [{
            ctor: "change",
            type: "redraw",
            data: elmLabel,
            node: null
        }]
    };
    
    var factsMutationPatch = {
        ctor: "change",
        type: "facts",
        data: {
            tag: "view",
            facts: {
                backgroundColor: "cyan"
            }
        }
    };
    
    var factsAdditionPatch = {
        ctor: "at",
        index: 1,
        patches: [{
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                facts: {
                    shadowColor: "red"
                }
            }
        }]
    };
    
    var factsRemovalPatch = {
        ctor: "at",
        index: 1,
        patches: [{
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                facts: {
                    numberOfLines: undefined,
                    color: undefined
                }
            }
        }]
    };
    
    var combinedPatch = {
        ctor: "at",
        index: 1,
        patches: [{
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                facts: {
                    numberOfLines: undefined,
                    color: undefined
                }
            }
        }, {
            ctor: "change",
            type: "facts",
            data: {
                tag: "label",
                facts: {
                    shadowColor: "red"
                }
            }
        }]
    }

    var removeLastPatch = {
        ctor: "change",
        type: "remove-last",
        data: 1,
        node: null
    };
    
    var appendPatch = {
        ctor: "change",
        type: "append",
        data: [helloLabel]
    };

    initialRender(column);
    consoleLog("called initialRender");
    
//    applyPatches([combinedPatch]);
    applyPatches([removeLastPatch, redrawPatch, appendPatch, factsMutationPatch]);
    consoleLog("called applyPatches");
}
