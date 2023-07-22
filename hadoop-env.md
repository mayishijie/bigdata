# 前言

http://archive.apache.org/dist/

所有apache下相关安装包

# 1. hadoop部署-单NameNode

集群部署规划，因nodemanager和resourcemanager很消耗资源，我们只有3台虚拟机，因此分开部署

|      | hadoop10            | hadoop11                    | hadoop12                    |
| ---- | ------------------- | --------------------------- | --------------------------- |
| hdfs | NameNode,  DataNode | dataNode                    | SecondaryNameNode, DataNode |
| yarn | NodeManager         | ResourceManager,NodeManager | NodeManager                 |

本次安装版本：hadoop-3.1.3

wget http://archive.apache.org/dist/hadoop/core/hadoop-3.1.3/hadoop-3.1.3.tar.gz

## 1.1 解压安装包到指定目录 

目前统一安装在/opt/module

```shell
tar -zxvf hadoop-3.1.3.tar.gz -C /opt/module/
```

## 1.2 配置hadoop环境变量

### 1.2.1 获取hadoop安装目录

```shell
[mayi@hadoop10 hadoop-3.1.3]$ pwd
/opt/module/hadoop-3.1.3
```

### 1.2.2 打开/etc/profile.d/my_env.sh文件

```shell
[mayi@hadoop10 hadoop-3.1.3]$ sudo vim /etc/profile.d/my_env.sh
```

在profile文件末尾添加jdk路径

```shell
# HADOOP_HOME
export HADOOP_HOME=/opt/module/hadoop-3.1.3
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
```

### 1.2.3 分发环境变量

```shell
xsync /etc/profile.d/my_env.sh

# 分发完成后，执行如下命令，使其生效
```

## 1.3 配置集群

### 1.3.1 core-site.xml

mayi是我系统当时的用户，这个可以根据自己用户替换

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<!-- 指定NameNode的地址 -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop10:8020</value>
</property>
<!-- 指定hadoop数据的存储目录 -->
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/module/hadoop-3.1.3/data</value>
</property>

<!-- 配置HDFS网页登录使用的静态用户为mayi -->
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>mayi</value>
</property>

<!-- 配置该mayi(superUser)允许通过代理访问的主机节点 -->
    <property>
        <name>hadoop.proxyuser.mayi.hosts</name>
        <value>*</value>
</property>
<!-- 配置该mayi(superUser)允许通过代理用户所属组 -->
    <property>
        <name>hadoop.proxyuser.mayi.groups</name>
        <value>*</value>
</property>
<!-- 配置该mayi(superUser)允许通过代理的用户-->
    <property>
        <name>hadoop.proxyuser.mayi.users</name>
        <value>*</value>
</property>
</configuration>
```

### 1.3.2 hdfs-site.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<!-- nn web端访问地址-->
	<property>
        <name>dfs.namenode.http-address</name>
        <value>hadoop10:9870</value>
    </property>
    
	<!-- 2nn web端访问地址-->
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>hadoop12:9868</value>
    </property>
    
    <!-- 测试环境指定HDFS副本的数量1 -->
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```

### 1.3.3 yarn-site.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<!-- 指定MR走shuffle -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    
    <!-- 指定ResourceManager的地址-->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoop11</value>
    </property>
    
    <!-- 环境变量的继承 -->
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
    
    <!-- yarn容器允许分配的最大最小内存 -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>512</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>4096</value>
    </property>
    
    <!-- yarn容器允许管理的物理内存大小 -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>4096</value>
    </property>
    
    <!-- 关闭yarn对物理内存和虚拟内存的限制检查 -->
    <property>
        <name>yarn.nodemanager.pmem-check-enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>
    <!-- 开启日志聚集功能 -->
    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>

    <!-- 设置日志聚集服务器地址 -->
    <property>  
        <name>yarn.log.server.url</name>  
        <value>http://hadoop10:19888/jobhistory/logs</value>
    </property>

    <!-- 设置日志保留时间为0.5天,12小时 -->
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>43200</value>
    </property>
