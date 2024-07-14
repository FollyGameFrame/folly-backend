#### 1、clone代码&更新依赖

```shell
$ git clone https://github.com/Drawmost/voyager-backend.git
$ go mod tidy
```

#### 2、启动项目所依赖的环境

```shell
$ docker network create voyager_net
$ docker-compose -f docker-compose-env.yml up -d
```
#### 3、导入数据
###### 3.1创建kafka topic
系统内使用了3个topic，默认是不允许程序自动创建topic的，进入kafka的容器创建3个topic
* 进入容器

```shell
$ docker exec -it kafka /bin/bash
$ cd /opt/bitnami/kafka/bin/
```

* 创建2个topic
```shell
$ ./kafka-topics.sh --create --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic voyager-log
$ ./kafka-topics.sh --create --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic payment-update-paystatus-topic

```

voyager-log ： 日志收集使用的
payment-update-paystatus-topic ： 支付成功通知所有订阅者

###### 3.2导入mysql数据

本地工具连接mysql的话要先进入容器，给root设置下远程连接权限

```shell
$ docker exec -it mysql mysql -u root -p
##输入密码：ll001226
$ use mysql;
$ update user set host='%' where user='root';
$ FLUSH PRIVILEGES;
```
创建数据库,并导入sql文件数据

#### 4、查看服务环境

Elastic search: http://127.0.0.1:9200/ （⚠️：这个启动时间有点长）

jaeger: http://127.0.0.1:16686/search  (⚠️：如果失败了，依赖es，因为es启动时间长这个有可能超时，等es启动玩restart一下)

go-stash :  如果发现kibana点击下一步，就是日志没有收集到，恰巧你的kafka又拿到了数据的话，请restart一下go-stash稍等一分钟即可  (⚠️：如果你是mac m1或者 linux arm，请更改一下docker-compose-env.yml中go-stash镜像 kevinwan/go-stash:1.0-arm64 ，默认是linux amd的)

asynq （延迟任务、定时任务、消息队列）: http://127.0.0.1:8980/

kibana  : http://127.0.0.1:5601/

Prometheus: http://127.0.0.1:9090/

Grafana: http://127.0.0.1:3001/  ， 默认账号、密码都是admin

[//]: # (Akhq: http://127.0.0.1:9050/  ， 默认账号、密码都是admin)

Mysql :  自行客户端工具(Navicat、Sequel Pro)查看

- host : 127.0.0.1

- port : 33069

- username : root

- pwd : ll001226

Redis :  自行工具（redisManager）查看

- host : 127.0.0.1

- port : 36379

- pwd : G62m50oigInC30sf

Kafka:  （发布、订阅｜pub、sub）自行客户端工具查看

- host : 127.0.0.1

- port : 9092

#### 5、启动服务

##### 5.1 拉取运行环境镜像

因为本项目是用docker+热加载，即改即生效

前台app下所有api+rpc服务统一使用modd + golang

【注】后续如果app下新增业务，要记得在项目根目录下的modd.conf复制添加一份就可以了

 关于modd更多用法可以去这里了解 ： https://github.com/cortesi/modd

##### 5.2 启动项目

```shell
$ docker-compose up -d 
```

【注】依赖的是项目根目录下的docker-compose.yml配置

#### 6、查看项目运行情况

访问 http://127.0.0.1:9090/ ， 点击上面菜单“Status”，在点击Targets ,蓝色的就是启动成了，红色就是没启动成功

访问API接口：
http://127.0.0.1:8888/usercenter/v1/user/registers

# 二 项目架构图
![img_1.png](images/img_1.png)

# 三、本项目镜像介绍
![img.png](images/img.png)
* nginx : 网关 （nginx->api->rpc）
* kafka ：业务使用的kafka
* zookeeper: kafka依赖的zookeeper
* redis：业务使用的redis
* mysql: 业务使用的数据库
* prometheus: 监控业务
* grafana: prometheus的ui很难看，用来显示prometheus收集来的数据
* elastic/filebeat： 收集日志到kafka
* go-stash : 消费kafka中日志，脱敏、过滤然后输出到es
* elasticsearch：存储收集的日志
* kibana：显示elasticsearch
* jaeger：链路追踪
