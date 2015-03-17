/***************************************************************************//**
 * \file solveStructure.inl
 * \author Christopher Minar
 * \brief Implementation of the methods of the class \c TCFSISolver
 *        to solve the structure equation on the bodies and solve for the new position
 */

//#include <solvers/NavierStokes/kernels/solveStructure.h>

//#define BLOCKSIZE 256

/**
 * \brief calculate new position
 * \	  strong coupling
 */

template <typename memoryType>
void TCFSISolver<memoryType>::solveStructure()
{
	NavierStokesSolver<memoryType>::logger.startTimer("solveStructure");
	//
	//d^2x
	//____  = F
	// t^2
	//discretize to...
	// Xk+1 - Xn        1     
	//___________   =   _ * (Thetak+1 + Thetan)
	//      dt          2

	//Thetak+1-Thetan   1
	//___________   =   _ * (F+Fo)
	//      dt          2

	parameterDB  &db = *NavierStokesSolver<memoryType>::paramDB;
	real dt  = db["simulation"]["dt"].get<real>();
	//real dx  = NavierStokesSolver<memoryType>::domInfo->dx[ NSWithBody<memoryType>::B.I[0] ];
	real alpha_ = .5;
	real ratio = 1; //rhofluid/rhosolid;

	//this loop could probably be done on the gpu
	real forcex;
	//real forcexo;
	     //forcey;
	forcex = NSWithBody<memoryType>::B.forceX[0];//  /  (NSWithBody<memoryType>::B.totalPoints);
	//forcexo=NSWithBody<memoryType>::B.forceXold[0];
	//forcey = NSWithBody<memoryType>::B.forceY[0]/NSWithBody<memoryType>::B.totalPoints;

	//find new velocities and positions
	for (int i = 0; i < NSWithBody<memoryType>::B.totalPoints; i++){//this should be done on the gpu
		//new velocity
		NSWithBody<memoryType>::B.uBkp1[i] = alpha_*(NSWithBody<memoryType>::B.uB[i] + ratio*dt*(forcex)) + (1-alpha_)*NSWithBody<memoryType>::B.uBk[i];
		//NSWithBody<memoryType>::B.uBkp1[i] = NSWithBody<memoryType>::B.uB[i] + ratio*dt*(forcex);
		//NSWithBody<memoryType>::B.vBkp1[i] =
		//new position
		NSWithBody<memoryType>::B.xk[i] = NSWithBody<memoryType>::B.x[i] + (NSWithBody<memoryType>::B.uB[i]+NSWithBody<memoryType>::B.uBkp1[i])*dt*0.5;
		//NSWithBody<memoryType>::B.yk[i] = 
	}
	//std::cout<<NSWithBody<memoryType>::B.uB[0]<<"\t"<<NSWithBody<memoryType>::B.uBk[0]<<std::endl;
	NavierStokesSolver<memoryType>::logger.stopTimer("solveStructure");
}