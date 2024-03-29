pragma solidity >= 0.4.22 < 0.6.0;

import './Safemath.sol';
import './LightToken.sol';

contract Crowdsale {
    using Safemath for uint256;
    
    bool public icoCompleted;
    uint public icoStartTime;
    uint public icoEndTime;
    uint public fundingGoal;
    address payable owner;
    LightToken public lightToken;
    uint public tokensRaised;
    uint public etherRaised;
    
    // add variables to increase the token price as the supply decreases
    uint256 public rateOne = 5000;
    uint256 public rateTwo = 4000;
    uint256 public rateThree = 3000;
    uint256 public rateFour = 2000;
    uint256 public limitTierOne = 25e6 * (10 ** token.decimals());
    uint256 public limitTierTwo = 50e6 * (10 ** token.decimals());
    uint256 public limitTierThree = 75e6 * (10 ** token.decimals());
    uint256 public limitTierFour = 100e6 * (10 ** token.decimals());
    
    modifier whenIcoCompleted {
        require(icoCompleted);
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor (uint _icoStartTime,
                 uint _icoEndTime,
                 uint _tokenRate,
                 address _tokenAddress,
                 uint _fundingGoal) public {
                     
        require(_icoStartTime != 0 &&
                _icoEndTime != 0 &&
                _icoStartTime < _icoEndTime &&
                _tokenRate != 0 &&
                _tokenAddress != address(0) &&
                _fundingGoal != 0);
        
        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        tokenRate = _tokenRate;
        fundingGoal = _fundingGoal;
        owner = msg.sender;
        lightToken = LightToken(_tokenAddress);
    }
    
    function () external payable {
        buy();
    }
    
    function buy() public payable {
        require(tokensRaised < fundingGoal);
        require(now < icoEndTime && now > icoStartTime);
        
        uint etherUsed = msg.value;
        uint tokensToBuy;
        
        // If the tokens raised are less then 25 million decimals, apply first rate
        if(tokensRaised < limitTierOne){
            // Tier One
            tokensToBuy = etherUsed * (10 ** lightToken.decimals()) / 1 ether * rateOne;
        }
        
        // check if we hace reached and exceeded the funcing goal to refund the exceeding tokens and ether
        if(tokensRaised + tokensToBuy > fundingGoal){
            uint exceedingTokens = (tokensToBuy + tokensRaised) - fundingGoal;
            
            // convert the exceeded tokens back to ether
            uint exceededEther = exceedingTokens * 1 ether / tokenRate / lightToken.decimals();
            
            // send exceeded ether back
            msg.sender.transfer(exceededEther);
            
            // remove the exceeded tokens from tokensToBuy
            tokensToBuy -= exceedingTokens;
            
            // remove the exceeded ether from etherUsed
            etherUsed -= exceededEther;
        }
        
        // send the tokens to the buyer
        lightToken.buyTokens(msg.sender, tokensToBuy);
        
        // increase the tokens and ether raised state variables
        tokensRaised += tokensToBuy;
        etherRaised += etherRaised;
    }
    
    function extractEther() public whenIcoCompleted onlyOwner{
        owner.transfer(address(this).balance);
    }
}