</configuration>
```

1. 日志聚集：应用运行完成以后，将程序运行日志信息上传到HDFS系统上
2. 注意：开启日志聚集功能，需要重新启动NodeManager 、ResourceManager和HistoryManager。

### 1.3.4 MapReduce配置文件 mapred-site.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
	<!-- 指定MapReduce程序运行在Yarn上 -->
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
  <!-- 历史服务器端地址 -->
  <property>
      <name>mapreduce.jobhistory.address</name>
      <value>hadoop10:10020</value>
  </property>

  <!-- 历史服务器web端地址 -->
  <property>
      <name>mapreduce.jobhistory.webapp.address</name>
      <value>hadoop10:19888</value>
  </property>
</configuration>
```

### 1.3.5 配置work

```shell
vim /opt/module/hadoop-3.1.3/etc/hadoop/workers

# 增加如下内容：注意：该文件中添加的内容结尾不允许有空格，文件中不允许有空行
hadoop10
hadoop11
hadoop12
```

## 1.4启动集群

### 1.4.1 首次启动集群

***\*如果集群是第一次启动\****，需要在hadoop10节点格式化NameNode（注意格式化之前，一定要先停止上次启动的所有namenode和datanode进程，然后再删除data和log数据）

```shell 
[mayi@hadoop10 hadoop-3.1.3]$ bin/hdfs namenode -format
```

### 1.4.2 启动hdfs

```shell
[mayi@hadoop10 hadoop-3.1.3]$ sbin/start-dfs.sh
```



### 1.4.3 在配置了ResourceManager的节(hadoop11)启动YARN

````shell
[mayi@hdoop11 hadoop-3.1.3]$ sbin/start-yarn.sh
````

### 1.4.4 Web端查看HDFS的Web页面：http://hadoop10:9870/

### 1.4.5Web端查看SecondaryNameNode http://hadoop12:9868/status.html

## 1.5 hadoop 群起脚本

```shell
#!/bin/bash
if [ $# -lt 1 ]
then
    echo "No Args Input..."
    exit ;
fi
case $1 in
"start")
        echo " =================== 启动 hadoop集群 ==================="

        echo " --------------- 启动 hdfs ---------------"
        ssh hdoop10 "/opt/module/hadoop-3.1.3/sbin/start-dfs.sh"
        echo " --------------- 启动 yarn ---------------"
        ssh hdoop11 "/opt/module/hadoop-3.1.3/sbin/start-yarn.sh"
        echo " --------------- 启动 historyserver ---------------"
        ssh hdoop10 "/opt/module/hadoop-3.1.3/bin/mapred --daemon start historyserver"
;;
"stop")
        echo " =================== 关闭 hadoop集群 ==================="

        echo " --------------- 关闭 historyserver ---------------"
        ssh hdoop10 "/opt/module/hadoop-3.1.3/bin/mapred --daemon stop historyserver"
        echo " --------------- 关闭 yarn ---------------"
        ssh hdoop11 "/opt/module/hadoop-3.1.3/sbin/stop-yarn.sh"
        echo " --------------- 关闭 hdfs ---------------"
        ssh hdoop10 "/opt/module/hadoop-3.1.3/sbin/stop-dfs.sh"
;;
*)
    echo "Input Args Error..."
;;
esac
```

# 2. hadoop 重置为单节点NN

## 2.1 删除hadoop 下data中的数据

## 2.2 删除所有logs 下log日志

## 2.3 替换1.3下4个配置文件

## 2.4 格式化NameNode

## 2.5 启动服务

# 3. 升级单NameNode->HA

## 3.1 集群规划

| NameNode    | NameNode        | NameNode    |
| ----------- | --------------- | ----------- |
| ZKFC        | ZKFC            | ZKFC        |
| JournalNode | JournalNode     | JournalNode |
| DataNode    | DataNode        | DataNode    |
| ZK          | ZK              | ZK          |
|             | ResourceManager |             |
| NodeManager | NodeManager     | NodeManager |

## 3.2 配置zookeeper集群

### 3.2.1 集群规划

在hadoop10、hadoop11和hadoop12三个节点上部署Zookeeper。

### 3.2.2 解压安装

1. 解压到安装目录

```shell
tar -zxvf zookeeper-3.5.7.tar.gz -C /opt/module/
```

2. 在/opt/module/zookeeper-3.5.7/这个目录下创建zkData

