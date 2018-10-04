pragma solidity ^0.4.24;

contract ProjectInterface 
{

  function shareBalanceOf(address _who) public view returns (uint256);
  function transferShares(address _to, uint256 _value) public returns (bool);
  event TransferShares(address indexed from, address indexed to, uint256 value);

  function shareTransferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approveShares(address _spender, uint256 _value) public returns (bool);
  event ApprovalShares(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
	
  function shareAllowance(address _owner, address _spender)
    public view returns (uint256);

  
  function launchSellShares (address _shareHolder, uint256 _value) public returns (bool);
  
  function launchNewTask (string _taskName, uint256 _percentageSharesOnOffer, address _contributor) 
	public returns (bool);
  
}

