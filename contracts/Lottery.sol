// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RandomNumberGenerator.sol";

contract Lottery is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    using SafeMath for uint256;

    enum LotteryState {Open, Closed, Finished}

    mapping(uint256 => EnumerableSet.AddressSet) entries;
    uint256[] public numbers;
    LotteryState public state;
    uint256 public numberOfEntries;
    uint256 public entryFee;
    uint256 public ownerCut;
    uint256 public winningNumber;
    address public randomNumberGenerator;
    bytes32 public randomNumberRequestId;

    event LotteryStateChanged(LotteryState newState);
    event NewEntry(address player, uint256 number);
    event NumberRequested(bytes32 requestId);
    event NumberDrawn(bytes32 requestId, uint winningNumber);

    // modifiers
    modifier isState(LotteryState _state) {
        require(state == _state, "Wrong state for this action");
        _;
    }

    modifier onlyRandomGenerator {
        require(msg.sender == randomNumberGenerator, "Must be correct generater");
        _;
    }

    // constructor
    constructor (uint256 _entryFee, uint256 _ownerCut, address _randomNumberGenerator)  Ownable() {
        require(_entryFee > 0, "Entry fee must be greater than 0");
		require(_ownerCut < _entryFee, "Entry fee must be greater than owner cut");
		require(_randomNumberGenerator != address(0), "Random number generator must be valid address");
		require(_randomNumberGenerator.isContract(), "Random number generator must be smart contract");
		entryFee = _entryFee;
		ownerCut = _ownerCut;
		randomNumberGenerator = _randomNumberGenerator;
		_changeState(LotteryState.Open);
    }

    // functions 
    function submitNumber(uint256 _number) public payable isState(LotteryState.Open){
        require(msg.value >= entryFee, "Minimum entry fee required");
        require(entries[_number].add(msg.sender), "Cannot submit the same number more than once");
        numbers.push(_number);
        numberOfEntries++;
        (bool success, ) = owner().call{ value: ownerCut }("");
        require(success, "Transfer of Owner cut failed");
        emit NewEntry(msg.sender, _number);

    }

    function drawNumber() public onlyOwner isState(LotteryState.Open) {
        _changeState(LotteryState.Closed);
        randomNumberRequestId = RandomNumberGenerator(randomNumberGenerator).request(); // Request a random number from RNG Contract 
        emit NumberRequested(randomNumberRequestId);
    }

    function rollover() public onlyOwner isState(LotteryState.Finished) {
        //rollover new lottery
    }
    
    function numberDrawn(bytes32 _randomNumberRequestId, uint _randomNumber) public onlyRandomGenerator isState(LotteryState.Closed) {
		if (_randomNumberRequestId == randomNumberRequestId) { // make sure that the requestId coming back is the correct one
			winningNumber = _randomNumber;
			emit NumberDrawn(_randomNumberRequestId, _randomNumber);
			_payout(entries[_randomNumber]);
			_changeState(LotteryState.Finished);
		}
	}

    function _payout(EnumerableSet.AddressSet storage winners) private {
        uint256 balance = address(this).balance;
        for (uint256 index=0; index < winners.length(); index++){
            payable(winners.at(index)).transfer(balance.div(winners.length()));
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }
}