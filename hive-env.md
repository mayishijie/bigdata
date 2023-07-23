# 1. mysql 安装部署

# 2. Hive 安装部署

本次安装的是hive-3.1.2 版本

## 2.1 下载安装

```shell
# 1.下载
wget http://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz

# 2. 解压
[root@hadoop10 software]$ tar -zxvf /opt/software/apache-hive-3.1.2-bin.tar.gz -C /opt/module/

# 3. 配置环境变量：修改/etc/profile.d/my_env.sh，添加环境变量
#HIVE_HOME
export HIVE_HOME=/opt/module/apache-hive-3.1.2-bin
export PATH=$PATH:$HIVE_HOME/bin

# 4.解决jar包日志冲突
[root@hadoop10 software]$ mv $HIVE_HOME/lib/log4j-slf4j-impl-2.10.0.jar $HIVE_HOME/lib/log4j-slf4j-impl-2.10.0.bak
```

## 2.2 元数据配置

### 2.2.1 拷贝驱动

```shell
# 将MySQL的JDBC驱动拷贝到Hive的lib目录下
[root@hadoop10 software]$ cp /opt/software/mysql-connector-java-5.1.48.jar $HIVE_HOME/lib
```

### 2.2.2 配置元数据metastore到MySQL

在$HIVE_HOME/conf目录下新建hive-site.xml文件

```shell
[root@hadoop10 software]$ vim $HIVE_HOME/conf/hive-site.xml
```

hive-site.xml内容：

````xml-dtd
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- jdbc连接的URL -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop10:3306/metastore?useSSL=false</value>
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
        <value>/user/hive/warehouse</value>
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
</configuration>
````

## 2.3 启动hive

### 2.3.1 前提-启动Hadoop集群

### 2.3.2 启动hive

```shell
# 1）启动Hive
[root@hadoop10 hive]$ bin/hive
# 2）使用Hive
hive> show databases;
hive> show tables;
hive> create table test (id int);
hive> insert into test values(1);
hive> select * from test;
# 3）开启另一个窗口测试开启hive
[root@hadoop10 hive]$ bin/hive
```

## 2.4 使用hive元数据的方式访问hive

### 2.4.1 在hive-site.xml文件中添加如下配置信息

```xml
    <!-- 指定存储元数据要连接的地址 -->
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hadoop10:9083</value>
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
        <value>jdbc:mysql://hadoop10:3306/metastore?useSSL=false</value>
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
        <value>123456</value>
</property>

    <!-- Hive默认在HDFS的工作目录 -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
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
</configuration>
```

### 2.4.2 启动metastroe

```shell
[root@hadoop202 hive]$ hive --service metastore
2020-04-24 16:58:08: Starting Hive Metastore Server
# 注意: 启动后窗口不能再操作，需打开一个新的shell窗口做别的操作
```

### 2.4.4 启动hive

```shell
[root@hadoop202 hive]$ bin/hive
```

## 2.5 使用jdbc方式访问hive

### 2.5.1 在hive-site.xml中添加如下配置

```xml
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
```

完整hive-site.xml

```xml-dtd
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- jdbc连接的URL -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop10:3306/metastore?useSSL=false</value>
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
        <value>123456</value>
</property>

    <!-- Hive默认在HDFS的工作目录 -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
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
</configuration>
```

### 2.5.2 启动hive-server2

```shell
[root@hadoop10 hive]$ bin/hive --service hiveserver2
```

### 2.5.3 启动beline客户端

```shell
[root@hadoop10 hive]$ bin/beeline -u jdbc:hive2://hadoop10:10000 -n root
```

### 2.5.4 看到如下界面

```tex
Connecting to jdbc:hive2://hadoop10:10000
Connected to: Apache Hive (version 3.1.2)
Driver: Hive JDBC (version 3.1.2)
Transaction isolation: TRANSACTION_REPEATABLE_READ
Beeline version 3.1.2 by Apache Hive
0: jdbc:hive2://hadoop10:10000>
```

# 3. 异常

1. 异常

   ```tex
   Error: Could not open client transport with JDBC Uri: jdbc:hive2://hadoop10:10000: Failed to open new session: java.lang.RuntimeException: org.apache.hadoop.ipc.RemoteException(org.apache.hadoop.security.authorize.AuthorizationException): User: root is not allowed to impersonate root (state=08S01,code=0)
   ```

   core-site.xml

   ```xml
       <property>
           <name>hadoop.proxyuser.root.hosts</name>
           <value>*</value>
       </property>
       <property>
           <name>hadoop.proxyuser.root.groups</name>
           <value>*</value>
       </property>
   ```

   完整core-site.xml

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
     <!-- 指定zkfc要连接的zkServer地址 -->
     <property>
       <name>ha.zookeeper.quorum</name>
       <value>hadoop10:2181,hadoop11:2181,hadoop12:2181</value>
     </property>
     <!-- 访问限制 -->
     <property>
         <name>hadoop.proxyuser.root.hosts</name>
         <value>*</value>
     </property>
     <property>
         <name>hadoop.proxyuser.root.groups</name>
         <value>*</value>
     </property>
   </configuration>
   ```

   

2. 

