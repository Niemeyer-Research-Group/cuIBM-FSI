#include <solvers/NavierStokes/luo_base.h>

void luo_base::cast()
{

	//resize stuff
	pressureStar.resize(numP);
	ustar.resize(numUV);
	ghostTagsUV.resize(numUV);
	hybridTagsUV.resize(numUV);
	hybridTagsUV2.resize(numUV);
	body_intercept_x.resize(numUV);
	body_intercept_y.resize(numUV);
	image_point_x.resize(numUV);
	image_point_y.resize(numUV);
	body_intercept_p_x.resize(numP);
	body_intercept_p_y.resize(numP);
	body_intercept_p.resize(numP);
	image_point_p_x.resize(numP);
	image_point_p_y.resize(numP);
	distance_from_intersection_to_node.resize(numUV);
	distance_between_nodes_at_IB.resize(numUV);
	uv.resize(numUV);

	//testing
	x1_ip.resize(numUV);
	x2_ip.resize(numUV);
	y1_ip.resize(numUV);
	y2_ip.resize(numUV);
	x1_ip_p.resize(numP);
	x2_ip_p.resize(numP);
	y1_ip_p.resize(numP);
	y2_ip_p.resize(numP);
	image_point_u.resize(numUV);
	x1.resize(numUV);
	x2.resize(numUV);
	x3.resize(numUV);
	x4.resize(numUV);
	y1.resize(numUV);
	y2.resize(numUV);
	y3.resize(numUV);
	y4.resize(numUV);
	q1.resize(numUV);
	q2.resize(numUV);
	q3.resize(numUV);
	q4.resize(numUV);
	x1_p.resize(numP);
	x2_p.resize(numP);
	x3_p.resize(numP);
	x4_p.resize(numP);
	y1_p.resize(numP);
	y2_p.resize(numP);
	y3_p.resize(numP);
	y4_p.resize(numP);
	q1_p.resize(numP);
	q2_p.resize(numP);
	q3_p.resize(numP);
	q4_p.resize(numP);
	a0.resize(numP);
	a1.resize(numP);
	a2.resize(numP);
	a3.resize(numP);

	//tags
	ghostTagsP.resize(numP);
	hybridTagsP.resize(numP);
	distance_from_u_to_body.resize(numP);
	distance_from_v_to_body.resize(numP);

	ghostTagsUV_r 						= thrust::raw_pointer_cast( &(ghostTagsUV[0]) );
	ghostTagsP_r						= thrust::raw_pointer_cast( &(ghostTagsP[0]) );
	hybridTagsUV_r						= thrust::raw_pointer_cast( &(hybridTagsUV[0]) );
	hybridTagsP_r						= thrust::raw_pointer_cast( &(hybridTagsP[0]) );
	hybridTagsUV2_r						= thrust::raw_pointer_cast( &(hybridTagsUV2[0]) );

	pressureStar_r						= thrust::raw_pointer_cast( &(pressureStar[0]) );
	ustar_r								= thrust::raw_pointer_cast( &(ustar[0]) );
	body_intercept_x_r					= thrust::raw_pointer_cast( &(body_intercept_x[0]) );
	body_intercept_y_r					= thrust::raw_pointer_cast( &(body_intercept_y[0]) );
	image_point_x_r						= thrust::raw_pointer_cast( &(image_point_x[0]) );
	image_point_y_r						= thrust::raw_pointer_cast( &(image_point_y[0]) );
	body_intercept_p_x_r				= thrust::raw_pointer_cast( &(body_intercept_p_x[0]) );
	body_intercept_p_y_r				= thrust::raw_pointer_cast( &(body_intercept_p_y[0]) );
	body_intercept_p_r					= thrust::raw_pointer_cast( &(body_intercept_p[0]) );
	image_point_p_x_r					= thrust::raw_pointer_cast( &(image_point_p_x[0]) );
	image_point_p_y_r					= thrust::raw_pointer_cast( &(image_point_p_y[0]) );
	distance_from_intersection_to_node_r= thrust::raw_pointer_cast( &(distance_from_intersection_to_node[0]) );
	distance_between_nodes_at_IB_r		= thrust::raw_pointer_cast( &(distance_between_nodes_at_IB[0]) );
	distance_from_u_to_body_r			= thrust::raw_pointer_cast( &(distance_from_u_to_body[0]) );
	distance_from_v_to_body_r			= thrust::raw_pointer_cast( &(distance_from_v_to_body[0]) );
	uv_r								= thrust::raw_pointer_cast( &(uv[0]) );

	x1_ip_r				= thrust::raw_pointer_cast( &(x1_ip[0]) );
	x2_ip_r				= thrust::raw_pointer_cast( &(x2_ip[0]) );
	y1_ip_r				= thrust::raw_pointer_cast( &(y1_ip[0]) );
	y2_ip_r				= thrust::raw_pointer_cast( &(y2_ip[0]) );
	x1_ip_p_r			= thrust::raw_pointer_cast( &(x1_ip_p[0]) );
	x2_ip_p_r			= thrust::raw_pointer_cast( &(x2_ip_p[0]) );
	y1_ip_p_r			= thrust::raw_pointer_cast( &(y1_ip_p[0]) );
	y2_ip_p_r			= thrust::raw_pointer_cast( &(y2_ip_p[0]) );
	image_point_u_r		= thrust::raw_pointer_cast( &(image_point_u[0]) );
	x1_r				= thrust::raw_pointer_cast( &(x1[0]) );
	x2_r				= thrust::raw_pointer_cast( &(x2[0]) );
	x3_r				= thrust::raw_pointer_cast( &(x3[0]) );
	x4_r				= thrust::raw_pointer_cast( &(x4[0]) );
	y1_r				= thrust::raw_pointer_cast( &(y1[0]) );
	y2_r				= thrust::raw_pointer_cast( &(y2[0]) );
	y3_r				= thrust::raw_pointer_cast( &(y3[0]) );
	y4_r				= thrust::raw_pointer_cast( &(y4[0]) );
	q1_r				= thrust::raw_pointer_cast( &(q1[0]) );
	q2_r				= thrust::raw_pointer_cast( &(q2[0]) );
	q3_r				= thrust::raw_pointer_cast( &(q3[0]) );
	q4_r				= thrust::raw_pointer_cast( &(q4[0]) );
	x1_p_r				= thrust::raw_pointer_cast( &(x1_p[0]) );
	x2_p_r				= thrust::raw_pointer_cast( &(x2_p[0]) );
	x3_p_r				= thrust::raw_pointer_cast( &(x3_p[0]) );
	x4_p_r				= thrust::raw_pointer_cast( &(x4_p[0]) );
	y1_p_r				= thrust::raw_pointer_cast( &(y1_p[0]) );
	y2_p_r				= thrust::raw_pointer_cast( &(y2_p[0]) );
	y3_p_r				= thrust::raw_pointer_cast( &(y3_p[0]) );
	y4_p_r				= thrust::raw_pointer_cast( &(y4_p[0]) );
	q1_p_r				= thrust::raw_pointer_cast( &(q1_p[0]) );
	q2_p_r				= thrust::raw_pointer_cast( &(q2_p[0]) );
	q3_p_r				= thrust::raw_pointer_cast( &(q3_p[0]) );
	q4_p_r				= thrust::raw_pointer_cast( &(q4_p[0]) );
	a0_r				= thrust::raw_pointer_cast( &(a0[0]) );
	a1_r				= thrust::raw_pointer_cast( &(a1[0]) );
	a2_r				= thrust::raw_pointer_cast( &(a2[0]) );
	a3_r				= thrust::raw_pointer_cast( &(a3[0]) );
}
