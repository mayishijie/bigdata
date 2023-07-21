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
