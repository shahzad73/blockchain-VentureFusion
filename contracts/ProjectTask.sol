pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract ProjectTask is Ownable {

   string public taskTitle;
   address public projectAddress;

   address public contributorAddress;
   uint public contributorProjectShares;
   bool public isContributorSolutionSubmitted = false;
   bool public isContributorSolutionAcceptedAndSharesTransferred = false;

   address public evaluatorAddress;
   uint public evaluatorProjectShares;
   bool public isEvaluatorSolutionSubmitted = false;
   bool public isEvaluatorSolutionAcceptedAndSharesTransferred = false;

   uint tempNoteSendBy = 0;
   
   uint public numberOfTaskNotes = 0;   //current number of notes
   struct taskNoteStruct {             //project structure
		string notes;
		uint sendBy;       // 1=Owner     2=Contributor     3=Evaluator
   }
   mapping (uint => taskNoteStruct) public taskNotes;     //mapping of task notes    

	
   event ContributorTaskAccepted(address owner, address contributor, address taskAddress);
	
   
   constructor(
	  string _taskTitle,
	  address _contributorAddress,
	  uint _contributorProjectShares,
	  address _evaluatorAddress,
	  uint _evaluatorProjectShares,
	  address _projectAddress
   )
   public {
      taskTitle = _taskTitle;
	  contributorAddress = _contributorAddress;
 	  contributorProjectShares = _contributorProjectShares;
	  evaluatorProjectShares = _evaluatorProjectShares;
	  evaluatorAddress = _evaluatorAddress;
	  projectAddress = _projectAddress;
   }


   
  modifier onlyContributor() {
    require(msg.sender == contributorAddress);
    _;
  }
   
   
  modifier onlyEvaluator() {
    require(msg.sender == evaluatorAddress);
    _;
  }
  
  
  modifier onlyParticipent () {
     require(msg.sender == contributorAddress || msg.sender == evaluatorAddress || msg.sender == owner);
	 if(msg.sender == owner) 
	    tempNoteSendBy = 0;
	 if(msg.sender == contributorAddress) 
	    tempNoteSendBy = 1;
	 if(msg.sender == evaluatorAddress) 
	    tempNoteSendBy = 2;
	 _;
  }
   


   
	function setContributorAddress(address _address) onlyOwner public {
	   require(isContributorSolutionAcceptedAndSharesTransferred == false);		
	   contributorAddress = _address;
	}
	
	function setEvaluatorAddress(address _address) onlyOwner public  {
	   require(isEvaluatorSolutionAcceptedAndSharesTransferred == false);		
	   evaluatorAddress = _address;
	}

	
	taskNoteStruct newNotes;
	function addNotes (string _note, uint _sendBy) public
	{
		newNotes = taskNoteStruct(_note, _sendBy);
		taskNotes[numberOfTaskNotes] = newNotes;
		numberOfTaskNotes = numberOfTaskNotes + 1;
	}



	function contributorDeliverablesAreReadyWithNotes(string _notes) onlyContributor public  {
		require(bytes(_notes).length > 0);
		isContributorSolutionSubmitted = true;
		addNotes(_notes, 2);
	}


	function evaluatorDeliverablesAreReadyWithNotes(string _notes) onlyEvaluator public  {
		require(bytes(_notes).length > 0);
		isEvaluatorSolutionSubmitted = true;
		addNotes(_notes, 3);	
	}


	function setNotes(string _notes) onlyParticipent  public {
		require(bytes(_notes).length > 0);
		addNotes(_notes, tempNoteSendBy);
	}

	function rejectContibutorTaskSubmissionAndSetNotes(string _notes) onlyOwner public {
		require(isContributorSolutionSubmitted == true);
		require(bytes(_notes).length > 0);
		isContributorSolutionSubmitted = false;
		addNotes(_notes, 1);	
	}

	function rejectEvaluatorTaskSubmissionAndSetNotes(string _notes) onlyOwner public {
		require(isEvaluatorSolutionSubmitted == true);
		require(bytes(_notes).length > 0);
		isEvaluatorSolutionSubmitted = false;
		addNotes(_notes, 1);	
	}



	function markContributorTaskDoneAndTransferShare() onlyOwner public  {
		require(isContributorSolutionSubmitted == true);
		require(isContributorSolutionAcceptedAndSharesTransferred == false);
		
		//transfer contributor tokens to him
		//require(projectAddress.call(bytes4(keccak256("shareTransferFrom(address, address, uint)")), owner, contributorAddress, contributorProjectShares));
		
		ProjectEquity receiver = ProjectEquity(projectAddress);
		receiver.shareTransferFrom(owner, contributorAddress, contributorProjectShares);		
		
		isContributorSolutionAcceptedAndSharesTransferred = true;
		
		emit ContributorTaskAccepted(owner, contributorAddress, address(this));
	}
	
	function markEvaluatorTaskDoneAndTransferShare() onlyOwner public  {
		require(isEvaluatorSolutionSubmitted = true);
		require(isEvaluatorSolutionAcceptedAndSharesTransferred == false);
		isEvaluatorSolutionAcceptedAndSharesTransferred = true;
	}



}