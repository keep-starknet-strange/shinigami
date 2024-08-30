const express = require('express');
const { exec } = require('child_process');
const app = express();
const cors = require('cors');

const MAX_SIZE = 350000; // Max script size is 10000 bytes, longest named opcode is ~25 chars, so 25 * 10000 = 250000 + extra allowance

function runShellCommand(command, callback) {
    exec(command, (error, stdout, stderr) => {
        if (error) {
            callback(`Error: ${error.message}`);
            return;
        }
        callback(stdout);
    });
}

function extractRunStack(output) {
    const match = output.match(/\[.*\]/);
    return match ? match[0] : 'No message found';
}

function handleScriptRequest(req, res, functionName) {
    const { pub_key, sig } = req.body;
    if (!pub_key) {
        return res.status(400).send('Missing public key parameter');
    }
    if (pub_key.length > MAX_SIZE || sig.length > MAX_SIZE) {
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
            const cairoCommand = `scarb cairo-run --function ${functionName} ${combinedOutput} --no-build`;
            runShellCommand(cairoCommand, (finalOutput) => {
                if (functionName === 'backend_run') {
                    const message = extractRunStack(finalOutput);
                    res.json({ message });
                } else if (functionName === 'backend_debug') {
                    const matches = finalOutput.match(/"0x[0-9a-fA-F]+"/g);
                    const message = matches ? matches.map(match => match.replace(/"/g, '')) : [];
                    res.json({ message });
                }
            });
        });
    });
}

app.use(cors());
app.use(express.json());

app.get('/', (_, res) => {
    res.sendStatus(200);
});

app.post('/run-script', (req, res) => {
    handleScriptRequest(req, res, 'backend_run');
});

app.post('/debug-script', (req, res) => {
    handleScriptRequest(req, res, 'backend_debug');
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});