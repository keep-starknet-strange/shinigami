const express = require('express');
const { exec } = require('child_process');
const app = express();

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

function extractStack(output) {
    const match = output.match(/\[.*\]/);
    return match ? match[0] : 'No message found';
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
        runShellCommand(cairoCommand, (finalOutput) => {
            const message = extractStack(finalOutput);
            res.json({ message });
        });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});