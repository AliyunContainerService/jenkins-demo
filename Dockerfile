FROM registry.cn-beijing.aliyuncs.com/acs-sample/tomcat
ADD target/demo.war /usr/local/tomcat/webapps/demo.war
