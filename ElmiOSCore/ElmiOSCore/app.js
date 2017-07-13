function ready() {
    
    function makeChangePatch(type, data) {
        return {
            ctor: 'change',
            type: type,
            data: data,
            node: undefined
        };
    }

    function makeAtPatch(index, patch) {
        return {
            ctor: 'at',
            index: index,
            patch: patch
        };
    }

    function makeBatchPatch(patches) {
        return {
            ctor: 'batch',
            patches: patches
        }
    }

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

    var redrawPatch = makeAtPatch(0, makeChangePatch("redraw", elmLabel));

    var factsMutationPatch = makeChangePatch("facts", { tag: "view", backgroundColor: "cyan" });

    var factsAdditionPatch = makeAtPatch(1, makeChangePatch("facts", { tag: "label", shadowColor: "red" }));

    var factsRemovalPatch = makeAtPatch(1, makeChangePatch("facts", { tag: "label", numberOfLines: undefined, color: undefined }));

    var combinedPatch = makeAtPatch(1, makeBatchPatch([makeChangePatch("facts", { tag: "label", numberOfLines: undefined, color: undefined }), makeChangePatch("facts", { tag: "label", shadowColor: "red" })]));

    var removeLastPatch = makeChangePatch("remove-last", 1);

    var appendPatch = makeChangePatch("append", [helloLabel]);

    var batchedPatches = makeBatchPatch([removeLastPatch, appendPatch, redrawPatch, factsMutationPatch]);

    initialRender(column);

    applyPatches(batchedPatches);
    
}
