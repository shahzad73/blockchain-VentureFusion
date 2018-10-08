pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract Incubator is Ownable {
	
	uint public incubatorOwnerPercentageInProject;
	
	uint public ventureFusionPercentageInProject;
	address internal ventureFusionOwnerAddress;
	
	uint public transactionPriceInTokens;

	event changeIncubatorOwnerProjectPercentageEvent(uint oldPercentage, uint percentage);
	event changeVentureFusionProjectPercentageEvent(uint oldPercentage, uint percentage);
	event changeVETTokenForTransactionsEvent(uint oldPrice, uint price);
	
	
	uint public numberOfProjectsInThisIncubator = 0;   //current number of project in this incubator
	struct projectsStruct {             //project structure
		string projectName;
		address projectContractAddress;
	}
	mapping (uint => projectsStruct) public incubatorProjects;     //mapping of projects
	
	
	event ProjectCreatedEvent(string projectName, uint ProjectNo);
	
	
	constructor( 
	     uint _incubatorOwnerPercentageInProject, 
		 uint _ventureFusionPercentageInProject,
		 address _ventureFusionOwnerAddress,
		 uint _transactionPriceInTokens ) 
    public 
    {
		incubatorOwnerPercentageInProject = _incubatorOwnerPercentageInProject;
		ventureFusionPercentageInProject = _ventureFusionPercentageInProject;
		transactionPriceInTokens = _transactionPriceInTokens;
		ventureFusionOwnerAddress = _ventureFusionOwnerAddress;
	}
	
	
	
	
	//-------------------------------------------------
	// Check that only venture fusion owner is calling this function
	//-------------------------------------------------
	modifier onlyVentureFusionOwner() {
		require(msg.sender == ventureFusionOwnerAddress);
		_;
	}	
	

	//-------------------------------------------------
	// Change the percentages owned by incubator owner when creating a new project
	//-------------------------------------------------
	function changeIncubatorOwnerProjectPercentage(uint _projectPercentage) public onlyVentureFusionOwner {	
		emit changeIncubatorOwnerProjectPercentageEvent(incubatorOwnerPercentageInProject, _projectPercentage);
		incubatorOwnerPercentageInProject = _projectPercentage;
	}
	
	
	
	//-------------------------------------------------
	// Change the percentages owned by VentureFusion when creating a new project  
	//-------------------------------------------------
	function changeVentureFusionProjectPercentage(uint _projectPercentage) public onlyVentureFusionOwner {	
		emit changeVentureFusionProjectPercentageEvent(ventureFusionPercentageInProject, _projectPercentage);
		ventureFusionPercentageInProject = _projectPercentage;
	}
	
	
	//-------------------------------------------------
	// This interface will be called by the VentureFusion admin and will set the number of tokens required to perform 
    // each transaction in this incubator. For exmaple to launch SellBuy shares needs 4 VET tokens  	
	//-------------------------------------------------
	function changeVETTokenForTransactions(uint _transactionPriceInTokens) public onlyOwner {
		emit changeVETTokenForTransactionsEvent(transactionPriceInTokens, _transactionPriceInTokens);
		transactionPriceInTokens = _transactionPriceInTokens;
	}




	projectsStruct newProject;
	//-------------------------------------------------
	// Add new project.   This will create a new project within this incubator
	//-------------------------------------------------
	function addNewProject(string _projectName, address _projectOwner) 
		public onlyOwner 
		returns ( uint newProjectID, address projectAddress, string projectName )  
	{
		address newProjectContract = new ProjectEquity(_projectOwner, incubatorOwnerPercentageInProject, ventureFusionPercentageInProject);

		newProject = projectsStruct(_projectName, newProjectContract);
		incubatorProjects[numberOfProjectsInThisIncubator] = newProject;

		//set return values 
		newProjectID = numberOfProjectsInThisIncubator;
		projectAddress = newProject.projectContractAddress;
		projectName = _projectName;
		
		emit ProjectCreatedEvent(_projectName, numberOfProjectsInThisIncubator);
		
		//increment the counter for next new project
		numberOfProjectsInThisIncubator = numberOfProjectsInThisIncubator + 1;
	}


}

