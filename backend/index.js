const express = require('express');
const { exec } = require('child_process');
const app = express();
const cors = require('cors')

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

app.use(cors());
app.use(express.json()); 

app.post('/run-script', (req, res) => {
    const { pub_key, sig } = req.body;
    if (!pub_key) {
        return res.status(400).send('Missing public key parameter');
    }
    const scriptPath = '../tests/text_to_byte_array.sh';
    const sigCommand = `bash ${scriptPath} "${sig}"`;
    const pubCommand = `bash ${scriptPath} "${pub_key}"`;
    runShellCommand(sigCommand, (sigOutput) => {
        runShellCommand(pubCommand, (pubOutput) => {
            const modifiedSigOutput = sigOutput.trim().slice(1, -1);
            const modifiedPubOutput = pubOutput.trim().slice(1, -1);
            const combinedOutput = `[${modifiedSigOutput},${modifiedPubOutput}]`;
            const cairoCommand = `scarb cairo-run ${combinedOutput}`;
            runShellCommand(cairoCommand, (finalOutput) => {
                const message = extractStack(finalOutput);
                res.json({ message });
            });
        });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});