3. 重命名/opt/module/zookeeper-3.4.14/conf这个目录下的zoo_sample.cfg为zoo.cfg

4. 配置zoo.cfg

   ```shell
   # 修改点1：数据目录配置成自己的目录
   dataDir=/opt/module/apache-zookeeper-3.5.7-bin/zkData
   
   # 修改点2 尾号追加自己的服务配置项：Server.A=B:C:D
   # 参数解读：
   # A是一个数字，表示这个是第几号服务器；
   # B是这个服务器的IP地址；
   # C是这个服务器与集群中的Leader服务器交换信息的端口；
   # D是万一集群中的Leader服务器挂了，需要一个端口来重新进行选举，选出一个新的Leader，而这个端口就是用来执行选举时服务器相互通信的端口。集群模式下配置一个文件myid，这个文件在dataDir目录下，这个文件里面有一个数据就是A的值，Zookeeper启动时读取此文件，拿到里面的数据与zoo.cfg里面的配置信息比较从而判断到底是哪个server。
   server.1=hadoop10:2888:3888
   server.2=hadoop11:2888:3888
   server.3=hadoop12:2888:3888
   
   # 修改点3
   quorumListenOnAllIPs=true
   ```

5. zkData下新建myid文件，并设置对应server编号，如1,每台机器要专门指定一个

6. 启动zk

   ```shell
   [mayi@hadoop10 zookeeper-3.5.7]$ bin/zkServer.sh start
   
   # 查看状态
   [mayi@hadoop10 zookeeper-3.5.7]$ bin/zkServer.sh status
   ```

## 3.3 配置HDFS-HA集群(我本次用的是root用户)

### 3.3.1  在opt目录下创建hdfs-ha目录

```shell
# 创建hdfs-ha,并将hadoop-3.1.3 移动到hdfs-ha目录下（移动后记得删除data,和log文件）
[root@hadoop10 module]# mkdir hdfs-ha
[root@hadoop10 module]# cp -r hadoop-3.1.3/ ./hdfs-ha/
```

### 3.3.2 配置 hadoop-env.sh 环境变量

```shell
[root@hadoop10 hadoop-3.1.3]# vim etc/hadoop/hadoop-env.sh 

# 填入如下内容
export JAVA_HOME=/opt/module/jdk1.8.0_212
```



### 3.3.3 配置core-site.xml

```xml-dtd
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<!-- 把多个NameNode的地址组装成一个集群mycluster -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://mycluster</value>
  </property>
<!-- 指定hadoop运行时产生文件的存储目录 -->
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/module/hdfs-ha/hadoop-3.1.3/data</value>
  </property>
</configuration>
```



### 3.3.4 配置 hdfs-site.xml

```xml-dtd
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<!-- NameNode数据存储目录 -->
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://${hadoop.tmp.dir}/name</value>
  </property>
<!-- DataNode数据存储目录 -->
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://${hadoop.tmp.dir}/data</value>
  </property>
<!-- JournalNode数据存储目录 -->
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>${hadoop.tmp.dir}/jn</value>
  </property>
<!-- 完全分布式集群名称 -->
  <property>
    <name>dfs.nameservices</name>
    <value>mycluster</value>
  </property>
<!-- 集群中NameNode节点都有哪些 -->
  <property>
    <name>dfs.ha.namenodes.mycluster</name>
    <value>nn1,nn2,nn3</value>
  </property>
<!-- NameNode的RPC通信地址 -->
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn1</name>
    <value>hadoop10:8020</value>
  </property>
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn2</name>
    <value>hadoop11:8020</value>
  </property>
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn3</name>
    <value>hadoop12:8020</value>
  </property>
<!-- NameNode的http通信地址 -->
  <property>
    <name>dfs.namenode.http-address.mycluster.nn1</name>
    <value>hadoop10:9870</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.mycluster.nn2</name>
    <value>hadoop11:9870</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.mycluster.nn3</name>
    <value>hadoop12:9870</value>
  </property>
<!-- 指定NameNode元数据在JournalNode上的存放位置 -->
  <property>
<name>dfs.namenode.shared.edits.dir</name>
<value>qjournal://hadoop10:8485;hadoop11:8485;hadoop12:8485/mycluster</value>
  </property>
<!-- 访问代理类：client用于确定哪个NameNode为Active -->
  <property>
    <name>dfs.client.failover.proxy.provider.mycluster</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>
<!-- 配置隔离机制，即同一时刻只能有一台服务器对外响应 -->
  <property>
    <name>dfs.ha.fencing.methods</name>
    <value>sshfence</value>
  </property>
<!-- 使用隔离机制时需要ssh秘钥登录-->
  <property>
    <name>dfs.ha.fencing.ssh.private-key-files</name>
    <value>/home/root/.ssh/id_rsa</value>
  </property>
</configuration>
```

