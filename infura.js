const axios = require("axios").default;
const walletAddress = 0x9700f79688e2318dc95b3417a509adcc8df7c4a9;
const chainId = "1";

const baseUrl = "https://nft.api.infura.io";
const url = `${baseUrl}/networks/${chainId}/accounts/${walletAddress}/assets/nfts`;

// API request
const config = {
  method: "get",
  url: url,
  auth: {
    username: "https://sepolia.infura.io/v3/1083fe85d22d49aa875daf445f5a89f2",
    password:
      "<excite sentence fit must photo coconut gasp chaos various cigar water riot>",
  },
};

// API Request
axios(config)
  .then((response) => {
    console.log(response["data"]);
  })
  .catch((error) => console.log("error", error));
