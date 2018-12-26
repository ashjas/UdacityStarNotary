pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 { 

    struct Star { 
        string name;
        string story;
        string dec;
        string mag;
        string cen;
    }

    uint256 lastTokenId;
    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes32 => uint8) private uniqueHashOfStar;

    event starClaimed(address owner);

    function checkIfStarExists(string _dec, string _mag, string _cen) private returns (bool) {
        if(uniqueHashOfStar[keccak256(abi.encodePacked(_dec,_mag,_cen))] != 1)
        {
            uniqueHashOfStar[keccak256(abi.encodePacked(_dec,_mag,_cen))] = 1;
            return false;
        }
        return true;
    }

    function createStar(string _name, string _story, string _dec, string _mag, string _cen) public returns (uint256){ 
        // validate, if any info is missing.
        require(keccak256(abi.encodePacked(_story)) != keccak256(""),"Empty Story not allowed!");
        require(keccak256(abi.encodePacked(_dec)) != keccak256(""),"Empty dec not allowed!");
        require(keccak256(abi.encodePacked(_mag)) != keccak256(""),"Empty mag not allowed!");
        require(keccak256(abi.encodePacked(_cen)) != keccak256(""),"Empty cen not allowed!");
        
        string memory dec = string(abi.encodePacked("dec_",_dec));
        string memory mag = string(abi.encodePacked("mag_",_mag));
        string memory cen = string(abi.encodePacked("ra_",_cen));

        
        
        
        require(!checkIfStarExists(dec, mag, cen),"Star already registered.");
        Star memory newStar = Star(_name, _story, dec, mag, cen);

        tokenIdToStarInfo[lastTokenId] = newStar;
        //log0(bytes32(newStar));

        _mint(msg.sender, lastTokenId);
        emit starClaimed(msg.sender);
        return lastTokenId++;
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }
}