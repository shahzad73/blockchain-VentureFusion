pragma solidity ^0.4.24;

import "./contracts/venturefusion/ProjectInterface.sol";
import "./contracts/math/SafeMath.sol";
import './contracts/ownership/Ownable.sol';

contract ProjectEquity is ProjectInterface, Ownable {

  mapping(address => uint256) internal shareBalances;
  
  mapping (address => mapping (address => uint256)) internal shareAllowed;

  using SafeMath for uint256;
  
  
  constructor(address _projectOwner, uint _incubatorOwnerPercentageInProject, uint _ventureFusionPercentageInProject) 
  public {
	 uint totalPercent = 100;
	 shareBalances[msg.sender] = _incubatorOwnerPercentageInProject;
	 shareBalances[0x0] = totalPercent.sub(_incubatorOwnerPercentageInProject);
  }

  

  /**
  * @dev Gets the share balance of the specified address.
  * @param _shareHolder The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function shareBalanceOf(
     address _shareHolder
  ) 
    public view returns (uint256) 
  {
    return shareBalances[_shareHolder];
  }
  
  
  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
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
    emit TransferShares(msg.sender, _to, _value);
    return true;
  }

  
  
  

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
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
    emit TransferShares(_from, _to, _value);
    return true;
  }

  
  
  
  
  
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
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

  
  
  
  
  
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function shareAllowance(
    address _owner,
    address _spender
  )
    public view returns (uint256) 
  {
     return shareAllowed[_owner][_spender];
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
