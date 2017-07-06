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
            isHighlighted: true,
            fontSize: 28,
            margin: 20
        }
    };
    
    var elmLabel = {
        tag: "label",
        facts: {
            text: "I am the skeleton of Elm for iOS :)",
            font: "Times",
            numberOfLines: 3,
            width: 100,
            textColor: "blue",
            margin: 20
        }
    }
    
    var column = {
        tag: "view",
        facts: {
            flexDirection: "column",
            flexGrow: 1,
            justifyContent: "center",
            alignItems: "center",
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

    initialRender(column);
    consoleLog("called initialRender");
    
    applyPatches(redrawPatch);
    consoleLog("called applyPatches");
}
