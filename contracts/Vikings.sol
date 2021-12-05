// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Ownable.sol";

contract ValhallaVacationClub is ERC721, Ownable {
    using Address for address;

    // some call it 'provenance'
    string public PROOF_OF_ANCESTRY;

    // eth://valhallavacayclub.com/look-at-me
    string public baseURI;

    // 9s EVERYWHERE
    uint256 public constant MAX_VIKINGS = 9999;
    uint256 public constant MAX_PRESALE = 750;
    uint256 public constant MAX_LUCKY_VIKINGS = 69;
    uint256 public constant FOR_THE_VAULT = 149;

    uint256 public constant PRICE = 0.065 ether;
    uint256 public constant PRESALE_PRICE = 0.04 ether;

    uint256 public luckySupply;
    uint256 public presaleSupply;
    uint256 public totalSupply;

    // Stay on your toes.
    bool public luckyActive = false;
    bool public presaleActive = false;
    bool public saleActive = false;

    // We need
    bool public vikingsBroughtHome = false;

    // Vault address
    address vaultAddress = 0xc7C15A3DC9A053D852de73651913532B0Ab5FD0B;

    // Store all the lucky mints to prevent duplicates
    mapping (address => bool) public claimedLuckers;

    // there is a lot to unpack here
    constructor() ERC721("Valhalla Vacation Club", "VVC") {}

    // Reserve some Vikings for the Team!
    function reserveVikings() public onlyOwner {
        require(bytes(PROOF_OF_ANCESTRY).length > 0,                "No distributing Vikings until provenance is established.");
        require(!vikingsBroughtHome,                                "Only once, even for you Odin");
        require(totalSupply + FOR_THE_VAULT <= MAX_VIKINGS,         "You have missed your chance, Fishlord.");

        for (uint256 i = 0; i < FOR_THE_VAULT; i++) {
            _safeMint(vaultAddress, totalSupply + i);
        }

        totalSupply += FOR_THE_VAULT;
        presaleSupply += FOR_THE_VAULT;

        vikingsBroughtHome = true;
    }

    // A freebie for you - Lucky you!
    function luckyViking() public {
        require(luckyActive,                                            "A sale period must be active to claim");
        require(!claimedLuckers[msg.sender],                            "You have already claimed your Lucky Viking.");
        require(totalSupply + 1 <= MAX_VIKINGS,                         "Sorry, you're too late! All vikings have been claimed.");
        require(luckySupply + 1 <= MAX_LUCKY_VIKINGS,                   "Sorry, you're too late! All Lucky Vikings have been claimed.");

        _safeMint( msg.sender, totalSupply);
        totalSupply += 1;
        luckySupply += 1;
        presaleSupply += 1;

        claimedLuckers[msg.sender] = true;
    }

    // Lets raid together, earlier than the others!!!!!!!!! LFG
    function mintPresale(uint256 numberOfMints) public payable {
        require(presaleActive,                                      "Presale must be active to mint");
        require(totalSupply + numberOfMints <= MAX_VIKINGS,         "Purchase would exceed max supply of tokens");
        require(presaleSupply + numberOfMints <= MAX_PRESALE,       "We have to save some Vikings for the public sale - Presale: SOLD OUT!");
        require(PRESALE_PRICE * numberOfMints == msg.value,         "Ether value sent is not correct");

        for(uint256 i; i < numberOfMints; i++){
            _safeMint( msg.sender, totalSupply + i );
        }

        totalSupply += numberOfMints;
        presaleSupply += numberOfMints;
    }

    // ..and now for the rest of you
    function mint(uint256 numberOfMints) public payable {
        require(saleActive,                                         "Sale must be active to mint");
        require(numberOfMints > 0 && numberOfMints < 6,             "Invalid purchase amount");
        require(totalSupply + numberOfMints <= MAX_VIKINGS,         "Purchase would exceed max supply of tokens");
        require(PRICE * numberOfMints == msg.value,                 "Ether value sent is not correct");

        for(uint256 i; i < numberOfMints; i++) {
            _safeMint(msg.sender, totalSupply + i);
        }

        totalSupply += numberOfMints;
    }

    // The Lizards made us do it!
    function setAncestry(string memory provenance) public onlyOwner {
        require(bytes(PROOF_OF_ANCESTRY).length == 0, "Now now, Loki, do not go and try to play god...twice.");

        PROOF_OF_ANCESTRY = provenance;
    }

    function toggleLuckers() public onlyOwner {
        require(bytes(PROOF_OF_ANCESTRY).length > 0, "No distributing Vikings until provenance is established.");

        luckyActive = !luckyActive;
        presaleActive = false;
    }

    //and a flip of the (small) switch
    function togglePresale() public onlyOwner {
        require(bytes(PROOF_OF_ANCESTRY).length > 0, "No distributing Vikings until provenance is established.");

        luckyActive = false;
        presaleActive = !presaleActive;
    }

    // LETS GO RAIDING!!! #VVCGANG
    function toggleSale() public onlyOwner {
        require(bytes(PROOF_OF_ANCESTRY).length > 0, "No distributing Vikings until provenance is established.");

        luckyActive = false;
        presaleActive = false;
        saleActive = !saleActive;
    }

    // For the grand reveal and where things are now.. where things will forever be.. gods willing
    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    // Look at those god damn :horny: Vikings
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // We don't want to have all the money stuck in the contract, right?
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}