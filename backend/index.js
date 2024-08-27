const express = require('express');
const { exec } = require('child_process');
const app = express();

// Function to run shell commands
function runShellCommand(command, callback) {
    exec(command, (error, stdout, stderr) => {
        if (error) {
            callback(`Error: ${error.message}`);
            return;
        }
        if (stderr) {
            callback(stderr);
            return;
        }
        callback(stdout);
    });
}

app.get('/run-script', (req, res) => {
    const args = req.query.args;
    if (!args) {
        return res.status(400).send('Missing "args" parameter');
    }

    const scriptPath = '../tests/text_to_byte_array.sh';
    const initialCommand = `bash ${scriptPath} ${args}`;

    runShellCommand(initialCommand, (firstOutput) => {
        const modifiedOutput = `[[],0,0,${firstOutput.trim().slice(1)}`;
        const cairoCommand = `scarb cairo-run ${modifiedOutput}`;
        console.log("initial output: ", firstOutput)
        console.log("test command: ", cairoCommand)
        runShellCommand(cairoCommand, (finalOutput) => {
            console.log("final output: ", finalOutput)
            res.send(finalOutput);
        });
    });
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});