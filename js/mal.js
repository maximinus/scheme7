// Skeleton for MAL

class MalLanguage {
    constructor(print_callback) {
        // store the last 5 commands
        this.history = [];
        // this is already bound
        this.print_callback = print_callback;
    };

    runCommand(string) {
        this.history.push(string);
        while(this.history.length > 5) {
            this.history.shift();
        }
        this.history = this.history.slice(0, 5);
        if(string === 'help') {
            this.print_callback('Scheme 7 v0.1');
        }
        else if(string === 'history') {
            this.printHistory();
        }
        else if(string === 'about') {
            this.print_callback('Programmed by Chris Handy');
        }
        else {
            this.print_callback('Command not recognised');
            return false;
        }
        return true;
    };

    printHistory() {
        for(var i of this.history) {
            this.print_callback(i);
        }
    };
};
