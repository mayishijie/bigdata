# 1.spark on hive

使用hive管理元数据，使用spark-sql计算数据

```shell
wget http://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz
```

## 2. 安装部署

## 2.1 解压安装包

```shell
```



## 2.2 复制hive-site.xml到spark conf

增加以下配置，开启动态分区

```xml
<!-- 开启动态分区 -->
<property>
    <name>hive.exec.dynamic.partition.mode</name>
    <value>nonstrict</value>
</property>
```

完整hive-site.xml

```xml-dtd
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- jdbc连接的URL -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop10:3306/hive3?useSSL=false</value>
</property>

    <!-- jdbc连接的Driver-->
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
</property>

	<!-- jdbc连接的username-->
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
    </property>

    <!-- jdbc连接的password -->
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>root</value>
</property>

    <!-- Hive默认在HDFS的工作目录 -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive3/warehouse</value>
    </property>
    
   <!-- Hive元数据存储的验证 -->
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>
   
    <!-- 元数据存储授权  -->
    <property>
        <name>hive.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
    <!-- 指定存储元数据要连接的地址 -->
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hadoop10:9083</value>
    </property>
    <!-- 指定hiveserver2连接的host -->
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>hadoop10</value>
    </property>

    <!-- 指定hiveserver2连接的端口号 -->
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>
    <!-- 开启动态分区 -->
    <property>
        <name>hive.exec.dynamic.partition.mode</name>
        <value>nonstrict</value>
    </property>
</configuration>
```



## 2.3 在$SPARK_HOME/jars增加依赖

```shell
# mysql依赖
[root@hadoop10 jars]# cp -v /opt/module/apache-hive-3.1.2-bin/lib/mysql-connector-java-5.1.48.jar ./
"/opt/module/apache-hive-3.1.2-bin/lib/mysql-connector-java-5.1.48.jar" -> "./mysql-connector-java-5.1.48.jar"

# lzo依赖
[root@hadoop10 jars]# cp -v /opt/module/hdfs-ha/hadoop-3.1.3/share/hadoop/common/hadoop-lzo-0.4.20.jar ./
"/opt/module/hdfs-ha/hadoop-3.1.3/share/hadoop/common/hadoop-lzo-0.4.20.jar" -> "./hadoop-lzo-0.4.20.jar"
```



## 2.4  配置环境变量

```shell
#SPARK_HOME
export SPARK_HOME=/opt/module/spark-3.0.0-bin-hadoop3.2
export PATH=$PATH:$SPARK_HOME/bin
```



## 2.5 配置spark-default.conf

```shell
[root@hadoop10 conf]$ vim spark-defaults.conf 
```

增加以下配置

```sh
#指定Spark master为yarn
spark.master=yarn
#是否记录Spark任务日志
spark.eventLog.enabled=true
#Spark任务日志的存储路径
spark.eventLog.dir=hdfs://hadoop10:8020/spark_historylog
#Spark历史服务器地址
spark.yarn.historyServer.address=hadoop10:18080
#Spark历史服务器读取历史任务日志的路径
spark.history.fs.logDirectory=hdfs://hadoop10:8020/spark_historylog
#开启Spark-sql自适应优化
spark.sql.adaptive.enabled=true
#开启Spark-sql中Reduce阶段分区数自适应
spark.sql.adaptive.coalescePartitions.enabled=true
#使用Hive提供的Parquet文件的序列化和反序列化工具，以兼容Hive
spark.sql.hive.convertMetastoreParquet=false
#使用老版的Parquet文件格式，以兼容Hive
spark.sql.parquet.writeLegacyFormat=true
#解决SPARK-21725问题
spark.hadoop.fs.hdfs.impl.disable.cache=true
#降低Spark-sql中类型检查级别，兼容Hive
spark.sql.storeAssignmentPolicy=LEGACY
```

## 2.6 配置spark-env.sh

```shell
vim spark-env.sh
#添加如下内容
 YARN_CONF_DIR=/opt/module/hdfs-ha/hadoop-3.1.3/etc/hadoop
```



## 2.7 启动历史服务器

```shell
# 新建spark历史服务器日志目录
hadoop dfs -mkdir /spark_historylog
# 启动历史服务
start-history-server.sh
```



2.8 