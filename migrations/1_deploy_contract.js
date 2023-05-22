// Get instance of the NFT contract
const nftContract = artifacts.require("NftTicketing");

module.exports = async function (deployer) {
  // Deploy the contract
  await deployer.deploy(nftContract);
  const contract = await nftContract.deployed();

  // Mint 5 tickets
  await contract.reserveNfts(5);
  console.log("5 NFT Tickets have been minted!");
};