### 3.3.5启动HDFS-HA集群

#### 3.3.5.1 将HADOOP_HOME环境变量更改到HA目录(记得同步到其它机器上)

```shell
[root@hadoop10 data]# vim /etc/profile.d/my_env.sh 
#HADOOP_HOME
# 单NameNode
#export HADOOP_HOME=/opt/module/hadoop-3.1.3
# NameNode-HA
export HADOOP_HOME=/opt/module/hdfs-ha/hadoop-3.1.3
export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

#### 3.3.5.2 在各个JournalNode节点上，输入以下命令启动journalnode服务

```shell
[root@hadoop10 ~]$ hdfs --daemon start journalnode
[root@hadoop11 ~]$ hdfs --daemon start journalnode
[root@hadoop12 ~]$ hdfs --daemon start journalnode
```



#### 3.3.5.3 在[nn1]上，对其进行格式化，并启动

```shell
[root@hadoop10 ~]$ hdfs namenode -format
[root@hadoop10 ~]$ hdfs --daemon start namenode
```



#### 3.3.5.4 在[nn2]和[nn3]上，同步nn1的元数据信息

```shell
[root@hadoop11 ~]$ hdfs namenode -bootstrapStandby
[root@hadoop12~]$ hdfs namenode -bootstrapStandby
```



#### 3.3.5.5 启动nn2,nn3

```sh
[root@hadoop11 ~]$ hdfs --daemon start namenode
[root@hadoop12 ~]$ hdfs --daemon start namenode
```

#### 3.3.5.2 在所有节点上，启动datanode

```shell
[root@hadoop10 ~]$ hdfs --daemon start datanode
[root@hadoop11 ~]$ hdfs --daemon start datanode
[root@hadoop12 ~]$ hdfs --daemon start datanode
```



#### 3.3.5.2 将nn1切换为Active

```shell
[root@hadoop10 ~]$ hdfs haadmin -transitionToActive nn1
```

#### 3.3.5.2 查看是否Active

```shell
[root@hadoop10 ~]$ hdfs haadmin -getServiceState nn1
```

### 3.3.6 配置HA故障自动转移(借助zk)

#### 3.3.6.1 hdfs-site.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<!-- NameNode数据存储目录 -->
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://${hadoop.tmp.dir}/name</value>
  </property>
<!-- DataNode数据存储目录 -->
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://${hadoop.tmp.dir}/data</value>
  </property>
<!-- JournalNode数据存储目录 -->
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>${hadoop.tmp.dir}/jn</value>
  </property>
<!-- 完全分布式集群名称 -->
  <property>
    <name>dfs.nameservices</name>
    <value>mycluster</value>
  </property>
<!-- 集群中NameNode节点都有哪些 -->
  <property>
    <name>dfs.ha.namenodes.mycluster</name>
    <value>nn1,nn2,nn3</value>
  </property>
<!-- NameNode的RPC通信地址 -->
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn1</name>
    <value>hadoop10:8020</value>
  </property>
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn2</name>
    <value>hadoop11:8020</value>
  </property>
  <property>
    <name>dfs.namenode.rpc-address.mycluster.nn3</name>
    <value>hadoop12:8020</value>
  </property>
<!-- NameNode的http通信地址 -->
  <property>
    <name>dfs.namenode.http-address.mycluster.nn1</name>
    <value>hadoop10:9870</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.mycluster.nn2</name>
    <value>hadoop11:9870</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.mycluster.nn3</name>
    <value>hadoop12:9870</value>
  </property>
<!-- 指定NameNode元数据在JournalNode上的存放位置 -->
  <property>
<name>dfs.namenode.shared.edits.dir</name>
<value>qjournal://hadoop10:8485;hadoop11:8485;hadoop12:8485/mycluster</value>
  </property>
<!-- 访问代理类：client用于确定哪个NameNode为Active -->
  <property>
    <name>dfs.client.failover.proxy.provider.mycluster</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>
<!-- 配置隔离机制，即同一时刻只能有一台服务器对外响应 -->
  <property>
    <name>dfs.ha.fencing.methods</name>
    <value>sshfence</value>
  </property>
<!-- 使用隔离机制时需要ssh秘钥登录-->
  <property>
    <name>dfs.ha.fencing.ssh.private-key-files</name>
    <value>/home/root/.ssh/id_rsa</value>
  </property>
  <!-- 启用nn故障自动转移 -->
  <property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
  </property>
</configuration>
```

