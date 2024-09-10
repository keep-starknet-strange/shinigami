const express = require('express');
const { spawn } = require('child_process');
const app = express();
const cors = require('cors');

const MAX_SIZE = 350000; // Max script size is 10000 bytes, longest named opcode is ~25 chars, so 25 * 10000 = 250000 + extra allowance

// This function runs a shell command asynchronously using spawn
// `spawn` is preferred over `exec` when you need to handle a large amount of data or streams 
// because it doesn't buffer the output in memory, making it more memory-efficient for long-running processes
function runShellCommand(command, args, callback) {
    // Pass the command as the first argument and arguments as an array
    const process = spawn(command, args);  // 'args' must be an array
    let output = '';

    // Listen for data from the process
    process.stdout.on('data', (data) => {
        output += data.toString();
    });

    // On process close, execute the callback
    process.on('close', (code) => {
        callback(output);
    });
}

function handleScriptRequest(req, res, functionName) {
    const { pub_key, sig } = req.body;
    
    // Input validation
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

    // Use `spawn` by separating the script path from its arguments
    const sigArgs = [scriptPath, sig]; // Arguments should be passed as an array
    const pubArgs = [scriptPath, pub_key];

    runShellCommand('bash', sigArgs, (sigOutput) => {
        runShellCommand('bash', pubArgs, (pubOutput) => {
            const modifiedSigOutput = sigOutput.trim().slice(1, -1);
            const modifiedPubOutput = pubOutput.trim().slice(1, -1);
            const combinedOutput = `[${modifiedSigOutput},${modifiedPubOutput}]`;
            
            // Similarly, separate the command and its arguments for cairo-run
            const cairoArgs = ['cairo-run', '--function', functionName, combinedOutput, '--no-build'];
            runShellCommand('scarb', cairoArgs, (finalOutput) => {
                const matches = [...finalOutput.matchAll(/\[.*\]/g)].map((m) => m[0]);
                res.json({ message: matches ? matches : 'No message found' });
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
