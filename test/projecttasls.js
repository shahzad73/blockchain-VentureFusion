var Incubator = artifacts.require("./Incubator.sol");
var projectEquity = artifacts.require("./ProjectEquity.sol");
var projectTask = artifacts.require("./ProjectTask.sol");

const truffleAssert = require('truffle-assertions');

contract('Incubator', function(accounts) {


  beforeEach(async () => {

  });





  it("Create new project for testing", async () => {  
  
	const ventureFusionAccount = accounts[0];
	const incubatorOwner1 = accounts[1];
	const projectOwner = accounts[3];
	 
 	 var meta = await Incubator.deployed();

	 let tx = await meta.addNewProject("Test Proj 101", projectOwner, {from : incubatorOwner1});
     truffleAssert.eventEmitted(tx, 'ProjectCreatedEvent', (ev) => {
		return ev.projectName == "Test Proj 101" && ev.ProjectNo == 0;
     });

  });


  
  
  it("Create a new task in the project", async () => {
	 
	 const ventureFusionAccount = accounts[0];        //2000 shares 
	 const incubatorOwner1 = accounts[1];             //3000 shares
	 const projectOwner = accounts[3];                //9500 shares 
	 const contributor = accounts[5];                //0 shares 
	 const evaluator = accounts[6];                //0 shares 	 
	 
	 const meta = await Incubator.deployed();
	 	
	 var zz = await meta.incubatorProjects(0);	 
	 var project = await projectEquity.at(zz[1]);
	 
	 //Add a new task in the project 
	 let tx = await project.launchNewTask("Task 1", 100, 10, {from : projectOwner});
	 var tasksNos = await project.numberOfTotalTasksInArray();
	 assert.equal(tasksNos.valueOf(), 1, "Expected value 1 was not returned");	 
	 
	 //get added task and test its parameters 
	 zz = await project.tasksAddresses(0);	 
	 var task = await projectTask.at(zz);
	 
	 tasksNos = await task.contributorProjectShares();
	 assert.equal(tasksNos.valueOf(), 100, "Expected value 100 was not returned");	 
	 
	 tasksNos = await task.evaluatorProjectShares();
	 assert.equal(tasksNos.valueOf(), 10, "Expected value 10 was not returned");	 	 
	 
	 //set the contributor and check 
	 tx = await task.setContributorAddress(contributor, {from : projectOwner});
	 let var1 = await task.contributorAddress();
	 assert.equal(var1, contributor, "Expected value is contributor address was not returned");	 

	 //now set the evaluator and check 
	 tx = await task.setEvaluatorAddress(evaluator, {from : projectOwner});
	 var1 = await task.evaluatorAddress();
	 assert.equal(var1, evaluator, "Expected value is evaluator address was not returned");	 
	 
	 //set notes from project owner
	 tx = await task.setNotes("Note 1", {from : projectOwner});
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 1, "Expected value 1 was not returned");
	 //get the project owner note and test it was equal to Note 1
	 var1 = await task.taskNotes(0);
	 assert.equal(var1[0], "Note 1", "Expected value Notte 1 was not returned");
	 assert.equal(var1[1], 0, "Expected value 0 was not returned");
	 
	 
	 //now notes from contributor 
	 tx = await task.setNotes("Cont 1", {from : contributor});
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 2, "Expected value 2 was not returned");
	 //get the contributor note and test it was equal to Note 1
	 var1 = await task.taskNotes(1);
	 assert.equal(var1[0], "Cont 1", "Expected value Cont 1 was not returned");
	 assert.equal(var1[1], 1, "Expected value 1 was not returned");
	 
	 
	 //now notes from Evaluator
	 tx = await task.setNotes("Eva 1", {from : evaluator});
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 3, "Expected value 3 was not returned");
	 //get the evaluator note and test it was equal to Note 1
	 var1 = await task.taskNotes(2);
	 assert.equal(var1[0], "Eva 1", "Expected value Cont 1 was not returned");
	 assert.equal(var1[1], 2, "Expected value 1 was not returned");
	 
	 
	 
	 
  });
  
  
  
  
  
  
  
  afterEach(async () => {

  });

  

  
})