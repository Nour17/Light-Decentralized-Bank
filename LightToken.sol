pragma solidity >= 0.4.22 < 0.6.0;

import './Token.sol';

contract LightToken is Token(100e24){
    string public name = 'Light Distributed Bank';
    string public symbol = 'LDB';
    uint public decimals = 18;
    address public crowdsaleAddress;
    address payable owner;
    uint public ICOEndTime;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    modifier onlyCrowdsale() {
        require(crowdsaleAddress == msg.sender);
        _;
    }
    
    modifier afterCrowdsale() {
        require(now > ICOEndTime || msg.sender == crowdsaleAddress);
        _;
    }
    
    constructor (uint _ICOEndTime) public {
        require(_ICOEndTime > 0);
        owner = msg.sender;
        ICOEndTime = _ICOEndTime;
    }
    
    function setCrowdsale(address _crowdsaleAddress) public onlyOwner {
        require(_crowdsaleAddress != address(0));
        crowdsaleAddress = _crowdsaleAddress;
    }
    
    function buyTokens(address _receiver, uint _amount) public onlyCrowdsale {
        require(_receiver != address(0));
        require(_amount > 0);
        transfer(_receiver, _amount);
    }
    
    // Override the functions to not allow token transfers until the end of the ICO
    function transfer(address _to, uint _value) public afterCrowdsale returns (bool) {
        return super.transfer(_to, _value);
    }
    
    // Override the functions to not allow token transfers until the end of the ICO
    function approve(address _spender, uint _value) public afterCrowdsale returns (bool) {
        return super.approve(_spender, _value);
    }
    
    // Override the functions to not allow token transfers until the end of the ICO
    function increaseApproval(address _spender, uint _value) public afterCrowdsale returns (bool) {
        return super.increaseApproval(_spender, _value);
    }
    
    // Override the functions to not allow token transfers until the end of the ICO
    function decreaseApproval(address _spender, uint _value) public afterCrowdsale returns (bool) {
        return super.decreaseApproval(_spender, _value);
    }
    
    // Override the functions to not allow token transfers until the end of the ICO
    function transferFrom(address _from, address _to, uint _value) public afterCrowdsale returns (bool) {
        return super.transferFrom(_from , _to, _value);
    }
    
    function emergencyExtract() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}
