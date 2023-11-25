// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract StakeV2 is ReentrancyGuard{
    uint256 public timeReward;
    uint256 public rewardPercent;
    address public immutable owner;
    address public immutable token;

    using SafeMath for uint256;

    struct StakeInfo{
        uint256 amount;
        uint256 stakeTime;
    }

    mapping (address=>StakeInfo) public Stake;

    event stakeConract(address _account,uint256 _amount,uint256 _stakeTime);

    constructor(uint256 _timeReward,uint256 _rewardPercent,address _token){
        timeReward=_timeReward;
        rewardPercent=_rewardPercent;
        token=_token;
        owner=msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,'You are not the owner of this contract');
        _;
    }

    function approveContract(uint256 _amount) public{
        require(IERC20(token).approve(address(this), _amount),'Approval failed');
    }

    function stake(uint256 _amount) public{
        require(_amount!=0,'Amount must be greater than zero');

        require(IERC20(token).transferFrom(msg.sender,address(this),_amount),'Stake failed');
        Stake[msg.sender]=StakeInfo(_amount,block.timestamp);

        emit stakeConract(msg.sender, _amount, block.timestamp);
    }

    function unSatke() public nonReentrant{
        uint256 _dayReward=_dayRewardCalc(Stake[msg.sender].stakeTime);
        uint256 _reward=(Stake[msg.sender].amount * (rewardPercent * _dayReward))/100;
        require(_dayReward!=0,'You cannot unStake at this time');
        require(IERC20(token).balanceOf(address(this)) >= (Stake[msg.sender].amount + _reward),'');
        Stake[msg.sender].amount+=_reward;
        Stake[msg.sender].amount -= (Stake[msg.sender].amount+_reward);
        Stake[msg.sender].stakeTime=block.timestamp;

        IERC20(token).transfer(msg.sender, Stake[msg.sender].amount+_reward);
    }

    function withdraw(uint256 _amount) public nonReentrant{
        uint256 _dayReward=_dayRewardCalc(Stake[msg.sender].stakeTime);
        uint256 _reward=(Stake[msg.sender].amount * (_dayReward * rewardPercent))/100;
        require(_amount!=0,'Amount must be gratter then zero');
        require((Stake[msg.sender].amount +_reward)>=_amount,'You dont have enough token in contract to withdraw');

        Stake[msg.sender].amount +=_reward;
        Stake[msg.sender].amount -= _amount;
        Stake[msg.sender].stakeTime=block.timestamp;

        IERC20(token).transfer(msg.sender, _amount);
    }

    function reward() public view returns(uint256){
        uint256 _dayReward=_dayRewardCalc(Stake[msg.sender].stakeTime);
        uint256 _reward=(Stake[msg.sender].amount * (_dayReward * rewardPercent))/100;
        
        return _reward;
    }

    function getBalance() public view returns(uint256){
        uint256 _dayReward=_dayRewardCalc(Stake[msg.sender].stakeTime);
        uint256 _reward=(Stake[msg.sender].amount * (_dayReward * rewardPercent))/100;

        uint256 balance=Stake[msg.sender].amount + _reward;

        return balance;
    }

    function withdrawReward()public nonReentrant{
        uint256 _dayReward=_dayRewardCalc(Stake[msg.sender].stakeTime);
        uint256 _reward=(Stake[msg.sender].amount * (_dayReward * rewardPercent))/100;
        require(_dayReward!=0,"You cant withdraw your reward at this time");
        
        Stake[msg.sender].stakeTime=block.timestamp;

        IERC20(token).transfer(msg.sender, _reward);
    }

    function changeTimeReward(uint256 _timeReward)public onlyOwner{
        timeReward=_timeReward;
    }

    function changeRewardPercentage(uint256 _rewardPercent) public onlyOwner{
        rewardPercent=_rewardPercent;
    }

    function getOwner() public view returns(address){
        return owner;
    }
    
    function getToken() public view returns(address){
        return token;
    }

    function contractBalance()public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function _dayRewardCalc(uint256 _stakeTime) public view returns(uint256){
        uint256 stakeTime=((((_stakeTime /1000)/60)/60)/24);
        uint256 realTime=((((block.timestamp /1000)/60)/60)/24);
        uint256 dayReward= SafeMath.div((realTime-stakeTime), timeReward);

        return dayReward;
    }
}