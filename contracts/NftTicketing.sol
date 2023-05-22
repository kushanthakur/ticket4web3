//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftTicketing is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    // Total number of tickets available for the event
    uint public constant MAX_SUPPLY = 10000;

    // Number of tickets you can book at a time; prevents spamming
    uint public constant MAX_PER_MINT = 5;

    string public baseTokenURI;

    // Price of a single ticket
    uint public price = 0.05 ether;

    // Flag to turn sales on and off
    bool public saleIsActive = false;

    // Give collection a name and a ticker
    constructor() ERC721("My NFT Tickets", "MNT") {}

    // Generate NFT metadata
    function generateMetadata(uint tokenId) public pure returns (string memory) {
        string memory svg = string(abi.encodePacked(
            "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinyMin meet' viewBox='0 0 350 350'>",
            "<style>.base { fill: white; font-family: serif; font-size: 25px; }</style>",
            "<rect width='100%' height='100%' fill='red' />",
            "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>",
            "<tspan y='50%' x='50%'>NFT Ticket #",
            Strings.toString(tokenId),
            "</tspan></text></svg>"
        ));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "NFT Ticket #',
                        Strings.toString(tokenId),
                        '", "description": "A ticket that gives you access to a cool event!", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '", "attributes": [{"trait_type": "Type", "value": "Base Ticket"}]}'
                    )
                )
            )
        );

        string memory metadata = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return metadata;
    }

    // Reserve tickets to creator wallet
    function reserveNfts(uint _count) public onlyOwner {
        uint nextId = _tokenIds.current();

        require(nextId + _count < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < _count; i++) {
            string memory metadata = generateMetadata(nextId + i);
            _mintSingleNft(msg.sender, metadata);
        }
    }

    // Airdrop NFTs
    function airDropNfts(address[] calldata _wAddresses) public onlyOwner {
        uint nextId = _tokenIds.current();
        uint count = _wAddresses.length;

        require(nextId + count < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < count; i++) {
            string memory metadata = generateMetadata(nextId + i);
            _mintSingleNft(_wAddresses[i], metadata);
        }
    }

    // Set Sale state
    function setSaleState(bool _activeState) public onlyOwner {
        saleIsActive = _activeState;
    }

    // Allow public to mint NFTs
    function mintNfts(uint _count) public payable {

        uint nextId = _tokenIds.current();

        require(nextId + _count < MAX_SUPPLY, "Not enough NFT tickets left!");
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFT tickets.");
        require(saleIsActive, "Sale is not currently active!");
        require(msg.value >= price * _count, "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            string memory metadata = generateMetadata(nextId + i);
            _mintSingleNft(msg.sender, metadata);
        }
    }

    // Mint a single NFT ticket
    function _mintSingleNft(address _wAddress, string memory _tokenURI) private {
        // Sanity check for absolute worst case scenario
        require(totalSupply() == _tokenIds.current(), "Indexing has broken down!");
        uint newTokenID = _tokenIds.current();
        _safeMint(_wAddress, newTokenID);
        _setTokenURI(newTokenID, _tokenURI);
        _tokenIds.increment();
    }

    // Update price
    function updatePrice(uint _newPrice) public onlyOwner {
        price = _newPrice;
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Get tokens of an owner
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}