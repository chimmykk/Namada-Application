const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const { osmosis } = require('osmojs');
const { coin, coins } = require('@cosmjs/amino');
const { getSigningOsmosisClient } = require('osmojs');
const { DirectSecp256k1HdWallet } = require('@cosmjs/proto-signing');
const axios = require('axios');
const app = express();
app.use(bodyParser.json());

// Define sender address and chain information
const senderAddress = 'osmo1jkrnefugex9sx329lpqxhpg3tj8al22ck38fyc'; //
const rpcEndpoint = "https://rpc.osmotest5.osmosis.zone:443"; // 
const mnemonic = ''; // Update this with your mnemonic
const poolId = "308"; 
const outputDenom = 'ibc/9FF2B7A5F55038A7EE61F4FD6749D9A648B48E89830F2682B67B5DC158E2753C'; 
const inputDenom = 'uosmo'; 

// Define the swapTokens function
async function swapTokens(senderAddress, rpcEndpoint, mnemonic, poolId, outputDenom, inputDenom, swapAmount) {
  const msg = osmosis.gamm.v1beta1.MessageComposer.withTypeUrl.swapExactAmountIn({
    sender: senderAddress,
    routes: [
      {
        poolId,
        tokenOutDenom: outputDenom,
      },
    ],
    tokenIn: coin(swapAmount, inputDenom),
    tokenOutMinAmount: '1', 
  });

  const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {
    prefix: 'osmo',
  });
  const client = await getSigningOsmosisClient({
    rpcEndpoint,
    signer: wallet,
  });

  const fee = {
    amount: coins(5000, 'uosmo'), 
    gas: '200000',
  };

  try {
    const broadcastResult = await client.signAndBroadcast(senderAddress, [msg], fee, '');
    console.log('Broadcast result:', broadcastResult);
    if (broadcastResult.code !== undefined && broadcastResult.code !== 0) {
      console.error('Failed to broadcast transaction:', broadcastResult.log || broadcastResult.rawLog);
      return { error: 'Failed to broadcast transaction' };
    } else {
      console.log('Transaction broadcast successfully:', broadcastResult.transactionHash);
      return { transactionHash: broadcastResult.transactionHash };
    }
  } catch (error) {
    console.error('Error broadcasting transaction:', error);
    return { error: 'Error broadcasting transaction' };
  }
}

// Define the POST endpoint for swapping tokens
app.post('/swap', async (req, res) => {
  const { swapAmount } = req.body;
  const result = await swapTokens(senderAddress, rpcEndpoint, mnemonic, poolId, outputDenom, inputDenom, swapAmount);
  res.json(result);
});

// Define the POST endpoint for storing details
app.post('/getdetails', async (req, res) => {
  const { swapAmount, receiverAddress } = req.body;

  if (!swapAmount || isNaN(swapAmount)) {
    return res.status(400).json({ error: 'Swap amount is missing or invalid' });
  }

  let result;

  if (receiverAddress && typeof receiverAddress === 'string') {
    result = { swapAmount, receiverAddress };
  } else {
    result = { swapAmount };
  }

  // Create a folder if it does not exist
  const folderPath = './datatxn';
  if (!fs.existsSync(folderPath)) {
    fs.mkdirSync(folderPath);
  }

  // Find the next available file number
  let fileNumber = 1;
  while (fs.existsSync(`${folderPath}/${fileNumber}.json`)) {
    fileNumber++;
  }

  // Save the details as a JSON file
  const filePath = `${folderPath}/${fileNumber}.json`;
  fs.writeFileSync(filePath, JSON.stringify(result));

  console.log('Saved details to:', filePath);
  res.json(result);
});


app.get('/atom-price', async (req, res) => {
    try {
      const response = await axios.get('https://api.coingecko.com/api/v3/simple/price?ids=cosmos&vs_currencies=usd');
      const atomPrice = response.data.cosmos.usd;
      res.json({ price: atomPrice });
    } catch (error) {
      console.error('Error fetching Atom price:', error);
      res.status(500).json({ error: 'Failed to fetch Atom price' });
    }
  });

// Start the server
const PORT = 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
