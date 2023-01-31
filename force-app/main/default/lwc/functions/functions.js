export {logMsg, logKeyVal, logEnterMethod, logExitMethod}

       const logMsg = (str) => {
            console.log(str);
        }
        
        const logKeyVal = (key, value) => {
            console.log(key + ': ' + value);
        }

        const logEnterMethod = (methodName) => {
            console.log('>> ' + methodName + '()');
        }

        const logExitMethod = (methodName) => {
            console.log('<< ' + methodName);
        }