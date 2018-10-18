pragma solidity ^0.4.24;

import './contracts/ownership/Ownable.sol';
import './ProjectEquity.sol';

contract Incubator is Ownable {
	
	//-----------------------------------------------------------------------------------------------------
	// Incubator projects collection, Project structure and number of projects in this incubator. 
	// numberOfProjectsInThisIncubator contains number of projects in this incubator and this is 0 based
	// which means if value is 1 then first project contract is at 0 index in the mapping 
	//-----------------------------------------------------------------------------------------------------
	uint public numberOfProjectsInThisIncubator = 0;   
	struct projectsStruct {             				
		string projectName;
		address projectContractAddress;
		uint8 decimals;
		address projectOwner;
		address projectIncubatorOwner;
	}
	mapping (uint => projectsStruct) public incubatorProjects; 

	
	
	//-----------------------------------------------------------------------------------------------------
	// Events in this contract 
	//-----------------------------------------------------------------------------------------------------
	event ProjectCreatedEvent(uint ProjectID, string projectName );
	
	
	
	
	//-------------------------------------------------
	// Contract Constructor       
	//-------------------------------------------------
	constructor() public 
    {
		
	}
	
	


	//-----------------------------------------------------------------------------------------
	// Add new project.   This interface will create a new project within this incubator
	//-----------------------------------------------------------------------------------------
	projectsStruct newProject;
	function addNewProject(
					string _projectName, 
					address _projectOwner,
					address _incubatorOwnerAddress,
					uint incubatorOwnerPercentageInProject, 
					address ventureFusionOwnerAddress, 
					uint ventureFusionPercentageInProject, 
					uint8 decimals
				) public onlyOwner 		
		returns ( uint newProjectID, 
				  address projectAddress, 
				  string projectName
				)
	{
		//Create new project contract
		address newProjectContract = new ProjectEquity(_projectOwner, _incubatorOwnerAddress, incubatorOwnerPercentageInProject, ventureFusionOwnerAddress, ventureFusionPercentageInProject, decimals);
		
		//Create project structure object and add it to projects collection
		newProject = projectsStruct(_projectName, newProjectContract, decimals, _projectOwner, _incubatorOwnerAddress);
		incubatorProjects[numberOfProjectsInThisIncubator] = newProject;
		
		//Transfer ownership to project owner
		require(newProjectContract.call(bytes4(keccak256("transferOwnership(address)")),_projectOwner));
		
		//Emit event that project has been created 
		emit ProjectCreatedEvent(numberOfProjectsInThisIncubator, _projectName);
		
		//Increment counter for next new project
		numberOfProjectsInThisIncubator = numberOfProjectsInThisIncubator + 1;
		
		//Set return values of this function 
		newProjectID = numberOfProjectsInThisIncubator;
		projectAddress = newProject.projectContractAddress;
		projectName = _projectName;
	}



}

