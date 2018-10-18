pragma solidity ^0.4.24;


import "./contracts/math/SafeMath.sol";
import './contracts/ownership/Ownable.sol';
import './ProjectTask.sol';


contract ProjectEquity2 is Ownable {

  //------------------------------------------------------------------
  //how many decimal places each single share has. for example 1000 
  //means each share can be broken down 1000. So 0.5 means 500
  //------------------------------------------------------------------
  string public name;
  string public symbol;
  uint public decimals;  


  //-------------------------------
  // Project Balances in token 
  //-------------------------------
  mapping(address => uint256) internal balances;

  
  //-------------------------------
  // Project token allowances 
  //-------------------------------
  mapping (address => mapping (address => uint256)) internal allowed;


  
  //-------------------------------------------------------------------------------------------
  // Task management      numberOfTotalTasksInArray contains number of tasks in this project 
  // tasksAddresses is the collection of Tasks
  //-------------------------------------------------------------------------------------------
  uint public numberOfTotalTasksInArray = 0;
  address[] public tasksAddresses;
  
  
  using SafeMath for uint256;

  
  //--------------------------
  // Events of this Contract 
  //--------------------------
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed from, address indexed to, uint256 value);
  
  
  
  
  //-------------------------------------------------
  // Contract Constructor 
  //-------------------------------------------------
  constructor(    address _projectOwner,                            // Project Owner address 
				  address _incubatorOwnerAddres,                    // Incubator Owner address 
				  uint _incubatorOwnerPercentageInProject,          // Incubator owner percentage in this project 
				  address _ventureFusionAddress,                    // VentureFusion owner address 
				  uint _ventureFusionPercentageInProject,           // VentureFusion percentage in this project 
				  uint _decimals )                // Division of each share 
  public {
     require(_projectOwner != address(0));
	 require(_incubatorOwnerAddres != address(0));
     require(_ventureFusionAddress != address(0));
	 require(_incubatorOwnerPercentageInProject >= 0);
	 require(_ventureFusionPercentageInProject >= 0);
	 require(_decimals > 0);
	 
	 uint totalShares = 100 * _decimals;
	 balances[_incubatorOwnerAddres] = _incubatorOwnerPercentageInProject;
	 balances[_ventureFusionAddress] = _ventureFusionPercentageInProject;
	 balances[_projectOwner] = totalShares.sub(_incubatorOwnerPercentageInProject + _ventureFusionPercentageInProject);
	 decimals = _decimals;        
  }





  //----------------------------------------------------
  // Transfer Shares from message sender to recipient
  //----------------------------------------------------
  function transfer (
	address _to, 
	uint256 _value
  ) 
    public returns (bool) 
  {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }





  //--------------------------------------------------------------------------
  // Share owner can give rights to spender to spend shares on his behalf 
  //--------------------------------------------------------------------------
  function approve (
     address _spender, 
	 uint256 _value
  ) 
    public returns (bool) 
  {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }





  //----------------------------------------------------------------------------
  // How many shares the spender has rights to spend on behalf of share owner 
  //----------------------------------------------------------------------------
  function allowance (
    address _owner,
    address _spender
  )
    public view returns (uint256) 
  {
     return allowed[_owner][_spender];
  }


  
  
  

  //--------------------------------------------------------------------------
  // Trnasfer share to new recipient by spender
  //--------------------------------------------------------------------------
  function transferFrom (
    address _from,
    address _to,
    uint256 _value
  )
    public returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));
	
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }





  //--------------------------------------------------------------------------
  // Current Balance of shares 
  //--------------------------------------------------------------------------
  function balanceOf (
     address _shareHolder
  ) 
  public view returns (uint256) 
  {
     return balances[_shareHolder];
  }





  //----------------------------------------------------------------------------
  // Launch a new task in this project and keep track this new task contract in 
  // local collection of tasks    only project owner can launch a new task 
  //----------------------------------------------------------------------------
  function launchNewTask (
     string _taskTitle,                             // Task title
	 uint _contributorSharesOffered,                // How many share offered to contributor 
	 uint _evaluatorSharesOffered                   // How many shares offered to evaluator 
  ) onlyOwner
  public returns (bool)
  {
     //TODO Check project owner has required number of token or shares to make trnasfer and some other checks
	 require(_contributorSharesOffered >= 0);      // Shares can be 0 for contributor 
	 require(_evaluatorSharesOffered >= 0);        // Shares can be 0 for evaluator
  
  
	 //Create a new task contract 
  	 address projectTask = new ProjectTask(_taskTitle, _contributorSharesOffered, _evaluatorSharesOffered, address(this));
	 
	 //Add task to local collection and increment number of tasks 
	 tasksAddresses.push(projectTask);
	 numberOfTotalTasksInArray = numberOfTotalTasksInArray + 1;
	 	  
	 //Transfer ownership of task to project owner
	 require(projectTask.call(bytes4(keccak256("transferOwnership(address)")), owner));
	 

	 //TODO  lock certain number of tokens so that project owner cannot use them in other contracts
	 
	 
	 //Give access to certain number tokens to the new task contract so that it can make 
	 //transfers to contributors and evaluator
	 allowed[owner][projectTask] = _contributorSharesOffered + _evaluatorSharesOffered;
  }






}
