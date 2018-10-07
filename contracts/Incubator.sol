pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract Incubator is Ownable {
	
	uint public incubatorOwnerPercentageInProject;
	uint public transactionPriceInTokens;

	
	uint public numberOfProjectsInThisIncubator = 0;   //current number of project in this incubator
	struct projectsStruct {             //project structure
		string projectName;
		address projectContractAddress;
	}
	mapping (uint => projectsStruct) public incubatorProjects;     //mapping of projects
	
	
	event ProjectCreatedEvent(string projectName, uint ProjectNo);
	
	
	constructor(uint _projectPercentage, uint _transactionPriceInTokens) public {
		incubatorOwnerPercentageInProject = _projectPercentage;
		transactionPriceInTokens = _transactionPriceInTokens;
	}
	
	
	//-------------------------------------------------
	// Change the percentages owned by VentureFusion when creating a new project  
	//-------------------------------------------------
	function changeProjectPercentage(uint _projectPercentage) public onlyOwner {	
		incubatorOwnerPercentageInProject = _projectPercentage;
	}
	
	
	//-------------------------------------------------
	// This interface will be called by the VentureFusion admin and will set the number of tokens required to perform 
    // each transaction in this incubator. For exmaple to launch SellBuy shares needs 4 VET tokens  	
	//-------------------------------------------------
	function setVETTokenTransactionPrice(uint _transactionPriceInTokens) public onlyOwner {
		transactionPriceInTokens = _transactionPriceInTokens;
	}


	

	projectsStruct newProject;
	//-------------------------------------------------
	// Add new project.   This will create a new project within this incubator
	//-------------------------------------------------
	function addNewProject(string _projectName) 
		public onlyOwner 
		returns ( uint newProjectID, address projectAddress, string projectName )  
	{
		address newProjectContract = new ProjectEquity(incubatorOwnerPercentageInProject);

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

