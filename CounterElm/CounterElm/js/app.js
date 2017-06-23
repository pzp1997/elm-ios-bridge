var myModel = 0;

function updateLabel() {
    _consoleLog(myModel);
    myLabel.text = myModel.toString();
}

function incrementAction() {
    myModel++;
    myLabel.textColor = Color.greenColor();
    updateLabel();
}

function decrementAction() {
    myModel--;
    myLabel.textColor = Color.redColor();
    updateLabel();
}

var myLabel = Label.makeLabel();
updateLabel();
