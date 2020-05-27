import rospy
import numpy as np
import casadi as ca
import time
from geometry_msgs.msg import Point32
from costmap_converter.msg import ObstacleArrayMsg, ObstacleMsg
from visualization_msgs.msg import MarkerArray, Marker
rospy.init_node('publish_MO_obs_node', anonymous=True)  # Initialize the ROS node

MO_init = np.array([[50.0, 1.0, ca.pi / 2, 0.5, 0.3],
                    [50.0, 6.5, 0.0, 0.5, 0.3],
                    [50.5, 2.5, ca.pi, 0.7, 0.2],
                    [50.0, -4.0, -ca.pi, 0.6, 0.3]])  # Define all the obstacles in the workspace.

n_MO = len(MO_init[:, 0])

pub = rospy.Publisher('/MO_Obstacles', ObstacleArrayMsg, queue_size=1)  # Setup the publisher and the topic
pub1 = rospy.Publisher('/visualization_marker', MarkerArray, queue_size=1)
rate = rospy.Rate(10)  # Define the publishing rate

MO_msg = ObstacleArrayMsg()  # Create a msg of type ObstacleArrayMsg
MO_msg.header.stamp = rospy.Time.now()
MO_msg.header.frame_id = '/map'
markerArray = MarkerArray()
for k in range(n_MO):
	MO_msg.obstacles.append(ObstacleMsg())
	MO_msg.obstacles[k].id = k
	MO_msg.obstacles[k].polygon.points = [Point32()]
	MO_msg.obstacles[k].polygon.points[0].x = MO_init[k, 0]
	MO_msg.obstacles[k].polygon.points[0].y = MO_init[k, 1]
	MO_msg.obstacles[k].radius = MO_init[k, 4]
	MO_msg.obstacles[k].orientation.z = MO_init[k, 2]
	MO_msg.obstacles[k].velocities.twist.linear.x = MO_init[k, 3]

while not rospy.is_shutdown():
	pub.publish(MO_msg)
	#pub1.publish(markerArray)
	print('It should be published now')
	time.sleep(10)
