 source ~/kalibr_ws/src/imu_calib/devel/setup.bash
roslaunch imu_utils PX4.launch
rosbag play -r 200 ~/kalibr_ws/bag/imu/imu_1.bag

roslaunch realsense2_camera rs_camera.launch
source ~/kalibr_ws/src/kalibr/devel/setup.bash
rosrun topic_tools throttle messages /camera/infra1/image_rect_raw 4.0 /infra_left
rosrun topic_tools throttle messages /camera/infra2/image_rect_raw 4.0 /infra_right
rosbag record /infra_left /infra_right -O ~/kalibr_ws/bag/stereo/stereo.bag

rosrun kalibr kalibr_calibrate_cameras \
--target ~/kalibr_ws/bag/april_6x6_80x80cm.yaml \
--bag  ~/kalibr_ws/bag/stereo/stereo.bag \
--models pinhole-radtan pinhole-radtan \
--topics /infra_left /infra_right \
--show-extraction --approx-sync 0.1


# 联合标定
sudo chmod 777 /dev/ttyTHS0
roslaunch mavros px4_THS0.launch
rosrun topic_tools throttle messages /camera/infra1/image_rect_raw 20.0 /infra_left #左目设置20hz
rosrun topic_tools throttle messages /camera/infra2/image_rect_raw 20.0 /infra_right #右目设置20hz
rosbag record /infra_left /infra_right /mavros/imu/data_raw -O ~/kalibr_ws/bag/stereo_imu/imu_cam.bag

rosrun kalibr kalibr_calibrate_imu_camera \
--target ~/kalibr_ws/bag/april_6x6_80x80cm.yaml \
--cam ~/kalibr_ws/bag/stereo/stereo-camchain.yaml \
--imu ~/kalibr_ws/bag/imu/imu.yaml \
--bag ~/kalibr_ws/bag/stereo_imu/imu_cam.bag
