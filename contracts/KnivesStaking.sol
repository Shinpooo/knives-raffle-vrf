//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Authorizable.sol";


contract KnivesStaking is Authorizable {
    mapping(address => uint256[]) public depositedTokens;
    mapping (uint => uint) public tokenIdToIndex;
    mapping(uint => address) public stakerOf;
    mapping (address => uint) public stakedAmount;
    mapping (uint => uint) public updatedAmount;
    mapping(uint => uint) public refreshTimestamp;
    uint constant RATE_PER_SEC = 1;
    uint constant MAX_CAP = 200;

    IERC721 knives_legacy = IERC721(0x7be6026396eb71465A78154C3dcEdA5B5b5b4269);

    event Deposit(address user, uint256 tokenId);
    event Withdraw(address user, uint256 tokenId);

    constructor() {}

    function deposit(uint256 tokenId, address user) internal
    {
        require (user == knives_legacy.ownerOf(tokenId), "Sender must be owner.");
        // require(stakedAmount[user] < 5, "Cannot stake more.");
        stakedAmount[user] += 1;
        stakerOf[tokenId] = user;
        refreshTimestamp[tokenId] = block.timestamp;
        tokenIdToIndex[tokenId] = depositedTokens[user].length; // save the index
        depositedTokens[user].push(tokenId);
        knives_legacy.transferFrom(user, address(this), tokenId);
        emit Deposit(user, tokenId);
    }

    function depositSelected(uint256[] calldata tokenIds) external {
        for (uint i = 0; i < tokenIds.length; i++){
            deposit(tokenIds[i], msg.sender);
        }
    }

    function withdraw(uint256 tokenId, address user) internal
    {
        require(stakerOf[tokenId] == user, "TokenId not staked by sender.");
        stakedAmount[user] -= 1;
        uint index = tokenIdToIndex[tokenId];
        remove(index, user);
        stakerOf[tokenId] = address(0);
        knives_legacy.transferFrom(address(this), user, tokenId);
        emit Withdraw(user, tokenId);
    }

    function withdrawSelected(uint256[] calldata tokenIds) external {
        for (uint i = 0; i < tokenIds.length; i++){
            withdraw(tokenIds[i], msg.sender);
        }
    }

    function getDepositedTokens(address user) public view returns(uint[] memory){
        uint256[] memory stakedTokens = depositedTokens[user];
        return stakedTokens;
    }

    function remove(uint _index, address user) internal {
        uint256[] storage stakedTokens = depositedTokens[user];
        stakedTokens[_index] = stakedTokens[stakedTokens.length - 1];
        tokenIdToIndex[stakedTokens[_index]] = _index;
        stakedTokens.pop();
    }
    

    function getLGCYMPAmount(uint tokenId) external view returns (uint) {
        if(refreshTimestamp[tokenId] == 0) return 0;
        else {
            uint calculated_amount = block.timestamp - refreshTimestamp[tokenId] + updatedAmount[tokenId];
            return calculated_amount * RATE_PER_SEC >= MAX_CAP  ? MAX_CAP : calculated_amount;
            }
    }

    function setLGCYMPAmount(uint amount, uint tokenId) external onlyAuthorized {
        updatedAmount[tokenId] = amount;
        refreshTimestamp[tokenId] = block.timestamp;
    }

}
