pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract ProjectTask is Ownable {

   //------------------------------------------------------------------------------------------
   // Task related information
   //------------------------------------------------------------------------------------------
   string public taskTitle;
   address public projectAddress;

   
   //------------------------------------------------------------------------------------------
   // Contributor's parameters    address, shares, solution submitted, solution accepted
   //------------------------------------------------------------------------------------------
   address public contributorAddress;
   uint public contributorProjectShares;
   bool public isContributorSolutionSubmitted = false;
   bool public isContributorSolutionAcceptedAndSharesTransferred = false;

   
   //------------------------------------------------------------------------------------------
   // Evaluator's parameters    address, shares, solution submitted, solution accepted
   //------------------------------------------------------------------------------------------   
   address public evaluatorAddress;
   uint public evaluatorProjectShares;
   bool public isEvaluatorSolutionSubmitted = false;
   bool public isEvaluatorSolutionAcceptedAndSharesTransferred = false;

   
   //------------------------------------------------------------------------------------------   
   // Temporary variable set in modifier onlyParticipent and used in setNote public function
   //------------------------------------------------------------------------------------------   
   uint tempNoteSendBy = 0;
   
   
   //----------------------------------------------------------------------------------------------------
   // Local Tasks collection.   All tasks that belong to this project are collected in this collection
   // They are added in the order they are received 
   //----------------------------------------------------------------------------------------------------
   uint public numberOfTaskNotes = 0;   //current number of notes
   struct taskNoteStruct {             //project structure
		string notes;
		uint sendBy;       // 1=Owner     2=Contributor     3=Evaluator
   }
   mapping (uint => taskNoteStruct) public taskNotes;     //mapping of task notes

   
   
   
   event ContributorTaskAccepted(address owner, address contributor, uint shares);
   event EvaluatorTaskAccepted(address owner, address evaluator, uint shares);
   
   
  //-------------------------------------------------
  // Contract Constructor 
  //-------------------------------------------------   
   constructor(
	  string _taskTitle,                            // Task title 
	  uint _contributorProjectShares,               // Contributor's shares 
	  uint _evaluatorProjectShares,                 // Evaluator's shares 
	  address _projectAddress                       // Project address to which this contract belong 
   )
   public {
      require(_projectAddress != address(0));
	  require(_contributorProjectShares >= 0);
	  require(_evaluatorProjectShares >= 0);
	  require(bytes(_taskTitle).length > 0);
	     
      taskTitle = _taskTitle;
 	  contributorProjectShares = _contributorProjectShares;
	  evaluatorProjectShares = _evaluatorProjectShares;
	  projectAddress = _projectAddress;
   }


  //-------------------------------------------------
  // Check message is send by only contributor 
  //-------------------------------------------------      
  modifier onlyContributor() {
    require(msg.sender == contributorAddress);
    _;
  }
   
   
  //-------------------------------------------------
  // Check message is send by only evaluator 
  //-------------------------------------------------         
  modifier onlyEvaluator() {
    require(msg.sender == evaluatorAddress);
    _;
  }
  

  
  //----------------------------------------------------------------------------------------------
  // Check message is send by only contributor, evaluator or project owner 
  // Also set tempNoteSendBy who send the message     owner = 1, contributor = 2, evaluator = 3
  //----------------------------------------------------------------------------------------------        
  modifier onlyParticipent () {
     require(msg.sender == contributorAddress || msg.sender == evaluatorAddress || msg.sender == owner);
	 
	 if(msg.sender == owner) 
	    tempNoteSendBy = 1;
	 if(msg.sender == contributorAddress) 
	    tempNoteSendBy = 2;
	 if(msg.sender == evaluatorAddress) 
	    tempNoteSendBy = 3;
	 _;
  }
   



   //----------------------------------------------------------------------------------------------
   // Owner can set contributor's address.   Only set contrinutor can send notes or deliverables 
   //----------------------------------------------------------------------------------------------   
   function setContributorAddress(address _address) onlyOwner public {
	   require(_address != address(0));
	   
	   require(isContributorSolutionAcceptedAndSharesTransferred == false);		
	   contributorAddress = _address;
   }
	
	
	
   //----------------------------------------------------------------------------------------------
   // Owner can set evaluator's address.   Only set evaluator can send notes or deliverables 
   //----------------------------------------------------------------------------------------------   	
	function setEvaluatorAddress(address _address) onlyOwner public  {
	   require(_address != address(0));
	   
	   require(isEvaluatorSolutionAcceptedAndSharesTransferred == false);		
	   evaluatorAddress = _address;
	}

	
	
   //----------------------------------------
   // Add notes to local notes collection 
   //----------------------------------------
	taskNoteStruct newNotes;
	function addNotes (string _note, uint _sendBy) public
	{		
		newNotes = taskNoteStruct(_note, _sendBy);
		taskNotes[numberOfTaskNotes] = newNotes;
		numberOfTaskNotes = numberOfTaskNotes + 1;
	}

	

   //----------------------------------------------------------------------------------------------   	
   // Contributor can send deliverables. only current contributor can call this function and 
   // owner can change contributor 
   //----------------------------------------------------------------------------------------------   	
	function contributorDeliverablesAreReadyWithNotes(string _notes) onlyContributor public  {
		require(bytes(_notes).length > 0);
		
		isContributorSolutionSubmitted = true;
		addNotes(_notes, 2);
	}

	
	
	
   //----------------------------------------------------------------------------------------------   	
   // Evaluator can send deliverables. only current evaluator can call this function and 
   // owner can change evaluator 
   //----------------------------------------------------------------------------------------------   	
	function evaluatorDeliverablesAreReadyWithNotes(string _notes) onlyEvaluator public  {
		require(bytes(_notes).length > 0);
		
		isEvaluatorSolutionSubmitted = true;
		addNotes(_notes, 3);	
	}

	
	
		
   //------------------------------------------------  
   // Owner, contributor or evaluator can send notes 
   //------------------------------------------------
	function setNotes(string _notes) onlyParticipent  public {
		require(bytes(_notes).length > 0);
		
		addNotes(_notes, tempNoteSendBy);
	}

	
	
	
   //-------------------------------------------------------  
   // Owner can reject contributor deliverables with notes 
   //-------------------------------------------------------	
	function rejectContibutorTaskSubmissionAndSetNotes(string _notes) onlyOwner public {
		require(isContributorSolutionSubmitted == true);
		require(bytes(_notes).length > 0);
		
		isContributorSolutionSubmitted = false;
		addNotes(_notes, 1);	
	}

	
	
	
   //-------------------------------------------------------  
   // Owner can reject evaluator deliverables with notes 
   //-------------------------------------------------------
	function rejectEvaluatorTaskSubmissionAndSetNotes(string _notes) onlyOwner public {
		require(isEvaluatorSolutionSubmitted == true);
		require(bytes(_notes).length > 0);
		
		isEvaluatorSolutionSubmitted = false;
		addNotes(_notes, 1);	
	}

	
	

   //--------------------------------------------------------------------
   // Owner can finalized the contributor's submissions. 
   // This will call the projectt to transfer equity to contributor 
   //--------------------------------------------------------------------
	function markContributorTaskDoneAndTransferShare() onlyOwner public  {
		require(isContributorSolutionSubmitted == true);
		require(isContributorSolutionAcceptedAndSharesTransferred == false);
				
	    // call the project contract and transfer share/equity to contributor
		ProjectEquity receiver = ProjectEquity(projectAddress);
		require(receiver.shareTransferFrom(owner, contributorAddress, contributorProjectShares));		
		
		//Set variable that contributor submission is accepted and shares are transferred
		isContributorSolutionAcceptedAndSharesTransferred = true;
		
		//Generate event 
		emit ContributorTaskAccepted(owner, contributorAddress, contributorProjectShares);
	}
	
	
	
	
   //--------------------------------------------------------------------
   // Owner can finalized the evaluator's submissions. 
   // This will call the projectt to transfer equity to contributor 
   //--------------------------------------------------------------------
	function markEvaluatorTaskDoneAndTransferShare() onlyOwner public  {
		require(isEvaluatorSolutionSubmitted = true);
		require(isEvaluatorSolutionAcceptedAndSharesTransferred == false);
		
		// call the project contract and  transfer share/equity to evaluator 
		ProjectEquity receiver = ProjectEquity(projectAddress);
		require(receiver.shareTransferFrom(owner, evaluatorAddress, evaluatorProjectShares));
		
		//Set variable that evaluator submission is accepted and shares are transferred
		isEvaluatorSolutionAcceptedAndSharesTransferred = true;
		
		//Genetate event 
		emit EvaluatorTaskAccepted(owner, evaluatorAddress, evaluatorProjectShares);
	}



}