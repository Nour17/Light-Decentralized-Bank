pragma solidity >= 0.4.22 < 0.6.0;

import './SafeMath.sol';
import './ERC20Interface.sol';

contract Token {
    
    using SafeMath for uint256;
    
    uint totalSupplyVal;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
    
    mapping(address => uint) public Balances;
    mapping(address => mapping(address => uint)) public Allowances;
    
    modifier validValue(address _to, uint _value) {
        require(Balances[msg.sender] >= _value &&
                _value > 0 &&
                _to != address(0));
        _;
    }
    
    modifier validTransferFrom(address _from, address _to, uint _value) {
        require(Balances[_from] >= _value &&
                Allowances[_from][msg.sender] >= _value &&
                _value > 0 &&
                _to != address(0));
        _;
    }
    
    constructor (uint _totalSupply) public {
        totalSupplyVal = _totalSupply;
    }
    
    function totalSupply() public view returns (uint) {
        return totalSupplyVal;
    }
    
    function balanceOf(address _owner) public view returns (uint) {
        return Balances[_owner];
    }
    
    function transfer(address _to, uint _value) public validValue(_to, _value) returns (bool) {
        Balances[msg.sender] = Balances[msg.sender].sub(_value);
        Balances[_to] = Balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint) {
        return Allowances[_owner][_spender];
    }
    
    function approve(address _spender, uint _value) public validValue(_spender, _value) returns (bool) {
        Allowances[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    
    function increaseApproval(address _spender, uint _value) public validValue(_spender, _value) returns (bool) {
        Allowances[msg.sender][_spender] = Allowances[msg.sender][_spender].add(_value);
        
        emit Approval(msg.sender, _spender, Allowances[msg.sender][_spender]);
        
        return true;
    }
    
    function decreaseApproval(address _spender, uint _value) public validValue(_spender, _value) returns (bool) {
        uint256 oldValue = Allowances[msg.sender][_spender];
          
        if (_value >= oldValue) {
           Allowances[msg.sender][_spender] = 0;
        } else {
           Allowances[msg.sender][_spender] = oldValue.sub(_value);
        }  
      
        emit Approval(msg.sender, _spender, Allowances[msg.sender][_spender]);
        
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public validTransferFrom(_from, _to, _value) returns (bool) {
        Balances[_from] = Balances[_from].sub(_value);
        Allowances[_from][msg.sender] = Allowances[_from][msg.sender].sub(_value);
        Balances[_to] = Balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
