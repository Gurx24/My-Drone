# 无人机系统仿真

参考的开源项目[XTDrone](https://github.com/robin-shaun/XTDrone).



## 仿真环境介绍

| 操作系统       | ubuntu20.04 |
| -------------- | ----------- |
| ROS            | noetic      |
| Gazebo         | 11          |
| PX4            | 1.13.2      |
| QGroundControl | 4.4.4       |



## 控制无人机

在终端启动gazebo仿真环境后输入以下命令

```bash
cd ~/My-Drone/communication/
python multirotor_communication.py iris 0
```

后面参数表示与0号iris机型建立通信

```bash
cd ~/My-Drone/control/keyboard
python multirotor_keyboard_control.py iris 1 vel
```

solo代表子机型，1代表飞机的个数，vel代表速度控制。虽然多旋翼飞行器提供了速度控制和加速度控制两种键盘控制方式，但手动控制速度比较方便，加速度控制在后面的高级运动规划任务中比较有用。

通过键盘控制1架iris的解锁/上锁(arm/disarm)，修改飞行模式，飞机速度等。使用v起飞利用的是takeoff飞行模式，相关参数（起飞速度、高度）要在rcS中设置。一般可以使用offboard模式起飞，这时起飞速度要大于0.3m/s才能起飞(即：upward velocity 需要大于0.3)。注意，飞机要先解锁才能起飞！飞到一定高度后可以切换为‘hover’模式悬停，再运行自己的飞行脚本，或利用键盘控制飞机。

推荐起飞流程，按i把向上速度加到0.3以上，再按b切offboard模式，最后按t解锁。



## PX4飞控EKF配置

 

- 直接修改编译后的rcS文件

  ```bash
  gedit ~/PX4_Firmware/build/px4_sitl_default/etc/init.d-posix/rcS
  ```



- 修改参数

  通过注释来修改不同的参数

  ```txt
  	# GPS used
  	#param set EKF2_AID_MASK 1
  	# Vision used and GPS denied
  	param set EKF2_AID_MASK 24
  
  	# Barometer used for hight measurement
  	#param set EKF2_HGT_MODE 0
  	# Barometer denied and vision used for hight measurement
  	param set EKF2_HGT_MODE 3
  ```

- 删除原参数配置文件

  重启仿真前，需要删除上一次记录在虚拟eeprom中的参数文件，否则仿真程序会读取该参数文件，导致本次rcS的修改不能生效

  ```bash
  rm ~/.ros/eeprom/parameters*
  rm -rf ~/.ros/sitl*
  ```



## 多旋翼姿态控制

 

1.XTDrone的所有示例对于多旋翼无人机的控制都是位置/速度/加速度控制

2.姿态控制的控制指令发送给

`mavros/setpoint_raw/attitude`

该话题有两种控制方式①角度+油门；②角速度+油门。只能选择其中一种控制方式，并需要设置好掩码（详细请看代码）。

3.该示例的代码使用的是PID控制，读者根据需要可以自行利用其他方法设计控制器。示例的PID参数并没有严格调整过，可能不适用于所有的控制目标。

4.该教程内的偏航角设置为0方可使用，对于不同的偏航角请读者根据自己的控制想法进行设计。

5.该控制代码中限制了最大姿态角（0.3弧度），读者可自行修改（搜索“angle_max”可以修改限幅）。

6.该程序对两种控制方式①角度+油门②角速度+油门

 



启动一个仿真场景，由于该示例姿态变化剧烈，建议使用GPS定位方式

本示例把通信和控制合在一个脚本中

```bash
roslaunch px4 indoor1.launch
python attitude_contorl_demo.py iris angular_speed #或angle
```



## SLAM



## 运动规划

