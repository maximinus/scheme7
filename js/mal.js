// Skeleton for MAL

class MalLanguage {
    constructor(print_callback) {
        // store the last 5 commands
        this.history = [];
        // this is already bound
        this.print = print_callback;
    };

    runCommand(string) {
        this.history.push(string);
        while(this.history.length > 5) {
            this.history.shift();
        }
        this.history = this.history.slice(0, 5);
        // ignore empty lines
        if(string.length == 0) {
            return true
        }
        if(string === 'help') {
            this.print('Scheme 7 v0.1');
            this.print('  about   - About this program');
            this.print('  help    - Program help');
            this.print('  history - Terminal history');
        }
        else if(string === 'history') {
            this.printHistory();
        }
        else if(string === 'about') {
            this.print('Programmed by Chris Handy');
        }
        else {
            this.print('Command not recognised');
            return false;
        }
        return true;
    };

    printHistory() {
        for(var i of this.history) {
            this.print(i);
        }
    };
};
