pragma solidity ^0.4.24;

import './contracts/token/ERC20/StandardToken.sol';
import './contracts/ownership/Ownable.sol';
import './ProjectTask.sol';
import "./contracts/math/SafeMath.sol";


contract ProjectEquity is StandardToken, Ownable {

	string public name;
	string public symbol;
	uint8 public decimals;

	
  //-------------------------------------------------------------------------------------------
  // Task management      numberOfTotalTasksInArray contains number of tasks in this project 
  // tasksAddresses is the collection of Tasks
  //-------------------------------------------------------------------------------------------
  uint public numberOfTotalTasksInArray = 0;
  address[] public tasksAddresses;
  
  
  using SafeMath for uint256;	
	
	
	
  //-------------------------------------------------
  // Contract Constructor 
  //-------------------------------------------------
  constructor(    address _projectOwner,                            // Project Owner address 
				  address _incubatorOwnerAddres,                    // Incubator Owner address 
				  uint _incubatorOwnerPercentageInProject,          // Incubator owner percentage in this project 
				  address _ventureFusionAddress,                    // VentureFusion owner address 
				  uint _ventureFusionPercentageInProject,           // VentureFusion percentage in this project 
				  uint8 _decimals )                // Division of each share 
  public {
     require(_projectOwner != address(0));
	 require(_incubatorOwnerAddres != address(0));
     require(_ventureFusionAddress != address(0));
	 require(_incubatorOwnerPercentageInProject >= 0);
	 require(_ventureFusionPercentageInProject >= 0);
	 require(_decimals >= 0 && _decimals <= 6);
	 
	 if(_decimals == 0)
		totalSupply_ = 100;
	 else if(_decimals == 1)
		totalSupply_ = 100 * 10;
	 else if(_decimals == 2)
		totalSupply_ = 100 * 100;
	 else if(_decimals == 3)
		totalSupply_ = 100 * 1000;
	 else if(_decimals == 4)
		totalSupply_ = 100 * 10000;
	 else if(_decimals == 5)
		totalSupply_ = 100 * 100000;
	 else if(_decimals == 6)
		totalSupply_ = 100 * 1000000;
		
	 
	 balances[_incubatorOwnerAddres] = _incubatorOwnerPercentageInProject;
	 balances[_ventureFusionAddress] = _ventureFusionPercentageInProject;
	 balances[_projectOwner] = totalSupply_.sub(_incubatorOwnerPercentageInProject + _ventureFusionPercentageInProject);
	 decimals = _decimals;        
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