#### 3.3.6.2 core-site.xml

````xml-dtd
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<!-- 把多个NameNode的地址组装成一个集群mycluster -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://mycluster</value>
  </property>
	<!-- 指定hadoop运行时产生文件的存储目录 -->
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/module/hdfs-ha/hadoop-3.1.3/data</value>
  </property>
  <!-- 指定zkfc要连接的zkServer地址 -->
  <property>
    <name>ha.zookeeper.quorum</name>
    <value>hadoop10:2181,hadoop11:2181,hadoop12:2181</value>
  </property>
</configuration>

````

#### 3.3.6.3 修改后，文件分发

### 3.3.7 启动

#### 3.3.7.1关闭所有hdfs服务

```shell
[root@hadoop10 ~]$ stop-dfs.sh
```



#### 3.3.7.2 启动zk集群

```shell
[root@hadoop10 ~]$ zkServer.sh start
[root@hadoop11 ~]$ zkServer.sh start
[root@hadoop12 ~]$ zkServer.sh start
```



#### 3.3.7.3 启动zk后，初始化HA在zk中的状态

```shell
[root@hadoop10 ~]$ hdfs zkfc -formatZK
```



#### 3.3.7.4 启动hdfs 服务

```shell
[root@hadoop10 ~]$ start-dfs.sh
```



#### 3.3.7.5 以去zkCli.sh客户端查看Namenode选举锁节点内容

#### 3.3.7.6 验证

将Active NameNode进程kill，查看网页端三台Namenode的状态变化

```shell
[root@hadoop10 ~]$ kill -9 namenode的进程id
```

#### 3.3.7.7 异常处理

因为配置了3台NameNode,3台 HA,但是发现重启后，有2台是standly,还有一台报如下异常，我后面将hadoop10下目录mycluster文件全部拷贝一份到另外没有这个文件的机器中，重启即可，应该是之前没有等主节点同步，就关闭hdfs服务有关（目前是这个怀疑）

```txt
172.16.24.11:8485: Journal Storage Directory root= /opt/module/hdfs-ha/hadoop-3.1.3/data/jn/mycluster; location= null not formatted ; journal id: mycluster
        at org.apache.hadoop.hdfs.qjournal.server.Journal.checkFormatted(Journal.java:532)
        at org.apache.hadoop.hdfs.qjournal.server.Journal.getEditLogManifest(Journal.java:722)
        at org.apache.hadoop.hdfs.qjournal.server.JournalNodeRpcServer.getEditLogManifest(JournalNodeRpcServer.java:228)
        at org.apache.hadoop.hdfs.qjournal.protocolPB.QJournalProtocolServerSideTranslatorPB.getEditLogManifest(QJournalProtocolServerSideTranslatorPB.java:230)
        at org.apache.hadoop.hdfs.qjournal.protocol.QJournalProtocolProtos$QJournalProtocolService$2.callBlockingMethod(QJournalProtocolProtos.java:28894)
        at org.apache.hadoop.ipc.ProtobufRpcEngine$Server$ProtoBufRpcInvoker.call(ProtobufRpcEngine.java:527)
        at org.apache.hadoop.ipc.RPC$Server.call(RPC.java:1036)
        at org.apache.hadoop.ipc.Server$RpcCall.run(Server.java:1000)
        at org.apache.hadoop.ipc.Server$RpcCall.run(Server.java:928)
        at java.security.AccessController.doPrivileged(Native Method)
        at javax.security.auth.Subject.doAs(Subject.java:422)
        at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1729)
        at org.apache.hadoop.ipc.Server$Handler.run(Server.java:2916)
```



