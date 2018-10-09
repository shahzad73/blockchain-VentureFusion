pragma solidity ^0.4.24;

import "./contracts/venturefusion/ProjectInterface.sol";
import "./contracts/math/SafeMath.sol";
import './contracts/ownership/Ownable.sol';

contract ProjectEquity is ProjectInterface, Ownable {

  mapping(address => uint256) internal shareBalances;

  mapping (address => mapping (address => uint256)) internal shareAllowed;

  //how many decimal places each single share has. for example 1000 
  //means each share can be broken down 1000. So 0.5 means 500
  uint public decimals;        

  using SafeMath for uint256;

  
  constructor(    address _projectOwner, 
				  address _incubatorOwnerAddres, 
				  uint _incubatorOwnerPercentageInProject, 
				  address _ventureFusionAddress, 
				  uint _ventureFusionPercentageInProject, 
				  uint _decimals )
  public {
	 uint totalPercent = 100 * _decimals;
	 shareBalances[_incubatorOwnerAddres] = _incubatorOwnerPercentageInProject;
	 shareBalances[_ventureFusionAddress] = _ventureFusionPercentageInProject;
	 shareBalances[_projectOwner] = totalPercent.sub(_incubatorOwnerPercentageInProject + _ventureFusionPercentageInProject);
	 decimals = _decimals;        
  }

  



  function transferShares(
	address _to, 
	uint256 _value
  ) 
    public returns (bool) 
  {
    require(_value <= shareBalances[msg.sender]);
    require(_to != address(0));

    shareBalances[msg.sender] = shareBalances[msg.sender].sub(_value);
    shareBalances[_to] = shareBalances[_to].add(_value);
    //emit TransferShares(msg.sender, _to, _value);
    return true;
  }



  

  

  function approveShares (
     address _spender, 
	 uint256 _value
  ) 
    public returns (bool) 
  {
    shareAllowed[msg.sender][_spender] = _value;
    emit ApprovalShares(msg.sender, _spender, _value);
    return true;
  }

  
  
  
  
    

  function shareAllowance(
    address _owner,
    address _spender
  )
    public view returns (uint256) 
  {
     return shareAllowed[_owner][_spender];
  }


  
  
  


  function shareTransferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public returns (bool)
  {
    require(_value <= shareBalances[_from]);
    require(_value <= shareAllowed[_from][msg.sender]);
    require(_to != address(0));

    shareBalances[_from] = shareBalances[_from].sub(_value);
    shareBalances[_to] = shareBalances[_to].add(_value);
    shareAllowed[_from][msg.sender] = shareAllowed[_from][msg.sender].sub(_value);
    //emit TransferShares(_from, _to, _value);
    return true;
  }

  



  
  

  function shareBalanceOf(
     address _shareHolder
  ) 
    public view returns (uint256) 
  {
    return shareBalances[_shareHolder];
  }
 
 

 
  
  
  function launchSellShares (
	address _shareHolder, 
	uint256 _value
  ) 
  public returns (bool)
  {
  
  }
  
  
  
  
  function launchNewTask (
    string _taskName, 
	uint256 _percentageSharesOnOffer, 
	address _contributor
  ) 
  public returns (bool)
  {
    
  }
  
  
  
}
