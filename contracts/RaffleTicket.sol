// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract KnivesLegacyTicket is ERC721, ERC721Enumerable, Pausable, Ownable, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61
;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    // uint32 numWords =  2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint256 public current_raffle;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _RaffleIdCounter;

    mapping (uint => uint) tokenIdToRaffleId;
    mapping (uint => Raffle) raffleIdToRaffle;
    // mapping (address => bool) canTransfer;
    
    struct Raffle { 
        string project_name;
        string image_url;
        uint price;
        uint max_ticket;
        uint max_ticket_wallet;
        uint32 winners_amount;
        uint raffle_id;
        uint open_timestamp;
        uint close_timestamp;
        uint[] random_numbers;
        address[] participants;
        address[] winners;
        mapping (address => bool) has_won;
    }

    
    constructor(uint64 subscriptionId) ERC721("KnivesLegacyTicket", "KLTICKET") VRFConsumerBaseV2(vrfCoordinator){
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }

    function setRequestConfirmation(uint16 _requestConfirmation) external onlyOwner {
        requestConfirmations = _requestConfirmation;
    }
    function setcallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }
    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }

    function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        s_subscriptionId = _subscriptionId;
    }

    function setVrfCoordinator(address _vrfCoordinator) external onlyOwner {
        vrfCoordinator = _vrfCoordinator;
    }

      // Assumes the subscription is funded sufficiently.
    function requestRandomWords(uint raffleId) external onlyOwner {
        // Will revert if subscription is not set and funded.
        Raffle storage raffle = raffleIdToRaffle[raffleId];
        require(isRaffleOpen(raffleId), "Raffle is closed.");
        require(raffle.winners_amount < raffle.participants.length, "Not enough participants.");
        current_raffle = raffleId;
        uint32 numWords = raffle.winners_amount;
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }

    function isRaffleOpen(uint raffleId) public view returns (bool){
        Raffle storage raffle = raffleIdToRaffle[raffleId];
        return block.timestamp >= raffle.open_timestamp && block.timestamp <= raffle.close_timestamp ? true : false;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        Raffle storage raffle = raffleIdToRaffle[current_raffle];
        for (uint i=0; i < raffle.winners_amount; i++) {
            raffle.random_numbers.push(randomWords[i]);
        }

        // uint n_participants = raffle.participants.length;
        // for (uint i=0; i < raffle.winners_amount; i++) {
        //     uint random_number = randomWords[i];
        //     uint random_index = random_number % n_participants;
        //     address winner = raffle.participants[random_index];
        //     while (raffle.has_won[winner]){
        //         random_number += 1;
        //         random_index = random_number % n_participants;
        //         winner = raffle.participants[random_index];
        //     }
        //     raffle.winners.push(winner);
        //     raffle.has_won[winner] = true;
        // }
    }

    function pickWinners(uint raffleId) public onlyOwner {
        Raffle storage raffle = raffleIdToRaffle[raffleId];
        uint[] memory random_numbers = raffle.random_numbers;
        uint n_participants = raffle.participants.length;
        for (uint i=0; i < raffle.winners_amount; i++) {
            uint random_number = random_numbers[i];
            uint random_index = random_number % n_participants;
            address winner = raffle.participants[random_index];
            while (raffle.has_won[winner]){
                random_number += 1;
                random_index = random_number % n_participants;
                winner = raffle.participants[random_index];
            }
            raffle.winners.push(winner);
            raffle.has_won[winner] = true;
        }

    }



    // testing
    function addParticipants(uint raffleId, address[] calldata participants) public {
        Raffle storage raffle = raffleIdToRaffle[raffleId];
        for (uint i = 0; i < participants.length; i++){
            raffle.participants.push(participants[i]);
        }
    }

    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // function switchCanTransfer(address user) public onlyOwner {
    //     canTransfer[user] = !canTransfer[user];
    // }

    function createRaffle(string memory project_name, string memory image_url, uint price, uint max_ticket, uint max_ticket_wallet, uint32 winners_amount, uint open_timestamp, uint close_timestamp) public onlyOwner {
        _RaffleIdCounter.increment();
        uint raffle_id = _RaffleIdCounter.current();
        Raffle storage new_raffle = raffleIdToRaffle[raffle_id];
        new_raffle.project_name = project_name;
        new_raffle.image_url = image_url;
        new_raffle.price = price;
        new_raffle.max_ticket = max_ticket;
        new_raffle.max_ticket_wallet = max_ticket_wallet;
        new_raffle.winners_amount = winners_amount;
        new_raffle.raffle_id = raffle_id;
        new_raffle.open_timestamp = open_timestamp;
        new_raffle.close_timestamp = close_timestamp;
    }

    function editRaffle(uint raffle_id, string memory project_name, string memory image_url, uint price, uint max_ticket, uint max_ticket_wallet, uint32 winners_amount, uint open_timestamp, uint close_timestamp) public onlyOwner {
        Raffle storage raffle = raffleIdToRaffle[raffle_id];
        raffle.project_name = project_name;
        raffle.image_url = image_url;
        raffle.price = price;
        raffle.max_ticket = max_ticket;
        raffle.max_ticket_wallet = max_ticket_wallet;
        raffle.winners_amount = winners_amount;
        raffle.open_timestamp = open_timestamp;
        raffle.close_timestamp = close_timestamp;
    }



    function safeMint(uint raffleId) public payable {
        Raffle storage raffle = raffleIdToRaffle[raffleId];
        require(isRaffleOpen(raffleId), "Raffle is closed.");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        tokenIdToRaffleId[tokenId] = raffleId;
        raffle.participants.push(msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {   
        require(from == address(0), "Non transferable NFT.");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function getWinners(uint raffle_id) public view returns (address[] memory) {
        Raffle storage raffle = raffleIdToRaffle[raffle_id];
        address[] memory winners = raffle.winners;
        return winners;
    }

    function getRandomNumbers(uint raffle_id) public view returns (uint[] memory) {
        Raffle storage raffle = raffleIdToRaffle[raffle_id];
        uint[] memory random_numbers = raffle.random_numbers;
        return random_numbers;
    }

    function getParticipants(uint raffle_id) public view returns (address[] memory) {
        Raffle storage raffle = raffleIdToRaffle[raffle_id];
        address[] memory participants = raffle.participants;
        return participants;
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}