## 3.4 配置yarn-HA

| hadoop10        | hadoop11        | hadoop12    |
| --------------- | --------------- | ----------- |
| NameNode        | NameNode        | NameNode    |
| JournalNode     | JournalNode     | JournalNode |
| DataNode        | DataNode        | DataNode    |
| ZK              | ZK              | ZK          |
| ResourceManager | ResourceManager |             |
| NodeManager     | NodeManager     | NodeManager |



### 3.4.1 yarn-site.xml

```xml-dtd
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <!-- 启用resourcemanager ha -->
    <property>
        <name>yarn.resourcemanager.ha.enabled</name>
        <value>true</value>
    </property>
 
    <!-- 声明两台resourcemanager的地址 -->
    <property>
        <name>yarn.resourcemanager.cluster-id</name>
        <value>cluster-yarn1</value>
    </property>
    <!--指定resourcemanager的逻辑列表-->
    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>rm1,rm2</value>
		</property>
    <!-- ========== rm1的配置 ========== -->
    <!-- 指定rm1的主机名 -->
    <property>
        <name>yarn.resourcemanager.hostname.rm1</name>
        <value>hadoop10</value>
      </property>
      <!-- 指定rm1的web端地址 -->
      <property>
           <name>yarn.resourcemanager.webapp.address.rm1</name>
           <value>hadoop10:8088</value>
      </property>
      <!-- 指定rm1的内部通信地址 -->
      <property>
           <name>yarn.resourcemanager.address.rm1</name>
           <value>hadoop10:8032</value>
      </property>
      <!-- 指定AM向rm1申请资源的地址 -->
      <property>
           <name>yarn.resourcemanager.scheduler.address.rm1</name>  
           <value>hadoop10:8030</value>
      </property>
      <!-- 指定供NM连接的地址 -->  
      <property>
           <name>yarn.resourcemanager.resource-tracker.address.rm1</name>
           <value>hadoop10:8031</value>
      </property>
      <!-- ========== rm2的配置 ========== -->
    <!-- 指定rm2的主机名 -->
    <property>
        <name>yarn.resourcemanager.hostname.rm2</name>
        <value>hadoop11</value>
    </property>
    <property>
         <name>yarn.resourcemanager.webapp.address.rm2</name>
         <value>hadoop11:8088</value>
    </property>
    <property>
         <name>yarn.resourcemanager.address.rm2</name>
         <value>hadoop11:8032</value>
    </property>
    <property>
         <name>yarn.resourcemanager.scheduler.address.rm2</name>
         <value>hadoop11:8030</value>
    </property>
    <property>
         <name>yarn.resourcemanager.resource-tracker.address.rm2</name>
         <value>hadoop11:8031</value>
    </property>
 
    <!-- 指定zookeeper集群的地址 --> 
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>hadoop10:2181,hadoop11:2181,hadoop12:2181</value>
    </property>

    <!-- 启用自动恢复 --> 
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>
 
    <!-- 指定resourcemanager的状态信息存储在zookeeper集群 --> 
    <property>
       <name>yarn.resourcemanager.store.class</name> 
       <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
  </property>
  <!-- 环境变量的继承 -->
   <property>
        <name>yarn.nodemanager.env-whitelist</name>  <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
```

### 3.4.2 同步yarn-site.xml 到其它节点

```shell
[root@hadoop10 etc]$ xsync hadoop/
```



### 3.4.3 启动hdfs

```shell
[root@hadoop10 ~]$ start-dfs.sh
```

### 3.4.3 启动yarn

#### 3.4.3.1 在hadoop10或者hadoop11中执行：

```shell
[root@hadoop10 ~]$ start-yarn.sh
```

#### 3.4.3.2 查看服务状态

```shell
[root@hadoop10 ~]$ yarn rmadmin -getServiceState rm1
```

#### 3.4.3.3 web端查看hadoop10:8088和hadoop11:8088的YARN的状态，和NameNode对比，查看区别
