/***************************************************************************//**
 * \file  luoIBM.cu
 * \author Christopher Minar (minarc@oregonstate.edu)
 * \based on code by Anush Krishnan (anush@bu.edu)
 * \brief Declaration of the class oscCylinder.
 */

#include "luoIBM.h"
#include <sys/stat.h>

/**
 * \brief Constructor. Copies the database and information about the computational grid.
 *
 * \param pDB database that contains all the simulation parameters
 * \param dInfo information related to the computational grid
 */
luoIBM::luoIBM(parameterDB *pDB, domain *dInfo)
{
	paramDB = pDB;
	domInfo = dInfo;
}

/*
 * Initialise the solver
 */
void luoIBM::initialise()
{

	NavierStokesSolver::initialiseNoBody();
	NavierStokesSolver::logger.startTimer("initialise");

	int nx = NavierStokesSolver::domInfo->nx,
		ny = NavierStokesSolver::domInfo->ny;

	int numUV = (nx-1)*ny + nx*(ny-1);
	int numP  = nx*ny;
	////////////////////////////////////////////////////////////////////////////////////////////////
	//ARRAYS
	////////////////////////////////////////////////////////////////////////////////////////////////
	//tagpoints, size numuv
	ustar.resize(numUV);
	ghostTagsUV.resize(numUV);
	hybridTagsUV.resize(numUV);
	hybridTagsUV2.resize(numUV);
	x1.resize(numUV);
	x2.resize(numUV);
	y1.resize(numUV);
	y2.resize(numUV);
	body_intercept_x.resize(numUV);
	body_intercept_y.resize(numUV);
	image_point_x.resize(numUV);
	image_point_y.resize(numUV);
	distance_from_intersection_to_node.resize(numUV);
	distance_between_nodes_at_IB.resize(numUV);
	uv.resize(numUV);

	//tagpoints, size nump
	ghostTagsP.resize(numP);
	hybridTagsP.resize(numP);
	distance_from_u_to_body.resize(numP);
	distance_from_v_to_body.resize(numP);

	////////////////////////////////////////////////////////////////////////////////////////////////
	//Initialize Bodies
	////////////////////////////////////////////////////////////////////////////////////////////////
	B.initialise((*paramDB), *domInfo);
	std::cout << "Initialised bodies!" << std::endl;

	/////////////////////////////////////////////////////////////////////////////////////////////////
	//TAG POINTS
	/////////////////////////////////////////////////////////////////////////////////////////////////
	tagPoints();
	std::cout << "Tagged points!" << std::endl;

	/////////////////////////////////////////////////////////////////////////////////////////////////
	//LHS
	/////////////////////////////////////////////////////////////////////////////////////////////////
	initialiseLHS();

	/////////////////////////////////////////////////////////////////////////////////////////////////
	//OUTPUT
	/////////////////////////////////////////////////////////////////////////////////////////////////
	parameterDB  &db = *NavierStokesSolver::paramDB;
	std::string folder = db["inputs"]["caseFolder"].get<std::string>();
	std::stringstream out;
	out << folder << "/forces";
	forceFile.open(out.str().c_str());

	logger.stopTimer("initialise");
}

/*
 * Initialise the LHS matricies
 */
void luoIBM::initialiseLHS()
{
	parameterDB  &db = *NavierStokesSolver::paramDB;
	generateLHS1();
	generateLHS2();

	NavierStokesSolver::PC.generate(NavierStokesSolver::LHS1,NavierStokesSolver::LHS2, db["velocitySolve"]["preconditioner"].get<preconditionerType>(), db["PoissonSolve"]["preconditioner"].get<preconditionerType>());
	std::cout << "Assembled LUO LHS matrices!" << std::endl;
}

/**
 * \brief Writes data into files.
 */
void luoIBM::writeData()
{
	parameterDB  &db = *NavierStokesSolver::paramDB;
	double dt  = db["simulation"]["dt"].get<double>();

	logger.startTimer("output");

	writeCommon();
	//calculateForce();
	if (NavierStokesSolver::timeStep == 0)
		forceFile<<"timestep\tFx\tFxX\tFxY\tFxU\tFy\n";
	forceFile << timeStep*dt << '\t' << B.forceX[0] << '\t'<<fxx<<"\t"<<fxy<<"\t"<<fxu<<"\t" << B.forceY[0] << std::endl;

	logger.stopTimer("output");
}

/**
 * \brief Writes numerical solution at current time-step,
 *        as well as the number of iterations performed in each solver.
 */
void luoIBM::writeCommon()
{
	NavierStokesSolver::writeCommon();
	parameterDB  &db = *NavierStokesSolver::paramDB;
	int nsave = db["simulation"]["nsave"].get<int>();
	std::string folder = db["inputs"]["caseFolder"].get<std::string>();

	// write body output
	if (timeStep % nsave == 0)
	{
		B.writeToFile(folder, NavierStokesSolver::timeStep);
	}

	// write the number of iterations for each solve
	iterationsFile << timeStep << '\t' << iterationCount1 << '\t' << iterationCount2 << std::endl;
}

/**
 * \brief Calculates the variables at the next time step.
 */
void luoIBM::stepTime()
{
	generateRHS1();
	NavierStokesSolver::solveIntermediateVelocity();
	arrayprint(uhat,"uhat","x");
	arrayprint(ghostTagsUV,"gn","x");

	generateRHS2();
	NavierStokesSolver::solvePoisson();

	velocityProjection();

	std::cout<<timeStep<<std::endl;
	NavierStokesSolver::timeStep++;
}

/**
 * \brief Prints timing information and closes the different files.
 */
void luoIBM::shutDown()
{
	NavierStokesSolver::shutDown();
	forceFile.close();
}

#include "luoIBM/intermediateVelocity.inl"
#include "luoIBM/intermediatePressure.inl"
#include "luoIBM/projectVelocity.inl"
#include "luoIBM/tagpoints.inl"
//#include "luoIBM/calculateForce.inl"
//#include "luoIBM/checkTags.inl"