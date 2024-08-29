const express = require('express');
const { exec } = require('child_process');
const app = express();
const cors = require('cors')

const MAX_SIZE = 350000; // Max script size is 10000 bytes, longest named opcode is ~25 chars, so 25 * 10000 = 250000 + extra allowance

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

// Default route
app.get('/', (_, res) => {
  res.sendStatus(200);
});

app.post('/run-script', (req, res) => {
    const { pub_key, sig } = req.body;
    if (!pub_key) {
        return res.status(400).send('Missing public key parameter');
    }
    if (pub_key.length > MAX_SIZE || sig.length > MAX_SIZE) {
        //for a more detailed error message
        if (pub_key.length > MAX_SIZE) {
            return res.status(400).send('Script Public Key exceeds maximum allowed size');
        }
        if (sig.length > MAX_SIZE) {
            return res.status(400).send('Script Signature exceeds maximum allowed size');
        }
    }
    const scriptPath = '../tests/text_to_byte_array.sh';
    const sigCommand = `bash ${scriptPath} "${sig}"`;
    const pubCommand = `bash ${scriptPath} "${pub_key}"`;
    runShellCommand(sigCommand, (sigOutput) => {
        runShellCommand(pubCommand, (pubOutput) => {
            const modifiedSigOutput = sigOutput.trim().slice(1, -1);
            const modifiedPubOutput = pubOutput.trim().slice(1, -1);
            const combinedOutput = `[${modifiedSigOutput},${modifiedPubOutput}]`;
            const cairoCommand = `scarb cairo-run ${combinedOutput} --no-build`;
            runShellCommand(cairoCommand, (finalOutput) => {
                const message = extractStack(finalOutput);
                res.json({ message });
            });
        });
    });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
