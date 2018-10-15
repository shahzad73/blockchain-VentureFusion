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
		return ev.projectName == "Test Proj 101" && ev.ProjectID == 0;
     });

  });


  
  
  it("Create a new task in the project and accept task from contributor", async () => {
	 
	 const ventureFusionAccount = accounts[0];        //2000 shares 
	 const incubatorOwner1 = accounts[1];             //3000 shares
	 const projectOwner = accounts[3];                //9500 shares 
	 const contributor = accounts[5];                //0 shares 
	 const evaluator = accounts[6];                //0 shares 	 
	 
	 const meta = await Incubator.deployed();

	 var projectAddress = await meta.incubatorProjects(0);	 
	 var project = await projectEquity.at(projectAddress[1]);
	 
	 
	 //Add a new task in the project 
	 let tx = await project.launchNewTask("Task 1", 100, 20, {from : projectOwner});
	 var tmpNumber = await project.numberOfTotalTasksInArray();
	 assert.equal(tmpNumber.valueOf(), 1, "Expected value 1 was not returned");	 
	 
	 //get added task and test its parameters 
	 var taskAddress = await project.tasksAddresses(0);	 
	 var task = await projectTask.at(taskAddress);
	 
	 //check that this Task has access to 100+20 tokens to transferon on behalf of the 
	 tmpNumber = await project.shareAllowance(projectOwner, taskAddress);
	 assert.equal(tmpNumber.valueOf(), 120, "Expected value 100 was not returned");

	 
	 tmpNumber = await task.contributorProjectShares();
	 assert.equal(tmpNumber.valueOf(), 100, "Expected value 100 was not returned");	 
	 
	 tmpNumber = await task.evaluatorProjectShares();
	 assert.equal(tmpNumber.valueOf(), 20, "Expected value 10 was not returned");	 	 
	 
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
	 assert.equal(var1[1], 1, "Expected value 0 was not returned");
	 
	 
	 //now notes from contributor 
	 tx = await task.setNotes("Cont 1", {from : contributor});
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 2, "Expected value 2 was not returned");
	 //get the contributor note and test it was equal to Note 1
	 var1 = await task.taskNotes(1);
	 assert.equal(var1[0], "Cont 1", "Expected value Cont 1 was not returned");
	 assert.equal(var1[1], 2, "Expected value 1 was not returned");
	 
	 
	 //now notes from Evaluator
	 tx = await task.setNotes("Eva 1", {from : evaluator});
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 3, "Expected value 3 was not returned");
	 //get the evaluator note and test it was equal to Note 1
	 var1 = await task.taskNotes(2);
	 assert.equal(var1[0], "Eva 1", "Expected value Cont 1 was not returned");
	 assert.equal(var1[1], 3, "Expected value 1 was not returned");
	 
	 
	 
	 
	 
	 
	 
	 

	 //---------------------------------------------------
	 //    test isContributorSolutionSubmitted is false
	 //---------------------------------------------------
	 tmpNumber = await task.isContributorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");	 
	 //now send a project proposal submission from contributor 
	 tx = await task.contributorDeliverablesAreReadyWithNotes("Submission 1", {from : contributor});
     //now check that contract has set task complete from contributor
	 tmpNumber = await task.isContributorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");	 
	 //also check that note has been added 
	 var1 = await task.taskNotes(3);
	 assert.equal(var1[0], "Submission 1", "Expected value Submission 1 was not returned");	 
	 assert.equal(var1[1], 2, "Expected value 1 was not returned");
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 4, "Expected value 4 was not returned");


	 //now reject project proposal submission from contributor 
	 tx = await task.rejectContibutorTaskSubmissionAndSetNotes("Rejection 1", {from : projectOwner});
	 //now check that contract has set task complete from contributor
	 tmpNumber = await task.isContributorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");	 
	 //also check that note has been added 
	 var1 = await task.taskNotes(4);
	 assert.equal(var1[0], "Rejection 1", "Expected value Submission 1 was not returned");	 
	 assert.equal(var1[1], 1, "Expected value 0 was not returned");
	 var1 = await task.numberOfTaskNotes();
	 assert.equal(var1, 5, "Expected value 5 was not returned");


	 //check that contributor balanace is 0 before accepting his task and tasnferring token 
	 var share1 = await project.shareBalanceOf(contributor);
	 assert.equal(share1.valueOf(), 0, "0 decimals should be returned"); 	 


	 //now accept proposal send by contributor
	 tmpNumber = await task.isContributorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");
	 tx = await task.contributorDeliverablesAreReadyWithNotes("Submission 2", {from : contributor});
	 tmpNumber = await task.isContributorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");
	 
	 tmpNumber = await task.isContributorSolutionAcceptedAndSharesTransferred();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");
	 
	 tx = await task.markContributorTaskDoneAndTransferShare({from : projectOwner});	 
     truffleAssert.eventEmitted(tx, 'ContributorTaskAccepted', (ev) => {
	 	//console.log( "PO:" + ev.owner + "  Con:" + ev.contributor + "  TA:" + ev.taskAddress);
		return true;
     });
	 
	 tmpNumber = await task.isContributorSolutionAcceptedAndSharesTransferred();	 
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");
	 
	 //check that tokens are transferred to contributor 
	 var share1 = await project.shareBalanceOf(contributor);
	 assert.equal(share1.valueOf(), 100, "100 decimals should be returned . . "); 	 
	 
	 
	 //Check that this Task has now access to only 20 tokens to transfer on behalf of owner 
	 tmpNumber = await project.shareAllowance(projectOwner, taskAddress);
	 assert.equal(tmpNumber.valueOf(), 20, "Expected value 100 was not returned");
	 
	 
	 //---------------------------------------------------
	 //    test isEvaluatorSolutionSubmitted is false
	 //---------------------------------------------------
	 tmpNumber = await task.isEvaluatorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");	 
	 //now send a project proposal submission from evaluator 
	 tx = await task.evaluatorDeliverablesAreReadyWithNotes("Submission 1", {from : evaluator});
     //now check that contract has set task complete from evaluator
	 tmpNumber = await task.isEvaluatorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");	 
	 //also check that note has been added 
	 var1 = await task.numberOfTaskNotes();	 
	 var1 = await task.taskNotes(var1 - 1);
	 assert.equal(var1[0], "Submission 1", "Expected value Submission 1 was not returned");	 
	 assert.equal(var1[1], 3, "Expected value 1 was not returned");

	 
	 
	 //now reject project proposal submission from evaluator 
	 tx = await task.rejectEvaluatorTaskSubmissionAndSetNotes("Rejection 123", {from : projectOwner});
	 //now check that contract has set task complete from evaluator
	 tmpNumber = await task.isEvaluatorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");	 
	 //also check that note has been added 
	 var1 = await task.numberOfTaskNotes();	 
	 var1 = await task.taskNotes(var1 - 1);
	 assert.equal(var1[0], "Rejection 123", "Expected value Rejection 123 was not returned");	 
	 assert.equal(var1[1], 1, "Expected value 1 was not returned");


	 //check that evaluator balanace is 0 before accepting his task and tasnferring token 
	 var share1 = await project.shareBalanceOf(evaluator);
	 assert.equal(share1.valueOf(), 0, "0 decimals should be returned"); 	 


	 //now accept proposal send by evaluator 
	 tmpNumber = await task.isEvaluatorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");
	 tx = await task.evaluatorDeliverablesAreReadyWithNotes("Submission 2", {from : evaluator});
	 tmpNumber = await task.isEvaluatorSolutionSubmitted();
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");
	 
	 tmpNumber = await task.isEvaluatorSolutionAcceptedAndSharesTransferred();
	 assert.equal(tmpNumber.valueOf(), false, "Expected value false was not returned");
	 
	 tx = await task.markEvaluatorTaskDoneAndTransferShare({from : projectOwner});	 
     truffleAssert.eventEmitted(tx, 'EvaluatorTaskAccepted', (ev) => {
	 	//console.log( "PO:" + ev.owner + "  Con:" + ev.evaluator + "  TA:" + ev.taskAddress);
		return true;
     });

	 tmpNumber = await task.isEvaluatorSolutionAcceptedAndSharesTransferred();	 
	 assert.equal(tmpNumber.valueOf(), true, "Expected value true was not returned");

	 //check that tokens are transferred to evaluator 
	 var share1 = await project.shareBalanceOf(evaluator);
	 assert.equal(share1.valueOf(), 20, "20 decimals should be returned . . "); 	 
	 

	 //Check that this Task has now access to only 20 tokens to transfer on behalf of owner 
	 tmpNumber = await project.shareAllowance(projectOwner, taskAddress);
	 assert.equal(tmpNumber.valueOf(), 0, "Expected value 0 was not returned");
	 
	 
	 
  });
  
  
  
  
  
  
  
  afterEach(async () => {

  });

  

  
})
