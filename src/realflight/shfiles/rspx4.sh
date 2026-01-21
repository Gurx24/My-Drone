sudo chmod 777 /dev/ttyTHS0 & sleep 2;
roslaunch realsense2_camera rs_camera.launch & sleep 10;
roslaunch mavros px4_THS0.launch & sleep 10;
roslaunch vins first_drone.launch
wait;
